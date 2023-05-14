from airflow import DAG
from airflow.operators.python_operator import BranchPythonOperator
from airflow.operators.dummy_operator import DummyOperator
from datetime import datetime, timedelta

default_args = {
    "owner": "airflow",
    "depends_on_past": False,
    "retries": 1,
    "retry_delay": timedelta(minutes=5),
    # "queue": "bash_queue",
    # "pool": "backfill",
    # "priority_weight": 10,
    # "end_date": datetime(2016, 1, 1),
    # "wait_for_downstream": False,
    # "dag": dag,
    # "sla": timedelta(hours=2),
    # "execution_timeout": timedelta(seconds=300),
    # "on_failure_callback": some_function,
    # "on_success_callback": some_other_function,
    # "on_retry_callback": another_function,
    # "sla_miss_callback": yet_another_function,
    # "trigger_rule": "all_success"
}

branch_dag = DAG(
    dag_id="branch_dag",
    default_args=default_args
)

# Create a function to determine if years are different
def year_check(**kwargs):
    current_year = int(kwargs["ds_nodash"][0:4])
    previous_year = int(kwargs["prev_ds_nodash"][0:4])
    if current_year == previous_year:
        return "current_year_task"
    else:
        return "new_year_task"

# Define the BranchPythonOperator
branch_task = BranchPythonOperator(
    task_id="branch_task",
    start_date=datetime(2020,2,20),
    dag=branch_dag,
    python_callable=year_check, 
    provide_context=True
)

current_year_task = DummyOperator(
    task_id="current_year_task",
    start_date=datetime(2020,2,20),
)
new_year_task = DummyOperator(
    task_id="new_year_task",
    start_date=datetime(2020,2,20),
)

# Define the dependencies
branch_dag >> current_year_task
branch_dag >> new_year_task