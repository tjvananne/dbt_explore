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