import mlflow
import pickle
import os
import numpy as np
from sklearn import datasets
from mlflow.models import infer_signature


FILENAME = "lr_model.pkl"
TRACKING_URI = "http://localhost:8080"
os.environ["MLFLOW_TRACKING_USERNAME"] = "admin"
os.environ["MLFLOW_TRACKING_PASSWORD"] = "password"

loaded_model = pickle.load(open(FILENAME, "rb"))
diabetes_X, diabetes_y = datasets.load_diabetes(return_X_y=True)
diabetes_X = diabetes_X[:, np.newaxis, 2]
signature = infer_signature(diabetes_X, diabetes_y)
mlflow.set_tracking_uri(TRACKING_URI)

mlflow.sklearn.log_model(
    loaded_model,
    "sk_learn",
    serialization_format="cloudpickle",
    signature=signature,
    registered_model_name="SklearnLinearRegression"
)
