%% perspective the captured images in batch (needed for images captured by camera)
%% clean up the workspace
clear;
clc;
close all;
%% read in captured images
% the input image path
scanned_halftone_dir_name = 'D:\Databases\HalftoneImageDatabase\scanned\pcpc_ht_ref_45_73_600_1200_600_1200_raw\';
% delete the hidden files
delete([scanned_halftone_dir_name 'desktop.ini']);
delete([scanned_halftone_dir_name '/.*']);
% get the directory object
scanned_halftone_dir = dir(scanned_halftone_dir_name);
% do not include the . and .. directories
scanned_halftone_dir([scanned_halftone_dir.isdir]) = [];
%% specifies the output images settings
% the crop size: the crop_size must be even to allow easier spectrum processing 
crop_width = 600;
crop_height = 600;
% the output image path
scanned_halftone_corrected_dir_name = 'D:\Databases\HalftoneImageDatabase\scanned\pcpc_ht_ref_45_73_600_1200_600_1200\';
% delete the previously existing files
redo = 0;
if redo
  delete([scanned_halftone_corrected_dir_name '/*']);
end
scanned_halftone_corrected_dir = dir(scanned_halftone_corrected_dir_name);
scanned_halftone_corrected_dir([scanned_halftone_corrected_dir.isdir]) = [];
% extract the filenames of the existing files
scanned_halftone_corrected_name = cell(length(scanned_halftone_corrected_dir), 1);
for i = 1:length(scanned_halftone_corrected_dir)
  scanned_halftone_corrected_name{i} = scanned_halftone_corrected_dir(i).name;
end
inputImageFigure = figure;
outputImageFigure = figure;
%% process each scanned image
for i = 1 : length(scanned_halftone_dir)
  % read in input gray scale images
  fileName = scanned_halftone_dir(i).name;
  % if the cropped images exists and not re-doing the crop, then skip
  fileIdx = find(cellfun(@(x) contains(x, fileName), scanned_halftone_corrected_name, 'UniformOutput', true), 1);
  if ~isempty(fileIdx) && ~redo
    continue;
  end
  % read input image
  img_input = (imread([scanned_halftone_dir_name fileName]));
  while true
    %% select corner pooint
    % show input image
    figure(inputImageFigure)
    clf(inputImageFigure)
    imshow(img_input);
    set(gcf, 'units', 'pixels', 'Color', 'w', 'OuterPosition', [0 0 1500 1500], 'Position', [0 0 1500 1500]);  
    % get corner points in clockwise order
    [X, Y] = ginput(4);
    %% do perspective correction DLT method
    x = [1; crop_width; crop_width; 1];
    y = [1; 1; crop_height; crop_height];
    % c): uses the direct linear method
    A = zeros(8, 8);
    A(1,:) = [X(1),Y(1), 1, 0, 0, 0,-1 * X(1) * x(1), -1 * Y(1) * x(1)];
    A(2,:) = [0, 0, 0, X(1), Y(1), 1,-1*X(1)*y(1),-1*Y(1)*y(1)];
    A(3,:) = [X(2),Y(2),1,0,0,0,-1*X(2)*x(2),-1*Y(2)*x(2)];
    A(4,:) = [0,0,0,X(2),Y(2),1,-1*X(2)*y(2),-1*Y(2)*y(2)];
    A(5,:) = [X(3),Y(3),1,0,0,0,-1*X(3)*x(3),-1*Y(3)*x(3)];
    A(6,:) = [0,0,0,X(3),Y(3),1,-1*X(3)*y(3),-1*Y(3)*y(3)];
    A(7,:) = [X(4),Y(4),1,0,0,0,-1*X(4)*x(4),-1*Y(4)*x(4)];
    A(8,:) = [0,0,0,X(4),Y(4),1,-1*X(4)*y(4),-1*Y(4)*y(4)];
    v = [x(1); y(1); x(2); y(2); x(3); y(3); x(4); y(4)];
    u = A \ v;
    U = reshape([u; 1], 3, 3)';
    w = U * [X'; Y'; ones(1, 4)];
    w = w ./ (ones(3, 1) * w(3, :));
    T = maketform('projective', U');
    img_corrected = imtransform(img_input, T, 'bicubic', 'XData', [1 crop_width], 'YData', [1 crop_height]);
    % show correction result
    figure(outputImageFigure);
    clf(outputImageFigure);
    imshow(img_corrected);
    [~, ~, b] = ginput(1);
    % check the correction result
    switch b
      case 99     % 'c': keep the result and continue the next selection process
        % save the corrected images
        corrected_img_path = [scanned_halftone_corrected_dir_name fileName];
        % save the cropped image
        if ~exist(corrected_img_path, 'file')
          imwrite(rgb2gray(img_corrected), corrected_img_path);
          disp(['writting ' corrected_img_path]);
        end
        break;
      otherwise   % clear figure and repeat
        figure(outputImageFigure);
        clf(outputImageFigure);
        continue;
    end
  end
end