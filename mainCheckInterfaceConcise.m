%% this script include the analysis of the collected data
%% workspace initialization
close all; 
clc;
set(0, 'DefaultFigureVisible', 'on');
clear;
%%
databaseDirPath = '';
%% process the genuine images
refDataPath = ['data_1st_ref_45_73_224_1200_space_7.mat'];
docDataPath = ['data_1st_doc_45_73_224_1200_space_7.mat'];
halftoneDataAnalyzerObj1 = halftoneDataAnalyzer(refDataPath, docDataPath, 1);
halftoneDataAnalyzerObj1.sampleSize = 10;
halftoneDataAnalyzerObj1 = halftoneDataAnalyzerObj1.checkSigmaAHistogram();
halftoneDataAnalyzerObj1 = halftoneDataAnalyzerObj1.getTStatBaseLine();
halftoneDataAnalyzerObj1 = halftoneDataAnalyzerObj1.getTStatTest();
halftoneDataAnalyzerObj1 = halftoneDataAnalyzerObj1.checkTStat();
halftoneDataAnalyzerObj1 = halftoneDataAnalyzerObj1.testTStat();
close all;
%% process the recaptured 
refDataPath = ['data_1st_ref_45_73_224_1200_space_7.mat'];
docDataPath = ['data_2nd_doc_45_73_224_1200_space_7.mat'];
halftoneDataAnalyzerObj2 = halftoneDataAnalyzer(refDataPath, docDataPath, 2);
halftoneDataAnalyzerObj2.sampleSize = 10;
halftoneDataAnalyzerObj2.checkSigmaAHistogram();
halftoneDataAnalyzerObj2 = halftoneDataAnalyzerObj2.getTStatBaseLine();
halftoneDataAnalyzerObj2 = halftoneDataAnalyzerObj2.getTStatTest();
halftoneDataAnalyzerObj2 = halftoneDataAnalyzerObj2.checkTStat();
halftoneDataAnalyzerObj2 = halftoneDataAnalyzerObj2.testTStat();
close all;
%% initilize the experiment result
experiment_result = [];
%% collect genuine data for the baseline experiments
docIdxList = 1:22;
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
for i = 1:length(device_info_list)
  % get the device indices
  device_idx = device_info_extract(device_info_list(i, :), device_info);
  device_idx_rot = device_info_extract(device_info_rot_list(i, :), device_info_rot);
  % get the sigmaA results
  PrinterScannerWidthGenuine1 = halftoneDataAnalyzerObj1.sigmaATestTstatDocArrayPrinterScanner(device_idx, :);
  PrinterScannerWidthGenuine1Rot = halftoneDataAnalyzerObj1.sigmaATestTstatDocArrayPrinterScannerRot(device_idx_rot, :);
  % continue if there is no result
  if isempty(PrinterScannerWidthGenuine1) && isempty(PrinterScannerWidthGenuine1Rot)
    continue;
  end
  % for each document
  for k = 1:length(docIdxList)
    PrinterScannerWidthGenuine = PrinterScannerWidthGenuine1(PrinterScannerWidthGenuine1(:, 5) == docIdxList(k), :);
    PrinterScannerWidthGenuineRot = PrinterScannerWidthGenuine1Rot(PrinterScannerWidthGenuine1Rot(:, 5) == docIdxList(k), :);
    if isempty(PrinterScannerWidthGenuine) || isempty(PrinterScannerWidthGenuineRot)
      PrinterScannerWidthGenuineScore(end + 1, :) = [device_info_list(i, :) docIdxList(k) 99];
      PrinterScannerWidthGenuineRotScore(end + 1, :) = [device_info_rot_list(i, :) docIdxList(k) 99];
      PrinterScannerWidthGenuineDoubleScore(end + 1, :) = [device_info_list(i, :) docIdxList(k) 99];
    else
      PrinterScannerWidthGenuineScore(end + 1, :) = [device_info_list(i, :) docIdxList(k) median(PrinterScannerWidthGenuine(:, 8))];
      PrinterScannerWidthGenuineRotScore(end + 1, :) = [device_info_rot_list(i, :) docIdxList(k) median(PrinterScannerWidthGenuineRot(:, 8))];
      PrinterScannerWidthGenuineDoubleScore(end + 1, :) = ...
      [device_info_list(i, :) docIdxList(k) median([PrinterScannerWidthGenuine(:, 8); PrinterScannerWidthGenuineRot(:, 8)])];
    end
  end
end      
%% collect genuine data for the semi-controlled experiments
docIdxList = 1:22;

% initialize the scores for document images
PrinterTypeScannerWidthGenuineScore = [];
PrinterTypeScannerWidthGenuineRotScore = [];
PrinterTypeScannerWidthGenuineDoubleScore = [];

% get the device info list in terms of doc (with and without rotation)
device_info = halftoneDataAnalyzerObj1.sigmaATestTstatDocArrayPrinterTypeScanner(:, 1:4);
device_info_list = unique(device_info, 'row');
device_info_list(device_info_list(:, 1) > 4, :) = [];
device_info_rot = halftoneDataAnalyzerObj1.sigmaATestTstatDocArrayPrinterTypeScannerRot(:, 1:4);
device_info_rot_list = unique(device_info_rot, 'row');
device_info_rot_list(device_info_rot_list(:, 1) > 4, :) = [];
% get the device info list in terms of image blocks
device_info_array = halftoneDataAnalyzerObj1.sampleHalftoneWidthBaselineArray(:, 1:4);
device_info_array_list = unique(device_info_array, 'row');
device_info_array_list(device_info_array_list(:, 1) > 4, :) = [];
device_info_rot = halftoneDataAnalyzerObj1.sigmaATestTstatDocArrayPrinterTypeScannerRot(:, 1:4);
device_info_rot_list = unique(device_info_rot, 'row');
device_info_rot_list(device_info_rot_list(:, 1) > 4, :) = [];

% for each devide combination
for i = 1:length(device_info_list)
  device_idx = device_info_extract(device_info_list(i, :), device_info);
  device_idx_rot = device_info_extract(device_info_rot_list(i, :), device_info_rot);
  PrinterTypeScannerWidthGenuine1 = halftoneDataAnalyzerObj1.sigmaATestTstatDocArrayPrinterTypeScanner(device_idx, :);
  PrinterTypeScannerWidthGenuine1Rot = halftoneDataAnalyzerObj1.sigmaATestTstatDocArrayPrinterTypeScannerRot(device_idx_rot, :);
  if isempty(PrinterTypeScannerWidthGenuine1) && isempty(PrinterTypeScannerWidthGenuine1Rot)
    continue;
  end
  % for each document
  for k = 1:length(docIdxList)
    PrinterTypeScannerWidthGenuine = PrinterTypeScannerWidthGenuine1(PrinterTypeScannerWidthGenuine1(:, 5) == docIdxList(k), :);
    PrinterTypeScannerWidthGenuineRot = PrinterTypeScannerWidthGenuine1Rot(PrinterTypeScannerWidthGenuine1Rot(:, 5) == docIdxList(k), :);
    if isempty(PrinterTypeScannerWidthGenuine) || isempty(PrinterTypeScannerWidthGenuineRot)
      PrinterTypeScannerWidthGenuineScore(end + 1, :) = [device_info_list(i, :) docIdxList(k) 99];
      PrinterTypeScannerWidthGenuineRotScore(end + 1, :) = [device_info_list(i, :) docIdxList(k) 99];
      PrinterTypeScannerWidthGenuineDoubleScore(end + 1, :) = [device_info_list(i, :) docIdxList(k) 99];
    else
      PrinterTypeScannerWidthGenuineScore(end + 1, :) = [device_info_list(i, :) docIdxList(k) median(PrinterTypeScannerWidthGenuine(:, 8))];
      PrinterTypeScannerWidthGenuineRotScore(end + 1, :) = [device_info_list(i, :) docIdxList(k) median(PrinterTypeScannerWidthGenuineRot(:, 8))];
      PrinterTypeScannerWidthGenuineDoubleScore(end + 1, :) = ...
      [device_info_list(i, :) docIdxList(k) median([PrinterTypeScannerWidthGenuine(:, 8); PrinterTypeScannerWidthGenuineRot(:, 8)])];
    end
  end
end     
%% collect genuine data for the realistic experiments
docIdxList = 1:22;

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
for i = 1:length(device_info_list)
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
    else
      ScannerWidthGenuineScore(end + 1, :) = [device_info_list(i, :) docIdxList(k) median(ScannerWidthGenuine(:, 8))];
      ScannerWidthGenuineRotScore(end + 1, :) = [device_info_list(i, :) docIdxList(k) median(ScannerWidthGenuineRot(:, 8))];
      ScannerWidthGenuineDoubleScore(end + 1, :) = ...
      [device_info_list(i, :) docIdxList(k) median([ScannerWidthGenuine(:, 8); ScannerWidthGenuineRot(:, 8)])];
    end
  end
end
%% collect genuine data for the in-the-wild experiments
docIdxList = [23 24 25 28 32 34];

% initialize the scores
WildScannerWidthGenuineScore = [];
WildScannerWidthGenuineRotScore = [];
WildScannerWidthGenuineDoubleScore = [];

device_info = halftoneDataAnalyzerObj1.sigmaATestTstatDocArrayPrinterTypeScanner(:, 1:4);
device_info_rot = halftoneDataAnalyzerObj1.sigmaATestTstatDocArrayPrinterTypeScannerRot(:, 1:4);

device_info_list = unique(device_info, 'row');
device_info_list(device_info_list(:, 1) < 5, :) = [];

device_info_rot_list = unique(device_info_rot, 'row');
device_info_rot_list(device_info_rot_list(:, 1) < 5, :) = [];

% for each printer
for i = 1:length(device_info_list)
  device_idx = device_info_extract(device_info_list(i, :), device_info);
  device_idx_rot = device_info_extract(device_info_rot_list(i, :), device_info_rot);
  
  % find the t-test results
  WildScannerWidthGenuine1 = halftoneDataAnalyzerObj1.sigmaATestTstatDocArrayScanner(device_idx, :);
  WildScannerWidthGenuine1Rot = halftoneDataAnalyzerObj1.sigmaATestTstatDocArrayScannerRot(device_idx_rot, :);
  
  % continue if there is no t-test result
  if isempty(WildScannerWidthGenuine1) && isempty(WildScannerWidthGenuine1Rot)
    continue;
  end
  % for each document
  for k = 1:length(docIdxList)
    % find the t-test results corresponding to documents
    WildScannerWidthGenuine = WildScannerWidthGenuine1(WildScannerWidthGenuine1(:, 5) == docIdxList(k), :);
    WildScannerWidthGenuineRot = WildScannerWidthGenuine1Rot(WildScannerWidthGenuine1Rot(:, 5) == docIdxList(k), :);
    if isempty(WildScannerWidthGenuine) || isempty(WildScannerWidthGenuineRot)
      WildScannerWidthGenuineScore(end + 1, :) = [device_info_list(i, :) docIdxList(k) 99];
      WildScannerWidthGenuineRotScore(end + 1, :) = [device_info_list(i, :) docIdxList(k) 99];
      WildScannerWidthGenuineDoubleScore(end + 1, :) = [device_info_list(i, :) docIdxList(k) 99];
%       continue;
    else
      WildScannerWidthGenuineScore(end + 1, :) = [device_info_list(i, :) docIdxList(k) median(WildScannerWidthGenuine(:, 8))];
      WildScannerWidthGenuineRotScore(end + 1, :) = [device_info_list(i, :) docIdxList(k) median(WildScannerWidthGenuineRot(:, 8))];
      WildScannerWidthGenuineDoubleScore(end + 1, :) = ...
      [device_info_list(i, :) docIdxList(k) median([WildScannerWidthGenuine(:, 8); WildScannerWidthGenuineRot(:, 8)])];
    end
  end
end
%% collect recapture data for the baseline experiments
docIdxList = 1:22;

% initialize the scores
PrinterScannerWidthRecaptureScore = [];
PrinterScannerWidthRecaptureRotScore = [];
PrinterScannerWidthRecaptureDoubleScore = [];

device_info = halftoneDataAnalyzerObj2.sigmaATestTstatDocArrayPrinterScanner(:, 1:4);
device_info_list = unique(device_info, 'row');

device_info_rot = halftoneDataAnalyzerObj2.sigmaATestTstatDocArrayPrinterScannerRot(:, 1:4);
device_info_rot_list = unique(device_info_rot, 'row');

for i = 1:length(device_info_list)
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
    PrinterScannerWidthRecapture = PrinterScannerWidthRecapture1(PrinterScannerWidthRecapture1(:, 5) == docIdxList(k), :);
    PrinterScannerWidthRecaptureRot = PrinterScannerWidthRecapture1Rot(PrinterScannerWidthRecapture1Rot(:, 5) == docIdxList(k), :);
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
        [device_info_list(i, :) docIdxList(k) median([PrinterScannerWidthRecapture(:, 8); PrinterScannerWidthRecaptureRot(:, 8)])];
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
for i = 1:length(device_info_list)
  device_idx = device_info_extract(device_info_list(i, :), device_info);
  device_idx_rot = device_info_extract(device_info_rot_list(i, :), device_info_rot);
  PrinterTypeScannerWidthRecapture1 = halftoneDataAnalyzerObj2.sigmaATestTstatDocArrayPrinterTypeScanner(device_idx, :);
  PrinterTypeScannerWidthRecapture1Rot = halftoneDataAnalyzerObj2.sigmaATestTstatDocArrayPrinterTypeScannerRot(device_idx_rot, :);
  if isempty(PrinterTypeScannerWidthRecapture1) && isempty(PrinterTypeScannerWidthRecapture1Rot)
    continue;
  end
  % for each document
  for k = 1:length(docIdxList)
    PrinterTypeScannerWidthRecapture = PrinterTypeScannerWidthRecapture1(PrinterTypeScannerWidthRecapture1(:, 5) == docIdxList(k), :);
    PrinterTypeScannerWidthRecaptureRot = PrinterTypeScannerWidthRecapture1Rot(PrinterTypeScannerWidthRecapture1Rot(:, 5) == docIdxList(k), :);
    if isempty(PrinterTypeScannerWidthRecapture) || isempty(PrinterTypeScannerWidthRecaptureRot)
      PrinterTypeScannerWidthRecaptureScore(end + 1, :) = [device_info_list(i, :) docIdxList(k) 99];
      PrinterTypeScannerWidthRecaptureRotScore(end + 1, :) = [device_info_list(i, :) docIdxList(k) 99];
      PrinterTypeScannerWidthRecaptureDoubleScore(end + 1, :) = [device_info_list(i, :) docIdxList(k) 99];
    else
      PrinterTypeScannerWidthRecaptureScore(end + 1, :) = [device_info_list(i, :) docIdxList(k) median(PrinterTypeScannerWidthRecapture(:, 8))];
      PrinterTypeScannerWidthRecaptureRotScore(end + 1, :) = [device_info_list(i, :) docIdxList(k) median(PrinterTypeScannerWidthRecaptureRot(:, 8))];
      PrinterTypeScannerWidthRecaptureDoubleScore(end + 1, :) = ...
      [device_info_list(i, :) docIdxList(k) median([PrinterTypeScannerWidthRecapture(:, 8); PrinterTypeScannerWidthRecaptureRot(:, 8)])];
    end
  end
end     
%% collect recapture data for the realistic experiments
printerIdxList = [1 3 4];
scannerIdxList = [1 3];

docIdxList = 1:22;

%initialize the scores
ScannerWidthRecaptureScore = [];
ScannerWidthRecaptureRotScore = [];
ScannerWidthRecaptureDoubleScore = [];

device_info = halftoneDataAnalyzerObj2.sigmaATestTstatDocArrayScanner(:, 1:4);
device_info_list = unique(device_info, 'row');
device_info_list(device_info_list(:, 1) > 4, :) = [];

device_info_rot = halftoneDataAnalyzerObj2.sigmaATestTstatDocArrayScannerRot(:, 1:4);
device_info_rot_list = unique(device_info_rot, 'row');
device_info_rot_list(device_info_rot_list(:, 1) > 4, :) = [];

% for each printer
for i = 1:length(device_info_list)
  device_idx = device_info_extract(device_info_list(i, :), device_info);
  device_idx_rot = device_info_extract(device_info_rot_list(i, :), device_info_rot);
  
  ScannerWidthRecapture1 = halftoneDataAnalyzerObj2.sigmaATestTstatDocArrayScanner(device_idx, :);
  ScannerWidthRecapture1Rot = halftoneDataAnalyzerObj2.sigmaATestTstatDocArrayScannerRot(device_idx_rot, :);
  
  if isempty(ScannerWidthRecapture1) && isempty(ScannerWidthRecapture1Rot)
    continue;
  end
  for k = 1:length(docIdxList)
    ScannerWidthRecapture = ScannerWidthRecapture1(ScannerWidthRecapture1(:, 5) == docIdxList(k), :);
    ScannerWidthRecaptureRot = ScannerWidthRecapture1Rot(ScannerWidthRecapture1Rot(:, 5) == docIdxList(k), :);
    if isempty(ScannerWidthRecapture) || isempty(ScannerWidthRecaptureRot)
      ScannerWidthRecaptureScore(end + 1, :) =  [device_info_list(i, :) docIdxList(k) 99];
      ScannerWidthRecaptureRotScore(end + 1, :) = [device_info_list(i, :) docIdxList(k) 99];
      ScannerWidthRecaptureDoubleScore(end + 1, :) = [device_info_list(i, :) docIdxList(k) 99];
    else
      ScannerWidthRecaptureScore(end + 1, :) =  [device_info_list(i, :) docIdxList(k) median(ScannerWidthRecapture(:, 8))];
      ScannerWidthRecaptureRotScore(end + 1, :) = [device_info_list(i, :) docIdxList(k) median(ScannerWidthRecaptureRot(:, 8))];
      ScannerWidthRecaptureDoubleScore(end + 1, :) = ...
      [device_info_list(i, :) docIdxList(k) median([ScannerWidthRecapture(:, 8); ScannerWidthRecaptureRot(:, 8)])];
    end
  end
end                                              
%% collect recapture data for in-the-wild experiments
docIdxList = [23 24 25 28 32 34];

% initialize the scores
WildScannerWidthRecaptureScore = [];
WildScannerWidthRecaptureRotScore = [];
WildScannerWidthRecaptureDoubleScore = [];

device_info = halftoneDataAnalyzerObj2.sigmaATestTstatDocArrayScanner(:, 1:4);
device_info_rot = halftoneDataAnalyzerObj2.sigmaATestTstatDocArrayScannerRot(:, 1:4);

device_info_list = unique(device_info, 'row');
device_info_list(device_info_list(:, 1) < 5, :) = [];

device_info_rot_list = unique(device_info_rot, 'row');
device_info_rot_list(device_info_rot_list(:, 1) < 5, :) = [];

% for each printer
for i = 1:length(device_info_list)
  device_idx = device_info_extract(device_info_list(i, :), device_info);
  device_idx_rot = device_info_extract(device_info_rot_list(i, :), device_info_rot);
  
  WildScannerWidthRecapture1 = halftoneDataAnalyzerObj2.sigmaATestTstatDocArrayScanner(device_idx, :);
  WildScannerWidthRecapture1Rot = halftoneDataAnalyzerObj2.sigmaATestTstatDocArrayScannerRot(device_idx_rot, :);
  
  if isempty(WildScannerWidthRecapture1) && isempty(WildScannerWidthRecapture1Rot)
    continue;
  end
  % for each document
  for k = 1:length(docIdxList)
    WildScannerWidthRecapture = WildScannerWidthRecapture1(WildScannerWidthRecapture1(:, 5) == docIdxList(k), :);
    WildScannerWidthRecaptureRot = WildScannerWidthRecapture1Rot(WildScannerWidthRecapture1Rot(:, 5) == docIdxList(k), :);
    if isempty(WildScannerWidthRecapture) || isempty(WildScannerWidthRecaptureRot)
      WildScannerWidthRecaptureScore(end + 1, :) =  [device_info_list(i, :) docIdxList(k) 99];
      WildScannerWidthRecaptureRotScore(end + 1, :) = [device_info_list(i, :) docIdxList(k) 99];
      WildScannerWidthRecaptureDoubleScore(end + 1, :) = [device_info_list(i, :) docIdxList(k) 99];
    else
      WildScannerWidthRecaptureScore(end + 1, :) =  [device_info_list(i, :) docIdxList(k) median(WildScannerWidthRecapture(:, 8))];
      WildScannerWidthRecaptureRotScore(end + 1, :) = [device_info_list(i, :) docIdxList(k) median(WildScannerWidthRecaptureRot(:, 8))];
      WildScannerWidthRecaptureDoubleScore(end + 1, :) = ...
      [device_info_list(i, :) docIdxList(k) median([WildScannerWidthRecapture(:, 8); WildScannerWidthRecaptureRot(:, 8)])];
    end
  end
end
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
PrinterScannerWidthRotLabels = zeros(1, length(PrinterScannerWidthGenuineRotScore) + length(PrinterScannerWidthRecaptureRotScore));
PrinterScannerWidthRotLabels((length(PrinterScannerWidthGenuineRotScore) + 1):length(PrinterScannerWidthRotLabels)) = 1;
PrinterScannerWidthDoubleLabels = zeros(1, length(PrinterScannerWidthGenuineDoubleScore) + length(PrinterScannerWidthRecaptureDoubleScore));
PrinterScannerWidthDoubleLabels((length(PrinterScannerWidthGenuineDoubleScore) + 1):length(PrinterScannerWidthDoubleLabels)) = 1; 
% for semi-controlled experiment: clean
PrinterTypeScannerWidthGenuineScore(isnan(PrinterTypeScannerWidthGenuineScore(:, 6)), :) = [];
PrinterTypeScannerWidthGenuineRotScore(isnan(PrinterTypeScannerWidthGenuineRotScore(:, 6)), :) = [];
PrinterTypeScannerWidthGenuineDoubleScore(isnan(PrinterTypeScannerWidthGenuineDoubleScore(:, 6)), :) = [];
PrinterTypeScannerWidthRecaptureScore(isnan(PrinterTypeScannerWidthRecaptureScore(:, 6)), :) = [];
PrinterTypeScannerWidthRecaptureRotScore(isnan(PrinterTypeScannerWidthRecaptureRotScore(:, 6)), :) = [];
PrinterTypeScannerWidthRecaptureDoubleScore(isnan(PrinterTypeScannerWidthRecaptureDoubleScore(:, 6)), :) = [];
% for semi-controlled experiment: assign label
PrinterTypeScannerWidthLabels = zeros(1, length(PrinterTypeScannerWidthGenuineScore) + length(PrinterTypeScannerWidthRecaptureScore));
PrinterTypeScannerWidthLabels((length(PrinterTypeScannerWidthGenuineScore) + 1):length(PrinterTypeScannerWidthLabels)) = 1;
PrinterTypeScannerWidthRotLabels = zeros(1, length(PrinterTypeScannerWidthGenuineRotScore) + length(PrinterTypeScannerWidthRecaptureRotScore));
PrinterTypeScannerWidthRotLabels((length(PrinterScannerWidthGenuineRotScore) + 1):length(PrinterTypeScannerWidthRotLabels)) = 1;
PrinterTypeScannerWidthDoubleLabels = zeros(1, length(PrinterTypeScannerWidthGenuineDoubleScore) + length(PrinterTypeScannerWidthRecaptureDoubleScore));
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
% for wild experiment: clean
WildScannerWidthGenuineScore(isnan(WildScannerWidthGenuineScore(:, 6)), :) = [];
WildScannerWidthGenuineRotScore(isnan(WildScannerWidthGenuineRotScore(:, 6)), :) = [];
WildScannerWidthGenuineDoubleScore(isnan(WildScannerWidthGenuineDoubleScore(:, 6)), :) = [];
WildScannerWidthRecaptureScore(isnan(WildScannerWidthRecaptureScore(:, 6)), :) = [];
WildScannerWidthRecaptureRotScore(isnan(WildScannerWidthRecaptureRotScore(:, 6)), :) = [];
WildScannerWidthRecaptureDoubleScore(isnan(WildScannerWidthRecaptureDoubleScore(:, 6)), :) = [];
% for wild experiment: assign labels
WildScannerWidthLabels = zeros(1, length(WildScannerWidthGenuineScore) + length(WildScannerWidthRecaptureScore));
WildScannerWidthLabels((length(WildScannerWidthGenuineScore) + 1):length(WildScannerWidthLabels)) = 1;
WildScannerWidthRotLabels = zeros(1, length(WildScannerWidthGenuineRotScore) + length(WildScannerWidthRecaptureRotScore));
WildScannerWidthRotLabels((length(WildScannerWidthGenuineRotScore) + 1):length(WildScannerWidthRotLabels)) = 1;
WildScannerWidthDoubleLabels = zeros(1, length(WildScannerWidthGenuineDoubleScore) + length(WildScannerWidthRecaptureDoubleScore));
WildScannerWidthDoubleLabels((length(WildScannerWidthGenuineDoubleScore) + 1):length(WildScannerWidthDoubleLabels)) = 1;
%% calculate ROC for baseline experiment proposed method
% fast direction
[proposed_fast_baseline_X, ...
  proposed_fast_baseline_Y, ~, ...
  proposed_fast_baseline_AUC] = ...
    perfcurve(PrinterScannerWidthLabels, [PrinterScannerWidthGenuineScore(:, 6); PrinterScannerWidthRecaptureScore(:, 6)], 1);
% slow direction
[proposed_slow_baseline_X, ...
  proposed_slow_baseline_Y, ~, ...
  proposed_slow_baseline_AUC] = ...
    perfcurve(PrinterScannerWidthRotLabels, [PrinterScannerWidthGenuineRotScore(:, 6); PrinterScannerWidthRecaptureRotScore(:, 6)], 1);
% double direction             
[proposed_double_baseline_X, ...
  proposed_double_baseline_Y, ~,...
  proposed_double_baseline_AUC] = ...
    perfcurve(PrinterScannerWidthDoubleLabels, [PrinterScannerWidthGenuineDoubleScore(:, 6); PrinterScannerWidthRecaptureDoubleScore(:, 6)], 1);
experiment_result = [experiment_result proposed_fast_baseline_AUC proposed_slow_baseline_AUC proposed_double_baseline_AUC];
%% calculate ROC for semicontrolled experiment proposed method
% fast direction
[proposed_fast_semicontrolled_X, ...
  proposed_fast_semicontrolled_Y, ~, ...
  proposed_fast_semicontrolled_AUC] = ...
  perfcurve(PrinterTypeScannerWidthLabels, [PrinterTypeScannerWidthGenuineScore(:, 6); PrinterTypeScannerWidthRecaptureScore(:, 6)], 1);
% slow direction
[proposed_slow_semicontrolled_X, ...
  proposed_slow_semicontrolled_Y, ~, ...
  proposed_slow_semicontrolled_AUC] = ...
  perfcurve(PrinterTypeScannerWidthRotLabels, [PrinterTypeScannerWidthGenuineRotScore(:,6); PrinterTypeScannerWidthRecaptureRotScore(:,6)], 1);
% double direction      
[proposed_double_semicontrolled_X, ...
  proposed_double_semicontrolled_Y, ~, ...
  proposed_double_semicontrolled_AUC] = ...
  perfcurve(PrinterTypeScannerWidthDoubleLabels, [PrinterTypeScannerWidthGenuineDoubleScore(:,6); PrinterTypeScannerWidthRecaptureDoubleScore(:,6)], 1);
experiment_result = [experiment_result proposed_fast_semicontrolled_AUC proposed_slow_semicontrolled_AUC proposed_double_semicontrolled_AUC];
%% calculate ROC for realistic experiment proposed method
% fast direction
[proposed_fast_realistic_X, ...
  proposed_fast_realistic_Y,...
  proposed_fast_realistic_Thres, ...
  proposed_fast_realistic_AUC] = ...
    perfcurve(ScannerWidthLabels, [ScannerWidthGenuineScore(:, 6); ScannerWidthRecaptureScore(:, 6)], 1);

RealisticScannerWidthGenuineLaserScore = ScannerWidthGenuineScore(ScannerWidthGenuineScore(:, 1) == 4, :);
RealisticScannerWidthRecaptureLaserScore = ScannerWidthRecaptureScore(ScannerWidthRecaptureScore(:, 1) == 4, :);
RealisticScannerWidthLaserLabels = [zeros(1, length(RealisticScannerWidthGenuineLaserScore)) ones(1, length(RealisticScannerWidthRecaptureLaserScore))];
[proposed_fast_realistic_laser_X, ...
  proposed_fast_realistic_laser_Y,...
  proposed_fast_realisticd_laser_Thres, ...
  proposed_fast_realistic_laser_AUC] = ...
    perfcurve(RealisticScannerWidthLaserLabels, [RealisticScannerWidthGenuineLaserScore(:, 6); RealisticScannerWidthRecaptureLaserScore(:, 6)], 1);
disp(['proposed AUC laser realistic fast: ', num2str(proposed_fast_realistic_laser_AUC)]);

RealisticScannerWidthGenuineInkjetScore = ScannerWidthGenuineScore(ScannerWidthGenuineScore(:, 1) < 4, :);
RealisticScannerWidthRecaptureInkjetScore = ScannerWidthRecaptureScore(ScannerWidthRecaptureScore(:, 1) < 4, :);
RealisticScannerWidthInkjetLabels = [zeros(1, length(RealisticScannerWidthGenuineInkjetScore)) ones(1, length(RealisticScannerWidthRecaptureInkjetScore))];
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
RealisticScannerWidthLaserRotLabels = [zeros(1, length(RealisticScannerWidthGenuineLaserRotScore)) ones(1, length(RealisticScannerWidthRecaptureLaserRotScore))];
[proposed_slow_realistic_laser_X, ...
  proposed_slow_realistic_laser_Y,...
  proposed_slow_realisticd_laser_Thres, ...
  proposed_slow_realistic_laser_AUC] = ...
    perfcurve(RealisticScannerWidthLaserRotLabels, [RealisticScannerWidthGenuineLaserRotScore(:, 6); RealisticScannerWidthRecaptureLaserRotScore(:, 6)], 1);
disp(['proposed AUC laser realistic slow: ', num2str(proposed_slow_realistic_laser_AUC)]);

RealisticScannerWidthGenuineInkjetRotScore = ScannerWidthGenuineRotScore(ScannerWidthGenuineRotScore(:, 1) < 4, :);
RealisticScannerWidthRecaptureInkjetRotScore = ScannerWidthRecaptureRotScore(ScannerWidthRecaptureRotScore(:, 1) < 4, :);
RealisticScannerWidthInkjetRotLabels = [zeros(1, length(RealisticScannerWidthGenuineInkjetRotScore)) ones(1, length(RealisticScannerWidthRecaptureInkjetRotScore))];
[proposed_slow_realistic_inkjet_X, ...
  proposed_slow_realistic_inkjet_Y,...
  proposed_slow_realistic_inkjet_Thres, ...
  proposed_slow_realistic_inkjet_AUC] = ...
    perfcurve(RealisticScannerWidthInkjetRotLabels, [RealisticScannerWidthGenuineInkjetRotScore(:, 6); RealisticScannerWidthRecaptureInkjetRotScore(:, 6)], 1);
disp(['proposed AUC inkjet realistic slow: ', num2str(proposed_slow_realistic_inkjet_AUC)]);

% double direction                  
[proposed_double_realistic_X, ...
  proposed_double_realistic_Y, ~, ...
  proposed_double_realistic_AUC] = ...
    perfcurve(ScannerWidthDoubleLabels, [ScannerWidthGenuineDoubleScore(:, 6); ScannerWidthRecaptureDoubleScore(:, 6)], 1);
experiment_result = [experiment_result proposed_fast_realistic_AUC proposed_slow_realistic_AUC proposed_double_realistic_AUC];

RealisticScannerWidthGenuineLaserDoubleScore = ScannerWidthGenuineDoubleScore(ScannerWidthGenuineDoubleScore(:, 1) == 4, :);
RealisticScannerWidthRecaptureLaserDoubleScore = ScannerWidthRecaptureDoubleScore(ScannerWidthRecaptureDoubleScore(:, 1) == 4, :);
RealisticScannerWidthLaserDoubleLabels = ...
  [zeros(1, length(RealisticScannerWidthGenuineLaserDoubleScore)) ones(1, length(RealisticScannerWidthRecaptureLaserDoubleScore))];
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

%% calculate ROC for wild experiment proposed method
% fast direction
[proposed_fast_wild_X, ...
 proposed_fast_wild_Y,...
 proposed_fast_wild_Thres, ...
 proposed_fast_wild_AUC] = ...
  perfcurve(WildScannerWidthLabels, [WildScannerWidthGenuineScore(:, 6); WildScannerWidthRecaptureScore(:, 6)], 1);
experiment_result = [experiment_result proposed_fast_wild_AUC];

WildScannerWidthGenuineLaserScore = ...
  WildScannerWidthGenuineScore(WildScannerWidthGenuineScore(:, 1) < 7 | ...
                              (WildScannerWidthGenuineScore(:, 1) > 8 & WildScannerWidthGenuineScore(:, 1) < 11), :);
WildScannerWidthRecaptureLaserScore = ...
  WildScannerWidthRecaptureScore(WildScannerWidthRecaptureScore(:, 1) < 7 | ...
                                (WildScannerWidthRecaptureScore(:, 1) > 8 & WildScannerWidthRecaptureScore(:, 1) < 11), :);
                              
WildScannerWidthLaserLabels = [zeros(1, length(WildScannerWidthGenuineLaserScore)) ones(1, length(WildScannerWidthRecaptureLaserScore))];
[proposed_fast_wild_laser_X, ...
  proposed_fast_wild_laser_Y,...
  proposed_fast_wild_laser_Thres, ...
  proposed_fast_wild_laser_AUC] = ...
    perfcurve(WildScannerWidthLaserLabels, [WildScannerWidthGenuineLaserScore(:, 6); WildScannerWidthRecaptureLaserScore(:, 6)], 1);
disp(['proposed AUC laser wild fast: ', num2str(proposed_fast_wild_laser_AUC)]);

WildScannerWidthGenuineInkjetScore = WildScannerWidthGenuineScore(WildScannerWidthGenuineScore(:, 1) == 8 | WildScannerWidthGenuineScore(:, 1) == 11, :);
WildScannerWidthRecaptureInkjetScore = WildScannerWidthRecaptureScore(WildScannerWidthRecaptureScore(:, 1) == 8 | WildScannerWidthRecaptureScore(:, 1) == 11, :);
WildScannerWidthInkjetLabels = [zeros(1, length(WildScannerWidthGenuineInkjetScore)) ones(1, length(WildScannerWidthRecaptureInkjetScore))];
[proposed_fast_wild_inkjet_X, ...
  proposed_fast_wild_inkjet_Y,...
  proposed_fast_wild_inkjet_Thres, ...
  proposed_fast_wild_inkjet_AUC] = ...
    perfcurve(WildScannerWidthInkjetLabels, [WildScannerWidthGenuineInkjetScore(:, 6); WildScannerWidthRecaptureInkjetScore(:, 6)], 1);
disp(['proposed AUC inkjet wild fast: ', num2str(proposed_fast_wild_inkjet_AUC)]);
  
% slow direction                  
[proposed_slow_wild_X, ...
  proposed_slow_wild_Y, ~, ...
  proposed_slow_wild_AUC] = ...
    perfcurve(WildScannerWidthRotLabels, [WildScannerWidthGenuineRotScore(:, 6); WildScannerWidthRecaptureRotScore(:, 6)], 1);
experiment_result = [experiment_result proposed_slow_wild_AUC];

WildScannerWidthGenuineLaserSlowScore = ...
  WildScannerWidthGenuineRotScore(WildScannerWidthGenuineRotScore(:, 1) < 7 | ...
                                  (WildScannerWidthGenuineRotScore(:, 1) > 8 & WildScannerWidthGenuineRotScore(:, 1) < 11), :);
WildScannerWidthRecaptureLaserSlowScore = ...
  WildScannerWidthRecaptureRotScore(WildScannerWidthRecaptureRotScore(:, 1) < 7 | ...
                                    (WildScannerWidthRecaptureRotScore(:, 1) > 8 & WildScannerWidthRecaptureRotScore(:, 1) < 11), :);
WildScannerWidthLaserSlowLabels = [zeros(1, length(WildScannerWidthGenuineLaserSlowScore)) ones(1, length(WildScannerWidthRecaptureLaserSlowScore))];
[proposed_slow_wild_laser_X, ...
  proposed_slow_wild_laser_Y,...
  proposed_slow_wild_laser_Thres, ...
  proposed_slow_wild_laser_AUC] = ...
    perfcurve(WildScannerWidthLaserSlowLabels, [WildScannerWidthGenuineLaserSlowScore(:, 6); WildScannerWidthRecaptureLaserSlowScore(:, 6)], 1);
disp(['proposed AUC laser wild slow: ', num2str(proposed_slow_wild_laser_AUC)]);
  
WildScannerWidthGenuineInkjetSlowScore = ...
  WildScannerWidthGenuineRotScore(WildScannerWidthGenuineRotScore(:, 1) == 8 | WildScannerWidthGenuineRotScore(:, 1) == 11, :);
WildScannerWidthRecaptureInkjetSlowScore = ...
  WildScannerWidthRecaptureRotScore(WildScannerWidthRecaptureRotScore(:, 1) == 8 | WildScannerWidthRecaptureRotScore(:, 1) == 11, :);
WildScannerWidthInkjetSlowLabels = ...
  [zeros(1, length(WildScannerWidthGenuineInkjetSlowScore)) ones(1, length(WildScannerWidthRecaptureInkjetSlowScore))];
[proposed_slow_wild_inkjet_X, ...
  proposed_slow_wild_inkjet_Y,...
  proposed_slow_wild_inkjet_Thres, ...
  proposed_slow_wild_inkjet_AUC] = ...
    perfcurve(WildScannerWidthInkjetSlowLabels, [WildScannerWidthGenuineInkjetSlowScore(:, 6); WildScannerWidthRecaptureInkjetSlowScore(:, 6)], 1);
disp(['proposed AUC inkjet wild slow: ', num2str(proposed_slow_wild_inkjet_AUC)]);

% double direction                  
[proposed_double_wild_X, ...
  proposed_double_wild_Y, ~, ...
  proposed_double_wild_AUC] = ...
    perfcurve(WildScannerWidthDoubleLabels, [WildScannerWidthGenuineDoubleScore(:, 6); WildScannerWidthRecaptureDoubleScore(:, 6)], 1);
experiment_result = [experiment_result proposed_double_wild_AUC];

WildScannerWidthGenuineLaserDoubleScore = ...
    WildScannerWidthGenuineDoubleScore(WildScannerWidthGenuineDoubleScore(:, 1) < 7 | ...
                                      (WildScannerWidthGenuineDoubleScore(:, 1) > 8 & WildScannerWidthGenuineDoubleScore(:, 1) < 11), :);
WildScannerWidthRecaptureLaserDoubleScore = ...
    WildScannerWidthRecaptureDoubleScore(WildScannerWidthRecaptureDoubleScore(:, 1) < 7 | ...
                                         (WildScannerWidthRecaptureDoubleScore(:, 1) > 8 & WildScannerWidthRecaptureDoubleScore(:, 1) < 11), :);
WildScannerWidthLaserDoubleLabels = ...
  [zeros(1, length(WildScannerWidthGenuineLaserDoubleScore)) ones(1, length(WildScannerWidthRecaptureLaserDoubleScore))];
[proposed_double_wild_laser_X, ...
 proposed_double_wild_laser_Y,...
 proposed_double_wild_laser_Thres, ...
 proposed_double_wild_laser_AUC] = ...
  perfcurve(WildScannerWidthLaserDoubleLabels, [WildScannerWidthGenuineLaserDoubleScore(:, 6); WildScannerWidthRecaptureLaserDoubleScore(:, 6)], 1);
  
WildScannerWidthGenuineInkjetDoubleScore = ...
  WildScannerWidthGenuineDoubleScore(WildScannerWidthGenuineDoubleScore(:, 1) == 8 | WildScannerWidthGenuineDoubleScore(:, 1) == 11, :);
WildScannerWidthRecaptureInkjetDoubleScore = ...
  WildScannerWidthRecaptureDoubleScore(WildScannerWidthRecaptureDoubleScore(:, 1) == 8 | WildScannerWidthRecaptureDoubleScore(:, 1) == 11, :);
WildScannerWidthInkjetDoubleLabels = ...
  [zeros(1, length(WildScannerWidthGenuineInkjetDoubleScore)) ones(1, length(WildScannerWidthRecaptureInkjetDoubleScore))];
[proposed_double_wild_inkjet_X, ...
 proposed_double_wild_inkjet_Y,...
 proposed_double_wild_inkjet_Thres, ...
 proposed_double_wild_inkjet_AUC] = ...
  perfcurve(WildScannerWidthInkjetDoubleLabels, ...
            [WildScannerWidthGenuineInkjetDoubleScore(:, 6); WildScannerWidthRecaptureInkjetDoubleScore(:, 6)], 1);

%% prepare data from external classifiers
% load SVM test result one-class genuine
one_class_SVM_genuine_set_1 = readtable('dataDrivenMethod\test_results_SVM\test_result_genuine_1_one_class_svm.csv');
one_class_SVM_genuine_set_2 = readtable('dataDrivenMethod\test_results_SVM\test_result_genuine_2_one_class_svm.csv');
one_class_SVM_genuine_set_3 = readtable('dataDrivenMethod\test_results_SVM\test_result_genuine_3_one_class_svm.csv');
one_class_SVM_genuine_set_4 = readtable('dataDrivenMethod\test_results_SVM\test_result_genuine_4_one_class_svm.csv');
one_class_SVM_genuine_set_5 = readtable('dataDrivenMethod\test_results_SVM\test_result_genuine_5_one_class_svm.csv');
% load SVM test result one-class recapture
one_class_SVM_recapture_set_1 = readtable('dataDrivenMethod\test_results_SVM\test_result_recapture_1_one_class_svm.csv');
one_class_SVM_recapture_set_2 = readtable('dataDrivenMethod\test_results_SVM\test_result_recapture_2_one_class_svm.csv');
one_class_SVM_recapture_set_3 = readtable('dataDrivenMethod\test_results_SVM\test_result_recapture_3_one_class_svm.csv');
one_class_SVM_recapture_set_4 = readtable('dataDrivenMethod\test_results_SVM\test_result_recapture_4_one_class_svm.csv');
one_class_SVM_recapture_set_5 = readtable('dataDrivenMethod\test_results_SVM\test_result_recapture_5_one_class_svm.csv');
% load SVM test result two-class genuine
two_class_SVM_genuine_set_1 = readtable('dataDrivenMethod\test_results_SVM\test_result_genuine_1_two_class_svm.csv');
two_class_SVM_genuine_set_2 = readtable('dataDrivenMethod\test_results_SVM\test_result_genuine_2_two_class_svm.csv');
two_class_SVM_genuine_set_3 = readtable('dataDrivenMethod\test_results_SVM\test_result_genuine_3_two_class_svm.csv');
two_class_SVM_genuine_set_4 = readtable('dataDrivenMethod\test_results_SVM\test_result_genuine_4_two_class_svm.csv');
two_class_SVM_genuine_set_5 = readtable('dataDrivenMethod\test_results_SVM\test_result_genuine_5_two_class_svm.csv');
% load SVM test result two-class recapture
two_class_SVM_recapture_set_1 = readtable('dataDrivenMethod\test_results_SVM\test_result_recapture_1_two_class_svm.csv');
two_class_SVM_recapture_set_2 = readtable('dataDrivenMethod\test_results_SVM\test_result_recapture_2_two_class_svm.csv');
two_class_SVM_recapture_set_3 = readtable('dataDrivenMethod\test_results_SVM\test_result_recapture_3_two_class_svm.csv');
two_class_SVM_recapture_set_4 = readtable('dataDrivenMethod\test_results_SVM\test_result_recapture_4_two_class_svm.csv');
two_class_SVM_recapture_set_5 = readtable('dataDrivenMethod\test_results_SVM\test_result_recapture_5_two_class_svm.csv');
% load DNN test result one-class genuine
one_class_DNN_genuine_set_1 = readtable('dataDrivenMethod\test_results_DNN\test_result_genuine_0_1.csv');
one_class_DNN_genuine_set_2 = readtable('dataDrivenMethod\test_results_DNN\test_result_genuine_0_2.csv');
one_class_DNN_genuine_set_3 = readtable('dataDrivenMethod\test_results_DNN\test_result_genuine_0_3.csv');
one_class_DNN_genuine_set_4 = readtable('dataDrivenMethod\test_results_DNN\test_result_genuine_0_4.csv');
one_class_DNN_genuine_set_5 = readtable('dataDrivenMethod\test_results_DNN\test_result_genuine_0_5.csv');
% load DNN test result one-class recapture
one_class_DNN_recapture_set_1 = readtable('dataDrivenMethod\test_results_DNN\test_result_recapture_0_1.csv');
one_class_DNN_recapture_set_2 = readtable('dataDrivenMethod\test_results_DNN\test_result_recapture_0_2.csv');
one_class_DNN_recapture_set_3 = readtable('dataDrivenMethod\test_results_DNN\test_result_recapture_0_3.csv');
one_class_DNN_recapture_set_4 = readtable('dataDrivenMethod\test_results_DNN\test_result_recapture_0_4.csv');
one_class_DNN_recapture_set_5 = readtable('dataDrivenMethod\test_results_DNN\test_result_recapture_0_5.csv');
% load DNN test result two-class genuine
two_class_DNN_genuine_set_1 = readtable('dataDrivenMethod\test_results_DNN\test_result_genuine_1_1.csv');
two_class_DNN_genuine_set_2 = readtable('dataDrivenMethod\test_results_DNN\test_result_genuine_1_2.csv');
two_class_DNN_genuine_set_3 = readtable('dataDrivenMethod\test_results_DNN\test_result_genuine_1_3.csv');
two_class_DNN_genuine_set_4 = readtable('dataDrivenMethod\test_results_DNN\test_result_genuine_1_4.csv');
two_class_DNN_genuine_set_5 = readtable('dataDrivenMethod\test_results_DNN\test_result_genuine_1_5.csv');
% load DNN test result two-class recapture
two_class_DNN_recapture_set_1 = readtable('dataDrivenMethod\test_results_DNN\test_result_recapture_1_1.csv');
two_class_DNN_recapture_set_2 = readtable('dataDrivenMethod\test_results_DNN\test_result_recapture_1_2.csv');
two_class_DNN_recapture_set_3 = readtable('dataDrivenMethod\test_results_DNN\test_result_recapture_1_3.csv');
two_class_DNN_recapture_set_4 = readtable('dataDrivenMethod\test_results_DNN\test_result_recapture_1_4.csv');
two_class_DNN_recapture_set_5 = readtable('dataDrivenMethod\test_results_DNN\test_result_recapture_1_5.csv');
%% process one-class SVM data
% one class SVM baseline experiment result
one_class_SVM_baseline_scores = -[one_class_SVM_genuine_set_1.Var7; one_class_SVM_recapture_set_1.Var7];
one_class_SVM_baseline_label = [zeros(length(one_class_SVM_genuine_set_1.Var7), 1); ...
                                    ones(length(one_class_SVM_recapture_set_1.Var7), 1)];
one_class_SVM_baseline_printers = [one_class_SVM_genuine_set_1.Var3; one_class_SVM_recapture_set_1.Var3];
one_class_SVM_baseline_inkjet_idx = find(one_class_SVM_baseline_printers < 7);
one_class_SVM_baseline_laser_idx = find(one_class_SVM_baseline_printers == 7);
one_class_SVM_baseline_inkjet_scores = one_class_SVM_baseline_scores(one_class_SVM_baseline_inkjet_idx);
one_class_SVM_baseline_laser_scores = one_class_SVM_baseline_scores(one_class_SVM_baseline_laser_idx);
one_class_SVM_baseline_inkjet_label = one_class_SVM_baseline_label(one_class_SVM_baseline_inkjet_idx);
one_class_SVM_baseline_laser_label = one_class_SVM_baseline_label(one_class_SVM_baseline_laser_idx);

% one class SVM semicontrolled experiment result
one_class_SVM_semicontrolled_scores = -[one_class_SVM_genuine_set_2.Var7; one_class_SVM_recapture_set_2.Var7; ...
                                        one_class_SVM_genuine_set_3.Var7; one_class_SVM_recapture_set_3.Var7];
one_class_SVM_semicontrolled_label = [zeros(length(one_class_SVM_genuine_set_2.Var7), 1); ...
                                      ones(length(one_class_SVM_recapture_set_2.Var7), 1); ...
                                      zeros(length(one_class_SVM_genuine_set_3.Var7), 1); ...
                                      ones(length(one_class_SVM_recapture_set_3.Var7), 1)];
one_class_SVM_semicontrolled_printers = [one_class_SVM_genuine_set_2.Var3; one_class_SVM_recapture_set_2.Var3; ...
                                         one_class_SVM_genuine_set_3.Var3; one_class_SVM_recapture_set_3.Var3];
one_class_SVM_semicontrolled_inkjet_idx = find(one_class_SVM_semicontrolled_printers < 7);
one_class_SVM_semicontrolled_laser_idx = find(one_class_SVM_semicontrolled_printers == 7);
one_class_SVM_semicontrolled_inkjet_scores = one_class_SVM_semicontrolled_scores(one_class_SVM_semicontrolled_inkjet_idx);
one_class_SVM_semicontrolled_laser_scores = one_class_SVM_semicontrolled_scores(one_class_SVM_semicontrolled_laser_idx);
one_class_SVM_semicontrolled_inkjet_label = one_class_SVM_semicontrolled_label(one_class_SVM_semicontrolled_inkjet_idx);
one_class_SVM_semicontrolled_laser_label = one_class_SVM_semicontrolled_label(one_class_SVM_semicontrolled_laser_idx);

% one class SVM realistic experiment result
one_class_SVM_realistic_scores = -[one_class_SVM_genuine_set_4.Var7; one_class_SVM_recapture_set_4.Var7];
one_class_SVM_realistic_label = [zeros(length(one_class_SVM_genuine_set_4.Var7), 1); ...
                                 ones(length(one_class_SVM_recapture_set_4.Var7), 1)];
one_class_SVM_realistic_printers = [one_class_SVM_genuine_set_4.Var3; one_class_SVM_recapture_set_4.Var3];
one_class_SVM_realistic_inkjet_idx = find(one_class_SVM_realistic_printers < 7);
one_class_SVM_realistic_laser_idx = find(one_class_SVM_realistic_printers == 7);
one_class_SVM_realistic_inkjet_scores = one_class_SVM_realistic_scores(one_class_SVM_realistic_inkjet_idx);
one_class_SVM_realistic_laser_scores = one_class_SVM_realistic_scores(one_class_SVM_realistic_laser_idx);
one_class_SVM_realistic_inkjet_label = one_class_SVM_realistic_label(one_class_SVM_realistic_inkjet_idx);
one_class_SVM_realistic_laser_label = one_class_SVM_realistic_label(one_class_SVM_realistic_laser_idx);

% one class SVM wild experiment result
one_class_SVM_wild_scores = -[one_class_SVM_genuine_set_5.Var7; one_class_SVM_recapture_set_5.Var7];
one_class_SVM_wild_label = [zeros(length(one_class_SVM_genuine_set_5.Var7), 1); ...
                                    ones(length(one_class_SVM_recapture_set_5.Var7), 1)];
one_class_SVM_wild_printers = [one_class_SVM_genuine_set_5.Var3; one_class_SVM_recapture_set_5.Var3];
one_class_SVM_wild_inkjet_idx = find(one_class_SVM_wild_printers == 10 | one_class_SVM_wild_printers == 11);
one_class_SVM_wild_laser_idx = find(one_class_SVM_wild_printers < 10 | one_class_SVM_wild_printers > 11);
one_class_SVM_wild_inkjet_scores = one_class_SVM_wild_scores(one_class_SVM_wild_inkjet_idx);
one_class_SVM_wild_laser_scores = one_class_SVM_wild_scores(one_class_SVM_wild_laser_idx);
one_class_SVM_wild_inkjet_label = one_class_SVM_wild_label(one_class_SVM_wild_inkjet_idx);
one_class_SVM_wild_laser_label = one_class_SVM_wild_label(one_class_SVM_wild_laser_idx);

% calculate ROC for all printers
[one_class_SVM_baseline_X, ...
 one_class_SVM_baseline_Y, ...
 one_class_SVM_baseline_Thres, ...
 one_class_SVM_baseline_AUC] = perfcurve(one_class_SVM_baseline_label, one_class_SVM_baseline_scores, 1);
[one_class_SVM_semicontrolled_X, ...
 one_class_SVM_semicontrolled_Y, ...
 one_class_SVM_semicontrolled_Thres, ...
 one_class_SVM_semicontrolled_AUC] = perfcurve(one_class_SVM_semicontrolled_label, one_class_SVM_semicontrolled_scores, 1);
[one_class_SVM_realistic_X, ...
 one_class_SVM_realistic_Y, ...
 one_class_SVM_realistic_Thres, ...
 one_class_SVM_realistic_AUC] = perfcurve(one_class_SVM_realistic_label, one_class_SVM_realistic_scores, 1);
[one_class_SVM_wild_X, ...
 one_class_SVM_wild_Y, ...
 one_class_SVM_wild_Thres, ...
 one_class_SVM_wild_AUC] = perfcurve(one_class_SVM_wild_label, one_class_SVM_wild_scores, 1);
experiment_result_OSVM = [one_class_SVM_baseline_AUC one_class_SVM_semicontrolled_AUC one_class_SVM_realistic_AUC one_class_SVM_wild_AUC];

% calculate ROC for INKJET
[one_class_SVM_baseline_inkjet_X, ...
 one_class_SVM_baseline_inkjet_Y, ...
 one_class_SVM_baseline_inkjet_Thres, ...
 one_class_SVM_baseline_inkjet_AUC] = perfcurve(one_class_SVM_baseline_inkjet_label, one_class_SVM_baseline_inkjet_scores, 1);
[one_class_SVM_semicontrolled_inkjet_X, ...
 one_class_SVM_semicontrolled_inkjet_Y, ...
 one_class_SVM_semicontrolled_inkjet_Thres, ...
 one_class_SVM_semicontrolled_inkjet_AUC] = perfcurve(one_class_SVM_semicontrolled_inkjet_label, one_class_SVM_semicontrolled_inkjet_scores, 1);
[one_class_SVM_realistic_inkjet_X, ...
 one_class_SVM_realistic_inkjet_Y, ...
 one_class_SVM_realistic_inkjet_Thres, ...
 one_class_SVM_realistic_inkjet_AUC] = perfcurve(one_class_SVM_realistic_inkjet_label, one_class_SVM_realistic_inkjet_scores, 1);
[one_class_SVM_wild_inkjet_X, ...
 one_class_SVM_wild_inkjet_Y, ...
 one_class_SVM_wild_inkjet_Thres, ...
 one_class_SVM_wild_inkjet_AUC] = perfcurve(one_class_SVM_wild_inkjet_label, one_class_SVM_wild_inkjet_scores, 1);

% calculate ROC for LASER
[one_class_SVM_baseline_laser_X, ...
 one_class_SVM_baseline_laser_Y, ...
 one_class_SVM_baseline_lasert_Thres, ...
 one_class_SVM_baseline_laser_AUC] = perfcurve(one_class_SVM_baseline_laser_label, one_class_SVM_baseline_laser_scores, 1);
[one_class_SVM_semicontrolled_laser_X, ...
 one_class_SVM_semicontrolled_laser_Y, ...
 one_class_SVM_semicontrolled_laser_Thres, ...
 one_class_SVM_semicontrolled_laser_AUC] = perfcurve(one_class_SVM_semicontrolled_laser_label, one_class_SVM_semicontrolled_laser_scores, 1);
[one_class_SVM_realistic_laser_X, ...
 one_class_SVM_realistic_laser_Y, ...
 one_class_SVM_realistic_laser_Thres, ...
 one_class_SVM_realistic_laser_AUC] = perfcurve(one_class_SVM_realistic_laser_label, one_class_SVM_realistic_laser_scores, 1);
[one_class_SVM_wild_laser_X, ...
 one_class_SVM_wild_laser_Y, ...
 one_class_SVM_wild_laser_Thres, ...
 one_class_SVM_wild_laser_AUC] = perfcurve(one_class_SVM_wild_laser_label, one_class_SVM_wild_laser_scores, 1);

%% process the two class SVM data
% recapture is represented as -1, while genuine is represented as 1, that's why the scores are reversed
two_class_SVM_experiment_1_scores = -[two_class_SVM_genuine_set_1.Var7; two_class_SVM_recapture_set_1.Var7];
two_class_SVM_experiment_1_label = [zeros(1, length(two_class_SVM_genuine_set_1.Var7))  ...
                                    ones(1, length(two_class_SVM_recapture_set_1.Var7))];
                                  
two_class_SVM_experiment_2_scores = -[two_class_SVM_genuine_set_2.Var7; two_class_SVM_recapture_set_2.Var7];
two_class_SVM_experiment_2_label = [zeros(1, length(two_class_SVM_genuine_set_2.Var7))  ...
                                    ones(1, length(two_class_SVM_recapture_set_2.Var7))];
                                  
two_class_SVM_experiment_3_scores = -[two_class_SVM_genuine_set_3.Var7; two_class_SVM_recapture_set_3.Var7];
two_class_SVM_experiment_3_label = [zeros(1, length(two_class_SVM_genuine_set_3.Var7)) ...
                                    ones(1, length(two_class_SVM_recapture_set_3.Var7))];
                                  
two_class_SVM_experiment_4_scores = -[two_class_SVM_genuine_set_4.Var7; two_class_SVM_recapture_set_4.Var7];
two_class_SVM_experiment_4_label = [zeros(1, length(two_class_SVM_genuine_set_4.Var7)) ...
                                    ones(1, length(two_class_SVM_recapture_set_4.Var7))];

two_class_SVM_experiment_5_scores = -[two_class_SVM_genuine_set_5.Var7; two_class_SVM_recapture_set_5.Var7];
two_class_SVM_experiment_5_label = [zeros(1, length(two_class_SVM_genuine_set_5.Var7)) ...
                                    ones(1, length(two_class_SVM_recapture_set_5.Var7))];
                                  
% two class SVM
[two_class_SVM_baseline_X, ...
 two_class_SVM_baseline_Y, ...
 two_class_SVM_baseline_Thres, ...
 two_class_SVM_baseline_AUC] = perfcurve(two_class_SVM_experiment_1_label, two_class_SVM_experiment_1_scores, 1);
[two_class_SVM_semicontrolled_X, ...
 two_class_SVM_semicontrolled_Y, ...
 two_class_SVM_semicontrolled_Thres, ...
 two_class_SVM_semicontrolled_AUC] = perfcurve([two_class_SVM_experiment_2_label  two_class_SVM_experiment_3_label], ...
                                               [two_class_SVM_experiment_2_scores; two_class_SVM_experiment_3_scores], 1);
[two_class_SVM_realistic_X, ...
 two_class_SVM_realistic_Y, ...
 two_class_SVM_realistic_Thres, ...
 two_class_SVM_realistic_AUC] = perfcurve(two_class_SVM_experiment_4_label, two_class_SVM_experiment_4_scores, 1);
[two_class_SVM_wild_X, ...
 two_class_SVM_wild_Y, ...
 two_class_SVM_wild_Thres, ...
 two_class_SVM_wild_AUC] = perfcurve(two_class_SVM_experiment_5_label, two_class_SVM_experiment_5_scores, 1);
experiment_result_SVM = [two_class_SVM_baseline_AUC two_class_SVM_semicontrolled_AUC two_class_SVM_realistic_AUC two_class_SVM_wild_AUC];

%% process the DOC data
inkjet_print_name_lst = {'hp6222', 'hp258', 'hp2138', 'canong3800', 'epsonl805'};
laser_print_name_lst = {'hpm401n', 'fujip335d', 'kyoceram2530dn', 'hpm176', 'hpm251n'};

% process DOC data from baseline experiments
one_class_DNN_baseline_scores = [one_class_DNN_genuine_set_1.Var7; one_class_DNN_recapture_set_1.Var7];
one_class_DNN_baseline_label = [zeros(1, length(one_class_DNN_genuine_set_1.Var7)) ones(1, length(one_class_DNN_recapture_set_1.Var7))];
one_class_DNN_baseline_printers = [one_class_DNN_genuine_set_1.Var3; one_class_DNN_recapture_set_1.Var3];
one_class_DNN_baseline_inkjet_idx = find(ismember(one_class_DNN_baseline_printers, inkjet_print_name_lst));
one_class_DNN_baseline_laser_idx = find(ismember(one_class_DNN_baseline_printers, laser_print_name_lst));
one_class_DNN_baseline_inkjet_scores = one_class_DNN_baseline_scores(one_class_DNN_baseline_inkjet_idx);
one_class_DNN_baseline_laser_scores = one_class_DNN_baseline_scores(one_class_DNN_baseline_laser_idx);
one_class_DNN_baseline_inkjet_label = one_class_DNN_baseline_label(one_class_DNN_baseline_inkjet_idx);
one_class_DNN_baseline_laser_label = one_class_DNN_baseline_label(one_class_DNN_baseline_laser_idx);
                                  
% process DOC data from semicontrolled experiments                                  
one_class_DNN_semicontrolled_scores = [one_class_DNN_genuine_set_2.Var7; one_class_DNN_recapture_set_2.Var7; ...
                                       one_class_DNN_genuine_set_3.Var7; one_class_DNN_recapture_set_3.Var7];
one_class_DNN_semicontrolled_label = [zeros(1, length(one_class_DNN_genuine_set_2.Var7)) ...
                                      ones(1, length(one_class_DNN_recapture_set_2.Var7)) ...
                                      zeros(1, length(one_class_DNN_genuine_set_3.Var7)) ...
                                      ones(1, length(one_class_DNN_recapture_set_3.Var7))];
one_class_DNN_semicontrolled_printers = [one_class_DNN_genuine_set_2.Var3; one_class_DNN_recapture_set_2.Var3; ...
                                         one_class_DNN_genuine_set_3.Var3; one_class_DNN_recapture_set_3.Var3];
one_class_DNN_semicontrolled_inkjet_idx = find(ismember(one_class_DNN_semicontrolled_printers, inkjet_print_name_lst));
one_class_DNN_semicontrolled_laser_idx = find(ismember(one_class_DNN_semicontrolled_printers, laser_print_name_lst));
one_class_DNN_semicontrolled_inkjet_scores = one_class_DNN_semicontrolled_scores(one_class_DNN_semicontrolled_inkjet_idx);
one_class_DNN_semicontrolled_laser_scores = one_class_DNN_semicontrolled_scores(one_class_DNN_semicontrolled_laser_idx);
one_class_DNN_semicontrolled_inkjet_label = one_class_DNN_semicontrolled_label(one_class_DNN_semicontrolled_inkjet_idx);
one_class_DNN_semicontrolled_laser_label = one_class_DNN_semicontrolled_label(one_class_DNN_semicontrolled_laser_idx);

% process DOC data from realistic experiments                                  
one_class_DNN_realistic_scores = [one_class_DNN_genuine_set_4.Var7; one_class_DNN_recapture_set_4.Var7];
one_class_DNN_realistic_label = [zeros(1, length(one_class_DNN_genuine_set_4.Var7)) ...
                                 ones(1, length(one_class_DNN_recapture_set_4.Var7))];
one_class_DNN_realistic_printers = [one_class_DNN_genuine_set_4.Var3; one_class_DNN_recapture_set_4.Var3];
one_class_DNN_realistic_inkjet_idx = find(ismember(one_class_DNN_realistic_printers, inkjet_print_name_lst));
one_class_DNN_realistic_laser_idx = find(ismember(one_class_DNN_realistic_printers, laser_print_name_lst));
one_class_DNN_realistic_inkjet_scores = one_class_DNN_realistic_scores(one_class_DNN_realistic_inkjet_idx);
one_class_DNN_realistic_laser_scores = one_class_DNN_realistic_scores(one_class_DNN_realistic_laser_idx);
one_class_DNN_realistic_inkjet_label = one_class_DNN_realistic_label(one_class_DNN_realistic_inkjet_idx);
one_class_DNN_realistic_laser_label = one_class_DNN_realistic_label(one_class_DNN_realistic_laser_idx);
                               
% process DOC data from in the wild experiments                                        
one_class_DNN_wild_scores = [one_class_DNN_genuine_set_5.Var7; one_class_DNN_recapture_set_5.Var7];
one_class_DNN_wild_label = [zeros(1, length(one_class_DNN_genuine_set_5.Var7)) ones(1, length(one_class_DNN_recapture_set_5.Var7))];
one_class_DNN_wild_printers = [one_class_DNN_genuine_set_5.Var3; one_class_DNN_recapture_set_5.Var3];
one_class_DNN_wild_inkjet_idx = find(ismember(one_class_DNN_wild_printers, inkjet_print_name_lst));
one_class_DNN_wild_laser_idx = find(ismember(one_class_DNN_wild_printers, laser_print_name_lst));
one_class_DNN_wild_inkjet_scores = one_class_DNN_wild_scores(one_class_DNN_wild_inkjet_idx);
one_class_DNN_wild_laser_scores = one_class_DNN_wild_scores(one_class_DNN_wild_laser_idx);
one_class_DNN_wild_inkjet_label = one_class_DNN_wild_label(one_class_DNN_wild_inkjet_idx);
one_class_DNN_wild_laser_label = one_class_DNN_wild_label(one_class_DNN_wild_laser_idx);

% calculate ROC for all printers
[one_class_DNN_baseline_X, ...
 one_class_DNN_baseline_Y, ...
 one_class_DNN_baseline_Thres, ...
 one_class_DNN_baseline_AUC] = perfcurve(one_class_DNN_baseline_label, one_class_DNN_baseline_scores, 1);
[one_class_DNN_semicontrolled_X, ...
 one_class_DNN_semicontrolled_Y, ...
 one_class_DNN_semicontrolled_Thres, ...
 one_class_DNN_semicontrolled_AUC] = perfcurve(one_class_DNN_semicontrolled_label, one_class_DNN_semicontrolled_scores, 1);
[one_class_DNN_realistic_X, ...
 one_class_DNN_realistic_Y, ...
 one_class_DNN_realistic_Thres, ...
 one_class_DNN_realistic_AUC] = perfcurve(one_class_DNN_realistic_label, one_class_DNN_realistic_scores, 1);
[one_class_DNN_wild_X, ...
 one_class_DNN_wild_Y, ...
 one_class_DNN_wild_Thres, ...
 one_class_DNN_wild_AUC] = perfcurve(one_class_DNN_wild_label, one_class_DNN_wild_scores, 1);
experiment_result_DOC = [one_class_DNN_baseline_AUC one_class_DNN_semicontrolled_AUC one_class_DNN_realistic_AUC one_class_DNN_wild_AUC];

% calculate ROC for INKJET
[one_class_DNN_baseline_inkjet_X, ...
 one_class_DNN_baseline_inkjet_Y, ...
 one_class_DNN_baseline_inkjet_Thres, ...
 one_class_DNN_baseline_inkjet_AUC] = perfcurve(one_class_DNN_baseline_inkjet_label, one_class_DNN_baseline_inkjet_scores, 1);
[one_class_DNN_semicontrolled_inkjet_X, ...
 one_class_DNN_semicontrolled_inkjet_Y, ...
 one_class_DNN_semicontrolled_inkjet_Thres, ...
 one_class_DNN_semicontrolled_inkjet_AUC] = perfcurve(one_class_DNN_semicontrolled_inkjet_label, one_class_DNN_semicontrolled_inkjet_scores, 1);
[one_class_DNN_realistic_inkjet_X, ...
 one_class_DNN_realistic_inkjet_Y, ...
 one_class_DNN_realistic_inkjet_Thres, ...
 one_class_DNN_realistic_inkjet_AUC] = perfcurve(one_class_DNN_realistic_inkjet_label, one_class_DNN_realistic_inkjet_scores, 1);
[one_class_DNN_wild_inkjet_X, ...
 one_class_DNN_wild_inkjet_Y, ...
 one_class_DNN_wild_inkjet_Thres, ...
 one_class_DNN_wild_inkjet_AUC] = perfcurve(one_class_DNN_wild_inkjet_label, one_class_DNN_wild_inkjet_scores, 1);

% calculate ROC for LASER
[one_class_DNN_baseline_laser_X, ...
 one_class_DNN_baseline_laser_Y, ...
 one_class_DNN_baseline_lasert_Thres, ...
 one_class_DNN_baseline_laser_AUC] = perfcurve(one_class_DNN_baseline_laser_label, one_class_DNN_baseline_laser_scores, 1);
[one_class_DNN_semicontrolled_laser_X, ...
 one_class_DNN_semicontrolled_laser_Y, ...
 one_class_DNN_semicontrolled_laser_Thres, ...
 one_class_DNN_semicontrolled_laser_AUC] = perfcurve(one_class_DNN_semicontrolled_laser_label, one_class_DNN_semicontrolled_laser_scores, 1);
[one_class_DNN_realistic_laser_X, ...
 one_class_DNN_realistic_laser_Y, ...
 one_class_DNN_realistic_laser_Thres, ...
 one_class_DNN_realistic_laser_AUC] = perfcurve(one_class_DNN_realistic_laser_label, one_class_DNN_realistic_laser_scores, 1);
[one_class_DNN_wild_laser_X, ...
 one_class_DNN_wild_laser_Y, ...
 one_class_DNN_wild_laser_Thres, ...
 one_class_DNN_wild_laser_AUC] = perfcurve(one_class_DNN_wild_laser_label, one_class_DNN_wild_laser_scores, 1);
%% temporary plotting

% plot the ROC result for wild experiment
figure;
plot(proposed_fast_wild_laser_X, proposed_fast_wild_laser_Y, 'LineWidth', 5);
hold on
plot(proposed_slow_wild_laser_X, proposed_slow_wild_laser_Y, 'LineWidth', 5);
plot(proposed_double_wild_laser_X, proposed_double_wild_laser_Y, 'LineWidth', 5);
plot(proposed_fast_wild_inkjet_X, proposed_fast_wild_inkjet_Y, 'LineWidth', 5);
plot(proposed_slow_wild_inkjet_X, proposed_slow_wild_inkjet_Y, 'LineWidth', 5);
plot(proposed_double_wild_inkjet_X, proposed_double_wild_inkjet_Y, 'LineWidth', 5);
xlabel('FPR'); ylabel('TPR');
legend('proposed (laser horizontal)', 'proposed (laser vertical)', 'proposed (laser double)', ...
       'proposed (inkjet horizontal)', 'proposed (inkjet vertical)', 'proposed (inkjet double)', 'Location', 'southeast');
set(gca, 'FontName', 'times', 'FontSize', 27, 'FontSmoothing', 'on');  
set(gcf, 'units', 'pixels','OuterPosition', [0 0 700 700], 'Position', [0 0 700 700], 'Color', 'w');

% plot the ROC result for realistic experiment
figure;
plot(proposed_fast_realistic_laser_X, proposed_fast_realistic_laser_Y, 'LineWidth', 5);
hold on
plot(proposed_slow_realistic_laser_X, proposed_slow_realistic_laser_Y, 'LineWidth', 5);
plot(proposed_double_realistic_laser_X, proposed_double_realistic_laser_Y, 'LineWidth', 5);
plot(proposed_fast_realistic_inkjet_X, proposed_fast_realistic_inkjet_Y, 'LineWidth', 5);
plot(proposed_slow_realistic_inkjet_X, proposed_slow_realistic_inkjet_Y, 'LineWidth', 5);
plot(proposed_double_realistic_inkjet_X, proposed_double_realistic_inkjet_Y, 'LineWidth', 5);
xlabel('FPR'); ylabel('TPR');
legend('proposed (laser horizontal)', 'proposed (laser vertical)', 'proposed (laser double)', ...
       'proposed (inkjet horizontal)', 'proposed (inkjet vertical)', 'proposed (inkjet double)', 'Location', 'southeast');
set(gca, 'FontName', 'times', 'FontSize', 27, 'FontSmoothing', 'on');  
set(gcf, 'units', 'pixels','OuterPosition', [0 0 700 700], 'Position', [0 0 700 700], 'Color', 'w');

%% process the two class DNN data
% recapture is represented as 1, while genuine is represented as 0
two_class_DNN_experiment_1_scores = [two_class_DNN_genuine_set_1.Var7; two_class_DNN_recapture_set_1.Var7];
two_class_DNN_experiment_1_label = [zeros(1, length(two_class_DNN_genuine_set_1.Var7)) ...
                                    ones(1, length(two_class_DNN_recapture_set_1.Var7))];
                                  
two_class_DNN_experiment_2_scores = [two_class_DNN_genuine_set_2.Var7; two_class_DNN_recapture_set_2.Var7];
two_class_DNN_experiment_2_label = [zeros(1, length(two_class_DNN_genuine_set_2.Var7)) ...
                                    ones(1, length(two_class_DNN_recapture_set_2.Var7))];
                                  
two_class_DNN_experiment_3_scores = [two_class_DNN_genuine_set_3.Var7; two_class_DNN_recapture_set_3.Var7];
two_class_DNN_experiment_3_label = [zeros(1, length(two_class_DNN_genuine_set_3.Var7)) ...
                                    ones(1, length(two_class_DNN_recapture_set_3.Var7))];

two_class_DNN_experiment_4_scores = [two_class_DNN_genuine_set_4.Var7; two_class_DNN_recapture_set_4.Var7];
two_class_DNN_experiment_4_label = [zeros(1, length(two_class_DNN_genuine_set_4.Var7)) ...
                                    ones(1, length(two_class_DNN_recapture_set_4.Var7))];

two_class_DNN_experiment_5_scores = [two_class_DNN_genuine_set_5.Var7; two_class_DNN_recapture_set_5.Var7];
two_class_DNN_experiment_5_label = [zeros(1, length(two_class_DNN_genuine_set_5.Var7)) ...
                                    ones(1, length(two_class_DNN_recapture_set_5.Var7))];
%% calculate ROC and AUC 
% two class DNN (Resnet 50)
[two_class_DNN_baseline_X, ...
 two_class_DNN_baseline_Y, ...
 two_class_DNN_baseline_Thres, ...
 two_class_DNN_baseline_AUC] = perfcurve(two_class_DNN_experiment_1_label, two_class_DNN_experiment_1_scores, 1);
[two_class_DNN_semicontrolled_X, ...
 two_class_DNN_semicontrolled_Y, ...
 two_class_DNN_semicontrolled_Thres, ...
 two_class_DNN_semicontrolled_AUC] = perfcurve([two_class_DNN_experiment_2_label two_class_DNN_experiment_3_label], ...
                                               [two_class_DNN_experiment_2_scores; two_class_DNN_experiment_3_scores], 1);                                   
[two_class_DNN_realistic_X, ...
 two_class_DNN_realistic_Y, ...
 two_class_DNN_realistic_Thres, ...
 two_class_DNN_realistic_AUC] = perfcurve(two_class_DNN_experiment_4_label, two_class_DNN_experiment_4_scores, 1);
[two_class_DNN_wild_X, ...
 two_class_DNN_wild_Y, ...
 two_class_DNN_wild_Thres, ...
 two_class_DNN_wild_AUC] = perfcurve(two_class_DNN_experiment_5_label, two_class_DNN_experiment_5_scores, 1);
experiment_result_Resnet = [two_class_DNN_baseline_AUC two_class_DNN_semicontrolled_AUC two_class_DNN_realistic_AUC two_class_DNN_wild_AUC];

%% plot the ROC result
% plot the ROC result for baseline experiment
figure;
plot(proposed_fast_baseline_X, proposed_fast_baseline_Y, 'LineWidth', 5);
hold on;
plot(proposed_slow_baseline_X, proposed_slow_baseline_Y, 'LineWidth', 5);
plot(proposed_double_baseline_X, proposed_double_baseline_Y, 'LineWidth', 5);
plot(one_class_SVM_baseline_X, one_class_SVM_baseline_Y, 'LineWidth', 5);
hold on;
plot(two_class_SVM_baseline_X, two_class_SVM_baseline_Y, 'LineWidth', 5);
plot(one_class_DNN_baseline_X, one_class_DNN_baseline_Y, 'LineWidth', 5);
plot(two_class_DNN_baseline_X, two_class_DNN_baseline_Y, 'LineWidth', 5);
xlabel('FPR'); ylabel('TPR');
legend('proposed (horizontal)', 'proposed (vertical)', 'proposed (double)', 'LBP+OSVM', 'LBP+SVM', 'Deep SVDD', 'ResNet50', 'Location', 'southeast');
set(gca, 'FontName', 'times', 'FontSize', 25, 'FontSmoothing', 'on');  
set(gcf, 'units', 'pixels','OuterPosition', [0 0 700 700], 'Position', [0 0 700 700], 'Color', 'w');
disp(['proposed_fast_baseline_AUC: ', num2str(proposed_fast_baseline_AUC)]);
disp(['proposed_slow_baseline_AUC: ', num2str(proposed_slow_baseline_AUC)]);
disp(['proposed_double_baseline_AUC: ', num2str(proposed_double_baseline_AUC)]);
disp(['Resnet_baseline_AUC: ', num2str(two_class_DNN_baseline_AUC)]);
disp(['OSVM_baseline_AUC: ', num2str(one_class_DNN_baseline_AUC)]);

% plot the ROC result for semicontrolled experiment
figure;
plot(proposed_fast_semicontrolled_X, proposed_fast_semicontrolled_Y, 'LineWidth', 5);
hold on;
plot(proposed_slow_semicontrolled_X, proposed_slow_semicontrolled_Y, 'LineWidth', 5);
plot(proposed_double_semicontrolled_X, proposed_double_semicontrolled_Y, 'LineWidth', 5);
plot(one_class_SVM_semicontrolled_X, one_class_SVM_semicontrolled_Y, 'LineWidth', 5);
hold on;
plot(two_class_SVM_semicontrolled_X, two_class_SVM_semicontrolled_Y, 'LineWidth', 5);
plot(one_class_DNN_semicontrolled_X, one_class_DNN_semicontrolled_Y, 'LineWidth', 5);
plot(two_class_DNN_semicontrolled_X, two_class_DNN_semicontrolled_Y, 'LineWidth', 5);
xlabel('FPR'); ylabel('TPR');
legend('proposed (horizontal)', 'proposed (vertical)', 'proposed (double)', 'LBP+OSVM', 'LBP+SVM', 'Deep SVDD', 'ResNet50', 'Location', 'southeast');
set(gca, 'FontName', 'times', 'FontSize', 25, 'FontSmoothing', 'on');  
set(gcf, 'units', 'pixels','OuterPosition', [0 0 700 700], 'Position', [0 0 700 700], 'Color', 'w');
disp(['proposed_fast_semicontrolled_AUC: ' num2str(proposed_fast_semicontrolled_AUC)]);
disp(['proposed_slow_semicontrolled_AUC: ' num2str(proposed_slow_semicontrolled_AUC)]);
disp(['proposed_double_semicontrolled_AUC: ', num2str(proposed_double_semicontrolled_AUC)]);
disp(['OSVM_semicontrolled_AUC: ', num2str(one_class_DNN_semicontrolled_AUC)]);
disp(['Resnet_semicontrolled_AUC: ', num2str(two_class_DNN_semicontrolled_AUC)]);

% plot the ROC result for realistic experiment
figure;
plot(proposed_fast_realistic_X, proposed_fast_realistic_Y, 'LineWidth', 5);
hold on;
plot(proposed_slow_realistic_X, proposed_slow_realistic_Y, 'LineWidth', 5);
plot(proposed_double_realistic_X, proposed_double_realistic_Y, 'LineWidth', 5);
plot(one_class_SVM_realistic_X, one_class_SVM_realistic_Y, 'LineWidth', 5);
hold on;
plot(two_class_SVM_realistic_X, two_class_SVM_realistic_Y, 'LineWidth', 5);
plot(one_class_DNN_realistic_X, one_class_DNN_realistic_Y, 'LineWidth', 5);
plot(two_class_DNN_realistic_X, two_class_DNN_realistic_Y, 'LineWidth', 5);
xlabel('FPR'); ylabel('TPR');
legend('proposed (horizontal)', 'proposed (vertical)', 'proposed (double)', 'LBP+OSVM', 'LBP+SVM', 'Deep SVDD', 'ResNet50', 'Location', 'southeast');
set(gca, 'FontName', 'times', 'FontSize', 25, 'FontSmoothing', 'on');  
set(gcf, 'units', 'pixels','OuterPosition', [0 0 700 700], 'Position', [0 0 700 700], 'Color', 'w');
disp(['proposed_fast_realistic_AUC: ' num2str(proposed_fast_realistic_AUC)]);
disp(['proposed_slow_realistic_AUC: ' num2str(proposed_slow_realistic_AUC)]);
disp(['proposed_double_realistic_AUC: ', num2str(proposed_double_realistic_AUC)]);
disp(['Resnet_realistic_AUC: ', num2str(two_class_DNN_realistic_AUC)]);

% plot the ROC result for wild experiment
figure;
plot(proposed_fast_wild_X, proposed_fast_wild_Y, 'LineWidth', 5);
hold on;
plot(proposed_slow_wild_X, proposed_slow_wild_Y, 'LineWidth', 5);
plot(proposed_double_wild_X, proposed_double_wild_Y, 'LineWidth', 5);
plot(one_class_SVM_wild_X, one_class_SVM_wild_Y, 'LineWidth', 5);
hold on;
plot(two_class_SVM_wild_X, two_class_SVM_wild_Y, 'LineWidth', 5);
plot(one_class_DNN_wild_X, one_class_DNN_wild_Y, 'LineWidth', 5);
plot(two_class_DNN_wild_X, two_class_DNN_wild_Y, 'LineWidth', 5);
xlabel('FPR'); ylabel('TPR');
legend('proposed (horizontal)', 'proposed (vertical)', 'proposed (double)', 'LBP+OSVM', 'LBP+SVM', 'Deep SVDD', 'ResNet50', 'Location', 'southeast');
set(gca, 'FontName', 'times', 'FontSize', 25, 'FontSmoothing', 'on');  
set(gcf, 'units', 'pixels','OuterPosition', [0 0 700 700], 'Position', [0 0 700 700], 'Color', 'w');
disp(['proposed_fast_wild_AUC: ' num2str(proposed_fast_wild_AUC)]);
disp(['proposed_slow_wild_AUC: ' num2str(proposed_slow_wild_AUC)]);
disp(['proposed_double_wild_AUC: ', num2str(proposed_double_wild_AUC)]);
disp(['Resnet_wild_AUC: ', num2str(two_class_DNN_wild_AUC)]);
