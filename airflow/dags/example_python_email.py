from airflow import DAG
from airflow.operators.python_operator import PythonOperator
from airflow.operators.email_operator import EmailOperator

process_sales_dag = DAG(
   dag_id = "process_sales_dag",
   default_args={"start_date": "2019-10-01"}
)

def pull_file(URL, savepath):
    r = requests.get(URL)
    with open(savepath, "wb") as f:
        f.write(r.content)   
    # Use the print method for logging
    print(f"File pulled from {URL} and saved to {savepath}")

# Create the task
pull_file_task = PythonOperator(
    task_id="pull_file",
    # Add the callable
    python_callable=pull_file,
    # Define the arguments
    op_kwargs={"URL":"http://dataserver/sales.json", "savepath":"latestsales.json"},
    dag=process_sales_dag
)

# Define the task
email_manager_task = EmailOperator(
    task_id="email_manager",
    to="manager@example.com",
    subject="Latest sales JSON",
    html_content="Attached is the latest sales JSON file as requested.",
    files="latestsales.json",
    dag=process_sales_dag
)

# Set the order of tasks
pull_file_task >> email_manager_task