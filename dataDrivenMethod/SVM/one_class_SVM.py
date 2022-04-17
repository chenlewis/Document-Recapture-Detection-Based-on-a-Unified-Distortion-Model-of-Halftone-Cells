import pickle
import numpy as np
from sklearn import svm
from classifier_manager import classifier_manager
from sklearn.model_selection import GridSearchCV
from utils.mode_manager import mode_manager
from os import path
from sklearn.model_selection import ShuffleSplit

''' the one_class_SVM implementation'''
class one_class_SVM(classifier_manager):

  # the constructor
  def __init__(self):

    # initialize the parent class
    super(one_class_SVM, self).__init__()

    # define the parameters for one class SVM
    self.param_nu = 0.1
    self.param_C = 0
    self.param_gamma = 'auto'
    self.kernel = 'rbf'

  ''' implementing the train function '''
  def train_classifer(self, input_train_data, sample_set, opt):
    # set the name of the classifer
    classifier_name = \
      opt.SVM_classifier_dir + \
      'trained_one_class_SVM_' + str(sample_set[0]) + '_' + str(sample_set[1]) + '_' + str(sample_set[2]) + '.obj'
    # train classifier only when it does not exist
    if not path.exists(classifier_name):

      # initialize the one class classifer: here just initialize the dummy labels
      input_train_label = np.ones((len(input_train_data),), dtype=int)

      # param_grid = {'nu': np.arange(0.2, 0.6, 0.1).tolist(),
      #               'gamma': [1, 0.1, 0.01, 0.001, 0.0001],
      #               'kernel': ['rbf']}

      # this set of parameters are found to give reasonable results
      param_grid = {'nu': [0.2],
                    'gamma': [10],
                    'kernel': ['rbf']}

      cv = ShuffleSplit(n_splits=5, test_size=0.3, random_state=0)
      grid = GridSearchCV(svm.OneClassSVM(), n_jobs=6, refit=True, param_grid=param_grid, scoring='recall', verbose=1, cv=cv)
      grid.fit(input_train_data, input_train_label)
      # Mean cross-validated score of the best_estimator
      print(grid.best_score_)
      # save the trained classifier
      pickle.dump(grid.best_estimator_, open(classifier_name, 'wb'))
    else:
      print('classifier exists: ' + classifier_name)

  ''' implementing the test function '''
  def test_classifier(self, input_test_data, sample_set, opt):

    # load the trained classifier for testing
    classifier_name = \
      opt.SVM_classifier_dir + \
      'trained_one_class_SVM_' + str(sample_set[0]) + '_' + str(sample_set[1]) + '_' + str(sample_set[2]) + '.obj'

    # load the classifier
    self.classifier = pickle.load(open(classifier_name, 'rb'))

    # get the hard and soft outputs
    test_result_label = self.classifier.predict(input_test_data)
    test_result_label_soft = self.classifier.decision_function(input_test_data)
    return test_result_label, test_result_label_soft
