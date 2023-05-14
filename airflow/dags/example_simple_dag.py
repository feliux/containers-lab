from airflow.models import DAG
from datetime import datetime, timedelta

# Define the default_args dictionary
default_args = {
  "owner": "Engineering",
  "start_date": datetime(2019, 11, 1),
  "email": ["changeme@example.com"],
  "email_on_failure": False,
  "email_on_retry": False,
  "retries": 3,
  "retry_delay": timedelta(minutes=20)
}

# Instantiate the DAG object
etl_dag = DAG(
  "example_etl",
  default_args=default_args,
  schedule_interval="30 12 * * 3" # every Wednesday at 12:30pm
)