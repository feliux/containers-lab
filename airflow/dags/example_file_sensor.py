from airflow.models import DAG
from airflow.operators.bash_operator import BashOperator
from airflow.contrib.sensors.file_sensor import FileSensor
from datetime import datetime, timedelta

report_dag = DAG(
    dag_id = "execute_report",
    schedule_interval = "0 0 * * *"
)

precheck = FileSensor(
    task_id="check_for_datafile",
    filepath="salesdata_ready.csv",
    start_date=datetime(2020,2,20),
    poke_interval=5, # check every 5 seconds
    mode="reschedule", # https://stackoverflow.com/questions/63775318/confused-about-airflows-basesensoroperator-parameters-timeout-poke-interval
    dag=report_dag
)

generate_report_task = BashOperator(
    task_id="generate_report",
    bash_command="generate_report.sh",
    sla=timedelta(hours=3),
    start_date=datetime(2020,2,20),
    dag=report_dag
)

precheck >> generate_report_task