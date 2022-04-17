import os
import random
import torch
import numpy as np

from PIL import Image
from torchvision.transforms import transforms as T
from config import Config
from .dataset_preprocessing import get_target_label_idx, global_contrast_normalization
from torch.utils.data import DataLoader
from torch.utils.data import dataset
from utils.image_loader import image_loader
from utils.mode_manager import mode_manager

# 对于 torch data 的封装
class base_dataset(dataset.Dataset):

	# constructor
	def __init__(self, root: str, mode: mode_manager.MODES, network_mode, transforms=None):
		super().__init__()

		# root path to image
		self.root = root

		# 加载路径
		self.imgs_path = [os.path.join(root, img) for img in os.listdir(root)]
		random.shuffle(self.imgs_path)

		# initialize the image_loader object: this is important !
		self.image_loader = image_loader(mode_manager(mode=mode), network_mode_=network_mode)
		self.mode = mode
		self.network_mode = network_mode

		# apply the transformation to the input image
		if transforms is None:

			# for testing
			if self.mode == mode_manager.MODES['TRAIN_GENUINE'] or self.mode == mode_manager.MODES['TRAIN_RECAPTURE']:

				# # the composition of transforms
				# self.transforms = T.Compose([
				#   T.Resize(224),  # ???
				#   T.CenterCrop(224),
				#   T.RandomHorizontalFlip(),  # 以0.5的概率进行水平翻转
				#   # T.RandomRotation(45),
				#   # T.ColorJitter(brightness=1), #随机从0-2 之间亮度变化， 1表示原图
				#   # T.ColorJitter(contrast=1), #随机从0-2 之间对比度变化， 1表示原图
				#   # T.ColorJitter(hue=0.5), #随机从 -0.5-0.5之间对颜色变化
				#   # T.ColorJitter(brightness=0.5, contrast=0.5, hue=0.5),
				#   T.RandomVerticalFlip(),  # 以0.5的概率进行垂直翻转
				#   T.ToTensor(),
				# ])
				self.transforms = T.Compose([T.ToTensor(), T.Lambda(lambda x: global_contrast_normalization(x, scale='l1'))])

			# for training
			elif self.mode == mode_manager.MODES['TEST_GENUINE'] or self.mode == mode_manager.MODES['TEST_RECAPTURE']:

				# self.transforms = T.Compose([
				#   T.Resize(224),
				#   T.CenterCrop(224),
				#   T.RandomHorizontalFlip(),s
				#   T.RandomVerticalFlip(),
				#   T.ToTensor(),
				# ])
				self.transforms = T.Compose([T.ToTensor(),  T.Lambda(lambda x: global_contrast_normalization(x, scale='l1'))])

	# override the __getitem__ method
	def __getitem__(self, index):
		# image path
		img_path = self.imgs_path[index]
		# read images according to the mode: for training
		if self.mode == mode_manager.MODES['TRAIN_GENUINE'] or self.mode == mode_manager.MODES['TRAIN_RECAPTURE']:
			printer_name, scanner_name, label, img_read = self.image_loader.img_read(img_path)
			doc_idx = 0
			# one class
			if self.network_mode == mode_manager.NETWORK_MODE['ONE_CLASS']:
				img_transform = self.transforms(Image.fromarray(img_read, mode='L'))
			# two class
			elif self.network_mode == mode_manager.NETWORK_MODE['TWO_CLASS']:
				img_read_ext = np.r_[np.array([img_read]), np.array([img_read]), np.array([img_read])]
				img_read_ext = np.moveaxis(img_read_ext, 0, -1)
				img_transform = self.transforms(Image.fromarray(img_read_ext, mode='RGB'))
			return img_transform, label, printer_name, scanner_name, doc_idx
		# read images according to the mode: for testing
		elif self.mode == mode_manager.MODES['TEST_GENUINE'] or self.mode == mode_manager.MODES['TEST_RECAPTURE']:
			# load in image and image information
			first_printer_name, second_printer_name, \
			first_scanner_name, second_scanner_name, doc_idx, label, img_read = self.image_loader.img_read(img_path)

			if self.network_mode == mode_manager.NETWORK_MODE['ONE_CLASS']:
				img_transform = self.transforms(Image.fromarray(img_read, mode='L'))
			elif self.network_mode == mode_manager.NETWORK_MODE['TWO_CLASS']:
				# convert to three channels
				img_read_ext = np.r_[np.array([img_read]), np.array([img_read]), np.array([img_read])]
				img_read_ext = np.moveaxis(img_read_ext, 0, -1)
				img_transform = self.transforms(Image.fromarray(img_read_ext, mode='RGB'))
			# returns the transformed image, label, device pairs, and document index
			return img_transform, label, \
			       first_printer_name, second_printer_name, first_scanner_name, second_scanner_name, doc_idx

	def __len__(self):
		return len(self.imgs_path)

	def __repr__(self):
		return self.__class__.__name__

	''' get the data loader with the input of the dataset '''
	@staticmethod
	def data_loader(sample_set, batch_size_: int, shuffle_=True, num_workers: int = 0):
		sample_set_loader = DataLoader(dataset=sample_set, batch_size=batch_size_, shuffle=shuffle_,
									   num_workers=num_workers)
		return sample_set_loader
