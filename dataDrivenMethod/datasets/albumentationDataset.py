import os
import random
import numpy as np

import matplotlib
matplotlib.use('TkAgg')

from matplotlib import pyplot as plt
import albumentations as A
import albumentations.pytorch as AT
from .dataset_preprocessing import get_target_label_idx, global_contrast_normalization
from torch.utils.data import DataLoader
from torch.utils.data import dataset
from utils.image_loader import image_loader
from utils.mode_manager import mode_manager

# 对于 torch data 的封装
class albumentationDataset(dataset.Dataset):

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
			random.seed(7)
			# for training
			if self.mode == mode_manager.MODES['TRAIN_GENUINE'] or self.mode == mode_manager.MODES['TRAIN_RECAPTURE']:
				# compose the augmentation transform
				self.transforms = A.Compose([
					A.HorizontalFlip(p=0.5),
					A.VerticalFlip(p=0.5),
					A.RandomBrightness(p=0.2),
					A.RandomContrast(p=0.2),
					A.RandomGamma(p=0.2),
					A.GaussNoise(p=0.2),
					A.GaussianBlur(p=0.2),
					A.Equalize(p=0.2),
					A.Normalize(mean=[0.485, 0.456, 0.406], std=[0.229, 0.224, 0.225]),
					AT.ToTensorV2(),
				])
			# for testing
			elif self.mode == mode_manager.MODES['TEST_GENUINE'] or self.mode == mode_manager.MODES['TEST_RECAPTURE']:
				self.transforms = A.Compose([A.Normalize(mean=[0.485, 0.456, 0.406], std=[0.229, 0.224, 0.225]), AT.ToTensorV2()])

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
				img_transform = self.transforms(image=img_read)['image']
				# img_transform = self.transforms(Image.fromarray(img_read, mode='L'))['image']
			# two class
			elif self.network_mode == mode_manager.NETWORK_MODE['TWO_CLASS']:
				img_read_ext = np.r_[np.array([img_read]), np.array([img_read]), np.array([img_read])]
				img_read_ext = np.moveaxis(img_read_ext, 0, -1)
				img_transform = self.transforms(image=img_read_ext)['image']


			# # testing the trasnform results
			# img_transform_rgb = np.moveaxis(np.array(img_transform), 0, -1)
			# plt.figure('transform comparison')
			# plt.clf()
			# ax1 = plt.subplot(1, 2, 1)
			# ax1.imshow(img_read_ext, origin='upper')
			# ax1.grid(False)
			# ax1.axis('off')
			# ax1.set_title('input')
			# ax2 = plt.subplot(1, 2, 2)
			# ax2.imshow(img_transform_rgb, origin='upper')
			# ax2.grid(False)
			# ax2.axis('off')
			# ax2.set_title('transformed')
			# plt.show(block=False)

			return img_transform, label, printer_name, scanner_name, doc_idx
		# read images according to the mode: for testing
		elif self.mode == mode_manager.MODES['TEST_GENUINE'] or self.mode == mode_manager.MODES['TEST_RECAPTURE']:
			# load image and image info
			first_printer_name, second_printer_name, \
			first_scanner_name, second_scanner_name, doc_idx, label, img_read = self.image_loader.img_read(img_path)
			if self.network_mode == mode_manager.NETWORK_MODE['ONE_CLASS']:
				img_transform = self.transforms(image=img_read)['image']
			elif self.network_mode == mode_manager.NETWORK_MODE['TWO_CLASS']:
				# convert to three channels
				img_read_ext = np.r_[np.array([img_read]), np.array([img_read]), np.array([img_read])]
				img_read_ext = np.moveaxis(img_read_ext, 0, -1)
				img_transform = self.transforms(image=img_read_ext)['image']
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
		sample_set_loader = DataLoader(dataset=sample_set,
																	 batch_size=batch_size_,
																	 shuffle=shuffle_,
									   							 num_workers=num_workers)
		return sample_set_loader

	@staticmethod
	def visualize(image):
		plt.figure(figsize=(10, 10))
		plt.imshow(image, origin='upper')
		plt.show(block=False)
