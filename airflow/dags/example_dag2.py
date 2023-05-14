from airflow.models import DAG
from airflow.operators.bash_operator import BashOperator
from airflow.operators.python_operator import PythonOperator
from airflow.operators.http_operator import SimpleHttpOperator
from airflow.operators.email_operator import EmailOperator

dag = DAG(
   dag_id = "update_state",
   default_args={
      "start_date": "2019-10-01"
      }
)

part1 = BashOperator(
   task_id="generate_random_number",
   bash_command="echo $RANDOM",
   dag=dag
)

def python_version():
   import sys
   return sys.version

def sleep(length_of_time):
   time.sleep(length_of_time)

part2 = PythonOperator(
   task_id="get_python_version",
   python_callable=python_version,
   dag=dag
)
   
part3 = SimpleHttpOperator(
   task_id="query_server_for_external_ip",
   endpoint="https://api.ipify.org",
   method="GET",
   dag=dag
)

part4 = PythonOperator(
   task_id="sleep",
   python_callable=sleep,
   op_kwargs={
      "length_of_time": 5
      },
   dag=dag
)

part5 = EmailOperator(
   task_id="email_report",
   to="changeme@example.com",
   subject="Automated report",
   html_content="Attached is the report",
   files="report.xlsx",
   dag=dag
)

part1 >> part3
part3 >> part2 >> part4 >> part5