import pickle
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.font_manager
from sklearn import svm
from os import path

''' classifier manager managing all classifiers  '''
class classifier_manager:

  # the constructor
  def __init__(self):

    # the classifer to use
    self.classifier = ''

  # train the classifer (to be implemented by child classes)
  def train_classifer(self, input_train_data, sample_set):
    pass

  # test the classifer (to be implemented by child classes)
  def test_classifier(self, input_test_data, sample_set):
    pass