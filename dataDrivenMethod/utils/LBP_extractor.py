import pickle
import os
import numpy as np
import matplotlib.pyplot as plt
from scipy.stats import itemfreq
from skimage.transform import rotate
from skimage.feature import local_binary_pattern
from skimage import data
from skimage.color import label2rgb

from utils.image_loader import image_loader
from utils.image_splitter import image_splitter
from utils.mode_manager import mode_manager

class LBP_extractor:

  ''' the constructor '''
  def __init__(self):

    # the method used in LBP extraction
    self.LBP_method = 'nri_uniform'

    # self.LBP_radius_list = [2, 2]
    # self.LBP_num_pt_list = [8, 16]
    # self.LBP_num_bins_list = [59, 243]

    # LBP parameters
    self.LBP_radius_list = [2, 4]
    self.LBP_num_pt_list = [8, 16]
    self.LBP_num_bins_list = [59, 243]

    # overlap parameters
    self.overlap_LBP_radius_list = [1]
    self.overlap_LBP_num_pt_list = [8]
    self.overlap_LBP_num_bins_list = [59]

    # splitter
    self.img_splitter = image_splitter(overlap_in_pixel=76, crop_size_in_pixel=150)

  ''' extract LBP features for all images'''
  def LBP_Extraction(self, opt, feature_set_train, feature_set_test, data_set):
    ''' initialize image loader '''
    image_loader_ = image_loader(mode_manager_=mode_manager())
    ''' iterate through datasets for genuine training images'''
    image_loader_.mode_manager.set_mode(mode_manager.MODES['TRAIN_GENUINE'])
    # initialize the train feature array
    for sample_set, sample_set_path in mode_manager.TRAIN_GENUINE_SAMPLE_SETS.items():
      if sample_set[0] == data_set:
        LBP_dataset_name = opt.LBP_feature_dir + \
          feature_set_train['genuine'] + str(sample_set[0]) + '_' + str(sample_set[1]) + '_' + str(sample_set[2]) + '.txt'
        # load the LBP features if they are NOT extracted before
        if not os.path.exists(LBP_dataset_name):
          # get the image path list
          data_set_path = opt.all_image_root_dir + '\\' + sample_set_path
          img_path_list = [os.path.join(data_set_path, img) for img in os.listdir(data_set_path)]
          if len(img_path_list) == 0:
            continue
          print('extracting LBP features to: ' + LBP_dataset_name)
          train_data_features = np.array([])
          # read in through each image
          for i in range(0, len(img_path_list)):
            # read in training image
            printer_name, scanner_name, label, train_img = image_loader_.img_read(img_path_list[i])
            printer_name, scanner_name = \
              mode_manager.PRINTERS[printer_name.upper()], mode_manager.SCANNERS[scanner_name.upper()]
            # extract LBP features
            lbp_to_train_hist = self.extrac_LBP_from_image(train_img)
            if len(train_data_features) == 0:
              train_data_features = \
                np.insert(lbp_to_train_hist, 0, [data_set, printer_name, scanner_name, label]).reshape(1, -1)
            else:
              train_data_features = \
                np.r_[train_data_features,
                      np.insert(lbp_to_train_hist, 0, [data_set, printer_name, scanner_name, label]).reshape(1, -1)]
            print(i / len(img_path_list))
          # save the extracted LBP features
          pickle.dump(train_data_features, open(LBP_dataset_name, 'wb'))

    ''' iterate through datasets for recapture training images'''
    image_loader_.mode_manager.set_mode(mode_manager.MODES['TRAIN_RECAPTURE'])
    # initialize the train feature array
    for sample_set, sample_set_path in mode_manager.TRAIN_RECAPTURE_SAMPLE_SETS.items():
      if sample_set[0] == data_set:
        # the LBP featre dataset name
        LBP_dataset_name = opt.LBP_feature_dir + \
          feature_set_train['recapture'] + str(sample_set[0]) + '_' + str(sample_set[1]) + '_' + str(sample_set[2]) + '.txt'
        # load the LBP features if they are extracted before
        if not os.path.exists(LBP_dataset_name):
          # get the image path list
          data_set_path = opt.all_image_root_dir + '/' + sample_set_path
          img_path_list = [os.path.join(data_set_path, img) for img in os.listdir(data_set_path)]
          if len(img_path_list) == 0:
            continue
          print('extracting LBP features to: ' + LBP_dataset_name)
          train_data_features = np.array([])
          # read in through each image
          for i in range(0, len(img_path_list)):
            # read in training image
            printer_name, scanner_name, label, train_img = image_loader_.img_read(img_path_list[i])
            printer_name, scanner_name = \
              mode_manager.PRINTERS[printer_name.upper()], mode_manager.SCANNERS[scanner_name.upper()]
            # extract LBP features
            lbp_to_train_hist = self.extrac_LBP_from_image(train_img)
            if len(train_data_features) == 0:
              train_data_features = np.insert(lbp_to_train_hist, 0,
                                              [data_set, printer_name, scanner_name, label]).reshape(1, -1)
            else:
              train_data_features = \
                np.r_[train_data_features,
                      np.insert(lbp_to_train_hist, 0, [data_set, printer_name, scanner_name, label]).reshape(1, -1)]

            print(i / len(img_path_list))
          # save the extracted LBP features
          pickle.dump(train_data_features, open(LBP_dataset_name, 'wb'))

    '''  iterate through genuine test image datasets '''
    image_loader_.mode_manager.set_mode(mode_manager.MODES['TEST_GENUINE'])
    for sample_set, sample_set_path in mode_manager.TEST_GENUINE_SAMPLE_SETS.items():
      if sample_set[0] == data_set:
        # load in the LBP
        LBP_dataset_name = opt.LBP_feature_dir + \
          feature_set_test['genuine'] + str(sample_set[0]) + '_' + str(sample_set[1]) + '_' + str(sample_set[2]) + '.txt'
        # if the LBP exist, read in the LBP file
        if not os.path.exists(LBP_dataset_name):
          # get the image path list
          data_set_path = opt.all_image_root_dir + '/' + sample_set_path
          img_path_list = [os.path.join(data_set_path, img) for img in os.listdir(data_set_path)]
          # if there is no image in the path
          if len(img_path_list) == 0:
            continue
          print('extracting LBP features to: ' + LBP_dataset_name)
          test_data_features = np.array([])
          # read in through each image
          for i in range(0, len(img_path_list)):
            # read in test image
            first_printer_name, second_printer_name, \
            first_scanner_name, second_scanner_name, \
              doc_idx, label, test_img = image_loader_.img_read(img_path_list[i])
            first_printer_idx, second_printer_idx, \
            first_scanner_idx, second_scanner_idx, = \
              mode_manager.PRINTERS[first_printer_name.upper()], mode_manager.PRINTERS[second_printer_name.upper()], \
              mode_manager.SCANNERS[first_scanner_name.upper()], mode_manager.SCANNERS[second_scanner_name.upper()]
            # extract LBP features
            lbp_to_test_hist = self.extrac_LBP_from_image(test_img)
            # concatenate the results
            if len(test_data_features) == 0:
              test_data_features = \
                np.insert(lbp_to_test_hist, 0,
                          [data_set,
                           first_printer_idx, first_scanner_idx,
                           second_printer_idx, second_scanner_idx, doc_idx, label]).reshape(1, -1)
            else:
              test_data_features = \
                np.r_[test_data_features,
                      np.insert(lbp_to_test_hist, 0,
                                [data_set,
                                 first_printer_idx, first_scanner_idx,
                                 second_printer_idx, second_scanner_idx, doc_idx, label]).reshape(1, -1)]
            print(i / len(img_path_list))
          # save the extracted LBP features
          pickle.dump(test_data_features, open(LBP_dataset_name, 'wb'))

    '''  iterate through recapture test image datasets '''
    image_loader_.mode_manager.set_mode(mode_manager.MODES['TEST_RECAPTURE'])
    for sample_set, sample_set_path in mode_manager.TEST_RECAPTURE_SAMPLE_SETS.items():
      if sample_set[0] == data_set:
        # load in the LBP
        LBP_dataset_name = opt.LBP_feature_dir + \
          feature_set_test['recapture'] + str(sample_set[0]) + '_' + str(sample_set[1]) + '_' + str(sample_set[2]) + '.txt'
        # if the LBP exist don't extract
        if not os.path.exists(LBP_dataset_name):
          # get the image path list
          data_set_path = opt.all_image_root_dir + '/' + sample_set_path
          img_path_list = [os.path.join(data_set_path, img) for img in os.listdir(data_set_path)]
          # if no image in dataset
          if len(img_path_list) == 0:
            continue
          print('extracting LBP features to: ' + LBP_dataset_name)
          test_data_features = np.array([])
          # read in through each image
          for i in range(0, len(img_path_list)):
            # read in test image
            first_printer_name, second_printer_name, \
            first_scanner_name, second_scanner_name, \
            doc_idx, label, test_img = image_loader_.img_read(img_path_list[i])
            first_printer_idx, second_printer_idx, \
            first_scanner_idx, second_scanner_idx, = \
              mode_manager.PRINTERS[first_printer_name.upper()], mode_manager.SCANNERS[second_printer_name.upper()], \
              mode_manager.PRINTERS[first_scanner_name.upper()], mode_manager.SCANNERS[second_scanner_name.upper()]
            # extract LBP features
            lbp_to_test_hist = self.extrac_LBP_from_image(test_img)
            # concatenate the results
            if len(test_data_features) == 0:
              test_data_features = \
                np.insert(lbp_to_test_hist, 0,
                          [data_set,
                           first_printer_idx, first_scanner_idx,
                           second_printer_idx, second_scanner_idx, doc_idx, label]).reshape(1, -1)
            else:
              test_data_features = \
                np.r_[test_data_features,
                      np.insert(lbp_to_test_hist, 0,
                                [data_set,
                                 first_printer_idx, first_scanner_idx,
                                 second_printer_idx, second_scanner_idx, doc_idx, label]).reshape(1, -1)]

            print(i / len(img_path_list))
          # save the extracted LBP features
          pickle.dump(test_data_features, open(LBP_dataset_name, 'wb'))

  # do multi-level LBP extraction
  def extrac_LBP_from_image(self, input_image):

    # do image normalization
    input_image_normalized = (input_image - input_image.min()) * (255 / (input_image.max() - input_image.min()))
    # initialize the overall lbp hist list
    lbp_to_train_hist = np.array([])
    # extract the histogram of LBP for the whole image
    for LBP_radius, LBP_num_pt, LBP_num_bins in zip(self.LBP_radius_list, self.LBP_num_pt_list, self.LBP_num_bins_list):
      lbp = local_binary_pattern(input_image_normalized, P=LBP_num_pt, R=LBP_radius, method=self.LBP_method)
      # calculate the histogram
      (lbp_to_train_hist_, _) = np.histogram(lbp.ravel(), bins=np.arange(-0.5, LBP_num_bins), density=True)
      # concatenate the histograms
      lbp_to_train_hist = np.array(lbp_to_train_hist.tolist() + lbp_to_train_hist_.tolist())

    # extract the histogram of LBP for the overlapped image blocks
    for overlap_LBP_radius, overlap_LBP_num_pt, overlap_LBP_num_bins in \
            zip(self.overlap_LBP_radius_list, self.overlap_LBP_num_pt_list, self.overlap_LBP_num_bins_list):
      # do cropping to the whole LBP image obtained using different parameters
      lbp = local_binary_pattern(input_image_normalized, P=overlap_LBP_num_pt, R=overlap_LBP_radius,
                                 method=self.LBP_method)
      lbp_blk_list = self.img_splitter.crop_images(lbp)
      for lbp_blk in lbp_blk_list:
        # calculate the histogram
        (lbp_to_train_hist_, _) = np.histogram(lbp_blk.ravel(), bins=np.arange(-0.5, overlap_LBP_num_bins), density=True)
        # concatenate the histograms
        lbp_to_train_hist = np.array(lbp_to_train_hist.tolist() + lbp_to_train_hist_.tolist())

    return lbp_to_train_hist
