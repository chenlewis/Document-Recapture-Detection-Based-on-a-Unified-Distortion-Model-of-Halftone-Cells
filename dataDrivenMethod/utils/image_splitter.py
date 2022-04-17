import numpy as np

''' 
  this class accepct image input as a 2D ndarray and output a list of images after cropping with overlapping as 2D ndarray 
  now it only supports square image
'''
class image_splitter:

  def __init__(self, overlap_in_pixel, crop_size_in_pixel):
    self.points = [0]

    # the number of overlapping pixels
    self.overlap_in_pixel = overlap_in_pixel

    # the size of the cropped images
    self.crop_size_in_pixel = crop_size_in_pixel

    # the stride size in pixels
    self.stride_size_in_pixel = int(self.crop_size_in_pixel - self.overlap_in_pixel)


  def crop_images(self, input_img):

    output_img_list = []

    img_h, img_w = input_img.shape
    cut_points = [0]
    counter = 1
    while True:
      cut_point = self.stride_size_in_pixel * counter
      # detect the end of the cropping
      if cut_point + self.crop_size_in_pixel >= img_w:
        cut_points.append(img_w - self.crop_size_in_pixel)
        break
      else:
        cut_points.append(cut_point)
      counter += 1

    for i in cut_points:
      for j in cut_points:
        if i == 0 and j == 0:
          output_img_list = [input_img[i:i + self.crop_size_in_pixel, j:j + self.crop_size_in_pixel]]
        else:
          output_img_list += [input_img[i:i + self.crop_size_in_pixel, j:j + self.crop_size_in_pixel]]

    return output_img_list
