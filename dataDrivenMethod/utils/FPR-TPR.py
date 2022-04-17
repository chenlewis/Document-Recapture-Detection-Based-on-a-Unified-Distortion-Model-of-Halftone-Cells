import torch as t
import csv
from sklearn.metrics import roc_curve, auc
import matplotlib.pyplot as plt
import numpy as np
from scipy.interpolate import spline

csv_reader = csv.reader(open('D:/result-7.20/gold-result/yjb_ResNet152_dataset2-1-gold-all-7.29.csv'))
results = []
labels = []
scores = []
scores_0 = []

for row in csv_reader:
    results.append(row[0])
results.remove('id')
# print(results)

csv_reader = csv.reader(open('D:/result-7.20/gold-result/yjb_ResNet152_dataset2-1-gold-all-7.29.csv'))
for row in csv_reader:
    scores.append(row[1])
scores.remove('label')
#
print(len(scores))

for i in range(len(scores)):
    scores_0.append(float(scores[i]))

# print(scores_0)
second = 0
for i in range(len(results)):
    if len(results[i].split('_')) == 3:
        labels.append(1)
        second = second+1
    else:
        labels.append(0)
print(second)
fpr, tpr, thresholds = roc_curve(labels, scores_0, pos_label=1)

# fpr1=[round(i, 6) for i in fpr]
# print(fpr1)
# print(thresholds)
# for m, x in enumerate(fpr1):
#     if (x == 0.225371):
#         index = m
#         print(thresholds[index])
AUC = auc(fpr, tpr)
print('AUC= %.5f' %(AUC))

# fpr_new = np.linspace(fpr.min(), tpr.max(), 300)
# tpr_smooth = spline(fpr, tpr, fpr_new)
#plt.scatter(fpr, tpr)
line1, = plt.plot(fpr, tpr, marker='o')
# x = np.arange(0, 10, 1) / 10
# y = 1 - x
# line2, = plt.plot(x, y)
x = np.linspace(0, 1, 50)
y = 1 - x
line2, = plt.plot(x, y)
# plt.plot(x, y)
# plt.legend()
plt.legend([line1, line2], ['Line1', 'Line2'], loc=1)

plt.xlabel('FPR')
plt.ylabel('TPR')
plt.axis([0, 1, 0, 1])
plt.show()