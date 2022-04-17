import numpy as np
import matplotlib.pyplot as plt

from skimage.transform import rotate
from skimage.feature import local_binary_pattern
from skimage import data
from skimage.color import label2rgb

class mode_manager:

  MODES = {
    'TRAIN_GENUINE': 0,
    'TRAIN_RECAPTURE': 1,
    'TEST_GENUINE': 2,
    'TEST_RECAPTURE': 3
  }

  LABELS = {
    'GENUINE': 0,
    'RECAPTURE': 1
  }

  NETWORK_MODE = {
    'ONE_CLASS': 0,
    'TWO_CLASS': 1
  }

  PRINTERS = {
    'NO_PRINTER': 0,
    'ALL_PRINTERS': 1,
    'INKJET_PRINTERS': 2,
    'LASER_PRINTERS': 3,
    'HP6222': 4,
    'HP258': 5,
    'HPM401N': 7,
    'KYOCERAM2530DN': 8,        # for in wild test (for test only), laser
    'HPM251N': 9,               # for in wild test (for test only), laser
    'HP2138': 10,               # for in wild test (for test only), inkjet
    'CANONG3800': 11,           # for in wild test (for test only), inkjet
    'HPM176': 12,               # for in wild test (for test only), laser
    'FUJIP335D': 13,            # for in wild test (for test only), laser
    'WILD': 14                  # for in wild test
  }

  SCANNERS = {
    'NO_SCANNER': 0,
    'ALL_SCANNERS': 1,
    'EPSON850': 2,
    'HP6222': 3,
  }

  DATA_SETS = {
    'SET 0': 0,
    'SET 1': 1,
    'SET 2': 2,
    'SET 3': 3,
    'SET 4': 4,
    'SET 5': 5
  }

  FEATURE_SETS = {
    'LBP_train': {'genuine': 'LBP_train_genuine_', 'recapture': 'LBP_train_recapture_'},
    'LBP_test': {'genuine': 'LBP_test_genuine_', 'recapture': 'LBP_test_recapture_'},
  }

  # the genuine (positive) sample sets for training
  TRAIN_GENUINE_SAMPLE_SETS = {
    (DATA_SETS['SET 0'],
     PRINTERS['ALL_PRINTERS'], SCANNERS['ALL_SCANNERS']): 'cropped_baseline_genuine_6_224_all',
    # 数据集 1：单独打印机型号和单独扫描仪型号为一个数据集
    (DATA_SETS['SET 1'],
     PRINTERS['HP6222'], SCANNERS['EPSON850']): 'cropped_baseline_genuine_6_224_hp6222_epson850',
    (DATA_SETS['SET 1'],
     PRINTERS['HP6222'], SCANNERS['HP6222']): 'cropped_baseline_genuine_6_224_hp6222_hp6222',
    (DATA_SETS['SET 1'],
     PRINTERS['HP258'], SCANNERS['EPSON850']): 'cropped_baseline_genuine_6_224_hp258_epson850',
    (DATA_SETS['SET 1'],
     PRINTERS['HP258'], SCANNERS['HP6222']): 'cropped_baseline_genuine_6_224_hp258_hp6222',
    (DATA_SETS['SET 1'],
     PRINTERS['HPM401N'], SCANNERS['EPSON850']): 'cropped_baseline_genuine_6_224_hpm401n_epson850',
    (DATA_SETS['SET 1'],
     PRINTERS['HPM401N'], SCANNERS['HP6222']): 'cropped_baseline_genuine_6_224_hpm401n_hp6222',
    # 数据集 2：喷墨打印机和单独扫描仪型号为一个数据集
    (DATA_SETS['SET 2'],
     PRINTERS['INKJET_PRINTERS'], SCANNERS['EPSON850']): 'cropped_baseline_genuine_6_224_inkjet_epson850',
    (DATA_SETS['SET 2'],
     PRINTERS['INKJET_PRINTERS'], SCANNERS['HP6222']): 'cropped_baseline_genuine_6_224_inkjet_hp6222',
    # 数据集 3：激光打印机和单独扫描仪型号为一个数据集
    (DATA_SETS['SET 3'],
     PRINTERS['LASER_PRINTERS'], SCANNERS['EPSON850']): 'cropped_baseline_genuine_6_224_laser_epson850',
    (DATA_SETS['SET 3'],
     PRINTERS['LASER_PRINTERS'], SCANNERS['HP6222']): 'cropped_baseline_genuine_6_224_laser_hp6222',
    # 数据集4：所有打印机和单独扫描仪型号为一个数据集
    (DATA_SETS['SET 4'],
     PRINTERS['ALL_PRINTERS'], SCANNERS['EPSON850']): 'cropped_baseline_genuine_6_224_all_epson850',
    (DATA_SETS['SET 4'],
     PRINTERS['ALL_PRINTERS'], SCANNERS['HP6222']): 'cropped_baseline_genuine_6_224_all_hp6222',
  }

  # the recapture (negative) sample sets for training
  TRAIN_RECAPTURE_SAMPLE_SETS = {
    (DATA_SETS['SET 0'],
     PRINTERS['ALL_PRINTERS'], SCANNERS['ALL_SCANNERS']): 'cropped_baseline_recapture_6_224_all',
    # 数据集 1：单独打印机型号和单独扫描仪型号为一个数据集
    (DATA_SETS['SET 1'],
     PRINTERS['HP6222'], SCANNERS['EPSON850']): 'cropped_baseline_recapture_6_224_hp6222_epson850',
    (DATA_SETS['SET 1'],
     PRINTERS['HP6222'], SCANNERS['HP6222']): 'cropped_baseline_recapture_6_224_hp6222_hp6222',
    (DATA_SETS['SET 1'],
     PRINTERS['HP258'], SCANNERS['EPSON850']): 'cropped_baseline_recapture_6_224_hp258_epson850',
    (DATA_SETS['SET 1'],
     PRINTERS['HP258'], SCANNERS['HP6222']): 'cropped_baseline_recapture_6_224_hp258_hp6222',
    (DATA_SETS['SET 1'],
     PRINTERS['HPM401N'], SCANNERS['EPSON850']): 'cropped_baseline_recapture_6_224_hpm401n_epson850',
    (DATA_SETS['SET 1'],
     PRINTERS['HPM401N'], SCANNERS['HP6222']): 'cropped_baseline_recapture_6_224_hpm401n_hp6222',
    # 数据集 2：喷墨打印机和单独扫描仪型号为一个数据集
    (DATA_SETS['SET 2'],
     PRINTERS['INKJET_PRINTERS'], SCANNERS['EPSON850']): 'cropped_baseline_recapture_6_224_inkjet_epson850',
    (DATA_SETS['SET 2'],
     PRINTERS['INKJET_PRINTERS'], SCANNERS['HP6222']): 'cropped_baseline_recapture_6_224_inkjet_hp6222',
    # 数据集 3：激光打印机和单独扫描仪型号为一个数据集
    (DATA_SETS['SET 3'],
     PRINTERS['LASER_PRINTERS'], SCANNERS['EPSON850']): 'cropped_baseline_recapture_6_224_laser_epson850',
    (DATA_SETS['SET 3'],
     PRINTERS['LASER_PRINTERS'], SCANNERS['HP6222']): 'cropped_baseline_recapture_6_224_laser_hp6222',
    # 数据集4：所有打印机和单独扫描仪型号为一个数据集
    (DATA_SETS['SET 4'],
     PRINTERS['ALL_PRINTERS'], SCANNERS['EPSON850']): 'cropped_baseline_recapture_6_224_all_epson850',
    (DATA_SETS['SET 4'],
     PRINTERS['ALL_PRINTERS'], SCANNERS['HP6222']): 'cropped_baseline_recapture_6_224_all_hp6222',
  }

  ' the sample sets for testing genuine doc images '
  TEST_GENUINE_SAMPLE_SETS = {
    (DATA_SETS['SET 0'],
     PRINTERS['ALL_PRINTERS'], SCANNERS['ALL_SCANNERS']): 'cropped_doc_genuine_6_224_all',
    # 数据集 1：单独打印机型号和单独扫描仪型号为一个数据集
    (DATA_SETS['SET 1'],
     PRINTERS['HP6222'], SCANNERS['EPSON850']): 'cropped_doc_genuine_6_224_hp6222_epson850',
    (DATA_SETS['SET 1'],
     PRINTERS['HP6222'], SCANNERS['HP6222']): 'cropped_doc_genuine_6_224_hp6222_hp6222',
    (DATA_SETS['SET 1'],
     PRINTERS['HP258'], SCANNERS['EPSON850']): 'cropped_doc_genuine_6_224_hp258_epson850',
    (DATA_SETS['SET 1'],
     PRINTERS['HP258'], SCANNERS['HP6222']): 'cropped_doc_genuine_6_224_hp258_hp6222',
    (DATA_SETS['SET 1'],
     PRINTERS['HPM401N'], SCANNERS['EPSON850']): 'cropped_doc_genuine_6_224_hpm401n_epson850',
    (DATA_SETS['SET 1'],
     PRINTERS['HPM401N'], SCANNERS['HP6222']): 'cropped_doc_genuine_6_224_hpm401n_hp6222',
    # 数据集 2：喷墨打印机和单独扫描仪型号为一个数据集
    (DATA_SETS['SET 2'],
     PRINTERS['INKJET_PRINTERS'], SCANNERS['EPSON850']): 'cropped_doc_genuine_6_224_inkjet_epson850',
    (DATA_SETS['SET 2'],
     PRINTERS['INKJET_PRINTERS'], SCANNERS['HP6222']): 'cropped_doc_genuine_6_224_inkjet_hp6222',
    # 数据集 3：激光打印机和单独扫描仪型号为一个数据集
    (DATA_SETS['SET 3'],
     PRINTERS['LASER_PRINTERS'], SCANNERS['EPSON850']): 'cropped_doc_genuine_6_224_laser_epson850',
    (DATA_SETS['SET 3'],
     PRINTERS['LASER_PRINTERS'], SCANNERS['HP6222']): 'cropped_doc_genuine_6_224_laser_hp6222',
    # 数据集4：所有打印机和单独扫描仪型号为一个数据集
    (DATA_SETS['SET 4'],
     PRINTERS['ALL_PRINTERS'], SCANNERS['EPSON850']): 'cropped_doc_genuine_6_224_all_epson850',
    (DATA_SETS['SET 4'],
     PRINTERS['ALL_PRINTERS'], SCANNERS['HP6222']): 'cropped_doc_genuine_6_224_all_hp6222',
    # 数据集5：未知打印机和单独扫描仪型号为一个数据集 （只有测试数据）
    (DATA_SETS['SET 5'],
     PRINTERS['WILD'], SCANNERS['EPSON850']): 'cropped_doc_genuine_6_224_wild_epson850'
  }

  ''' the sample sets for testing recaptured doc images '''
  TEST_RECAPTURE_SAMPLE_SETS = {
    (DATA_SETS['SET 0'],
     PRINTERS['ALL_PRINTERS'], SCANNERS['ALL_SCANNERS']): 'cropped_doc_recapture_6_224_all',
    # 数据集 1：单独打印机型号和单独扫描仪型号为一个数据集
    (DATA_SETS['SET 1'],
     PRINTERS['HP6222'], SCANNERS['EPSON850']): 'cropped_doc_recapture_6_224_hp6222_epson850',
    (DATA_SETS['SET 1'],
     PRINTERS['HP6222'], SCANNERS['HP6222']): 'cropped_doc_recapture_6_224_hp6222_hp6222',
    (DATA_SETS['SET 1'],
     PRINTERS['HP258'], SCANNERS['EPSON850']): 'cropped_doc_recapture_6_224_hp258_epson850',
    (DATA_SETS['SET 1'],
     PRINTERS['HP258'], SCANNERS['HP6222']): 'cropped_doc_recapture_6_224_hp258_hp6222',
    (DATA_SETS['SET 1'],
     PRINTERS['HPM401N'], SCANNERS['EPSON850']): 'cropped_doc_recapture_6_224_hpm401n_epson850',
    (DATA_SETS['SET 1'],
     PRINTERS['HPM401N'], SCANNERS['HP6222']): 'cropped_doc_recapture_6_224_hpm401n_hp6222',
    # 数据集 2：喷墨打印机和单独扫描仪型号为一个数据集
    (DATA_SETS['SET 2'],
     PRINTERS['INKJET_PRINTERS'], SCANNERS['EPSON850']): 'cropped_doc_recapture_6_224_inkjet_epson850',
    (DATA_SETS['SET 2'],
     PRINTERS['INKJET_PRINTERS'], SCANNERS['HP6222']): 'cropped_doc_recapture_6_224_inkjet_hp6222',
    # 数据集 3：激光打印机和单独扫描仪型号为一个数据集
    (DATA_SETS['SET 3'],
     PRINTERS['LASER_PRINTERS'], SCANNERS['EPSON850']): 'cropped_doc_recapture_6_224_laser_epson850',
    (DATA_SETS['SET 3'],
     PRINTERS['LASER_PRINTERS'], SCANNERS['HP6222']): 'cropped_doc_recapture_6_224_laser_hp6222',
    # 数据集4：所有打印机和单独扫描仪型号为一个数据集
    (DATA_SETS['SET 4'],
     PRINTERS['ALL_PRINTERS'], SCANNERS['EPSON850']): 'cropped_doc_recapture_6_224_all_epson850',
    (DATA_SETS['SET 4'],
     PRINTERS['ALL_PRINTERS'], SCANNERS['HP6222']): 'cropped_doc_recapture_6_224_all_hp6222',
    # 数据集5：未知打印机和单独扫描仪型号为一个数据集 （只有测试数据）
    (DATA_SETS['SET 5'],
     PRINTERS['WILD'], SCANNERS['EPSON850']): 'cropped_doc_recapture_6_224_wild_epson850'
  }

  # the constructor
  def __init__(self, mode=MODES['TRAIN_GENUINE']):

    # the current mode
    self.current_mode = mode

    # the current training sample set: initialized to use all image samples
    self.current_train_data_set = mode_manager.DATA_SETS['SET 0']

    # the current test sample set: : initialized to use all image samples
    self.current_test_data_set = mode_manager.DATA_SETS['SET 0']

  # TODO: add error checkings
  def set_mode(self, mode):
    # mode is in str type
    self.current_mode = mode

  # set the current test data set
  def set_test_data_set(self, data_set):
    self.current_test_data_set = data_set

  # set the current train data set
  def set_train_data_set(self, data_set):
    self.current_test_data_set = data_set
