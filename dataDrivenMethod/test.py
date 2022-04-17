# import numpy as np
# from sklearn.model_selection import StratifiedKFold
# from sklearn.model_selection import train_test_split
# from sklearn.model_selection import ShuffleSplit
#
# X = np.array([[1, 3], [2, 2], [1, 2], [1, 3]])
# y = np.array([0, 0, 0, 0])
# skf = StratifiedKFold(n_splits=2)
# skf.get_n_splits(X, y)
# print(skf)
#
# for train_index, test_index in skf.split(X, y):
# 	print("TRAIN:", train_index, "TEST:", test_index)
# 	X_train, X_test = X[train_index], X[test_index]
# 	y_train, y_test = y[train_index], y[test_index]
#
# X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, shuffle=True, random_state=42)
# print("TRAIN:", X_train, "TEST:", X_test)
#
# # use shuffle split
# rs = ShuffleSplit(n_splits=5, test_size=.2, random_state=0)
# rs.get_n_splits(X)



from sklearn.metrics import precision_score
y_true = [0, 1, 2, 0, 1, 2]
y_pred = [0, 2, 1, 0, 0, 1]
print(precision_score(y_true, y_pred, average='macro'))
print(precision_score(y_true, y_pred, average='micro'))
print(precision_score(y_true, y_pred, average='weighted'))

