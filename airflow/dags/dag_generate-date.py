from datetime import datetime, timedelta
import logging
import os
from airflow import DAG
from airflow.operators.python_operator import PythonOperator
import pandas as pd
from sqlalchemy import create_engine

### TASK ###
def generate_synthetic_data():
    logging.info("fetching random data")
    psql_host = os.environ["POSTGRES_HOST"]
    user = os.environ["CUSTOM_USER"]
    password = os.environ["CUSTOM_PASSWORD"]
    database = os.environ["CUSTOM_DB"]
    sql_query = f"SELECT * FROM {database}"
    connection = create_engine("postgres://{user}:{password}@{psql_host}/{database}".format(**locals()))
    df = pd.read_sql(sql=sql_query, con=connection)
    
    logging.info("persisting data")
    df.to_sql(
        name="new_data",
        con=connection,
        index=False,
        if_exists="append"
        )


### DAG ###
default_args={
        "owner":"airflow",
        "depends_on_past":"false",
        "start_date":datetime.today()-timedelta(days=1),
        }

dag = DAG(
    dag_id="dag_generate_data",
    default_args=default_args,
    schedule_interval=timedelta(seconds=30)
)

task = PythonOperator(
    task_id="task_generate_data",
    python_callable=generate_synthetic_data,
    dag=dag
)