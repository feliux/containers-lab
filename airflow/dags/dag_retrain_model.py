from datetime import datetime, timedelta
import logging
import os
import re
import pandas as pd
from pathlib import Path
from tempfile import NamedTemporaryFile
from airflow import DAG
from airflow.operators.python_operator import PythonOperator
from minio import Minio
import joblib
from sqlalchemy import create_engine

### TASK ###
def retrain_model():
    logging.info("fetching data from Minio")
    minio_client = Minio(
        endpoint="minio:9000",
        access_key=os.environ["MINIO_ACCESS_KEY"],
        secret_key=os.environ["MINIO_SECRET_KEY"],
        secure=False
    )
    logging.info("connected to minio")

    with NamedTemporaryFile() as tmp:
        minio_client.fget_object(
            "sample-bucket",
            "sample-file.txt",
            tmp.name
        )
        #import the model
        #clf = joblib.load(tmp.name)

    #load the data
    psql_host = os.environ["POSTGRES_HOST"]
    user = os.environ["CUSTOM_USER"]
    password = os.environ["CUSTOM_PASSWORD"]
    database = os.environ["CUSTOM_DB"]
    sql_query = f"SELECT * FROM {database}"
    connection = create_engine("postgres://{user}:{password}@{psql_host}/{database}".format(**locals()))
    df = pd.read_sql(
        sql=sql_query,
        con=connection
    )
    
    #train the model
    #clf.fit(X=df[""], Y=df[""])

    #persist the model
    now = str(datetime.now())
    now_formated = re.sub(r"[ .:]", "-", now)
    with NamedTemporaryFile() as tmp:
        #dump the model to local file system
        #joblib.dump(value=clf, filename=tmp.name)
        #upload local file to minio
        minio_client.fput_object(
            bucket_name="model",
            object_name="sample-data-{now_formated}.txt".format(**locals()),
            file_path=Path(tmp.name)
        )
    logging.info("persisting data")
    #df.to_sql(name="new_data", con=connection, index=False, if_exists="append")


### DAG ###
default_args={
    "owner":"airflow",
    "depends_on_past":"false",
    "start_date":datetime.today()-timedelta(days=1)
}

dag = DAG(
    dag_id="dag_retrain_model",
    default_args=default_args,
    schedule_interval=timedelta(seconds=30)
)

task = PythonOperator(
    task_id="task_retrain_model",
    python_callable=retrain_model,
    dag=dag
)