import torch
from torchvision import models
import torch.nn as nn
import torch.nn.functional as F
from models.module_interface import module_interface

# import segmentation_models_pytorch as smp

class DenseNet121(module_interface):
    def __init__(self):
        super(DenseNet121, self).__init__()
        # this model is also self-defined.
        self.model = models.densenet121(pretrained=True)
        # the classifier is defined my yourself
        self.model.classifier = nn.Sequential(
            nn.Linear(1024, 256),
            nn.ReLU(inplace=True),
            nn.Linear(256, 2)
        )
        for params in self.model.parameters():
            params.requires_grad = False
        for index, param in enumerate(self.model.classifier.parameters()):
            if index >= 0:
                param.requires_grad = True

    def forward(self, x):
        output = self.model(x)
        return output


class DenseNet169(module_interface):
    def __init__(self):
        super(DenseNet169, self).__init__()
        self.model = models.densenet169(pretrained=True)
        self.model.classifier = nn.Sequential(
            nn.Linear(1664, 256),
            nn.ReLU(inplace=True),
            nn.Linear(256, 2)
        )
        for params in self.model.parameters():
            params.requires_grad = False
        for index, param in enumerate(self.model.classifier.parameters()):
            if index >= 0:
                param.requires_grad = True

    def forward(self, x):
        output = self.model(x)
        return output


class DenseNet201(module_interface):
    def __init__(self):
        super(DenseNet201, self).__init__()
        self.model = models.densenet201(pretrained=True)
        self.model.classifier = nn.Sequential(
            nn.Linear(1920, 256),
            nn.ReLU(inplace=True),
            nn.Linear(256, 2)
        )
        for params in self.model.parameters():
            params.requires_grad = False
        for index, param in enumerate(self.model.classifier.parameters()):
            if index >= 0:
                param.requires_grad = True

    def forward(self, x):
        output = self.model(x)
        return output


class MobileNet(module_interface):
    def __init__(self):
        super(MobileNet, self).__init__()
        self.model = models.mobilenet_v2(pretrained=True)
        self.model.classifier[1] = nn.Sequential(
            nn.Linear(1280, 256),
            nn.ReLU(inplace=True),
            nn.Linear(256, 2)
        )
        for params in self.model.parameters():
            params.requires_grad = False
        for index, param in enumerate(self.model.classifier.parameters()):
            if index >= 1:
                param.requires_grad = True

    def forward(self, x):
        output = self.model(x)
        return output


class VGG16(module_interface):
    def __init__(self):
        super(VGG16, self).__init__()
        self.model = models.vgg16(pretrained=True)
        self.model.classifier[6] = nn.Sequential(
            nn.Linear(4096, 256),
            nn.ReLU(inplace=True),
            nn.Linear(256, 2)
        )
        for params in self.model.parameters():
            params.requires_grad = False
        for index, param in enumerate(self.model.classifier.parameters()):
            if index >= 6:
                param.requires_grad = True

    def forward(self, x):
        output = self.model(x)
        return output


class VGG19(module_interface):
    def __init__(self):
        super(VGG19, self).__init__()
        self.model = models.vgg19(pretrained=True)
        self.model.classifier[6] = nn.Sequential(
            nn.Linear(4096, 256),
            nn.ReLU(inplace=True),
            nn.Linear(256, 2)
        )
        for params in self.model.parameters():
            params.requires_grad = False
        for index, param in enumerate(self.model.classifier.parameters()):
            if index >= 6:
                param.requires_grad = True

    def forward(self, x):
        output = self.model(x)
        return output


class ResNet34(module_interface):
    def __init__(self):
        super(ResNet34, self).__init__()
        self.model = models.resnet34(pretrained=True)
        self.model.fc = nn.Sequential(
            nn.Linear(512, 256),
            nn.ReLU(inplace=True),
            nn.Linear(256, 2)
        )
        for params in self.model.parameters():
            params.requires_grad = False
        for index, param in enumerate(self.model.fc.parameters()):
            if index >= 0:
                param.requires_grad = True

    def forward(self, x):
        output = self.model(x)
        return output

# the final fc layer is changed
class ResNet50(module_interface):
    def __init__(self):
        super(ResNet50, self).__init__()
        self.model = models.resnet50(pretrained=True)
        self.model.fc = nn.Sequential(
            nn.Linear(2048, 2),
            # nn.Linear(2048, 256),
            # nn.Linear(256, 2),
        )
        for params in self.model.parameters():
            params.requires_grad = False
        for index, param in enumerate(self.model.fc.parameters()):
            if index >= 0:
                param.requires_grad = True

    def forward(self, x):
        output = self.model(x)
        return output


class ResNet101(module_interface):
    def __init__(self):
        super(ResNet101, self).__init__()
        self.model = models.resnet101(pretrained=True)
        self.model.fc = nn.Sequential(
            nn.Linear(2048, 256),
            nn.ReLU(inplace=True),
            nn.Linear(256, 2)
        )
        for params in self.model.parameters():
            params.requires_grad = False
        for index, param in enumerate(self.model.fc.parameters()):
            if index >= 0:
                param.requires_grad = True

    def forward(self, x):
        output = self.model(x)
        return output


class ResNet152(module_interface):
    def __init__(self):
        super(ResNet152, self).__init__()
        self.model = models.resnet152(pretrained=True)
        self.model.fc = nn.Sequential(
            nn.Linear(2048, 256),
            nn.ReLU(inplace=True),
            nn.Linear(256, 2)
        )
        for params in self.model.parameters():
            params.requires_grad = False
        for index, param in enumerate(self.model.fc.parameters()):
            if index >= 0:
                param.requires_grad = True

    def forward(self, x):
        output = self.model(x)
        return output


class ResNeXt50(module_interface):
    def __init__(self):
        super(ResNeXt50, self).__init__()
        self.model = models.resnext50_32x4d(pretrained=True)
        self.model.fc = nn.Sequential(
            nn.Linear(2048, 256),
            nn.ReLU(inplace=True),
            nn.Linear(256, 2)
        )
        for params in self.model.parameters():
            params.requires_grad = False
        for index, param in enumerate(self.model.fc.parameters()):
            if index >= 0:
                param.requires_grad = True

    def forward(self, x):
        output = self.model(x)
        return output


class ResNeXt101(module_interface):
    def __init__(self):
        super(ResNeXt101, self).__init__()
        self.model = models.resnext101_32x8d(pretrained=True)
        self.model.fc = nn.Sequential(
            nn.Linear(2048, 256),
            nn.ReLU(inplace=True),
            nn.Linear(256, 2)
        )
        for params in self.model.parameters():
            params.requires_grad = False
        for index, param in enumerate(self.model.fc.parameters()):
            if index >= 0:
                param.requires_grad = True

    def forward(self, x):
        output = self.model(x)
        return output


class InceptionV3(module_interface):
    def __init__(self):
        super(InceptionV3, self).__init__()
        self.model = models.inception_v3(pretrained=True)
        self.model.fc = nn.Sequential(
            nn.Linear(2048, 256),
            nn.ReLU(inplace=True),
            nn.Linear(256, 2)
        )
        self.model.AuxLogits.fc = nn.Linear(768, 2)
        self.model.aux_logits = False
        for params in self.model.parameters():
            params.requires_grad = False
        for index, param in enumerate(self.model.fc.parameters()):
            if index >= 0:
                param.requires_grad = True

    def forward(self, x):
        output = self.model(x)
        return output

# LeNet from ICML 2018 Deep One Class paper
class LeNet(module_interface):
    def __init__(self):
        super().__init__()

        self.rep_dim = 784
        self.pool = nn.MaxPool2d(2, 2)

        self.conv1 = nn.Conv2d(1, 32, 5, bias=False, padding=2)
        self.bn2d1 = nn.BatchNorm2d(32, eps=1e-04, affine=False)
        self.conv2 = nn.Conv2d(32, 64, 5, bias=False, padding=2)
        self.bn2d2 = nn.BatchNorm2d(64, eps=1e-04, affine=False)
        self.conv3 = nn.Conv2d(64, 128, 5, bias=False, padding=2)
        self.bn2d3 = nn.BatchNorm2d(128, eps=1e-04, affine=False)
        self.fc1 = nn.Linear(128 * 28 * 28, self.rep_dim, bias=False)             # this might need to be changed

    def forward(self, x):
        x = self.conv1(x)
        x = self.pool(F.leaky_relu(self.bn2d1(x)))
        x = self.conv2(x)
        x = self.pool(F.leaky_relu(self.bn2d2(x)))
        x = self.conv3(x)
        x = self.pool(F.leaky_relu(self.bn2d3(x)))
        x = x.view(x.size(0), -1)
        x = self.fc1(x)
        return x

# LeNet auto-encoder from ICML 2018 Deep One Class paper
class LeNet_Autoencoder(module_interface):

    def __init__(self):
        super().__init__()

        self.rep_dim = 784
        self.pool = nn.MaxPool2d(2, 2)

        # Encoder (must match the Deep SVDD network above)
        self.conv1 = nn.Conv2d(1, 32, 5, bias=False, padding=2)
        nn.init.xavier_uniform_(self.conv1.weight, gain=nn.init.calculate_gain('leaky_relu'))
        self.bn2d1 = nn.BatchNorm2d(32, eps=1e-04, affine=False)
        self.conv2 = nn.Conv2d(32, 64, 5, bias=False, padding=2)
        nn.init.xavier_uniform_(self.conv2.weight, gain=nn.init.calculate_gain('leaky_relu'))
        self.bn2d2 = nn.BatchNorm2d(64, eps=1e-04, affine=False)
        self.conv3 = nn.Conv2d(64, 128, 5, bias=False, padding=2)
        nn.init.xavier_uniform_(self.conv3.weight, gain=nn.init.calculate_gain('leaky_relu'))
        self.bn2d3 = nn.BatchNorm2d(128, eps=1e-04, affine=False)
        self.fc1 = nn.Linear(128 * 28 * 28, self.rep_dim, bias=False)
        self.bn1d = nn.BatchNorm1d(self.rep_dim, eps=1e-04, affine=False)

        # Decoder
        self.deconv1 = nn.ConvTranspose2d(int(self.rep_dim / (28 * 28)), 128, 5, bias=False, padding=2)
        nn.init.xavier_uniform_(self.deconv1.weight, gain=nn.init.calculate_gain('leaky_relu'))
        self.bn2d4 = nn.BatchNorm2d(128, eps=1e-04, affine=False)
        self.deconv2 = nn.ConvTranspose2d(128, 64, 5, bias=False, padding=2)
        nn.init.xavier_uniform_(self.deconv2.weight, gain=nn.init.calculate_gain('leaky_relu'))
        self.bn2d5 = nn.BatchNorm2d(64, eps=1e-04, affine=False)
        self.deconv3 = nn.ConvTranspose2d(64, 32, 5, bias=False, padding=2)
        nn.init.xavier_uniform_(self.deconv3.weight, gain=nn.init.calculate_gain('leaky_relu'))
        self.bn2d6 = nn.BatchNorm2d(32, eps=1e-04, affine=False)
        self.deconv4 = nn.ConvTranspose2d(32, 1, 5, bias=False, padding=2)
        nn.init.xavier_uniform_(self.deconv4.weight, gain=nn.init.calculate_gain('leaky_relu'))

    def forward(self, x):
        x = self.conv1(x)
        x = self.pool(F.leaky_relu(self.bn2d1(x)))
        x = self.conv2(x)
        x = self.pool(F.leaky_relu(self.bn2d2(x)))
        x = self.conv3(x)
        x = self.pool(F.leaky_relu(self.bn2d3(x)))
        x = x.view(x.size(0), -1)
        x = self.bn1d(self.fc1(x))
        x = x.view(x.size(0), int(self.rep_dim / (28 * 28)), 28, 28)
        x = F.leaky_relu(x)
        x = self.deconv1(x)
        x = F.interpolate(F.leaky_relu(self.bn2d4(x)), scale_factor=2)
        x = self.deconv2(x)
        x = F.interpolate(F.leaky_relu(self.bn2d5(x)), scale_factor=2)
        x = self.deconv3(x)
        x = F.interpolate(F.leaky_relu(self.bn2d6(x)), scale_factor=2)
        x = self.deconv4(x)
        x = torch.sigmoid(x)
        return x

# LeNet_ELU from ICML 2018 Deep One Class paper: uses ELU as actication function
class LeNet_ELU(module_interface):

  def __init__(self):
    super().__init__()

    self.rep_dim = 128
    self.pool = nn.MaxPool2d(2, 2)

    self.conv1 = nn.Conv2d(3, 32, 5, bias=False, padding=2)
    self.bn2d1 = nn.BatchNorm2d(32, eps=1e-04, affine=False)
    self.conv2 = nn.Conv2d(32, 64, 5, bias=False, padding=2)
    self.bn2d2 = nn.BatchNorm2d(64, eps=1e-04, affine=False)
    self.conv3 = nn.Conv2d(64, 128, 5, bias=False, padding=2)
    self.bn2d3 = nn.BatchNorm2d(128, eps=1e-04, affine=False)
    self.fc1 = nn.Linear(128 * 4 * 4, self.rep_dim, bias=False)

  def forward(self, x):
    x = self.conv1(x)
    x = self.pool(F.elu(self.bn2d1(x)))
    x = self.conv2(x)
    x = self.pool(F.elu(self.bn2d2(x)))
    x = self.conv3(x)
    x = self.pool(F.elu(self.bn2d3(x)))
    x = x.view(x.size(0), -1)
    x = self.fc1(x)
    return x

# LeNet_ELU autoencoder from ICML 2018 Deep One Class paper: uses ELU as actication function
class LeNet_ELU_Autoencoder(module_interface):

  def __init__(self):
    super().__init__()

    self.rep_dim = 128
    self.pool = nn.MaxPool2d(2, 2)

    # Encoder (must match the Deep SVDD network above)
    self.conv1 = nn.Conv2d(3, 32, 5, bias=False, padding=2)
    nn.init.xavier_uniform_(self.conv1.weight)
    self.bn2d1 = nn.BatchNorm2d(32, eps=1e-04, affine=False)
    self.conv2 = nn.Conv2d(32, 64, 5, bias=False, padding=2)
    nn.init.xavier_uniform_(self.conv2.weight)
    self.bn2d2 = nn.BatchNorm2d(64, eps=1e-04, affine=False)
    self.conv3 = nn.Conv2d(64, 128, 5, bias=False, padding=2)
    nn.init.xavier_uniform_(self.conv3.weight)
    self.bn2d3 = nn.BatchNorm2d(128, eps=1e-04, affine=False)
    self.fc1 = nn.Linear(128 * 4 * 4, self.rep_dim, bias=False)
    self.bn1d = nn.BatchNorm1d(self.rep_dim, eps=1e-04, affine=False)

    # Decoder
    self.deconv1 = nn.ConvTranspose2d(int(self.rep_dim / (4 * 4)), 128, 5, bias=False, padding=2)
    nn.init.xavier_uniform_(self.deconv1.weight)
    self.bn2d4 = nn.BatchNorm2d(128, eps=1e-04, affine=False)
    self.deconv2 = nn.ConvTranspose2d(128, 64, 5, bias=False, padding=2)
    nn.init.xavier_uniform_(self.deconv2.weight)
    self.bn2d5 = nn.BatchNorm2d(64, eps=1e-04, affine=False)
    self.deconv3 = nn.ConvTranspose2d(64, 32, 5, bias=False, padding=2)
    nn.init.xavier_uniform_(self.deconv3.weight)
    self.bn2d6 = nn.BatchNorm2d(32, eps=1e-04, affine=False)
    self.deconv4 = nn.ConvTranspose2d(32, 3, 5, bias=False, padding=2)
    nn.init.xavier_uniform_(self.deconv4.weight)

  def forward(self, x):
    x = self.conv1(x)
    x = self.pool(F.elu(self.bn2d1(x)))
    x = self.conv2(x)
    x = self.pool(F.elu(self.bn2d2(x)))
    x = self.conv3(x)
    x = self.pool(F.elu(self.bn2d3(x)))
    x = x.view(x.size(0), -1)
    x = self.bn1d(self.fc1(x))
    x = x.view(x.size(0), int(self.rep_dim / (4 * 4)), 4, 4)
    x = F.elu(x)
    x = self.deconv1(x)
    x = F.interpolate(F.elu(self.bn2d4(x)), scale_factor=2)
    x = self.deconv2(x)
    x = F.interpolate(F.elu(self.bn2d5(x)), scale_factor=2)
    x = self.deconv3(x)
    x = F.interpolate(F.elu(self.bn2d6(x)), scale_factor=2)
    x = self.deconv4(x)
    x = torch.sigmoid(x)
    return x