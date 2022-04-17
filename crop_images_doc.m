%% crop document images
%% clean up the workspace
clear;
clc;
close all;
%% image parameters
secondPrint = 1;
%% read in captured images
% the input image path
scanned_halftone_dir_name = 'D:\Databases\HalftoneImageDatabase\scanned\ps_ht_doc_45_73_600_1200_raw\';
% delete the hidden files
delete([scanned_halftone_dir_name 'desktop.ini']);
delete([scanned_halftone_dir_name '/.*']);
% get the directory object
scanned_halftone_dir = dir(scanned_halftone_dir_name);
% do not include the . and .. directories
scanned_halftone_dir([scanned_halftone_dir.isdir]) = [];
%% specifies the output images settings
% the crop size: the crop_size must be even to allow easier spectrum processing
crop_width = 224;
crop_height = 224;
% the output image path
scanned_halftone_crop_dir_name = 'D:\Databases\HalftoneImageDatabase\scanned\ps_ht_doc_45_73_600_1200_crop_500\';
% delete the previously existing files
redo = 0;
if redo
  delete([scanned_halftone_crop_dir_name '/*']);
end
scanned_halftone_crop_dir = dir(scanned_halftone_crop_dir_name);
scanned_halftone_crop_dir([scanned_halftone_crop_dir.isdir]) = [];
% extract the filenames of the existing files
scanned_halftone_crop_name = cell(length(scanned_halftone_crop_dir), 1);
for i = 1:length(scanned_halftone_crop_dir)
  scanned_halftone_crop_name{i} = scanned_halftone_crop_dir(i).name;
end
%% load the crop points (this is unique for document images)
fileid = fopen('doc_1st_loc_45_73_1200.txt', 'r');
a = textscan(fileid, ['%s', repmat('%d', [1, 8])], 'CollectOutput', 1, 'Delimiter','|');
filenames = a{1};
crop_points = a{2};
%% process each scanned image
for i = 1 : length(scanned_halftone_dir)
  % read in input gray scale images
  fileName = scanned_halftone_dir(i).name;
  image_property_idx = strfind(fileName, '_');
  image_ext_idx = strfind(fileName, '.');
  % if the cropped images exists and not re-doing the crop, then skip
  fileIdx = find(cellfun(@(x) contains(x, fileName(1:image_ext_idx(1) - 1)), scanned_halftone_crop_name, 'UniformOutput', true), 1);
  if ~isempty(fileIdx) && ~redo
    continue;
  end
  % read input image
  img_input = (imread([scanned_halftone_dir_name fileName]));
  %% do cropping to the input image
  fileIdx = find(cellfun(@(x) strcmp(x, fileName), filenames, 'UniformOutput', true), 1);
  cropPtns = crop_points(fileIdx, :);
  img_input = img_input(cropPtns(2):cropPtns(4), cropPtns(1):cropPtns(5));
  % the cropping point
  crop_points_x = 1 : crop_width : size(img_input, 2);
  crop_points_y = 1 : crop_height : size(img_input, 1);
  %% initialized cropped image block
  img_crop = cell(length(crop_points_x) - 1, length(crop_points_y) - 1);
  for x = 1 : length(crop_points_x) - 1
    for y = 1 : length(crop_points_y) - 1
      x_range = crop_points_x(x) : crop_points_x(x + 1) - 1;
      y_range = crop_points_y(y) : crop_points_y(y + 1) - 1;
      img_crop{x, y} = img_input(y_range, x_range);
    end
  end
  %% save the cropped images
  for j = 1 : ((length(crop_points_x) - 1) * (length(crop_points_y) - 1))
    % initialize path of output images
    cropped_img_path = [scanned_halftone_crop_dir_name fileName '_' num2str(j) '.bmp'];
    cropped_img_rot_path = [scanned_halftone_crop_dir_name fileName '_' num2str(j) '_rot' '.bmp'];
    % save the cropped image
    if ~exist(cropped_img_path, 'file')
      imwrite(img_crop{j}, cropped_img_path);
      disp(['writting ' cropped_img_path]);
    end
    % save the cropped image rotated by 90
    if ~exist(cropped_img_rot_path, 'file')
      imwrite(fliplr(img_crop{j}'), cropped_img_rot_path);
      disp(['writting ' cropped_img_rot_path]);
    end  
  end
end