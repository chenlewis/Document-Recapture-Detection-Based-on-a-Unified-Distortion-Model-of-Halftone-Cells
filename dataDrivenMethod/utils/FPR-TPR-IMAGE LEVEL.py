import torch as t
import csv
from sklearn.metrics import roc_curve, auc
import matplotlib.pyplot as plt
import numpy as np
from scipy.interpolate import spline

csv_reader = csv.reader(open('D:/result-7.20/gold-result/yjb_DenseNet201_dataset2-1-gold-all-7.29.csv'))
results = []
labels = []
scores = []
scores_0 = []
score_0 = []
j = []
for row in csv_reader:
    results.append(row[0])
results.remove('id')
# print(results)

csv_reader = csv.reader(open('D:/result-7.20/gold-result/yjb_DenseNet201_dataset2-1-gold-all-7.29.csv'))
for row in csv_reader:
    scores.append(row[1])
scores.remove('label')
#
print(len(scores))

for i in range(len(scores)):
    scores_0.append(float(scores[i]))
# print(scores_0)

amount = []
for i in range(len(results)):

    if (results[i].split("_", -1)[-5:-1] != results[i - 1].split("_", -1)[-5:-1]):
        print(results[i].split("_", -1)[-5:-1])
        score_0 = [float(x) for x in score_0]
        if (score_0 != []):
            amount.append(len(score_0))
            j.append(np.mean(score_0))
            # print('j:', j)
        if len(results[i].split('_')) == 3:
            labels.append(1)
        else:
            labels.append(0)

        # print('labels:', len(labels))
        score_0 = []
        score_0.append(scores_0[i])
    elif (i != 0 and results[i].split("_", -1)[-5:-1] == results[i - 1].split("_", -1)[-5:-1]):
        score_0.append(scores_0[i])
        # print('score_0:', score_0)
        # k = score_0
score_0 = [float(x) for x in score_0]
amount.append(len(score_0))
j.append(np.mean(score_0))
print('labels:', len(labels))
print('j:', len(j))



fpr, tpr, thresholds = roc_curve(labels, j, pos_label=1)
# print(len(fpr))
# fpr1=[round(i, 4) for i in fpr]
# print(fpr1)
# print(thresholds)
# for m, x in enumerate(fpr1):
#     if (x == 0.2593):
#         index = m
# print(thresholds[index])
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


# b = 0
# c = 0
# percentage =[]
# str = '_'
# result_new = []
# for i in range(len(results)):
#     if len(results[i].split('_')) == 3:
#         a = str.join(results[i].split('_')[0:2])
#         c = c+1
#         if (scores_0[i] < 0.5):
#             b = b+1
#     if len(results[i].split('_')) == 4 :
#         a = str.join(results[i].split('_')[0:3])
#         c = c + 1
#         if (scores_0[i] > 0.5):
#             b = b+1
#     if len(results[i].split('_')) == 5 :
#         a = str.join(results[i].split('_')[0:4])
#         c = c + 1
#         if (scores_0[i] > 0.5):
#             b = b+1
#     if a not in result_new:
#         result_new.append(a)
#         if (i != 0):
#             d = b/c
#             percentage.append(d)
#             b = 0
#             c = 0
# d = b/c
# percentage.append(d)
#
# with open('yjb_ResNet50_dataset2-1_all_sort_image.csv', 'w', newline='') as file:
#     w = csv.writer(file)
#     w.writerow(['id', 'labels', 'amount'])
#     w.writerows(zip(result_new, j, amount))