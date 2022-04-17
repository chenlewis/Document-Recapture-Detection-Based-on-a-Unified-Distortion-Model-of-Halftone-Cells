%% calculate the percentage of the processed region and the number of cropped images
%% clean up the workspace
clear;
clc;
close all;
%% image parameters
secondPrint = 1;
%% read in captured images
scanned_halftone_dir_name = 'psps_ht_doc_45_73_600_1200_600_1200_raw';
scanned_halftone_crop_dir_name = 'psps_ht_doc_45_73_600_1200_600_1200_crop_224';
% the input image path
if ispc
  scanned_halftone_dir_path = ['D:\Databases\HalftoneImageDatabase\scanned\', scanned_halftone_dir_name, '\'];
  scanned_halftone_crop_dir_path = ['D:\Databases\HalftoneImageDatabase\scanned\', scanned_halftone_crop_dir_name, '\'];
else
  scanned_halftone_dir_path = ['/Volumes/d/Databases/HalftoneImageDatabase/scanned/', scanned_halftone_dir_name, '/'];
  scanned_halftone_crop_dir_path = ['/Volumes/d/Databases/HalftoneImageDatabase/scanned/', scanned_halftone_crop_dir_name, '/'];
end
% remove the invalid items from the directory
delete([scanned_halftone_dir_path '\.*']);
delete([scanned_halftone_dir_path 'desktop.ini']);
delete([scanned_halftone_dir_path 'Thumbs.db']);
% get the directory object: do not include the . and .. directoriess
scanned_halftone_dir = dir(scanned_halftone_dir_path);
scanned_halftone_dir([scanned_halftone_dir.isdir]) = [];
% remove the invalid items from the directory
delete([scanned_halftone_crop_dir_path '\.*']);
delete([scanned_halftone_crop_dir_path 'desktop.ini']);
delete([scanned_halftone_crop_dir_path 'Thumbs.db']);
% get the directory object for cropped images: do not include the . and .. directoriess
scanned_halftone_crop_dir = dir(scanned_halftone_crop_dir_path);
scanned_halftone_crop_dir([scanned_halftone_crop_dir.isdir]) = [];
%% specifies the output images settings
% extract the filenames of the existing files
scanned_halftone_crop_name = cell(length(scanned_halftone_crop_dir), 1);
for i = 1:length(scanned_halftone_crop_dir)
  scanned_halftone_crop_name{i} = scanned_halftone_crop_dir(i).name;
end
%% load the crop points (this is unique for document images)
fileid = fopen('doc_2nd_loc_45_73_1200.txt', 'r');
a = textscan(fileid, ['%s', repmat('%d', [1, 8])], 'CollectOutput', 1, 'Delimiter','|');
filenames = a{1};
crop_points = a{2};
%% process each scanned image
cropInfoList = cell(1, length(scanned_halftone_dir));
for i = 1 : length(scanned_halftone_dir)
  % read in input gray scale images
  fileName = scanned_halftone_dir(i).name;
  image_property_idx = strfind(fileName, '_');
  image_ext_idx = strfind(fileName, '.');
  % read input image
  img_input = (imread([scanned_halftone_dir_path fileName]));
  % if the cropped images exists and not re-doing the crop, then skip
  croppedFileIdices = find(cellfun(@(x) contains(x, fileName(1:image_ext_idx(1) - 1)), scanned_halftone_crop_name, 'UniformOutput', true));
  cropInfoList{i}.numCroppedImages = length(croppedFileIdices);
  cropInfoList{i}.fileName = fileName;
  cropInfoList{i}.imageSize = size(img_input);
  % calculate the crop area
  fileIdx = find(cellfun(@(x) strcmp(x, fileName), filenames, 'UniformOutput', true), 1);
  cropPtns = crop_points(fileIdx, :);
  cropInfoList{i}.selectionArea = double((cropPtns(4) - cropPtns(2) + 1) * (cropPtns(5) - cropPtns(1) + 1));
  cropInfoList{i}.selectionRatio = cropInfoList{i}.selectionArea / (cropInfoList{i}.imageSize(1) * cropInfoList{i}.imageSize(2));
  % show progress
  disp(i / length(scanned_halftone_dir));
end

%% 
selectionRatio = [];
numCroppedImages = [];
for i = 1 : length(cropInfoList)
  selectionRatio = [selectionRatio cropInfoList{i}.selectionRatio];
  numCroppedImages = [numCroppedImages cropInfoList{i}.numCroppedImages];
end

max(selectionRatio), min(selectionRatio), mean(selectionRatio)







