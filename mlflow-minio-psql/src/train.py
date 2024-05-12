import pickle
import numpy as np
from sklearn import datasets, linear_model
from sklearn.metrics import mean_squared_error, r2_score

# source: https://scikit-learn.org/stable/auto_examples/linear_model/plot_ols.html
FILENAME = "lr_model.pkl"


def print_predictions(m, y_pred):
    print("Coefficients: \n", m.coef_)
    print("Mean squared error: %.2f" % mean_squared_error(diabetes_y_test, y_pred))
    print("Coefficient of determination: %.2f" % r2_score(diabetes_y_test, y_pred))

diabetes_X, diabetes_y = datasets.load_diabetes(return_X_y=True)
diabetes_X = diabetes_X[:, np.newaxis, 2]
diabetes_X_train = diabetes_X[:-20]
diabetes_X_test = diabetes_X[-20:]
diabetes_y_train = diabetes_y[:-20]
diabetes_y_test = diabetes_y[-20:]
lr_model = linear_model.LinearRegression()
lr_model.fit(diabetes_X_train, diabetes_y_train)
diabetes_y_pred = lr_model.predict(diabetes_X_test)
print_predictions(lr_model, diabetes_y_pred)
pickle.dump(lr_model, open(FILENAME, "wb"))
