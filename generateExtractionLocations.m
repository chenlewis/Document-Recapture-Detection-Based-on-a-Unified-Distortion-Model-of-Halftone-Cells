%% clean up the workspace
clear; 
clc;
close all;
%% read in captured image path
% the input images
scanned_halftone_dir_name = 'D:\Databases\HalftoneImageDatabase\scanned\ps_ht_doc_45_73_600_1200_raw\';
% delete the hidden files
delete([scanned_halftone_dir_name 'desktop.ini']);
delete([scanned_halftone_dir_name '/.*']);
% get the directory object
scanned_halftone_dir = dir(scanned_halftone_dir_name);
% do not include the . and .. directories
scanned_halftone_dir([scanned_halftone_dir.isdir]) = [];
%% load the locations of the extracted regions
docLocFilename = 'doc_1st_loc_45_73_1200.txt';
fileid = fopen(docLocFilename, 'r');
a = textscan(fileid, ['%s', repmat('%d',[1, 8])], 'CollectOutput', 1, 'Delimiter','|');
fclose(fileid);
filenames = a{1};
cropPoints = a{2};
%% process each scanned image
checking = 0;
validRegionSelection = figure;
for i = 1 : length(scanned_halftone_dir)
  % read in input gray scale images
  fileName = scanned_halftone_dir(i).name;
  % find the file index in the extraction location file
  fileIdx = find(cellfun(@(x) strcmp(x, fileName), filenames, 'UniformOutput', true), 1);
  % add new ROI to the corresponding image. when the original ROI is not defined.
  if ~checking && isempty(fileIdx)
    % read input images
    imgInput = (imread([scanned_halftone_dir_name fileName]));
    % run ocr on selected regions
    while true
      % only need to see the selected image
      [selectedImage, roiPosition] =  ImageInteractive.SelectROI(imgInput);
      % check the image selection result
      figure(validRegionSelection);
      clf(validRegionSelection);
      imshow(selectedImage);
      title('imageSelectionResult');
      [x, y, b] = ginput(1);
      switch b
        case 99     % 'c': keep the result and continue the next selection process
          % open file
          fileid = fopen(docLocFilename, 'a');
          % save the ROI regiens 
          roiPosition = round(roiPosition);
          fprintf(fileid, '%s\n', [fileName ...
                                    '| ' num2str(roiPosition(1)) ...                      % TL: (xmin, ymin)
                                    ' | ' num2str(roiPosition(2)) ... 
                                    ' | ' num2str(roiPosition(1)) ...                     % BL: (xmin, ymin + height)
                                    ' | ' num2str(roiPosition(2) + roiPosition(4)) ...
                                    ' | ' num2str(roiPosition(1) + roiPosition(3)) ...    % TR: (xmin + width, ymin)
                                    ' | ' num2str(roiPosition(2)) ...
                                    ' | ' num2str(roiPosition(1) + roiPosition(3)) ...
                                    ' | ' num2str(roiPosition(2) + roiPosition(4))]);     % BR: (xmin + width, ymin + height)
          fclose(fileid);
          disp('continue to next image after saving');
          break;
        otherwise % when other key is pressed
          figure(validRegionSelection);
          clf(validRegionSelection);
          continue;
      end
    end
  % check the ROI only
  elseif checking && ~isempty(fileIdx)
    cropPtns = cropPoints(fileIdx, :);
    imgInput = (imread([scanned_halftone_dir_name fileName]));
    figure(validRegionSelection);
    clf(validRegionSelection);
    imshow(imgInput);
    hold on;
    plot(cropPtns(1:2:end), cropPtns(2:2:end), 'r*');
    pause
    disp(fileName);
  end
end