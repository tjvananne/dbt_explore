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
pip3 install --force-reinstall MarkupSafe==2.0.1

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



## experiment 1 - SCD type 0, 1, 2 with snapshots

