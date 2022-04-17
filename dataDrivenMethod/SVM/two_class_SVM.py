import pickle
from sklearn import svm
from sklearn.model_selection import GridSearchCV
from classifier_manager import classifier_manager
from os import path
from utils.mode_manager import mode_manager
from sklearn.model_selection import StratifiedShuffleSplit

''' the one_class_SVM implementation'''
class two_class_SVM(classifier_manager):

  # the constructor
  def __init__(self):

    # initialize the parent class
    super(two_class_SVM, self).__init__()

    # define the parameters for one class SVM
    self.param_nu = 0.5
    self.param_C = 0
    self.param_gamma = 'auto'
    self.kernel = 'rbf'

  ''' implementing the train function '''
  def train_classifer(self, input_train_data, input_train_label, sample_set, opt):

    classifier_name = \
      opt.SVM_classifier_dir + \
      'trained_two_class_SVM_' + str(sample_set[0]) + '_' + str(sample_set[1]) + '_' + str(sample_set[2]) + '.obj'

    # train classifier only when it does not exist
    if not path.exists(classifier_name):
      # defining parameter range
      param_grid = {'C': [0.1, 1, 10, 100, 1000],
                    'gamma': [1, 0.1, 0.01, 0.001, 0.0001],
                    'kernel': ['rbf']}

      cv = StratifiedShuffleSplit(n_splits=5, test_size=0.3, random_state=0)
      grid = GridSearchCV(svm.SVC(), n_jobs=6, param_grid=param_grid, refit=True, scoring='f1', verbose=3, cv=cv)
      grid.fit(input_train_data, input_train_label)

      # mean cross-validated score of the best_estimator
      print(grid.best_score_)
      # save the trained classifier
      pickle.dump(grid.best_estimator_, open(classifier_name, 'wb'))
    else:
      print('classifier exists: ' + classifier_name)

  ''' implementing the test function '''
  def test_classifier(self, input_test_data, sample_set, opt):

    # load the trained classifier for testing: the test dataset 5 uses the classifier trained for test dataset 4
    classifier_name = \
      opt.SVM_classifier_dir + \
      'trained_two_class_SVM_' + str(sample_set[0]) + '_' + str(sample_set[1]) + '_' + str(sample_set[2]) + '.obj'

    self.classifier = pickle.load(open(classifier_name, 'rb'))

    # get the hard and soft outputs
    test_result_label = self.classifier.predict(input_test_data)
    test_result_label_soft = self.classifier.decision_function(input_test_data)
    return test_result_label, test_result_label_soft
