import json
import torch
import warnings
from utils.mode_manager import mode_manager


class Config:

  ''' class variables '''
  env = 'default'
  vis_port = 8097

  classifier = ''

  # ' train image directories '
  # train_data_root = 'E:/Files/Halftone Model Work Images/scanned/data_driven_test'

  # ' test recapture image directions '
  # test_data_root = 'E:/Files/Halftone Model Work Images/scanned/cropped_scanned_document_psps_6_224'

  ' test genuine image directions '
  # all_image_root_dir = 'E:\\Files\Halftone Model Work Images\\scanned\\data_driven_test'   # external drive
  # all_image_root_dir = 'C:\\Users\\hzx19\\Documents\\Halftone Model Work Images\\scanned\\data_driven_test'
  all_image_root_dir = 'C:\\Users\\hzx19\\Repository\\HalftoneGeneration\\dataDrivenMethod\\data_driven_test'

  LBP_feature_dir = r'LBP_features/'
  SVM_classifier_dir = r'SVM_classifiers/'
  DNN_classifier_dir = r'DNN_classifiers/'
  AE_dir = r'AE_/'
  DNN_SVDD_center_dir = r'One-Class DNN Centers/'
  test_result_SVM_dir = r'test_results_SVM/'
  test_result_DNN_dir = r'test_results_dnn/'

  ''' constructor '''
  def __init__(self, settings=None):
    self.settings = settings
    self.mode_manager = mode_manager()

    ' model name '
    self.model_name = 'DenseNet201'

    ''' AE parameters with default values'''
    self.ae_optimizer_name = 'adam'
    self.ae_lr = 1e-5
    self.ae_gamma = 0.1
    self.ae_n_epochs = 150
    self.ae_lr_milestones = (50,)
    self.ae_batch_size = 32
    self.ae_weight_decay = 1e-5
    self.ae_device = 'cuda'
    self.ae_n_jobs_dataloader = 0

    ''' DNN parameters '''
    self.batch_size = 32
    self.use_gpu = True
    self.num_workers = 8
    self.print_freq = 20
    self.debug_file = ''
    self.lr = 1e-3
    self.gamma = 0.1
    self.lr_milestones = (80,)
    self.weight_decay = 1e-5
    self.device = 'cuda'
    self.optimizer_name = 'adam'          # default optimizer name
    self.n_jobs_dataloader = 0
    self.n_epochs = 20                    # number of epochs for ResNet

  ' load configuration from json '
  def load_config(self, json_path):
    """Load settings dict from import_json (path/filename.json) JSON-file."""
    with open(json_path, 'r') as fp:
      settings = json.load(fp)

    for key, value in settings.items():
      self.settings[key] = value

  ' save configuration from json '
  def save_config(self, json_path):
    """Save settings dict to export_json (path/filename.json) JSON-file."""
    with open(json_path, 'w') as fp:
      json.dump(self.settings, fp)

  # process the input arguements
  def _parse(self, kwargs):
    '''根据字典 kwargs 更新 config参数'''
    for k, v in kwargs.items():
      if not hasattr(self, k):
        warnings.warn("Warning: opt has not attribut %s" % k)
      setattr(self, k, v)

    # # assign device
    # self.device = t.device('cuda:0') if self.use_gpu else t.device('cpu')

    # # printout configurations
    # print('user config:')
    # for k, v in self.__class__.__dict__.items():
    #   if not k.startswith('_'):
    #     print(k, getattr(self, k))

# new_config = {'batch_size_0': 256}
# opt._parse(new_config)
