import os
from datetime import time

import matplotlib
matplotlib.use('TkAgg')
from matplotlib import pyplot as plt

from sklearn.metrics import roc_auc_score
import sys
from config import Config
from os import path
import pickle
import torch as t
from torch.utils.data import ConcatDataset
import models
from torchnet import meter
import torch.nn as nn
from tqdm.auto import tqdm
from SVM.one_class_SVM import one_class_SVM
from SVM.two_class_SVM import two_class_SVM
import numpy as np

# import the databases
from datasets.base_dataset import base_dataset
from datasets.albumentationDataset import albumentationDataset

from utils.LBP_extractor import LBP_extractor
from utils.mode_manager import mode_manager
import statistics

import matplotlib.pyplot as plt

''' train the DNN model '''
def train_DNN(model_, dataset_, network_mode_, pretrain_):

  # models is a directory
  net_dict = {}

  genuine_train_dataloader_dict = {}
  genuine_ae_train_dataloader_dict = {}

  genuine_train_dataset_dict = {}
  recapture_train_dataset_dict = {}

  ' initialize the networks and the sample sets '
  if network_mode_ == mode_manager.NETWORK_MODE['ONE_CLASS']:
    'if training using the genuine baseline images only'
    for dataset, image_path in mode_manager.TRAIN_GENUINE_SAMPLE_SETS.items():
      if dataset[0] == dataset_:
        # get the image sample set
        image_sampleset = base_dataset(root=opt.all_image_root_dir + '\\' + image_path,
                                       mode=mode_manager.MODES['TRAIN_GENUINE'],
                                       network_mode=network_mode_)
        if len(image_sampleset) != 0:
          # concatenate the sample set list and the data loader list
          genuine_train_dataloader_dict.update(
            {(network_mode_, dataset[0], dataset[1], dataset[2]):
               albumentationDataset.data_loader(sample_set=image_sampleset, batch_size_=opt.batch_size,
                                        shuffle_=True, num_workers=opt.n_jobs_dataloader)})

          if pretrain_ is True:
            genuine_ae_train_dataloader_dict.update(
              {(network_mode_, dataset[0], dataset[1], dataset[2]):
                 albumentationDataset.data_loader(sample_set=image_sampleset, batch_size_=opt.ae_batch_size,
                                          shuffle_=True, num_workers=opt.ae_n_jobs_dataloader)})
          # pass the network to GPU (same as the dot operation)
          net = getattr(models, model_)()
          # group the network: dataset / printer / scanner / network
          net_dict.update({(network_mode_, dataset[0], dataset[1], dataset[2]): net})
        else:
          continue
  elif network_mode_ == mode_manager.NETWORK_MODE['TWO_CLASS']:
    'if training using both of the genuine and the recapture baseline images'
    # load the genuine training images
    for dataset, image_path in mode_manager.TRAIN_GENUINE_SAMPLE_SETS.items():
      if dataset[0] == dataset_:
        # initialize the image sample set
        genuine_image_sampleset = \
              albumentationDataset(root=opt.all_image_root_dir + '\\' + image_path,
                                   mode=mode_manager.MODES['TRAIN_GENUINE'],
                                   network_mode=network_mode_)
        if len(genuine_image_sampleset) != 0:
          # concatenate the sample set list and the data loader list
          genuine_train_dataset_dict.update({(network_mode_, dataset[0], dataset[1], dataset[2]): genuine_image_sampleset})
        else:
          continue

    # extract the dataset information
    # load the recapture training images
    for dataset, image_path in mode_manager.TRAIN_RECAPTURE_SAMPLE_SETS.items():
      # only consider the datasets corresponding to the genuiune image datasets.
      if (network_mode_, dataset[0], dataset[1], dataset[2]) in genuine_train_dataset_dict.keys():
        # initialize the image sample set
        recapture_image_sampleset = albumentationDataset(root=opt.all_image_root_dir + '/' + image_path,
                                                         mode=mode_manager.MODES['TRAIN_RECAPTURE'],
                                                         network_mode=network_mode_)
        # check whether the directory is empty
        if len(recapture_image_sampleset) != 0:
          # concatenate the sample set list and the data loader list
          recapture_train_dataset_dict.update(
            {(network_mode_, dataset[0], dataset[1], dataset[2]): recapture_image_sampleset})
          # create network model only when both genuine and recapture sample sets exist
          # pass the network to GPU
          net = getattr(models, model_)()
          # group the network: dataset / printer / scanner / network
          net_dict.update({(network_mode_, dataset[0], dataset[1], dataset[2]): net})
        else:
          continue

  # # load the data for validation
  # val_data = recapture_detection_dataset(opt.train_data_root, train=False)
  # val_loader = DataLoader(val_data, batch_size=opt.batch_size_1, shuffle=True, num_workers=opt.num_workers)

  ''' do the pre-training '''
  # this does not have effect on two-class DNN
  if pretrain_ is True:
    # for each sample set
    for dataloader_info, train_loader in genuine_ae_train_dataloader_dict.items():
      print(str(dataloader_info[0]) + ' \ ' + str(dataloader_info[1]) + ' \ ' +
            str(dataloader_info[2]) + ' \ ' + str(dataloader_info[3]))
      # the saved model path
      ae_save_model_path = opt.AE_dir + '/' + str(dataloader_info[0]) + '_' + \
                           str(dataloader_info[1]) + '_' + str(dataloader_info[2]) + '_' + str(dataloader_info[3]) + '.pt'
      # the saved model path
      save_model_path = opt.DNN_classifier_dir + '/' + str(dataloader_info[0]) + '_' + \
                        str(dataloader_info[1]) + '_' + str(dataloader_info[2]) + '_' + str(dataloader_info[3]) + '.pt'
      if path.exists(save_model_path):
        continue
      # don't train if already trained
      if path.exists(ae_save_model_path):
        # select the auto-encoder network
        ae_net = models.LeNet_Autoencoder()
        ae_net.load_state_dict(t.load(ae_save_model_path))
        # set device for network
        ae_net = ae_net.to(opt.ae_device)
        # testing to verify
        loss_epoch = 0.0
        n_batches = 0
        ae_net.eval()
        with t.no_grad():
          for input, _, _, _, _ in train_loader:
            input = input.to(opt.ae_device)
            output = ae_net(input)
            scores = t.sum((output - input) ** 2, dim=tuple(range(1, output.dim())))
            loss = t.mean(scores)
            loss_epoch += loss.item()
            n_batches += 1
        print('Test set Loss: {:.8f}'.format(loss_epoch / n_batches))
        ae_net = ae_net.to('cpu')
        # Initialize the Deep SVDD network weights from the encoder weights of the pretraining autoencoder.
        net_temp = net_dict[dataloader_info]
        net_param = net_temp.state_dict()
        # filter out decoder network keys
        ae_net_param = {k: v for k, v in ae_net.state_dict().items() if k in net_param}
        # overwrite values in the existing state_dict
        net_param.update(ae_net_param)
        net_temp.load_state_dict(net_param)
        # group the network: dataset / printer / scanner / network
        net_dict.update({dataloader_info: net_temp})
        del ae_net
      else:
        # select the auto-encoder network
        ae_net = models.LeNet_Autoencoder()
        # Set device for network
        ae_net = ae_net.to(opt.ae_device)
        # set optimizer (Adam optimizer for now)
        optimizer = t.optim.Adam(ae_net.parameters(), lr=opt.ae_lr,
                                 weight_decay=opt.ae_weight_decay,
                                 amsgrad=opt.ae_optimizer_name == 'amsgrad')
        # set learning rate scheduler
        scheduler = t.optim.lr_scheduler.MultiStepLR(optimizer, milestones=opt.ae_lr_milestones, gamma=opt.ae_gamma)
        # set to train mode
        ae_net.train()
        # process each epoch
        for epoch in range(opt.ae_n_epochs):
          loss_epoch = 0.0
          n_batches = 0
          for input, _, _, _, _ in train_loader:
            # read in the input image
            input = input.to(opt.ae_device)
            # zero the network parameter gradients
            optimizer.zero_grad()
            # update network parameters via backpropagation: forward + backward + optimize
            output = ae_net(input)
            # the scores is simply the difference between in and out ...
            scores = t.sum((output - input) ** 2, dim=tuple(range(1, output.dim())))
            loss = t.mean(scores)
            # backpropagation
            loss.backward()
            optimizer.step()
            loss_epoch += loss.item()
            n_batches += 1
          # step the schedular
          scheduler.step()
          # print('loss: %.2f' % loss + ' at epoch: %f' % (epoch / opt.ae_n_epochs))
          print('Epoch {}/{}\t Loss: {:.8f}'.format(epoch + 1, opt.ae_n_epochs, loss_epoch / n_batches))
        # set device for network to GPU
        ae_net = ae_net.to(opt.ae_device)
        # testing to verify
        loss_epoch = 0.0
        n_batches = 0
        ae_net.eval()
        with t.no_grad():
          for input, _, _, _, _ in train_loader:
            input = input.to(opt.ae_device)
            output = ae_net(input)
            scores = t.sum((output - input) ** 2, dim=tuple(range(1, output.dim())))
            loss = t.mean(scores)
            loss_epoch += loss.item()
            n_batches += 1
        print('Test set Loss: {:.8f}'.format(loss_epoch / n_batches))
        ae_net = ae_net.to('cpu')
        # Initialize the Deep SVDD network weights from the encoder weights of the pretraining autoencoder.
        net_temp = net_dict[dataloader_info]
        net_param = net_temp.state_dict()
        # filter out decoder network keys
        ae_net_param = {k: v for k, v in ae_net.state_dict().items() if k in net_param}
        # overwrite values in the existing state_dict
        net_param.update(ae_net_param)
        net_temp.load_state_dict(net_param)
        # group the network: dataset / printer / scanner / network
        net_dict.update({dataloader_info: net_temp})
        t.save(ae_net.state_dict(), ae_save_model_path)
        del ae_net

  ''' do the training '''
  # one class network
  if network_mode_ == mode_manager.NETWORK_MODE['ONE_CLASS']:
    " for one class network "
    # for each network to train
    for net_info, net in net_dict.items():
      print(str(net_info[0]) + ' \ ' + str(net_info[1]) + ' \ ' + str(net_info[2]) + ' \ ' + str(net_info[3]))
      # the saved model path
      save_model_path = opt.DNN_classifier_dir + '/' + str(net_info[0]) + '_' + \
                        str(net_info[1]) + '_' + str(net_info[2]) + '_' + str(net_info[3]) + '.pt'
      # the saved center path
      save_center_path = opt.DNN_SVDD_center_dir + '/' + str(net_info[0]) + '_' + \
                         str(net_info[1]) + '_' + str(net_info[2]) + '_' + str(net_info[3]) + '.pt'
      # don't save if already trained
      if path.exists(save_model_path):
        continue
      # load the train_loader
      train_loader = genuine_train_dataloader_dict[net_info]
      # set device for network
      net = net.to(opt.device)
      # set optimizer
      optimizer = t.optim.Adam(net.parameters(), lr=opt.lr, weight_decay=opt.weight_decay,
                               amsgrad=opt.optimizer_name == 'amsgrad')
      # set learning rate scheduler
      scheduler = t.optim.lr_scheduler.MultiStepLR(optimizer, milestones=opt.lr_milestones, gamma=opt.gamma)
      # set Deep SVDD parameters
      n_samples = 0
      c = t.zeros(net.rep_dim, device=opt.device)
      net.eval()  # set in evaluation mode
      eps = 0.1
      with t.no_grad():
        for data in train_loader:
          # get the inputs of the batch
          input_, _, _, _, _ = data
          output_ = net(input_.to(opt.device))
          n_samples += output_.shape[0]
          c += t.sum(output_, dim=0)
      c /= n_samples
      # if c_i is too close to 0, set to +-eps. Reason: a zero unit can be trivially matched with zero weights.
      c[(abs(c) < eps) & (c < 0)] = -eps
      c[(abs(c) < eps) & (c > 0)] = eps

      # do the training
      net.train()  # set in training mode
      # iterate through epochs
      for epoch in range(opt.n_epochs):
        loss_epoch = 0.0
        n_batches = 0
        for data in train_loader:
          input_, _, _, _, _ = data
          # zero the network parameter gradients
          optimizer.zero_grad()
          # update network parameters via backpropagation: forward + backward + optimize
          output_ = net(input_.to(opt.device))
          dist = t.sum((output_ - c) ** 2, dim=1)
          loss = t.mean(dist)
          loss.backward()
          optimizer.step()
          loss_epoch += loss.item()
          n_batches += 1
        # print('loss: %.2f' % loss + ' at epoch: %f' % (epoch / opt.n_epochs))
        scheduler.step()
        print('Epoch {}/{}\t Loss: {:.8f}'.format(epoch + 1, opt.n_epochs, loss_epoch / n_batches))
      # save the model
      t.save(net.state_dict(), save_model_path)
      t.save(c, save_center_path)
      # remove the trained network to save memory
      net = net.to('cpu')
  elif network_mode_ == mode_manager.NETWORK_MODE['TWO_CLASS']:
    ' for two class network '
    # for each network to train
    for net_info, net in net_dict.items():
      print(str(net_info[0]) + ' \ ' +
            str(net_info[1]) + ' \ ' +
            str(net_info[2]) + ' \ ' +
            str(net_info[3]) +
            ' numParams: ' + str(sum(p.numel() for p in net.parameters() if p.requires_grad)))
      # save the model
      save_model_path = opt.DNN_classifier_dir + '/' + str(net_info[0]) + '_' + \
                        str(net_info[1]) + '_' + str(net_info[2]) + '_' + str(net_info[3]) + '.pt'
      # continue if the model is already trained
      if path.exists(save_model_path):
        continue
      # merge the two datasets
      two_class_dataset = ConcatDataset([genuine_train_dataset_dict[net_info], recapture_train_dataset_dict[net_info]])
      # load the train_loader
      train_loader = albumentationDataset.data_loader(sample_set=two_class_dataset,
                                              batch_size_=opt.batch_size,
                                              shuffle_=True, num_workers=opt.n_jobs_dataloader)
      # set device for network
      net = net.to(opt.device)
      # set optimizer
      optimizer = net.get_optimizer(opt.lr, opt.weight_decay)  # optimizer
      # initialize accuracy
      best_acc = 0.5
      # initialize criterion as cross entropy
      criterion = nn.CrossEntropyLoss().cuda(opt.device)
      # initialize error metrics
      loss_meter = meter.AverageValueMeter()  # metrics
      confusion_matrix = meter.ConfusionMeter(2)  # confusion matrix
      previous_loss = 1e10  #
      loss = 1e10
      net.train()  # set in training mode
      lr = opt.lr
      # set learning rate scheduler
      scheduler = t.optim.lr_scheduler.MultiStepLR(optimizer, milestones=opt.lr_milestones, gamma=opt.gamma)
      # iterate through epochs
      for epoch in range(opt.n_epochs):
        # reset metrics
        loss_meter.reset()
        confusion_matrix.reset()
        # for each image from the train_loader
        for data, label, _, _, _ in train_loader:
          optimizer.zero_grad()
          # read in the training data and labels
          inputs_train, labels_trian = data.to(opt.device), label.to(opt.device)
          # forward + backward + optimize
          score = net(inputs_train)
          loss = criterion(score, labels_trian)
          loss.backward()
          optimizer.step()
          # add errors to metrics
          loss_meter.add(loss.item())
          confusion_matrix.add(score.detach(), labels_trian.detach())
        scheduler.step()
        print('loss: %.2f' % loss + ' at epoch: %f \n' % (epoch / opt.n_epochs))

        # # training accuracy
        # cm_accuracy = confusion_matrix.value()
        # train_accuracy = 100 * (cm_accuracy[0][0] + cm_accuracy[1][1]) / (cm_accuracy.sum())

        # # update the learning rate
        # if loss_meter.value()[0] > previous_loss:
        #   lr = lr * opt.lr_decay
        #   # 第二种降低学习率的方法:不会有moment等信息的丢失
        #   for param_group in optimizer.param_groups:
        #     param_group['lr'] = lr

        # update the loss
        previous_loss = loss_meter.value()[0]

      # save the model: 并未用到封装的 net
      t.save(net.state_dict(), save_model_path)
      del net
  # return the trained classifier path
  return


''' testing DNN '''
def test_DNN(mode_, model_, test_dataset_, network_mode_):
  ' if testing using the genuine baseline images only '
  if mode_ is mode_manager.MODES['TEST_GENUINE']:
    sample_set_dict = mode_manager.TEST_GENUINE_SAMPLE_SETS
    test_results_path = opt.test_result_DNN_dir + 'test_result_genuine_' + str(network_mode_) + '_' + str(test_dataset_) + '.csv'
  elif mode_ is mode_manager.MODES['TEST_RECAPTURE']:
    sample_set_dict = mode_manager.TEST_RECAPTURE_SAMPLE_SETS
    test_results_path = opt.test_result_DNN_dir + 'test_result_recapture_' + str(network_mode_) + '_' + str(test_dataset_) + '.csv'

  test_data_set_name_list = []
  soft_result_list = []
  doc_idx_list = []
  first_printer_name_list = []
  second_printer_name_list = []
  first_scanner_name_list = []
  second_scanner_name_list = []
  ' iterate through sample sets '
  for dataset, image_path in sample_set_dict.items():
    net_info = (network_mode_, dataset[0], dataset[1], dataset[2])
    # for the specific dataset: sample set 不分 one class 或 two class
    print(str(net_info[0]) + ' \ ' + str(net_info[1]) + ' \ ' + str(net_info[2]) + ' \ ' + str(net_info[3]))
    if net_info[1] == test_dataset_:
      # if it is the in wild test, then use the trained model from realistic experiment
      # actually, there is no need to train the wild case
      if test_dataset_ is mode_manager.DATA_SETS['SET 5']:
        net_trained_path = opt.DNN_classifier_dir + '/' + str(network_mode_) + '_' + \
                           str(mode_manager.DATA_SETS['SET 4']) + '_' + \
                           str(mode_manager.PRINTERS['ALL_PRINTERS']) + '_' + str(net_info[3]) + '.pt'
      else:
        net_trained_path = opt.DNN_classifier_dir + '/' + str(network_mode_) + '_' + \
                            str(net_info[1]) + '_' + str(net_info[2]) + '_' + str(net_info[3]) + '.pt'
      # the path for test images
      test_image_path = opt.all_image_root_dir + '/' + image_path
      # if the specific network is not trained, test images not exist, or the test results exist
      if not path.exists(net_trained_path) or not os.listdir(test_image_path) or path.exists(test_results_path):
        continue
      # get the image sample set
      test_data = albumentationDataset(root=test_image_path, mode=mode_, network_mode=network_mode_)
      # from the sample set, get the image loader
      test_loader = albumentationDataset.data_loader(sample_set=test_data,
                                                     batch_size_=opt.batch_size,
                                                     shuffle_=True, num_workers=opt.n_jobs_dataloader)
      # load the trained model parameters
      net = getattr(models, model_)()

      net.load_state_dict(t.load(net_trained_path))
      # net = nn.DataParallel(net, device_ids=[0])
      net = net.to(opt.device)
      net.eval()  # set to evaluation mode

      idx_label_score = []
      test_data_set_name = str(net_info[1]) + '_' + str(net_info[2]) + '_' + str(net_info[3])
      # do testing: process each image block (only soft scores are available now)
      for imgs_read, labels, \
          first_printer_names, second_printer_names, \
          first_scanner_names, second_scanner_names, doc_idx in test_loader:
        # send to gpu
        imgs_read = imgs_read.to(opt.device)
        # evaluate the network
        outputs = net(imgs_read)
        if network_mode_ == mode_manager.NETWORK_MODE['ONE_CLASS']:
          if test_dataset_ is mode_manager.DATA_SETS['SET 5']:
            save_center_path = opt.DNN_SVDD_center_dir + '/' + str(net_info[0]) + '_' + \
                               str(mode_manager.DATA_SETS['SET 4']) + '_' + \
                               str(mode_manager.PRINTERS['ALL_PRINTERS']) + '_' + str(net_info[3]) + '.pt'
          else:
            save_center_path = opt.DNN_SVDD_center_dir + '/' + str(net_info[0]) + '_' + \
                               str(net_info[1]) + '_' + str(net_info[2]) + '_' + str(net_info[3]) + '.pt'
          c = t.load(save_center_path)
          scores = t.sum((outputs - c) ** 2, dim=1).detach().tolist()
        elif network_mode_ == mode_manager.NETWORK_MODE['TWO_CLASS']:
          # score for Two Class DNN
          scores = t.softmax(outputs.data, dim=1)[:, 1].detach().tolist()
        ''' group the image blocks '''
        idx_label_score += list(zip(doc_idx.cpu().data.numpy().tolist(),
                                    labels.cpu().data.numpy().tolist(),
                                    list(first_printer_names),
                                    list(second_printer_names),
                                    list(first_scanner_names),
                                    list(second_scanner_names),
                                    scores))
      ''' accumulate the errors of each sample set: using the major voting. '''
      # the first four columns containing the image information
      idx_label_score = np.array(idx_label_score)
      doc_info = idx_label_score[:, :6]
      test_result_soft = idx_label_score[:, 6].astype(float)
      doc_info_unique = np.unique(doc_info, axis=0)

      # for each document image
      for i in range(0, len(doc_info_unique)):
        doc_idx_idx = np.where(np.all(doc_info == doc_info_unique[i], axis=1))[0]
        # accumulate the test results
        soft_result_list = soft_result_list + [statistics.median(test_result_soft[doc_idx_idx].tolist())]
        test_data_set_name_list = test_data_set_name_list + [test_data_set_name]
        doc_idx_list = doc_idx_list + [doc_info_unique[i][0]]
        first_printer_name_list = first_printer_name_list + [doc_info_unique[i][2]]
        second_printer_name_list = second_printer_name_list + [doc_info_unique[i][3]]
        first_scanner_name_list = first_scanner_name_list + [doc_info_unique[i][4]]
        second_scanner_name_list = second_scanner_name_list + [doc_info_unique[i][5]]
  if not path.exists(test_results_path):
    # save the results
    batch_result = [(a, b, c, d, e, f, g) for
                    a, b, c, d, e, f, g in
                    zip(test_data_set_name_list, doc_idx_list,
                        first_printer_name_list, second_printer_name_list,
                        first_scanner_name_list, second_scanner_name_list, soft_result_list)]
    write_csv(batch_result, test_results_path)
  return

'''  validation DNN (not used for now) '''
def validate_DNN(model, dataloader):
  # change to eval mode
  model.eval()
  # construct separate confusion matrix
  confusion_matrix = meter.ConfusionMeter(2)
  # for each sample
  for ii, (val_input, label) in enumerate(dataloader):
    val_input = val_input.to(opt.device)
    label = label.to(opt.device)
    score = model(val_input)  # is the detach necessary
    confusion_matrix.add(score.detach().squeeze(), label.type(t.LongTensor))

  # change back to train mode
  model.train()

  # calculate accuracy
  cm_value = confusion_matrix.value()
  accuracy = 100 * (cm_value[0][0] + cm_value[1][1]) / (cm_value.sum())
  return confusion_matrix, accuracy


''' train SVM: dataset does not distinguish one-class or two-class classifier '''
def train_SVM(data_set, svm_type, feature_set_train, debug_mode):
  # assign the classifier based on the types
  if svm_type == 'one_class_svm':
    svm_class_SVM_ = one_class_SVM()
  elif svm_type == 'two_class_svm':
    svm_class_SVM_ = two_class_SVM()
  # train the SVM: each sample set has one classifier trained
  for sample_set, sample_set_path in mode_manager.TRAIN_GENUINE_SAMPLE_SETS.items():
    if sample_set[0] == data_set:
      if svm_type == 'one_class_svm':
        # load in the features
        feature_dataset_name = opt.LBP_feature_dir + \
                               feature_set_train['genuine'] + str(sample_set[0]) + '_' + str(sample_set[1]) + '_' + \
                               str(sample_set[2]) + '.txt'
        # if the LBP data exists
        if path.exists(feature_dataset_name):
          # load the training data features
          train_data_features = pickle.load(open(feature_dataset_name, 'rb'))
          # train the svm classifier
          svm_class_SVM_.train_classifer(input_train_data=train_data_features[:, 4:], sample_set=sample_set, opt=opt)

          if debug_mode is True:
            # plot histogram for debugging
            x_bins = np.arange(0, train_data_features.shape[1] - 4, 1)
            fig = plt.figure(figsize=(18, 7))
            plt.bar(x_bins, train_data_features[100, 4:], color='black')
            plt.ylim(top=0.3, bottom=0)
            plt.xticks(np.arange(0, x_bins.max() + 1, step=10))
            plt.show()
        else:
          continue
      elif svm_type == 'two_class_svm':
        # load in the genuine features (not necessarily LBP)
        feature_dataset_name_genuine = opt.LBP_feature_dir + \
                                       feature_set_train['genuine'] + str(sample_set[0]) + '_' + \
                                       str(sample_set[1]) + '_' + str(sample_set[2]) + '.txt'
        # load in the recaptured features (not necessarily LBP)
        feature_dataset_name_recapture = opt.LBP_feature_dir + \
                                         feature_set_train['recapture'] + str(sample_set[0]) + '_' + \
                                         str(sample_set[1]) + '_' + str(sample_set[2]) + '.txt'
        # proceed only when both of the genuine and the recaptured features exist
        if path.exists(feature_dataset_name_genuine) and path.exists(feature_dataset_name_recapture):
          # load in the feature data
          train_data_features_genuine = pickle.load(open(feature_dataset_name_genuine, 'rb'))
          train_data_features_recapture = pickle.load(open(feature_dataset_name_recapture, 'rb'))
          # concatenate the genuine and the recaptured training data
          train_data_features = np.r_[train_data_features_genuine, train_data_features_recapture]
          # train the svm classifier
          svm_class_SVM_.train_classifer(input_train_data=train_data_features[:, 4:],
                                         input_train_label=train_data_features[:, 3],
                                         sample_set=sample_set, opt=opt)
        # if there is no genuine and recapture images for training, continue
        else:
          continue

''' test SVM  '''
def test_SVM(test_mode, test_data_set, feature_set_test, svm_type, debug_mode, **kwargs):
  opt._parse(kwargs)

  # initialize svm classifiers
  if svm_type == 'one_class_svm':
    svm_class_SVM_ = one_class_SVM()
  elif svm_type == 'two_class_svm':
    svm_class_SVM_ = two_class_SVM()

  count_, total_ = 0, 0
  accu_list = []
  data_set_name_list = []
  doc_idx_list = []
  label_hard_result = []
  label_soft_result = []
  printer_1_list = []
  printer_2_list = []
  scanner_1_list = []
  scanner_2_list = []
  # 测试合法文档图像
  if test_mode == mode_manager.MODES['TEST_GENUINE']:
    # initialize the test image dataset
    '''  iterate through genuine test image datasets '''
    for sample_set, _ in mode_manager.TEST_GENUINE_SAMPLE_SETS.items():
      data_set_name = str(sample_set[0]) + '_' + str(sample_set[1]) + '_' + str(sample_set[2])
      if sample_set[0] == test_data_set:
        # load in the LBP
        test_feature_name = \
          opt.LBP_feature_dir + feature_set_test['genuine'] + str(sample_set[0]) + \
          '_' + str(sample_set[1]) + '_' + str(sample_set[2]) + '.txt'
        print('testing: ' + test_feature_name)
        # if the LBP exist, read in the LBP file
        try:
          # load the LBP features
          test_data_features = pickle.load(open(test_feature_name, 'rb'))
          # if debug_mode is True:
          #   # plot histogram for debugging
          #   x_bins = np.arange(0, test_data_features.shape[1] - 5, 1)
          #   fig = plt.figure(figsize=(18, 7))
          #   plt.bar(x_bins, test_data_features[1200, 5:], color='black')
          #   plt.ylim(top=0.3, bottom=0)
          #   plt.xticks(np.arange(0, x_bins.max() + 1, step=10))
          #   plt.show()
        # if the LBP does not exist, extract the LBP from the image
        except:
          print('test_data_features does not exist')
          continue

        # for test images, set the trained classifiers for set 4
        if sample_set[0] is mode_manager.DATA_SETS['SET 5']:
          sample_set_classifier = (mode_manager.DATA_SETS['SET 4'], mode_manager.PRINTERS['ALL_PRINTERS'], sample_set[2])
        else:
          sample_set_classifier = sample_set

        # for two class SVM
        if svm_type == 'two_class_svm':
          if path.exists(opt.SVM_classifier_dir +
                         'trained_two_class_SVM_' + str(sample_set_classifier[0]) +
                         '_' + str(sample_set_classifier[1]) + '_' + str(sample_set_classifier[2]) + '.obj'):
            test_result_label, test_result_label_soft = \
              svm_class_SVM_.test_classifier(test_data_features[:, 7:], sample_set_classifier, opt)
          else:
            continue
        # for one class SVM
        elif svm_type == 'one_class_svm':
          test_result_label, test_result_label_soft = \
            svm_class_SVM_.test_classifier(test_data_features[:, 7:], sample_set_classifier, opt)

        ''' accumulate the errors of each sample set: using the major voting. '''
        # the first four columns containing the image information
        doc_info_matrix = test_data_features[:, 0:7].astype(int)
        doc_info_matrix_unique = np.unique(doc_info_matrix, axis=0).astype(int)
        count_doc_, total_doc_ = 0, 0
        for i in range(0, len(doc_info_matrix_unique)):
          doc_idx_idx = np.where(np.all(doc_info_matrix == doc_info_matrix_unique[i], axis=1))[0]
          a = test_result_label[doc_idx_idx]
          if len(a[a == 1]) >= len(a[a == -1]):
            count_doc_ += 1
            label_hard_result = label_hard_result + [1]
          else:
            label_hard_result = label_hard_result + [-1]
          total_doc_ += 1
          # accumulate the test results
          label_soft_result = label_soft_result + [statistics.median(test_result_label_soft[doc_idx_idx].tolist())]
          data_set_name_list = data_set_name_list + [data_set_name]
          doc_idx_list = doc_idx_list + [doc_info_matrix_unique[i][-2]]
          printer_1_list = printer_1_list + [doc_info_matrix_unique[i][1]]
          scanner_1_list = scanner_1_list + [doc_info_matrix_unique[i][2]]
          printer_2_list = printer_2_list + [doc_info_matrix_unique[i][3]]
          scanner_2_list = scanner_2_list + [doc_info_matrix_unique[i][4]]

        # 图像块准确度
        print('Genuine 文档图像块准确度: ' + str(len(test_result_label[test_result_label == 1]) / len(test_result_label)))
        # 文档图像准确度
        print('Genuine 文档图像准确度（majority voting）: ' + str(count_doc_ / total_doc_))

        # accumulate the cross-dataset counts
        accu_list = accu_list + [count_doc_ / total_doc_]
        count_ += count_doc_
        total_ += total_doc_
    # store in csv
    batch_result_label = \
      [(a, b, c, d, e, f, g) for a, b, c, d, e, f, g in
       zip(data_set_name_list, doc_idx_list,
           printer_1_list, scanner_1_list, printer_2_list, scanner_2_list, label_soft_result)]
    write_csv(batch_result_label,
              opt.test_result_SVM_dir + 'test_result_genuine_' + str(test_data_set) + '_' + svm_type + '.csv')
    # 跨库文档图像 准确度
    print('Genuine 跨库文档图像准确度（majority voting）: ' + str(count_ / total_))

  # 测试翻拍文档图像
  elif test_mode == mode_manager.MODES['TEST_RECAPTURE']:
    '''  iterate through recapture test image datasets '''
    for sample_set, sample_set_path in mode_manager.TEST_RECAPTURE_SAMPLE_SETS.items():
      data_set_name = str(sample_set[0]) + '_' + str(sample_set[1]) + '_' + str(sample_set[2])
      if sample_set[0] == test_data_set:
        # load in the LBP
        test_feature_name = opt.LBP_feature_dir + \
                            feature_set_test['recapture'] + \
                            str(sample_set[0]) + '_' + str(sample_set[1]) + '_' + \
                            str(sample_set[2]) + '.txt'

        print('testing: ' + test_feature_name)
        # if the LBP exist, read in
        try:
          # load the LBP features
          test_data_features = pickle.load(open(test_feature_name, 'rb'))
          if debug_mode is True:
            # plot histogram for debugging
            x_bins = np.arange(0, test_data_features.shape[1] - 5, 1)
            fig = plt.figure(figsize=(18, 7))
            plt.bar(x_bins, test_data_features[1000, 5:], color='black')
            plt.ylim(top=0.3, bottom=0)
            plt.xticks(np.arange(0, x_bins.max() + 1, step=10))
            plt.show()
        # if the LBP does not exist, extract the LBP from the image
        except:
          print('test_data_features does not exist')
          continue

        # for test images, set the trained classifiers for set 4
        if sample_set[0] is mode_manager.DATA_SETS['SET 5']:
          sample_set_classifier = (mode_manager.DATA_SETS['SET 4'], mode_manager.PRINTERS['ALL_PRINTERS'], sample_set[2])
        else:
          sample_set_classifier = sample_set

        # for two class svm
        if svm_type == 'two_class_svm':
          if path.exists(opt.SVM_classifier_dir +
                         'trained_two_class_SVM_' + str(sample_set_classifier[0]) +
                         '_' + str(sample_set_classifier[1]) + '_' + str(sample_set_classifier[2]) + '.obj'):
            # test the data set using the trained classifier
            test_result_label, test_result_label_soft = \
              svm_class_SVM_.test_classifier(test_data_features[:, 7:], sample_set_classifier, opt)
          else:
            continue
        # for one class svm
        else:
          # test the data set using the trained classifier
          test_result_label, test_result_label_soft = \
            svm_class_SVM_.test_classifier(test_data_features[:, 7:], sample_set_classifier, opt)

        ''' accumulate the errors of each sample set: using the major voting. '''
        # the first four columns containing the image information
        doc_info_matrix = test_data_features[:, 0:7].astype(int)
        doc_info_matrix_unique = np.unique(doc_info_matrix, axis=0).astype(int)
        count_doc_, total_doc_ = 0, 0
        for i in range(0, len(doc_info_matrix_unique)):
          doc_idx_idx = np.where(np.all(doc_info_matrix == doc_info_matrix_unique[i], axis=1))[0]
          a = test_result_label[doc_idx_idx]
          if len(a[a == -1]) >= len(a[a == 1]):
            count_doc_ += 1
            label_hard_result = label_hard_result + [-1]
          else:
            label_hard_result = label_hard_result + [1]
          total_doc_ += 1
          # accumulate the test results
          label_soft_result = label_soft_result + [statistics.median(test_result_label_soft[doc_idx_idx].tolist())]
          data_set_name_list = data_set_name_list + [data_set_name]
          doc_idx_list = doc_idx_list + [doc_info_matrix_unique[i][-2]]
          printer_1_list = printer_1_list + [doc_info_matrix_unique[i][1]]
          scanner_1_list = scanner_1_list + [doc_info_matrix_unique[i][2]]
          printer_2_list = printer_2_list + [doc_info_matrix_unique[i][3]]
          scanner_2_list = scanner_2_list + [doc_info_matrix_unique[i][4]]

        # 图像块准确度
        print('Recapture 文档图像块准确度: ' + str(len(test_result_label[test_result_label == -1]) / len(test_result_label)))
        # 文档图像准确度
        print('Recapture 文档图像准确度（majority voting）: ' + str(count_doc_ / total_doc_))

        # accumulate the test results
        accu_list = accu_list + [count_doc_ / total_doc_]
        # accumulate the cross-dataset counts
        count_ += count_doc_
        total_ += total_doc_

    # store in csv
    batch_result_label = \
      [(a, b, c, d, e, f, g) for a, b, c, d, e, f, g in
       zip(data_set_name_list, doc_idx_list,
           printer_1_list, scanner_1_list, printer_2_list, scanner_2_list, label_soft_result)]
    write_csv(batch_result_label,
              opt.test_result_SVM_dir + 'test_result_recapture_' + str(test_data_set) + '_' + svm_type + '.csv')

    # 跨库文档图像 准确度
    print('Recapture 跨库文档图像准确度（majority voting）: ' + str(count_ / total_))

# write csv
def write_csv(results, file_name):
  import csv
  with open(file_name, 'w', newline='') as f:
    writer = csv.writer(f)
    # writer.writerow(['id', 'label'])
    writer.writerows(results)

def main():

  two_class_network_name = 'ResNet50'

  # # extract LBP features
  # LBP_extractor_ = LBP_extractor()
  #
  # do feature extraction
  # LBP_extractor_.LBP_Extraction(opt=opt,
  #                               feature_set_train=mode_manager.FEATURE_SETS['LBP_train'],
  #                               feature_set_test=mode_manager.FEATURE_SETS['LBP_test'],
  #                               data_set=mode_manager.DATA_SETS['SET 1'])
  # LBP_extractor_.LBP_Extraction(opt=opt,
  #                               feature_set_train=mode_manager.FEATURE_SETS['LBP_train'],
  #                               feature_set_test=mode_manager.FEATURE_SETS['LBP_test'],
  #                               data_set=mode_manager.DATA_SETS['SET 2'])
  # LBP_extractor_.LBP_Extraction(opt=opt,
  #                               feature_set_train=mode_manager.FEATURE_SETS['LBP_train'],
  #                               feature_set_test=mode_manager.FEATURE_SETS['LBP_test'],
  #                               data_set=mode_manager.DATA_SETS['SET 3'])
  # LBP_extractor_.LBP_Extraction(opt=opt,
  #                               feature_set_train=mode_manager.FEATURE_SETS['LBP_train'],
  #                               feature_set_test=mode_manager.FEATURE_SETS['LBP_test'],
  #                               data_set=mode_manager.DATA_SETS['SET 4'])
  # LBP_extractor_.LBP_Extraction(opt=opt,
  #                               feature_set_train=mode_manager.FEATURE_SETS['LBP_train'],
  #                               feature_set_test=mode_manager.FEATURE_SETS['LBP_test'],
  #                               data_set=mode_manager.DATA_SETS['SET 5'])

  'train one class SVM'
  train_SVM(data_set=mode_manager.DATA_SETS['SET 1'],
            svm_type='one_class_svm', feature_set_train=mode_manager.FEATURE_SETS['LBP_train'], debug_mode=False)
  train_SVM(data_set=mode_manager.DATA_SETS['SET 2'],
            svm_type='one_class_svm', feature_set_train=mode_manager.FEATURE_SETS['LBP_train'], debug_mode=False)
  train_SVM(data_set=mode_manager.DATA_SETS['SET 3'],
            svm_type='one_class_svm', feature_set_train=mode_manager.FEATURE_SETS['LBP_train'], debug_mode=False)
  train_SVM(data_set=mode_manager.DATA_SETS['SET 4'],
            svm_type='one_class_svm', feature_set_train=mode_manager.FEATURE_SETS['LBP_train'], debug_mode=False)
  #
  # 'train two class SVM'
  # train_SVM(data_set=mode_manager.DATA_SETS['SET 1'],
  #           svm_type='two_class_svm', feature_set_train=mode_manager.FEATURE_SETS['LBP_train'], debug_mode=False)
  # train_SVM(data_set=mode_manager.DATA_SETS['SET 2'],
  #           svm_type='two_class_svm', feature_set_train=mode_manager.FEATURE_SETS['LBP_train'], debug_mode=False)
  # train_SVM(data_set=mode_manager.DATA_SETS['SET 3'],
  #           svm_type='two_class_svm', feature_set_train=mode_manager.FEATURE_SETS['LBP_train'], debug_mode=False)
  # train_SVM(data_set=mode_manager.DATA_SETS['SET 4'],
  #           svm_type='two_class_svm', feature_set_train=mode_manager.FEATURE_SETS['LBP_train'], debug_mode=False)
  #
  
  # 'test one-class svm'
  # # test genuine
  # test_SVM(test_mode=mode_manager.MODES['TEST_GENUINE'], test_data_set=mode_manager.DATA_SETS['SET 1'],
  #          feature_set_test=mode_manager.FEATURE_SETS['LBP_test'], svm_type='one_class_svm', debug_mode=False)
  # test_SVM(test_mode=mode_manager.MODES['TEST_GENUINE'], test_data_set=mode_manager.DATA_SETS['SET 2'],
  #          feature_set_test=mode_manager.FEATURE_SETS['LBP_test'], svm_type='one_class_svm', debug_mode=False)
  # test_SVM(test_mode=mode_manager.MODES['TEST_GENUINE'], test_data_set=mode_manager.DATA_SETS['SET 3'],
  #          feature_set_test=mode_manager.FEATURE_SETS['LBP_test'], svm_type='one_class_svm', debug_mode=False)
  # test_SVM(test_mode=mode_manager.MODES['TEST_GENUINE'], test_data_set=mode_manager.DATA_SETS['SET 4'],
  #          feature_set_test=mode_manager.FEATURE_SETS['LBP_test'], svm_type='one_class_svm', debug_mode=False)
  # test_SVM(test_mode=mode_manager.MODES['TEST_GENUINE'], test_data_set=mode_manager.DATA_SETS['SET 5'],
  #          feature_set_test=mode_manager.FEATURE_SETS['LBP_test'], svm_type='one_class_svm', debug_mode=False)

  # # test recaptured
  # test_SVM(test_mode=mode_manager.MODES['TEST_RECAPTURE'], test_data_set=mode_manager.DATA_SETS['SET 1'],
  #          feature_set_test=mode_manager.FEATURE_SETS['LBP_test'], svm_type='one_class_svm', debug_mode=False)
  # test_SVM(test_mode=mode_manager.MODES['TEST_RECAPTURE'], test_data_set=mode_manager.DATA_SETS['SET 2'],
  #          feature_set_test=mode_manager.FEATURE_SETS['LBP_test'], svm_type='one_class_svm', debug_mode=False)
  # test_SVM(test_mode=mode_manager.MODES['TEST_RECAPTURE'], test_data_set=mode_manager.DATA_SETS['SET 3'],
  #          feature_set_test=mode_manager.FEATURE_SETS['LBP_test'], svm_type='one_class_svm', debug_mode=False)
  # test_SVM(test_mode=mode_manager.MODES['TEST_RECAPTURE'], test_data_set=mode_manager.DATA_SETS['SET 4'],
  #          feature_set_test=mode_manager.FEATURE_SETS['LBP_test'], svm_type='one_class_svm', debug_mode=False)
  # test_SVM(test_mode=mode_manager.MODES['TEST_RECAPTURE'], test_data_set=mode_manager.DATA_SETS['SET 5'],
  #          feature_set_test=mode_manager.FEATURE_SETS['LBP_test'], svm_type='one_class_svm', debug_mode=False)
  #
  # 'test two-class svm'
  # test_SVM(test_mode=mode_manager.MODES['TEST_GENUINE'], test_data_set=mode_manager.DATA_SETS['SET 1'],
  #          feature_set_test=mode_manager.FEATURE_SETS['LBP_test'], svm_type='two_class_svm', debug_mode=False)
  # test_SVM(test_mode=mode_manager.MODES['TEST_GENUINE'], test_data_set=mode_manager.DATA_SETS['SET 2'],
  #          feature_set_test=mode_manager.FEATURE_SETS['LBP_test'], svm_type='two_class_svm', debug_mode=False)
  # test_SVM(test_mode=mode_manager.MODES['TEST_GENUINE'], test_data_set=mode_manager.DATA_SETS['SET 3'],
  #          feature_set_test=mode_manager.FEATURE_SETS['LBP_test'], svm_type='two_class_svm', debug_mode=False)
  # test_SVM(test_mode=mode_manager.MODES['TEST_GENUINE'], test_data_set=mode_manager.DATA_SETS['SET 4'],
  #          feature_set_test=mode_manager.FEATURE_SETS['LBP_test'], svm_type='two_class_svm', debug_mode=False)
  # test_SVM(test_mode=mode_manager.MODES['TEST_GENUINE'], test_data_set=mode_manager.DATA_SETS['SET 5'],
  #          feature_set_test=mode_manager.FEATURE_SETS['LBP_test'], svm_type='two_class_svm', debug_mode=False)
  #
  # test_SVM(test_mode=mode_manager.MODES['TEST_RECAPTURE'], test_data_set=mode_manager.DATA_SETS['SET 1'],
  #          feature_set_test=mode_manager.FEATURE_SETS['LBP_test'], svm_type='two_class_svm', debug_mode=False)
  # test_SVM(test_mode=mode_manager.MODES['TEST_RECAPTURE'], test_data_set=mode_manager.DATA_SETS['SET 2'],
  #          feature_set_test=mode_manager.FEATURE_SETS['LBP_test'], svm_type='two_class_svm', debug_mode=False)
  # test_SVM(test_mode=mode_manager.MODES['TEST_RECAPTURE'], test_data_set=mode_manager.DATA_SETS['SET 3'],
  #          feature_set_test=mode_manager.FEATURE_SETS['LBP_test'], svm_type='two_class_svm', debug_mode=False)
  # test_SVM(test_mode=mode_manager.MODES['TEST_RECAPTURE'], test_data_set=mode_manager.DATA_SETS['SET 4'],
  #          feature_set_test=mode_manager.FEATURE_SETS['LBP_test'], svm_type='two_class_svm', debug_mode=False)
  # test_SVM(test_mode=mode_manager.MODES['TEST_RECAPTURE'], test_data_set=mode_manager.DATA_SETS['SET 5'],
  #          feature_set_test=mode_manager.FEATURE_SETS['LBP_test'], svm_type='two_class_svm', debug_mode=False)

  ' train one-class network '
  train_DNN(model_='LeNet', dataset_=mode_manager.DATA_SETS['SET 1'],
            network_mode_=mode_manager.NETWORK_MODE['ONE_CLASS'], pretrain_=True)
  train_DNN(model_='LeNet', dataset_=mode_manager.DATA_SETS['SET 2'],
            network_mode_=mode_manager.NETWORK_MODE['ONE_CLASS'], pretrain_=True)
  train_DNN(model_='LeNet', dataset_=mode_manager.DATA_SETS['SET 3'],
            network_mode_=mode_manager.NETWORK_MODE['ONE_CLASS'], pretrain_=True)
  train_DNN(model_='LeNet', dataset_=mode_manager.DATA_SETS['SET 4'],
            network_mode_=mode_manager.NETWORK_MODE['ONE_CLASS'], pretrain_=True)

  # ' test one-class network: results are written in csv file '
  # test_DNN(mode_=mode_manager.MODES['TEST_GENUINE'], model_='LeNet',
  #          test_dataset_=mode_manager.DATA_SETS['SET 1'], network_mode_=mode_manager.NETWORK_MODE['ONE_CLASS'])
  # test_DNN(mode_=mode_manager.MODES['TEST_GENUINE'], model_='LeNet',
  #          test_dataset_=mode_manager.DATA_SETS['SET 2'], network_mode_=mode_manager.NETWORK_MODE['ONE_CLASS'])
  # test_DNN(mode_=mode_manager.MODES['TEST_GENUINE'], model_='LeNet',
  #          test_dataset_=mode_manager.DATA_SETS['SET 3'], network_mode_=mode_manager.NETWORK_MODE['ONE_CLASS'])
  # test_DNN(mode_=mode_manager.MODES['TEST_GENUINE'], model_='LeNet',
  #          test_dataset_=mode_manager.DATA_SETS['SET 4'], network_mode_=mode_manager.NETWORK_MODE['ONE_CLASS'])
  # test_DNN(mode_=mode_manager.MODES['TEST_GENUINE'], model_='LeNet',
  #          test_dataset_=mode_manager.DATA_SETS['SET 5'], network_mode_=mode_manager.NETWORK_MODE['ONE_CLASS'])
  #
  # test_DNN(mode_=mode_manager.MODES['TEST_RECAPTURE'], model_='LeNet',
  #          test_dataset_=mode_manager.DATA_SETS['SET 1'], network_mode_=mode_manager.NETWORK_MODE['ONE_CLASS'])
  # test_DNN(mode_=mode_manager.MODES['TEST_RECAPTURE'], model_='LeNet',
  #          test_dataset_=mode_manager.DATA_SETS['SET 2'], network_mode_=mode_manager.NETWORK_MODE['ONE_CLASS'])
  # test_DNN(mode_=mode_manager.MODES['TEST_RECAPTURE'], model_='LeNet',
  #          test_dataset_=mode_manager.DATA_SETS['SET 3'], network_mode_=mode_manager.NETWORK_MODE['ONE_CLASS'])
  # test_DNN(mode_=mode_manager.MODES['TEST_RECAPTURE'], model_='LeNet',
  #          test_dataset_=mode_manager.DATA_SETS['SET 4'], network_mode_=mode_manager.NETWORK_MODE['ONE_CLASS'])
  # test_DNN(mode_=mode_manager.MODES['TEST_RECAPTURE'], model_='LeNet',
  #          test_dataset_=mode_manager.DATA_SETS['SET 5'], network_mode_=mode_manager.NETWORK_MODE['ONE_CLASS'])

  ' train two-class network '
  train_DNN(model_=two_class_network_name, dataset_=mode_manager.DATA_SETS['SET 1'],
            network_mode_=mode_manager.NETWORK_MODE['TWO_CLASS'], pretrain_=True)
  train_DNN(model_=two_class_network_name, dataset_=mode_manager.DATA_SETS['SET 2'],
            network_mode_=mode_manager.NETWORK_MODE['TWO_CLASS'], pretrain_=True)
  train_DNN(model_=two_class_network_name, dataset_=mode_manager.DATA_SETS['SET 3'],
            network_mode_=mode_manager.NETWORK_MODE['TWO_CLASS'], pretrain_=True)
  train_DNN(model_=two_class_network_name, dataset_=mode_manager.DATA_SETS['SET 4'],
            network_mode_=mode_manager.NETWORK_MODE['TWO_CLASS'], pretrain_=True)

  # ' test two class network: results are written in csv file '
  # test_DNN(mode_=mode_manager.MODES['TEST_GENUINE'], model_=two_class_network_name,
  #          test_dataset_=mode_manager.DATA_SETS['SET 1'], network_mode_=mode_manager.NETWORK_MODE['TWO_CLASS'])
  # test_DNN(mode_=mode_manager.MODES['TEST_GENUINE'], model_=two_class_network_name,
  #          test_dataset_=mode_manager.DATA_SETS['SET 2'], network_mode_=mode_manager.NETWORK_MODE['TWO_CLASS'])
  # test_DNN(mode_=mode_manager.MODES['TEST_GENUINE'], model_=two_class_network_name,
  #          test_dataset_=mode_manager.DATA_SETS['SET 3'], network_mode_=mode_manager.NETWORK_MODE['TWO_CLASS'])
  # test_DNN(mode_=mode_manager.MODES['TEST_GENUINE'], model_=two_class_network_name,
  #          test_dataset_=mode_manager.DATA_SETS['SET 4'], network_mode_=mode_manager.NETWORK_MODE['TWO_CLASS'])
  # test_DNN(mode_=mode_manager.MODES['TEST_GENUINE'], model_=two_class_network_name,
  #          test_dataset_=mode_manager.DATA_SETS['SET 5'], network_mode_=mode_manager.NETWORK_MODE['TWO_CLASS'])

  # test_DNN(mode_=mode_manager.MODES['TEST_RECAPTURE'], model_=two_class_network_name,
  #          test_dataset_=mode_manager.DATA_SETS['SET 1'], network_mode_=mode_manager.NETWORK_MODE['TWO_CLASS'])
  # test_DNN(mode_=mode_manager.MODES['TEST_RECAPTURE'], model_=two_class_network_name,
  #          test_dataset_=mode_manager.DATA_SETS['SET 2'], network_mode_=mode_manager.NETWORK_MODE['TWO_CLASS'])
  # test_DNN(mode_=mode_manager.MODES['TEST_RECAPTURE'], model_=two_class_network_name,
  #          test_dataset_=mode_manager.DATA_SETS['SET 3'], network_mode_=mode_manager.NETWORK_MODE['TWO_CLASS'])
  # test_DNN(mode_=mode_manager.MODES['TEST_RECAPTURE'], model_=two_class_network_name,
  #          test_dataset_=mode_manager.DATA_SETS['SET 4'], network_mode_=mode_manager.NETWORK_MODE['TWO_CLASS'])
  # test_DNN(mode_=mode_manager.MODES['TEST_RECAPTURE'], model_=two_class_network_name,
  #          test_dataset_=mode_manager.DATA_SETS['SET 5'], network_mode_=mode_manager.NETWORK_MODE['TWO_CLASS'])

if __name__ == '__main__':
  opt = Config()
  main()
