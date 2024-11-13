The github data are base on the project [Waku](https://github.com/waku-org/).

The database configuration :
* host: `recruitment.free.technology`
* port: `5432`
* user: will be provided
* password: will be provided
* database name: `recruitment_task`
* schemas: `raw_github`,`raw_finance`


## Requirements

* Have docker installed
* Export invoice table from recruitment_task.raw_finance, issues and repository from recruitment_task.raw_github to your local postgres

## Usage

* Deploy the container with `make run`
* Shutdown the containers with `make down`
* Build the dbt models with `make dbt-buidlt`
* Compile the dbt models with `make dbt-compile`
* Run data tests with  `make dbt-test`

The data from the database and grafana are persisted with docker volumes.

## Things I would do to continue this project 

- Set up alerts on Grafana for example if you spend more than we should 
- Add pipelines so that data is always up to date. I would use Airflow for example to make sure the date in the table are up to date and automate the population of the data.
- I would add indexes to the tables to make the query more efficient.
- I would make the conversion rate from EUR and AOA dynamic (used in invoice_dbt.sql). I would create a conversion rate table populated by an API that would give the updated conversion rate. 
- Write more tests