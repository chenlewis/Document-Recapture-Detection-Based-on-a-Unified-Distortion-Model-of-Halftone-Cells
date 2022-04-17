import numpy
from utils.mode_manager import mode_manager
from PIL import Image


class image_loader:

  # the constructor
  def __init__(self, mode_manager_: mode_manager, network_mode_=mode_manager.NETWORK_MODE['ONE_CLASS']):

    # only needs the mode manager. The rest is not use actually
    self.mode_manager = mode_manager_
    self.network_mode = network_mode_

  def img_read(self, img_path):

    # read in input, convert to grayscale, and return numpy representation
    img_read_gray = numpy.array(Image.open(img_path).convert('L'))
    img_name = img_path.split('\\')[-1]         # for windows directory
    # print('load image: ' + img_name)

    # locate image identifiers
    under_score_locs = [pos for pos, char in enumerate(img_name) if char == '_']
    dot_locs = [pos for pos, char in enumerate(img_name) if char == '.']

    # load the images for training: two cases
    if self.mode_manager.current_mode == mode_manager.MODES['TRAIN_GENUINE']:
      printer_name = img_name[:under_score_locs[0]]
      scanner_name = img_name[under_score_locs[0] + 1:under_score_locs[1]]
      if self.network_mode == mode_manager.NETWORK_MODE['ONE_CLASS']:
        label = 1
      elif self.network_mode == mode_manager.NETWORK_MODE['TWO_CLASS']:
        label = 0
      return printer_name, scanner_name, label, img_read_gray
    elif self.mode_manager.current_mode == mode_manager.MODES['TRAIN_RECAPTURE']:
      printer_name = img_name[:under_score_locs[0]]
      scanner_name = img_name[under_score_locs[2] + 1:under_score_locs[3]]
      if self.network_mode == mode_manager.NETWORK_MODE['ONE_CLASS']:
        label = -1
      elif self.network_mode == mode_manager.NETWORK_MODE['TWO_CLASS']:
        label = 1
      # in the case of training recapture image, still output one pair of device.
      return printer_name, scanner_name, label, img_read_gray
    # load the images for testing: two cases
    elif self.mode_manager.current_mode == mode_manager.MODES['TEST_GENUINE']:
      first_printer_name = img_name[:under_score_locs[0]]
      first_scanner_name = img_name[(under_score_locs[0] + 1):under_score_locs[1]]
      doc_idx = int(img_name[(under_score_locs[1] + 1):dot_locs[0]])
      if self.network_mode == mode_manager.NETWORK_MODE['ONE_CLASS']:
        label = 1
      elif self.network_mode == mode_manager.NETWORK_MODE['TWO_CLASS']:
        label = 0
      # in the case of genuine test image, return one pair of devices plust NO_PRINTER/NO_SCANNER
      return first_printer_name, 'NO_PRINTER', \
             first_scanner_name, 'NO_SCANNER', doc_idx, label, img_read_gray
    elif self.mode_manager.current_mode == mode_manager.MODES['TEST_RECAPTURE']:
      first_printer_name = img_name[:under_score_locs[0]]
      second_printer_name = img_name[under_score_locs[0] + 1:under_score_locs[1]]
      first_scanner_name = img_name[(under_score_locs[1] + 1):under_score_locs[2]]
      second_scanner_name = img_name[(under_score_locs[2] + 1):under_score_locs[3]]
      doc_idx = int(img_name[(under_score_locs[3] + 1):dot_locs[0]])
      if self.network_mode == mode_manager.NETWORK_MODE['ONE_CLASS']:
        label = -1
      elif self.network_mode == mode_manager.NETWORK_MODE['TWO_CLASS']:
        label = 1
      # in the case of recapture test image, return two pairs of devices
      return first_printer_name, second_printer_name, \
             first_scanner_name, second_scanner_name, doc_idx, label, img_read_gray
    return []