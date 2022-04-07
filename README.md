# dbt_explore

## setup

### dbt install and directory setup

Python version is 3.9.5.

```bash
# gitbash on windows

# create a virtual env
python -m venv venv

# activate it (windows)
source ./venv/Scripts/activate

# installs
pip install dbt

# fix one of the dependencies
# https://github.com/dbt-labs/dbt-core/issues/4745
pip3 install --force-reinstall MarkupSafe==2.0.1

# above version of MarkupSafe fixes this error message:
# ImportError: cannot import name 'soft_unicode' from 'markupsafe'

# create the tutorial project (temporarily)
dbt init jaffle_shop

# move all the files into this root project directory.
# remove the README.md first so we don't overwrite our own readme file...
rm jaffle_shop/README.md
mv jaffle_shop/* ./

# now we can remove jaffle_shop dir and just use our root project dir
rm -r jaffle_shop 
```

### dbt config and database VM setup

* using a VirtualBox VM as my postgres server
* Ubuntu 20.04.3
* postgres 14.1
* dbt 0.21.1 

Now let's make a few configuration changes per the dbt tutorial.

```yml
# dbt_project.yml

name: 'dbt_explore'   # (was 'my_new_project')
...  

profile: 'dbt_explore'    # (was 'default')
...

models:
  dbt_explore: # should match the value for "name:"
```

And I'll just go ahead and put the file that belongs in `~/.dbt/profile.yml` here as well

```yml
# ~/.dbt/profile.yml

# this particular instance of profile.yml is not sensitive because
# it only contains credentials for my VirtualBox VM on my local machine

dbt_explore: # this needs to match the profile: in your dbt_project.yml file
  target: dev
  outputs:
    dev:
      type: postgres
      host: localhost
      user: taylor
      password: taylor
      port: 5432
      dbname: taylor
      schema: public
      threads: 1
      keepalives_idle: 0 # default 0, indicating the system default
      connect_timeout: 10 # default 10 seconds
      #search_path: [optional, override the default postgres search_path]
      #role: [optional, set the role dbt assumes when executing queries]
      #sslmode: [optional, set the sslmode used to connect to the database]
```

And with that, we can now run the sample dbt models that are supplied by default with a new dbt project:

```bash
dbt run
```

Which should output:

```
Running with dbt=0.21.1
Found 2 models, 4 tests, 0 snapshots, 0 analyses, 162 macros, 0 operations, 0 seed files, 0 sources, 0 exposures

21:35:16 | Concurrency: 1 threads (target='dev')
21:35:16 |
21:35:16 | 1 of 2 START table model public.my_first_dbt_model................... [RUN]
21:35:19 | 1 of 2 OK created table model public.my_first_dbt_model.............. [←[32mSELECT 2←[0m in 2.18s]
21:35:19 | 2 of 2 START view model public.my_second_dbt_model................... [RUN]
21:35:21 | 2 of 2 OK created view model public.my_second_dbt_model.............. [←[32mCREATE VIEW←[0m in 2.11s]
21:35:23 | 
21:35:23 | Finished running 1 table model, 1 view model in 12.90s.

←[32mCompleted successfully←[0m

Done. PASS=2 WARN=0 ERROR=0 SKIP=0 TOTAL=2
```





## experiment 1 - SCD type 0, 1, 2 with snapshots

