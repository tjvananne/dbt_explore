# Slowly Changing Dimensions (type 0, 1, 2) with dbt snapshots

Quick recap of the first three SCD Types:

* **Type 0**: forget history. never update values or add records when values change. simply ignore the changes. probably not a winning strategy, but it happens.
* **Type 1**: update the value in place. probably the most common in the world of CRUD web apps and spreadsheet-based processes.
* **Type 2**: use `start_date` and `end_date` fields to create a date range where the record's values are valid. this is the first SCD type where history is actually captured at all.
    * **Example**: imagine you're doing data modeling for a sales team. when someone sells something, they get commission for several years (long sales cycles, idk, whatever). The business logic rules dictate that the manager of the sales rep who made the sale also gets a small % of this commission. If a sales person switches to another manager, this new manager doesn't immediately start earning the commissions of the sales person's previous sales. This means we need to build up a history of which manager each sales person reported to (and when) so that these sales commissions can be properly accounted for.


Let's say this is our employee table:


| employee_id | employee    | title      | manager         |
|-------------|-------------|------------|-----------------|
| 1           | Annie Smith | sr. sales rep | Jessica Walters |
| 2           | John Mendel | jr. sales rep   | Bart Simpson    |


For the purposes of this example, we have written up a technical spec that says we want to capture the history of each fields' value in the following manner:

* `employee_id`: this is our **key**. It's unique in the source table, but will be repeated in our final table that contains our history.
* `employee`: **Type 1** (if their name changes, we'll simply overwrite their old name with their new name)
* `title`: **Type 0** (we don't care about title changes for now. they will simply be ignored. we'll circle back around and add this in as Type 2 after, but for now, it'll be Type 0)
* `manager`: **Type 2** (this is the most critical field for our hypothetical example. history is critical to capture here, so when this value changes, we'll add a new record with a new `start_date`, then invalidate the old record and update that old record's `end_date`)


Let's get this staging table started. Keep in mind that `dbt` is ELT and not ETL, so we're assuming that our starting point is a table that has already been staged. The `public.employee` table will be that staging table for us.

```sql
/*
This is executed outside the context of dbt. In a real-world 
environment, this staging table would be populated by some
type of ETL, CDC, or replication process.
*/

-- DDL to create the table
create table if not exists public.employee (
	 employee_id		int primary key
	,employee			varchar(80) not null
	,title				varchar(60) not null
	,manager			varchar(80) not null
);

-- make sure it's empty (so we can easily re-run this script)
truncate public.employee;

-- insert our two rows of data
insert into public.employee values 
	 (1, 'Annie Smith', 'sr. sales rep', 'Jessica Walters')
	,(2, 'John Mendel', 'jr. sales rep', 'Bart Simpson');

-- inspect the data
select * from public.employee;
```

I've also created a `snapshots/schema.yml` file so we can use this table as a source table in our snapshot models:

```yml
# snapshots/schema.yml
version: 2
sources:
  - name: public
    schema: public
    tables:
      - name: employee
```

And now we can make our snapshot sql model:

```sql
-- snapshots/01_SCD_snapshots.sql

-- "employee_snapshot" will be the name of the output table
{% snapshot employee_snapshot %}

    {{
        config(
          target_schema='public',
          strategy='check',
          unique_key='employee_id',
          check_cols=['manager'],
        )
    }}

    select * from {{ source('public', 'employee') }}

{% endsnapshot %}
```

Now let's run our snapshot:

```
dbt snapshot
```

That should have got our snapshot table up and ready to go. Let's see what our output table looks like now that dbt has added a few fields:

|employee_id|employee|title|manager|dbt_scd_id|dbt_updated_at|dbt_valid_from|dbt_valid_to|
|-----------|--------|-----|-------|----------|--------------|--------------|------------|
|1|Annie Smith|sr. sales rep|Jessica Walters|f3a7ac58d9322823486bf86cecd32874|2022-04-07 05:04:03.077|2022-04-07 05:04:03.077||
|2|John Mendel|jr. sales rep|Bart Simpson|3901a5582ca7a4441fa031be6a1c7e6c|2022-04-07 05:04:03.077|2022-04-07 05:04:03.077||


Alright, so we have our same four fields followed by:

* `dbt_scd_id`: a hash of the fields we're asking dbt to check on for updates (only `manager` field for now)
* `dbt_updated_at`: the timestamp of when this record was last updated.
* `dbt_valid_from`: the timestamp of when this record is valid *from*.
* `dbt_valid_to`: the timestamp of when this record is valid *to*. if this is empty, then this is the most up-to-date record

*I'm going to wait a few days and come back to this experiment so I have a realistic time window to work with for these table updates. I'm sure there has to be some way to "fake" the timestamp data, but I'll revisit that later.*

