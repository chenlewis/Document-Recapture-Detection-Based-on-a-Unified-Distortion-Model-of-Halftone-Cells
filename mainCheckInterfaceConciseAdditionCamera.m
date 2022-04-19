%% this script include the analysis of the collected data
%% workspace initialization
close all; 
clc;
set(0, 'DefaultFigureVisible', 'on');
clear;
%%
databaseDirPath = '';
%% process the genuine images
genuineRefDataPath = [databaseDirPath '1st_ref_45_73_1200_camera.mat'];
recaptureRefDataPath = [databaseDirPath '1st_ref_45_73_1200_camera.mat'];
halftoneDataAnalyzerObj1 = halftoneDataAnalyzerCam(genuineRefDataPath, recaptureRefDataPath, 3);
halftoneDataAnalyzerObj1.sampleSize = 10;
halftoneDataAnalyzerObj1 = halftoneDataAnalyzerObj1.checkSigmaAHistogram();
halftoneDataAnalyzerObj1 = halftoneDataAnalyzerObj1.getTStatBaseLine(); % get the t-stat for reference images
halftoneDataAnalyzerObj1 = halftoneDataAnalyzerObj1.getTStatTest();     
halftoneDataAnalyzerObj1 = halftoneDataAnalyzerObj1.checkTStat();       % show only
halftoneDataAnalyzerObj1 = halftoneDataAnalyzerObj1.testTStat();        % do t-testing. This groups the documents
%% baseline result
figure;
% fast direction
subplot(121);
histBinEdges = -30 : 1 : 30;
histogram(halftoneDataAnalyzerObj1.sampleSigmaABaselineTstatGroupArrayPrinterScannerWidth(:, 4), ...
          histBinEdges, 'Normalization', 'probability');
hold on;
histogram(halftoneDataAnalyzerObj1.sigmaATestTstatDocArrayPrinterScanner(:, 8), ...
          histBinEdges, 'Normalization', 'probability');
title('t-stat hist baseline fast (doc img)');
legend('baseline', 'test');
set(gca, 'FontName', 'Times', 'FontSize', 25, 'FontSmoothing', 'on');   
set(gcf, 'InnerPosition', [0 0 800 800], 'OuterPosition', [0 0 800 800], 'color', 'w');  
ylim([0 0.25]);
% slow direction
subplot(122);
histBinEdges = -30 : 1 : 30;
histogram(halftoneDataAnalyzerObj1.sampleSigmaABaselineTstatGroupArrayPrinterScannerWidthRot(:, 4), ...
          histBinEdges, 'Normalization', 'probability');
hold on;
histogram(halftoneDataAnalyzerObj1.sigmaATestTstatDocArrayPrinterScannerRot(:, 8), ...
          histBinEdges, 'Normalization', 'probability');
title('t-stat hist baseline slow (doc img)');
legend('baseline', 'test');
set(gca, 'FontName', 'Times', 'FontSize', 25, 'FontSmoothing', 'on');  
set(gcf, 'InnerPosition', [0 0 800 800], 'OuterPosition', [0 0 800 800], 'color', 'w');  
ylim([0 0.25]);
%% realistic result
figure;
subplot(121);
% fast direction
histBinEdges = -30 : 1 : 30;
histogram(halftoneDataAnalyzerObj1.sampleSigmaABaselineTstatGroupArrayScannerWidth(:, 3), ...
          histBinEdges, 'Normalization', 'probability');
hold on;
histogram(halftoneDataAnalyzerObj1.sigmaATestTstatDocArrayScanner(:, 8), ...
          histBinEdges, 'Normalization', 'probability');
title('t-stat hist realistic fast (doc img)');
legend('baseline', 'test');
set(gca, 'FontName', 'Times', 'FontSize', 25, 'FontSmoothing', 'on');   
set(gcf, 'OuterPosition', [0 0 800 800], 'InnerPosition', [0 0 800 800], 'color','w'); 
ylim([0 0.25]);
% slow direction
subplot(122);
histBinEdges = -30 : 1 : 30;
histogram(halftoneDataAnalyzerObj1.sampleSigmaABaselineTstatGroupArrayScannerWidthRot(:, 3), ...
          histBinEdges, 'Normalization', 'probability');
hold on;
histogram(halftoneDataAnalyzerObj1.sigmaATestTstatDocArrayScannerRot(:, 8), ...
          histBinEdges, 'Normalization', 'probability');
title('t-stat hist realistic slow (doc img)');
legend('baseline', 'test');
set(gca, 'FontName', 'Times', 'FontSize', 25, 'FontSmoothing', 'on');   
set(gcf, 'OuterPosition', [0 0 800 800], 'InnerPosition', [0 0 800 800], 'color','w'); 
ylim([0 0.25]);
%% process the recaptured 
% close all;
refDataPath = [databaseDirPath '1st_ref_45_73_1200_camera.mat'];
docDataPath = [databaseDirPath '2nd_ref_45_73_1200_camera.mat'];
halftoneDataAnalyzerObj2 = halftoneDataAnalyzerCam(refDataPath, docDataPath, 4);
halftoneDataAnalyzerObj2.sampleSize = 10;
halftoneDataAnalyzerObj2.checkSigmaAHistogram();
halftoneDataAnalyzerObj2 = halftoneDataAnalyzerObj2.getTStatBaseLine();
halftoneDataAnalyzerObj2 = halftoneDataAnalyzerObj2.getTStatTest();
halftoneDataAnalyzerObj2 = halftoneDataAnalyzerObj2.checkTStat();
halftoneDataAnalyzerObj2 = halftoneDataAnalyzerObj2.testTStat();
%% baseline result (recapture tstat vs reference tstat)
figure;
subplot(121);
% fast direction
histBinEdges = -30 : 1 : 30;
histogram(halftoneDataAnalyzerObj2.sampleSigmaABaselineTstatGroupArrayPrinterScannerWidth(:, 4), ...
          histBinEdges, 'Normalization', 'probability');
hold on;
histogram(halftoneDataAnalyzerObj2.sigmaATestTstatDocArrayPrinterScanner(:, 8), ...
          histBinEdges, 'Normalization', 'probability');
title('t-stat hist fast baseline (doc img)');
legend('baseline', 'test');
set(gca, 'FontName', 'Times', 'FontSize', 25, 'FontSmoothing', 'on');   
set(gcf, 'InnerPosition', [0 0 800 800], 'OuterPosition', [0 0 800 800], 'color', 'w');  
ylim([0 0.25]);
% slow direction
subplot(122);
histBinEdges = -30 : 1 : 30;
histogram(halftoneDataAnalyzerObj2.sampleSigmaABaselineTstatGroupArrayPrinterScannerWidthRot(:, 4), ...
          histBinEdges, 'Normalization', 'probability');
hold on;
histogram(halftoneDataAnalyzerObj2.sigmaATestTstatDocArrayPrinterScannerRot(:, 8), ...
          histBinEdges, 'Normalization', 'probability');
title('t-stat hist slow baseline (doc img)');
legend('baseline', 'test');
set(gca, 'FontName', 'Times', 'FontSize', 25, 'FontSmoothing', 'on');   
set(gcf, 'InnerPosition', [0 0 800 800], 'OuterPosition', [0 0 800 800], 'color', 'w');  
ylim([0 0.25]);
%% realistic result (recapture tstat vs reference tstat)
figure;
subplot(121);
% fast direction
histBinEdges = -30 : 1 : 30;
histogram(halftoneDataAnalyzerObj2.sampleSigmaABaselineTstatGroupArrayScannerWidth(:, 3), ...
          histBinEdges, 'Normalization', 'probability');
hold on;
histogram(halftoneDataAnalyzerObj2.sigmaATestTstatDocArrayScanner(:, 8), ...
          histBinEdges, 'Normalization', 'probability');
title('t-stat hist fast realistic (doc img)');
legend('baseline', 'test');
set(gca, 'FontName', 'Times', 'FontSize', 25, 'FontSmoothing', 'on');   
set(gcf, 'OuterPosition', [0 0 800 800], 'InnerPosition', [0 0 800 800], 'color','w'); 
ylim([0 0.25]);
% slow direction
subplot(122);
histBinEdges = -30 : 1 : 30;
histogram(halftoneDataAnalyzerObj2.sampleSigmaABaselineTstatGroupArrayScannerWidthRot(:, 3), ...
          histBinEdges, 'Normalization', 'probability');
hold on;
histogram(halftoneDataAnalyzerObj2.sigmaATestTstatDocArrayScannerRot(:, 8), ...
          histBinEdges, 'Normalization', 'probability');
title('t-stat hist slow realistic (doc img)');
legend('baseline', 'test');
set(gca, 'FontName', 'Times', 'FontSize', 25, 'FontSmoothing', 'on');   
set(gcf, 'OuterPosition', [0 0 800 800], 'InnerPosition', [0 0 800 800], 'color','w'); 
ylim([0 0.25]);
%% baseline doc result (genuine tstat vs recapture tstat)
figure;
subplot(121);
% fast direction
histBinEdges = -30 : 1 : 30;
histogram(halftoneDataAnalyzerObj1.sigmaATestTstatDocArrayPrinterScanner(:, 8), ...
          histBinEdges, 'Normalization', 'probability');
hold on;
histogram(halftoneDataAnalyzerObj2.sigmaATestTstatDocArrayPrinterScanner(:, 8), ...
          histBinEdges, 'Normalization', 'probability');
title('t-stat hist baseline fast doc comparison');
legend('genuine doc', 'recapture doc');
set(gca, 'FontName', 'Times', 'FontSize', 25, 'FontSmoothing', 'on');   
set(gcf, 'InnerPosition', [0 0 800 800], 'OuterPosition', [0 0 800 800], 'color', 'w');  
ylim([0 0.25]);
% slow direction
subplot(122);
histBinEdges = -30 : 1 : 30;
histogram(halftoneDataAnalyzerObj1.sigmaATestTstatDocArrayPrinterScannerRot(:, 8), ...
          histBinEdges, 'Normalization', 'probability');
hold on;
histogram(halftoneDataAnalyzerObj2.sigmaATestTstatDocArrayPrinterScannerRot(:, 8), ...
          histBinEdges, 'Normalization', 'probability');
title('t-stat hist baseline slow doc comparison');
legend('genuine doc', 'recapture doc');
set(gca, 'FontName', 'Times', 'FontSize', 25, 'FontSmoothing', 'on');   
set(gcf, 'InnerPosition', [0 0 800 800], 'OuterPosition', [0 0 800 800], 'color', 'w');  
ylim([0 0.25]);
%% realistic doc result (genuine tstat vs recapture tstat)
figure;
subplot(121);
% fast direction
histBinEdges = -30 : 1 : 30;
histogram(halftoneDataAnalyzerObj1.sigmaATestTstatDocArrayScanner(:, 8), ...
          histBinEdges, 'Normalization', 'probability');
hold on;
histogram(halftoneDataAnalyzerObj2.sigmaATestTstatDocArrayScanner(:, 8), ...
          histBinEdges, 'Normalization', 'probability');
title('t-stat hist realistic fast doc comparison');
legend('genuine doc', 'recapture doc');
set(gca, 'FontName', 'Times', 'FontSize', 25, 'FontSmoothing', 'on');   
set(gcf, 'InnerPosition', [0 0 800 800], 'OuterPosition', [0 0 800 800], 'color', 'w');  
ylim([0 0.25]);
% slow direction
subplot(122);
histBinEdges = -30 : 1 : 30;
histogram(halftoneDataAnalyzerObj1.sigmaATestTstatDocArrayScannerRot(:, 8), ...
          histBinEdges, 'Normalization', 'probability');
hold on;
histogram(halftoneDataAnalyzerObj2.sigmaATestTstatDocArrayScannerRot(:, 8), ...
          histBinEdges, 'Normalization', 'probability');
title('t-stat hist realistic slow doc comparison');
legend('genuine doc', 'recapture doc');
set(gca, 'FontName', 'Times', 'FontSize', 25, 'FontSmoothing', 'on');   
set(gcf, 'InnerPosition', [0 0 800 800], 'OuterPosition', [0 0 800 800], 'color', 'w');  
ylim([0 0.25]);
%% initilize the experiment result
% close all
experiment_result = [];
docIdxList = 70:20:210;         % for camera (it is intensities for camera)
%% collect genuine data for the baseline experiments
% initialize the scores for document images
PrinterScannerWidthGenuineScore = [];
PrinterScannerWidthGenuineRotScore = [];
PrinterScannerWidthGenuineDoubleScore = [];
% get the device info list (with and without rotation)
device_info = halftoneDataAnalyzerObj1.sigmaATestTstatDocArrayPrinterScanner(:, 1:4);
device_info_list = unique(device_info, 'row');
device_info_rot = halftoneDataAnalyzerObj1.sigmaATestTstatDocArrayPrinterScannerRot(:, 1:4);
device_info_rot_list = unique(device_info_rot, 'row');
% for each device combination
for i = 1:size(device_info_list, 1)
  % get the device indices
  device_idx = device_info_extract(device_info_list(i, :), device_info);
  device_idx_rot = device_info_extract(device_info_rot_list(i, :), device_info_rot);
  % get the sigmaA results
  PrinterScannerWidthGenuine1 = halftoneDataAnalyzerObj1.sigmaATestTstatDocArrayPrinterScanner(device_idx, :);
  PrinterScannerWidthGenuine1Rot = halftoneDataAnalyzerObj1.sigmaATestTstatDocArrayPrinterScannerRot(device_idx_rot, :);
  % for debugging purpose
  if isequal(device_info_list(i, :), [1 0 0 1])
    disp('debug');
  end
  % continue if there is no result
  if isempty(PrinterScannerWidthGenuine1) && isempty(PrinterScannerWidthGenuine1Rot)
    continue;
  end
  % for each document
  for k = 1:length(docIdxList)
    PrinterScannerWidthGenuine = PrinterScannerWidthGenuine1(PrinterScannerWidthGenuine1(:, 5) == docIdxList(k), :);
    PrinterScannerWidthGenuineRot = PrinterScannerWidthGenuine1Rot(PrinterScannerWidthGenuine1Rot(:, 5) == docIdxList(k), :);
    % if either the genuine and genuine rot has no score
    if isempty(PrinterScannerWidthGenuine) || isempty(PrinterScannerWidthGenuineRot)
      PrinterScannerWidthGenuineScore(end + 1, :) = [device_info_list(i, :) docIdxList(k) 99];
      PrinterScannerWidthGenuineRotScore(end + 1, :) = [device_info_rot_list(i, :) docIdxList(k) 99];
      PrinterScannerWidthGenuineDoubleScore(end + 1, :) = [device_info_list(i, :) docIdxList(k) 99];
    % majority voting
    else
      PrinterScannerWidthGenuineScore(end + 1, :) = [device_info_list(i, :) docIdxList(k) median(PrinterScannerWidthGenuine(:, 8))];
      PrinterScannerWidthGenuineRotScore(end + 1, :) = [device_info_rot_list(i, :) docIdxList(k) median(PrinterScannerWidthGenuineRot(:, 8))];
      PrinterScannerWidthGenuineDoubleScore(end + 1, :) = [device_info_list(i, :) ...
                                                           docIdxList(k) ...
                                                           median([PrinterScannerWidthGenuine(:, 8); PrinterScannerWidthGenuineRot(:, 8)])];
    end
  end
end      
%% collect genuine data for the semi-controlled experiments
% initialize the scores for document images
PrinterTypeScannerWidthGenuineScore = [];
PrinterTypeScannerWidthGenuineRotScore = [];
PrinterTypeScannerWidthGenuineDoubleScore = [];
% get the device info list (with and without rotation)
device_info = halftoneDataAnalyzerObj1.sigmaATestTstatDocArrayPrinterTypeScanner(:, 1:4);
device_info_list = unique(device_info, 'row');
device_info_list(device_info_list(:, 1) > 4, :) = [];
device_info_rot = halftoneDataAnalyzerObj1.sigmaATestTstatDocArrayPrinterTypeScannerRot(:, 1:4);
device_info_rot_list = unique(device_info_rot, 'row');
device_info_rot_list(device_info_rot_list(:, 1) > 4, :) = [];
% for each devide combination
for i = 1:size(device_info_list, 1)
  device_idx = device_info_extract(device_info_list(i, :), device_info);
  device_idx_rot = device_info_extract(device_info_rot_list(i, :), device_info_rot);
  
  PrinterTypeScannerWidthGenuine1 = halftoneDataAnalyzerObj1.sigmaATestTstatDocArrayPrinterTypeScanner(device_idx, :);
  PrinterTypeScannerWidthGenuine1Rot = halftoneDataAnalyzerObj1.sigmaATestTstatDocArrayPrinterTypeScannerRot(device_idx_rot, :);
    
  if isempty(PrinterTypeScannerWidthGenuine1) && isempty(PrinterTypeScannerWidthGenuine1Rot)
    continue;
  end
  % for each document
  for k = 1:length(docIdxList)
    PrinterTypeScannerWidthGenuine = ...
      PrinterTypeScannerWidthGenuine1(PrinterTypeScannerWidthGenuine1(:, 5) == docIdxList(k), :);
    PrinterTypeScannerWidthGenuineRot = ...
      PrinterTypeScannerWidthGenuine1Rot(PrinterTypeScannerWidthGenuine1Rot(:, 5) == docIdxList(k), :);
    if isempty(PrinterTypeScannerWidthGenuine) || isempty(PrinterTypeScannerWidthGenuineRot)
      PrinterTypeScannerWidthGenuineScore(end + 1, :) = [device_info_list(i, :) docIdxList(k) 99];
      PrinterTypeScannerWidthGenuineRotScore(end + 1, :) = [device_info_list(i, :) docIdxList(k) 99];
      PrinterTypeScannerWidthGenuineDoubleScore(end + 1, :) = [device_info_list(i, :) docIdxList(k) 99];
    else
      PrinterTypeScannerWidthGenuineScore(end + 1, :) = [device_info_list(i, :) docIdxList(k) median(PrinterTypeScannerWidthGenuine(:, 8))];
      PrinterTypeScannerWidthGenuineRotScore(end + 1, :) = [device_info_list(i, :) docIdxList(k) median(PrinterTypeScannerWidthGenuineRot(:, 8))];
      PrinterTypeScannerWidthGenuineDoubleScore(end + 1, :) = [device_info_list(i, :) ...
                                                               docIdxList(k) ...
                                                               median([PrinterTypeScannerWidthGenuine(:, 8); PrinterTypeScannerWidthGenuineRot(:, 8)])];
    end
  end
end     
%% collect genuine data for the realistic experiments
% initialize the scores
ScannerWidthGenuineScore = [];
ScannerWidthGenuineRotScore = [];
ScannerWidthGenuineDoubleScore = [];

device_info = halftoneDataAnalyzerObj1.sigmaATestTstatDocArrayScanner(:, 1:4);
device_info_list = unique(device_info, 'row');
device_info_list(device_info_list(:, 1) > 4, :) = [];

device_info_rot = halftoneDataAnalyzerObj1.sigmaATestTstatDocArrayScannerRot(:, 1:4);
device_info_rot_list = unique(device_info_rot, 'row');
device_info_rot_list(device_info_rot_list(:, 1) > 4, :) = [];

% for each printer type
for i = 1:size(device_info_list, 1)
  device_idx = device_info_extract(device_info_list(i, :), device_info);
  device_idx_rot = device_info_extract(device_info_rot_list(i, :), device_info_rot);
  
  ScannerWidthGenuine1 = halftoneDataAnalyzerObj1.sigmaATestTstatDocArrayScanner(device_idx, :);
  ScannerWidthGenuine1Rot = halftoneDataAnalyzerObj1.sigmaATestTstatDocArrayScannerRot(device_idx_rot, :);
  
  if isempty(ScannerWidthGenuine1) && isempty(ScannerWidthGenuine1Rot)
    continue;
  end
  for k = 1:length(docIdxList)
    ScannerWidthGenuine = ScannerWidthGenuine1(ScannerWidthGenuine1(:, 5) == docIdxList(k), :);
    ScannerWidthGenuineRot = ScannerWidthGenuine1Rot(ScannerWidthGenuine1Rot(:, 5) == docIdxList(k), :);
    if isempty(ScannerWidthGenuine) || isempty(ScannerWidthGenuineRot)
      ScannerWidthGenuineScore(end + 1, :) = [device_info_list(i, :) docIdxList(k) 99];
      ScannerWidthGenuineRotScore(end + 1, :) = [device_info_list(i, :) docIdxList(k) 99];
      ScannerWidthGenuineDoubleScore(end + 1, :) = [device_info_list(i, :) docIdxList(k) 99];
%       continue;
    else
      ScannerWidthGenuineScore(end + 1, :) = [device_info_list(i, :) docIdxList(k) median(ScannerWidthGenuine(:, 8))];
      ScannerWidthGenuineRotScore(end + 1, :) = [device_info_list(i, :) docIdxList(k) median(ScannerWidthGenuineRot(:, 8))];
      ScannerWidthGenuineDoubleScore(end + 1, :) = [device_info_list(i, :) docIdxList(k) median([ScannerWidthGenuine(:, 8); ScannerWidthGenuineRot(:, 8)])];
    end
  end
end
%% collect recapture data for the baseline experiments
% initialize the scores
PrinterScannerWidthRecaptureScore = [];
PrinterScannerWidthRecaptureRotScore = [];
PrinterScannerWidthRecaptureDoubleScore = [];

device_info = halftoneDataAnalyzerObj2.sigmaATestTstatDocArrayPrinterScanner(:, 1:4);
device_info_list = unique(device_info, 'row');

device_info_rot = halftoneDataAnalyzerObj2.sigmaATestTstatDocArrayPrinterScannerRot(:, 1:4);
device_info_rot_list = unique(device_info_rot, 'row');

for i = 1:size(device_info_list, 1)
  % get the index of the device from the collection
  device_idx = device_info_extract(device_info_list(i, :), device_info);
  device_idx_rot = device_info_extract(device_info_rot_list(i, :), device_info_rot);
  
  PrinterScannerWidthRecapture1 = halftoneDataAnalyzerObj2.sigmaATestTstatDocArrayPrinterScanner(device_idx, :);
  PrinterScannerWidthRecapture1Rot = halftoneDataAnalyzerObj2.sigmaATestTstatDocArrayPrinterScannerRot(device_idx_rot, :);
  if isempty(PrinterScannerWidthRecapture1) && isempty(PrinterScannerWidthRecapture1Rot)
    continue;
  end
  % for each document
  for k = 1:length(docIdxList)
    PrinterScannerWidthRecapture = ...
      PrinterScannerWidthRecapture1(PrinterScannerWidthRecapture1(:, 5) == docIdxList(k), :);
    PrinterScannerWidthRecaptureRot = ...
      PrinterScannerWidthRecapture1Rot(PrinterScannerWidthRecapture1Rot(:, 5) == docIdxList(k), :);
    if isempty(PrinterScannerWidthRecapture) || isempty(PrinterScannerWidthRecaptureRot)
       % calculate the scores
      PrinterScannerWidthRecaptureScore(end + 1, :) = [device_info_list(i, :) docIdxList(k) 99];
      PrinterScannerWidthRecaptureRotScore(end + 1, :) = [device_info_list(i, :) docIdxList(k) 99];
      PrinterScannerWidthRecaptureDoubleScore(end + 1, :) = [device_info_list(i, :) docIdxList(k) 99];
%       continue;
    else
      % calculate the scores
      PrinterScannerWidthRecaptureScore(end + 1, :) = ...
        [device_info_list(i, :) docIdxList(k) median(PrinterScannerWidthRecapture(:, 8))];
      PrinterScannerWidthRecaptureRotScore(end + 1, :) = ...
        [device_info_list(i, :) docIdxList(k) median(PrinterScannerWidthRecaptureRot(:, 8))];
      PrinterScannerWidthRecaptureDoubleScore(end + 1, :) = ...
        [device_info_list(i, :) docIdxList(k) ...
         median([PrinterScannerWidthRecapture(:, 8); PrinterScannerWidthRecaptureRot(:, 8)])];
    end
  end
end
%% collect recapture data for the semi-controlled experiments
% initialize the scores
PrinterTypeScannerWidthRecaptureScore = [];
PrinterTypeScannerWidthRecaptureRotScore = [];
PrinterTypeScannerWidthRecaptureDoubleScore = [];

device_info = halftoneDataAnalyzerObj2.sigmaATestTstatDocArrayPrinterTypeScanner(:, 1:4);
device_info_list = unique(device_info, 'row');
device_info_list(device_info_list(:, 1) > 4, :) = [];

device_info_rot = halftoneDataAnalyzerObj2.sigmaATestTstatDocArrayPrinterTypeScannerRot(:, 1:4);
device_info_rot_list = unique(device_info_rot, 'row');
device_info_rot_list(device_info_rot_list(:, 1) > 4, :) = [];

% for each printer type
for i = 1:size(device_info_list, 1)
  device_idx = device_info_extract(device_info_list(i, :), device_info);
  device_idx_rot = device_info_extract(device_info_rot_list(i, :), device_info_rot);
  PrinterTypeScannerWidthRecapture1 = ...
    halftoneDataAnalyzerObj2.sigmaATestTstatDocArrayPrinterTypeScanner(device_idx, :);
  PrinterTypeScannerWidthRecapture1Rot = ...
    halftoneDataAnalyzerObj2.sigmaATestTstatDocArrayPrinterTypeScannerRot(device_idx_rot, :);
  if isempty(PrinterTypeScannerWidthRecapture1) && isempty(PrinterTypeScannerWidthRecapture1Rot)
    continue;
  end
  % for each document
  for k = 1:length(docIdxList)
    PrinterTypeScannerWidthRecapture = ...
      PrinterTypeScannerWidthRecapture1(PrinterTypeScannerWidthRecapture1(:, 5) == docIdxList(k), :);
    PrinterTypeScannerWidthRecaptureRot = ...
      PrinterTypeScannerWidthRecapture1Rot(PrinterTypeScannerWidthRecapture1Rot(:, 5) == docIdxList(k), :);
    if isempty(PrinterTypeScannerWidthRecapture) || isempty(PrinterTypeScannerWidthRecaptureRot)
      PrinterTypeScannerWidthRecaptureScore(end + 1, :) = [device_info_list(i, :) docIdxList(k) 99];
      PrinterTypeScannerWidthRecaptureRotScore(end + 1, :) = [device_info_list(i, :) docIdxList(k) 99];
      PrinterTypeScannerWidthRecaptureDoubleScore(end + 1, :) = [device_info_list(i, :) docIdxList(k) 99];
%       continue;
    else
      PrinterTypeScannerWidthRecaptureScore(end + 1, :) = ...
        [device_info_list(i, :) docIdxList(k) median(PrinterTypeScannerWidthRecapture(:, 8))];
      PrinterTypeScannerWidthRecaptureRotScore(end + 1, :) = ...
        [device_info_list(i, :) docIdxList(k) median(PrinterTypeScannerWidthRecaptureRot(:, 8))];
      PrinterTypeScannerWidthRecaptureDoubleScore(end + 1, :) = ...
        [device_info_list(i, :) docIdxList(k) ...
         median([PrinterTypeScannerWidthRecapture(:, 8); PrinterTypeScannerWidthRecaptureRot(:, 8)])];
    end
  end
end     
%% collect recapture data for the realistic experiments

printerIdxList = [1 3 4];
scannerIdxList = [1 2 3];

% initialize the scores
ScannerWidthRecaptureScore = [];
ScannerWidthRecaptureRotScore = [];
ScannerWidthRecaptureDoubleScore = [];

device_info = halftoneDataAnalyzerObj2.sigmaATestTstatDocArrayScanner(:, 1:4);
device_info_list = unique(device_info, 'row');
device_info_list(device_info_list(:, 1) > 4, :) = [];

device_info_rot = halftoneDataAnalyzerObj2.sigmaATestTstatDocArrayScannerRot(:, 1:4);
device_info_rot_list = unique(device_info_rot, 'row');
device_info_rot_list(device_info_rot_list(:, 1) > 4, :) = [];

% for each device combination
for i = 1:size(device_info_list, 1)
  device_idx = device_info_extract(device_info_list(i, :), device_info);
  device_idx_rot = device_info_extract(device_info_rot_list(i, :), device_info_rot);
  
  ScannerWidthRecapture1 = halftoneDataAnalyzerObj2.sigmaATestTstatDocArrayScanner(device_idx, :);
  ScannerWidthRecapture1Rot = halftoneDataAnalyzerObj2.sigmaATestTstatDocArrayScannerRot(device_idx_rot, :);
  
  if isempty(ScannerWidthRecapture1) && isempty(ScannerWidthRecapture1Rot)
    continue;
  end
  % for each document
  for k = 1:length(docIdxList)
    ScannerWidthRecapture = ScannerWidthRecapture1(ScannerWidthRecapture1(:, 5) == docIdxList(k), :);
    ScannerWidthRecaptureRot = ScannerWidthRecapture1Rot(ScannerWidthRecapture1Rot(:, 5) == docIdxList(k), :);
    if isempty(ScannerWidthRecapture) || isempty(ScannerWidthRecaptureRot)
      ScannerWidthRecaptureScore(end + 1, :) =  [device_info_list(i, :) docIdxList(k) 99];
      ScannerWidthRecaptureRotScore(end + 1, :) = [device_info_list(i, :) docIdxList(k) 99];
      ScannerWidthRecaptureDoubleScore(end + 1, :) = [device_info_list(i, :) docIdxList(k) 99];
    else
      ScannerWidthRecaptureScore(end + 1, :) =  [device_info_list(i, :) ...
                                                 docIdxList(k) ...
                                                 median(ScannerWidthRecapture(:, 8))];
      ScannerWidthRecaptureRotScore(end + 1, :) = [device_info_list(i, :) ...
                                                   docIdxList(k) ...
                                                   median(ScannerWidthRecaptureRot(:, 8))];
      ScannerWidthRecaptureDoubleScore(end + 1, :) = [device_info_list(i, :) ...
                                                      docIdxList(k) ...
                                                      median([ScannerWidthRecapture(:, 8); ...
                                                      ScannerWidthRecaptureRot(:, 8)])];
    end
  end
end
%% plot the score distributions
%% baseline doc result (genuine doc vs recapture doc)
figure;
subplot(131);
% fast direction
histBinEdges = -30 : 1 : 30;
histogram(PrinterScannerWidthGenuineScore(:, 6), ...
          histBinEdges, 'Normalization', 'probability');
hold on;
histogram(PrinterScannerWidthRecaptureScore(:, 6), ...
          histBinEdges, 'Normalization', 'probability');
title('score hist baseline fast doc');
legend('genuine doc', 'recapture doc');
set(gca, 'FontName', 'Times', 'FontSize', 25, 'FontSmoothing', 'on');   
set(gcf, 'InnerPosition', [0 0 800 800], 'OuterPosition', [0 0 800 800], 'color', 'w');  
ylim([0 0.25]);
% slow direction
subplot(132);
histogram(PrinterScannerWidthGenuineRotScore(:, 6), ...
          histBinEdges, 'Normalization', 'probability');
hold on;
histogram(PrinterScannerWidthRecaptureRotScore(:, 6), ...
          histBinEdges, 'Normalization', 'probability');
title('score hist baseline slow doc');
legend('genuine doc', 'recapture doc');
set(gca, 'FontName', 'Times', 'FontSize', 25, 'FontSmoothing', 'on');   
set(gcf, 'InnerPosition', [0 0 800 800], 'OuterPosition', [0 0 800 800], 'color', 'w');  
ylim([0 0.25]);
% double direction
subplot(133);
histogram(PrinterScannerWidthGenuineDoubleScore(:, 6), ...
          histBinEdges, 'Normalization', 'probability');
hold on;
histogram(PrinterScannerWidthRecaptureDoubleScore(:, 6), ...
          histBinEdges, 'Normalization', 'probability');
title('score hist baseline double doc');
legend('genuine doc', 'recapture doc');
set(gca, 'FontName', 'Times', 'FontSize', 25, 'FontSmoothing', 'on');   
set(gcf, 'InnerPosition', [0 0 800 800], 'OuterPosition', [0 0 800 800], 'color', 'w');  
ylim([0 0.25]);
%% realistic doc result (genuine doc vs recapture doc)
figure;
subplot(131);
% fast direction
histBinEdges = -30 : 1 : 30;
histogram(ScannerWidthGenuineScore(:, 6), ...
          histBinEdges, 'Normalization', 'probability');
hold on;
histogram(ScannerWidthRecaptureScore(:, 6), ...
          histBinEdges, 'Normalization', 'probability');
title('score hist realistic fast doc');
legend('genuine doc', 'recapture doc');
set(gca, 'FontName', 'Times', 'FontSize', 25, 'FontSmoothing', 'on');   
set(gcf, 'InnerPosition', [0 0 800 800], 'OuterPosition', [0 0 800 800], 'color', 'w');  
ylim([0 0.25]);
% slow direction
subplot(132);
histogram(ScannerWidthGenuineRotScore(:, 6), ...
          histBinEdges, 'Normalization', 'probability');
hold on;
histogram(ScannerWidthRecaptureRotScore(:, 6), ...
          histBinEdges, 'Normalization', 'probability');
title('score hist realistic slow doc');
legend('genuine doc', 'recapture doc');
set(gca, 'FontName', 'Times', 'FontSize', 25, 'FontSmoothing', 'on');   
set(gcf, 'InnerPosition', [0 0 800 800], 'OuterPosition', [0 0 800 800], 'color', 'w');  
ylim([0 0.25]);
% double direction
subplot(133);
histogram(ScannerWidthGenuineDoubleScore(:, 6), ...
          histBinEdges, 'Normalization', 'probability');
hold on;
histogram(ScannerWidthRecaptureDoubleScore(:, 6), ...
          histBinEdges, 'Normalization', 'probability');
title('score hist realistic double doc');
legend('genuine doc', 'recapture doc');
set(gca, 'FontName', 'Times', 'FontSize', 25, 'FontSmoothing', 'on');   
set(gcf, 'InnerPosition', [0 0 800 800], 'OuterPosition', [0 0 800 800], 'color', 'w');  
ylim([0 0.25]);
%% prepare the ROC calculation
% ****** data cleaning and label assignments ******
% for baseline experiments: clean
PrinterScannerWidthGenuineScore(isnan(PrinterScannerWidthGenuineScore(:, 6)), :) = [];
PrinterScannerWidthGenuineRotScore(isnan(PrinterScannerWidthGenuineRotScore(:, 6)), :) = [];
PrinterScannerWidthGenuineDoubleScore(isnan(PrinterScannerWidthGenuineDoubleScore(:, 6)), :) = [];
PrinterScannerWidthRecaptureScore(isnan(PrinterScannerWidthRecaptureScore(:, 6)), :) = [];
PrinterScannerWidthRecaptureRotScore(isnan(PrinterScannerWidthRecaptureRotScore(:, 6)), :) = [];
PrinterScannerWidthRecaptureDoubleScore(isnan(PrinterScannerWidthRecaptureDoubleScore(:, 6)), :) = [];
% for baseline experiments: assign label
PrinterScannerWidthLabels = zeros(1, length(PrinterScannerWidthGenuineScore) + length(PrinterScannerWidthRecaptureScore));
PrinterScannerWidthLabels((length(PrinterScannerWidthGenuineScore) + 1):length(PrinterScannerWidthLabels)) = 1;
PrinterScannerWidthRotLabels = ...
  zeros(1, length(PrinterScannerWidthGenuineRotScore) + length(PrinterScannerWidthRecaptureRotScore));
PrinterScannerWidthRotLabels((length(PrinterScannerWidthGenuineRotScore) + 1):length(PrinterScannerWidthRotLabels)) = 1;
PrinterScannerWidthDoubleLabels = ...
  zeros(1, length(PrinterScannerWidthGenuineDoubleScore) + length(PrinterScannerWidthRecaptureDoubleScore));
PrinterScannerWidthDoubleLabels((length(PrinterScannerWidthGenuineDoubleScore) + 1):length(PrinterScannerWidthDoubleLabels)) = 1; 
% for semi-controlled experiment: clean
PrinterTypeScannerWidthGenuineScore(isnan(PrinterTypeScannerWidthGenuineScore(:, 6)), :) = [];
PrinterTypeScannerWidthGenuineRotScore(isnan(PrinterTypeScannerWidthGenuineRotScore(:, 6)), :) = [];
PrinterTypeScannerWidthGenuineDoubleScore(isnan(PrinterTypeScannerWidthGenuineDoubleScore(:, 6)), :) = [];
PrinterTypeScannerWidthRecaptureScore(isnan(PrinterTypeScannerWidthRecaptureScore(:, 6)), :) = [];
PrinterTypeScannerWidthRecaptureRotScore(isnan(PrinterTypeScannerWidthRecaptureRotScore(:, 6)), :) = [];
PrinterTypeScannerWidthRecaptureDoubleScore(isnan(PrinterTypeScannerWidthRecaptureDoubleScore(:, 6)), :) = [];
% for semi-controlled experiment: assign label
PrinterTypeScannerWidthLabels = ...
  zeros(1, length(PrinterTypeScannerWidthGenuineScore) + length(PrinterTypeScannerWidthRecaptureScore));
PrinterTypeScannerWidthLabels((length(PrinterTypeScannerWidthGenuineScore) + 1):length(PrinterTypeScannerWidthLabels)) = 1;
PrinterTypeScannerWidthRotLabels = ...
  zeros(1, length(PrinterTypeScannerWidthGenuineRotScore) + length(PrinterTypeScannerWidthRecaptureRotScore));
PrinterTypeScannerWidthRotLabels((length(PrinterScannerWidthGenuineRotScore) + 1):length(PrinterTypeScannerWidthRotLabels)) = 1;
PrinterTypeScannerWidthDoubleLabels = ...
  zeros(1, length(PrinterTypeScannerWidthGenuineDoubleScore) + length(PrinterTypeScannerWidthRecaptureDoubleScore));
PrinterTypeScannerWidthDoubleLabels((length(PrinterTypeScannerWidthGenuineDoubleScore) + 1):length(PrinterTypeScannerWidthDoubleLabels)) = 1;
% for realistic experiment: clean
ScannerWidthGenuineScore(isnan(ScannerWidthGenuineScore(:, 6)), :) = [];
ScannerWidthGenuineRotScore(isnan(ScannerWidthGenuineRotScore(:, 6)), :) = [];
ScannerWidthGenuineDoubleScore(isnan(ScannerWidthGenuineDoubleScore(:, 6)), :) = [];
ScannerWidthRecaptureScore(isnan(ScannerWidthRecaptureScore(:, 6)), :) = [];
ScannerWidthRecaptureRotScore(isnan(ScannerWidthRecaptureRotScore(:, 6)), :) = [];
ScannerWidthRecaptureDoubleScore(isnan(ScannerWidthRecaptureDoubleScore(:, 6)), :) = [];
% for realistic experiment: assign labels
ScannerWidthLabels = zeros(1, length(ScannerWidthGenuineScore) + length(ScannerWidthRecaptureScore));
ScannerWidthLabels((length(ScannerWidthGenuineScore) + 1):length(ScannerWidthLabels)) = 1;
ScannerWidthRotLabels = zeros(1, length(ScannerWidthGenuineRotScore) + length(ScannerWidthRecaptureRotScore));
ScannerWidthRotLabels((length(ScannerWidthGenuineRotScore) + 1):length(ScannerWidthRotLabels)) = 1;
ScannerWidthDoubleLabels = zeros(1, length(ScannerWidthGenuineDoubleScore) + length(ScannerWidthRecaptureDoubleScore));
ScannerWidthDoubleLabels((length(ScannerWidthGenuineDoubleScore) + 1):length(ScannerWidthDoubleLabels)) = 1;
%% calculate ROC for baseline experiment proposed method
% fast direction
[proposed_fast_baseline_X, ...
 proposed_fast_baseline_Y, ~, ...
 proposed_fast_baseline_AUC] = perfcurve(PrinterScannerWidthLabels, ...
                                         [PrinterScannerWidthGenuineScore(:, 6); PrinterScannerWidthRecaptureScore(:, 6)], 1);
% slow direction
[proposed_slow_baseline_X, ...
 proposed_slow_baseline_Y, ~, ...
 proposed_slow_baseline_AUC] = ...
  perfcurve(PrinterScannerWidthRotLabels, ...
            [PrinterScannerWidthGenuineRotScore(:, 6); PrinterScannerWidthRecaptureRotScore(:, 6)], 1);
% double direction             
[proposed_double_baseline_X, ...
 proposed_double_baseline_Y, ~,...
 proposed_double_baseline_AUC] = ...
  perfcurve(PrinterScannerWidthDoubleLabels, ...
            [PrinterScannerWidthGenuineDoubleScore(:, 6); PrinterScannerWidthRecaptureDoubleScore(:, 6)], 1);
experiment_result = [experiment_result proposed_fast_baseline_AUC proposed_slow_baseline_AUC proposed_double_baseline_AUC];
%% calculate ROC for semicontrolled experiment proposed method
% fast direction
[proposed_fast_semicontrolled_X, ...
 proposed_fast_semicontrolled_Y, ~, ...
 proposed_fast_semicontrolled_AUC] = ...
  perfcurve(PrinterTypeScannerWidthLabels, ...
            [PrinterTypeScannerWidthGenuineScore(:, 6); PrinterTypeScannerWidthRecaptureScore(:, 6)], 1);
% slow direction
[proposed_slow_semicontrolled_X, ...
 proposed_slow_semicontrolled_Y, ~, ...
 proposed_slow_semicontrolled_AUC] = ...
  perfcurve(PrinterTypeScannerWidthRotLabels, ...
            [PrinterTypeScannerWidthGenuineRotScore(:,6); PrinterTypeScannerWidthRecaptureRotScore(:,6)], 1);
% double direction      
[proposed_double_semicontrolled_X, ...
 proposed_double_semicontrolled_Y, ~, ...
 proposed_double_semicontrolled_AUC] = ...
  perfcurve(PrinterTypeScannerWidthDoubleLabels, ...
            [PrinterTypeScannerWidthGenuineDoubleScore(:,6); PrinterTypeScannerWidthRecaptureDoubleScore(:,6)], 1);
experiment_result = ...
  [experiment_result proposed_fast_semicontrolled_AUC proposed_slow_semicontrolled_AUC proposed_double_semicontrolled_AUC];
%% calculate ROC for realistic experiment proposed method
% fast direction
[proposed_fast_realistic_X, ...
 proposed_fast_realistic_Y,...
 proposed_fast_realistic_Thres, ...
 proposed_fast_realistic_AUC] = ...
  perfcurve(ScannerWidthLabels, [ScannerWidthGenuineScore(:, 6); ScannerWidthRecaptureScore(:, 6)], 1);

RealisticScannerWidthGenuineLaserScore = ScannerWidthGenuineScore(ScannerWidthGenuineScore(:, 1) == 4, :);
RealisticScannerWidthRecaptureLaserScore = ScannerWidthRecaptureScore(ScannerWidthRecaptureScore(:, 1) == 4, :);
RealisticScannerWidthLaserLabels = [zeros(1, length(RealisticScannerWidthGenuineLaserScore)) ...
                                    ones(1, length(RealisticScannerWidthRecaptureLaserScore))];
[proposed_fast_realistic_laser_X, ...
 proposed_fast_realistic_laser_Y,...
 proposed_fast_realisticd_laser_Thres, ...
 proposed_fast_realistic_laser_AUC] = ...
  perfcurve(RealisticScannerWidthLaserLabels, [RealisticScannerWidthGenuineLaserScore(:, 6); RealisticScannerWidthRecaptureLaserScore(:, 6)], 1);
disp(['proposed AUC laser realistic fast: ', num2str(proposed_fast_realistic_laser_AUC)]);

RealisticScannerWidthGenuineInkjetScore = ScannerWidthGenuineScore(ScannerWidthGenuineScore(:, 1) < 4, :);
RealisticScannerWidthRecaptureInkjetScore = ScannerWidthRecaptureScore(ScannerWidthRecaptureScore(:, 1) < 4, :);
RealisticScannerWidthInkjetLabels = [zeros(1, length(RealisticScannerWidthGenuineInkjetScore)) ...
                                     ones(1, length(RealisticScannerWidthRecaptureInkjetScore))];
[proposed_fast_realistic_inkjet_X, ...
 proposed_fast_realistic_inkjet_Y,...
 proposed_fast_realistic_inkjet_Thres, ...
 proposed_fast_realistic_inkjet_AUC] = ...
  perfcurve(RealisticScannerWidthInkjetLabels, [RealisticScannerWidthGenuineInkjetScore(:, 6); RealisticScannerWidthRecaptureInkjetScore(:, 6)], 1);
disp(['proposed AUC inkjet realistic fast: ', num2str(proposed_fast_realistic_inkjet_AUC)]);

% slow direction                  
[proposed_slow_realistic_X, ...
 proposed_slow_realistic_Y, ~, ...
 proposed_slow_realistic_AUC] = ...
    perfcurve(ScannerWidthRotLabels, [ScannerWidthGenuineRotScore(:, 6); ScannerWidthRecaptureRotScore(:, 6)], 1);

RealisticScannerWidthGenuineLaserRotScore = ScannerWidthGenuineRotScore(ScannerWidthGenuineRotScore(:, 1) == 4, :);
RealisticScannerWidthRecaptureLaserRotScore = ScannerWidthRecaptureRotScore(ScannerWidthRecaptureRotScore(:, 1) == 4, :);
RealisticScannerWidthLaserRotLabels = [zeros(1, length(RealisticScannerWidthGenuineLaserRotScore)) ...
                                       ones(1, length(RealisticScannerWidthRecaptureLaserRotScore))];
[proposed_slow_realistic_laser_X, ...
 proposed_slow_realistic_laser_Y,...
 proposed_slow_realisticd_laser_Thres, ...
 proposed_slow_realistic_laser_AUC] = ...
  perfcurve(RealisticScannerWidthLaserRotLabels, [RealisticScannerWidthGenuineLaserRotScore(:, 6); ...
                                                  RealisticScannerWidthRecaptureLaserRotScore(:, 6)], 1);
disp(['proposed AUC laser realistic slow: ', num2str(proposed_slow_realistic_laser_AUC)]);

RealisticScannerWidthGenuineInkjetRotScore = ScannerWidthGenuineRotScore(ScannerWidthGenuineRotScore(:, 1) < 4, :);
RealisticScannerWidthRecaptureInkjetRotScore = ScannerWidthRecaptureRotScore(ScannerWidthRecaptureRotScore(:, 1) < 4, :);
RealisticScannerWidthInkjetRotLabels = [zeros(1, length(RealisticScannerWidthGenuineInkjetRotScore)) ...
                                        ones(1, length(RealisticScannerWidthRecaptureInkjetRotScore))];
[proposed_slow_realistic_inkjet_X, ...
 proposed_slow_realistic_inkjet_Y,...
 proposed_slow_realistic_inkjet_Thres, ...
 proposed_slow_realistic_inkjet_AUC] = ...
  perfcurve(RealisticScannerWidthInkjetRotLabels, [RealisticScannerWidthGenuineInkjetRotScore(:, 6); ...
                                                   RealisticScannerWidthRecaptureInkjetRotScore(:, 6)], 1);
disp(['proposed AUC inkjet realistic slow: ', num2str(proposed_slow_realistic_inkjet_AUC)]);

% double direction                  
[proposed_double_realistic_X, ...
 proposed_double_realistic_Y, ~, ...
 proposed_double_realistic_AUC] = ...
  perfcurve(ScannerWidthDoubleLabels, [ScannerWidthGenuineDoubleScore(:, 6); ScannerWidthRecaptureDoubleScore(:, 6)], 1);
experiment_result = [experiment_result proposed_fast_realistic_AUC proposed_slow_realistic_AUC proposed_double_realistic_AUC];

RealisticScannerWidthGenuineLaserDoubleScore = ScannerWidthGenuineDoubleScore(ScannerWidthGenuineDoubleScore(:, 1) == 4, :);
RealisticScannerWidthRecaptureLaserDoubleScore = ScannerWidthRecaptureDoubleScore(ScannerWidthRecaptureDoubleScore(:, 1) == 4, :);
RealisticScannerWidthLaserDoubleLabels = [zeros(1, length(RealisticScannerWidthGenuineLaserDoubleScore)) ...
                                          ones(1, length(RealisticScannerWidthRecaptureLaserDoubleScore))];
  
[proposed_double_realistic_laser_X, ...
 proposed_double_realistic_laser_Y,...
 proposed_double_realisticd_laser_Thres, ...
 proposed_double_realistic_laser_AUC] = ...
    perfcurve(RealisticScannerWidthLaserDoubleLabels, ...
              [RealisticScannerWidthGenuineLaserDoubleScore(:, 6); RealisticScannerWidthRecaptureLaserDoubleScore(:, 6)], 1);
disp(['proposed AUC laser realistic double: ', num2str(proposed_double_realistic_laser_AUC)]);

RealisticScannerWidthGenuineInkjetDoubleScore = ScannerWidthGenuineDoubleScore(ScannerWidthGenuineDoubleScore(:, 1) < 4, :);
RealisticScannerWidthRecaptureInkjetDoubleScore = ScannerWidthRecaptureDoubleScore(ScannerWidthRecaptureDoubleScore(:, 1) < 4, :);
RealisticScannerWidthInkjetDoubleLabels = ...
  [zeros(1, length(RealisticScannerWidthGenuineInkjetDoubleScore)) ones(1, length(RealisticScannerWidthRecaptureInkjetDoubleScore))];
[proposed_double_realistic_inkjet_X, ...
 proposed_double_realistic_inkjet_Y,...
 proposed_double_realistic_inkjet_Thres, ...
 proposed_double_realistic_inkjet_AUC] = ...
  perfcurve(RealisticScannerWidthInkjetDoubleLabels, ...
            [RealisticScannerWidthGenuineInkjetDoubleScore(:, 6); RealisticScannerWidthRecaptureInkjetDoubleScore(:, 6)], 1);
disp(['proposed AUC inkjet realistic double: ', num2str(proposed_double_realistic_inkjet_AUC)]);
%% plot the ROC result
% plot the ROC result for baseline experiment
figure;
plot(proposed_fast_baseline_X, proposed_fast_baseline_Y, 'LineWidth', 5);
hold on;
plot(proposed_slow_baseline_X, proposed_slow_baseline_Y, 'LineWidth', 5);
plot(proposed_double_baseline_X, proposed_double_baseline_Y, ':', 'LineWidth', 5);
xlabel('FPR'); ylabel('TPR');
legend('proposed (horizontal)', 'proposed (vertical)', 'proposed (double)', 'Location', 'southeast');
set(gca, 'FontName', 'times', 'FontSize', 25, 'FontSmoothing', 'on');  
set(gcf, 'units', 'pixels','OuterPosition', [0 0 700 700], 'Position', [0 0 700 700], 'Color', 'w');
disp(['proposed_fast_baseline_AUC: ', num2str(proposed_fast_baseline_AUC)]);
disp(['proposed_slow_baseline_AUC: ', num2str(proposed_slow_baseline_AUC)]);
disp(['proposed_double_baseline_AUC: ', num2str(proposed_double_baseline_AUC)]);

% plot the ROC result for semicontrolled experiment
figure;
plot(proposed_fast_semicontrolled_X, proposed_fast_semicontrolled_Y, 'LineWidth', 5);
hold on;
plot(proposed_slow_semicontrolled_X, proposed_slow_semicontrolled_Y, 'LineWidth', 5);
plot(proposed_double_semicontrolled_X, proposed_double_semicontrolled_Y, 'LineWidth', 5);
xlabel('FPR'); ylabel('TPR');
legend('proposed (horizontal)', 'proposed (vertical)', 'proposed (double)', 'Location', 'southeast');
set(gca, 'FontName', 'times', 'FontSize', 25, 'FontSmoothing', 'on');  
set(gcf, 'units', 'pixels','OuterPosition', [0 0 700 700], 'Position', [0 0 700 700], 'Color', 'w');
disp(['proposed_fast_semicontrolled_AUC: ' num2str(proposed_fast_semicontrolled_AUC)]);
disp(['proposed_slow_semicontrolled_AUC: ' num2str(proposed_slow_semicontrolled_AUC)]);
disp(['proposed_double_semicontrolled_AUC: ', num2str(proposed_double_semicontrolled_AUC)]);

% plot the ROC result for realistic experiment
figure;
plot(proposed_fast_realistic_X, proposed_fast_realistic_Y, 'LineWidth', 5);
hold on;
plot(proposed_slow_realistic_X, proposed_slow_realistic_Y, 'LineWidth', 5);
plot(proposed_double_realistic_X, proposed_double_realistic_Y, 'LineWidth', 5);
xlabel('FPR'); ylabel('TPR');
legend('proposed (horizontal)', 'proposed (vertical)', 'proposed (double)', 'Location', 'southeast');
set(gca, 'FontName', 'times', 'FontSize', 25, 'FontSmoothing', 'on');  
set(gcf, 'units', 'pixels','OuterPosition', [0 0 700 700], 'Position', [0 0 700 700], 'Color', 'w');
disp(['proposed_fast_realistic_AUC: ' num2str(proposed_fast_realistic_AUC)]);
disp(['proposed_slow_realistic_AUC: ' num2str(proposed_slow_realistic_AUC)]);
disp(['proposed_double_realistic_AUC: ', num2str(proposed_double_realistic_AUC)]);