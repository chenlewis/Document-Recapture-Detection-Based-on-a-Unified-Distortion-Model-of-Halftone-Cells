import torch.nn as nn
import torch as t
import time


# Basicmoudule是对nn.Module的简单封装，提供快速加载和保存模型的接口
# this is an interface, it does not contain any module yet
class module_interface(nn.Module):

  # constructor
  def __init__(self):
    super(module_interface, self).__init__()
    self.model_name = str(type(self))

    # dimension of the last layer
    self.rep_dim = None

  # load model from path (model parameters)
  def load(self, path):
    self.load_state_dict(t.load(path))

  # save model to path (model parameters)
  def save(self, name=None):
    if name is None:
      prefix = 'checkpoints/' + self.model_name + '_'
      name = time.strftime(prefix + '%m%d_%H:%M:%S.pth')
    t.save(self.state_dict(), name)
    return name

  def get_optimizer(self, lr, weight_deacy):
    # use adam optimizer
    return t.optim.Adam(self.parameters(), lr=lr, weight_decay=weight_deacy)

# flatten the tensor to vector??????
class Flat(nn.Module):
  def __init__(self):
    super(Flat, self).__init__()

  def forward(self, x):
    return x.view(x.size(0), -1)

