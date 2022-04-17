%% clear the workspace
close all;
clear;
clc;
warning('on','all');
% whether to show figures or not
set(0, 'DefaultFigureVisible', 'on');
%% read in captured images
halftoneAngle = 45;
imgBlkSize = 224;        % the block size of the image
cellSize = 12;           % the sampled cell size
clusterErrorThres = 12;  % initial value is 21
finalPPI = 1200;
numPeaks = 7;

minNumRows = 5;         % initial value is 5
numKmeanTrials = 20;    % 

scanned_halftone_dir_name = ['D:\Databases\HalftoneImageDatabase\scanned\ps_ht_ref_45_73_600_1200_crop_224\'];
dataFileName = 'data_1st_ref_45_73_224_1200_space_7.mat';
% remove the invalid items from the directory
delete([scanned_halftone_dir_name '\.*']);
delete([scanned_halftone_dir_name 'desktop.ini']);
delete([scanned_halftone_dir_name 'Thumbs.db']);
% do not include directory or hidden files
scanned_halftone_dir = dir(scanned_halftone_dir_name);
scanned_halftone_dir([scanned_halftone_dir.isdir]) = [];

%% read in existing data_collection
if (exist(dataFileName, 'file') == 2)
  load(dataFileName, 'data_collection');
else
  data_collection = {};
end
%% process the data_collection cell
% for empty data_collection: the file index from scanned_halftone_dir is the same as in dataset collection
if isempty(data_collection)
  data_collection = cell(length(scanned_halftone_dir), 12);
  data_collection(:, 1) = {scanned_halftone_dir.name};
% for non-empty data_collection: then add the names of the new filenames in the data collection cell array
else
  for scanned_halftone_dir_ind = 1:length(scanned_halftone_dir)
    % read in the input file name
    fileName = scanned_halftone_dir(scanned_halftone_dir_ind).name;
    % if image has not been processed, then append it to the end of the data-collection
    if isempty(find(cellfun(@(x) strcmp(x, fileName), data_collection(:, 1), 'UniformOutput', true), 1))
      data_collection(end + 1, :) = cell(1, 12);
      data_collection{end, 1} = fileName;
    end
  end
end
%% process image by image
redo = 1;
close all;
num_img_blks = length(data_collection);

%%
% parallel = 1;
% parfor ii = 1 : num_img_blks
  
%%
parallel = 0;
for ii = 1 : num_img_blks

  %% do checking
  % if the image has been processed
  data_collection_check = data_collection(ii, :);
  fileName = data_collection_check{1};
  % get the filename separater and extension
  separatorIdx = strfind(fileName, '_');
  extIdx = strfind(fileName, '.');     
   
%   % check particular image block
%   if strcmp(fileName, 'hp6222_realmegtneo_190_4.bmp_2.bmp') || strcmp(fileName, 'hp6222_realmegtneo_190_4.bmp_2_rot.bmp')
%     disp(fileName);
%   else 
%     continue;
%   end

  % check intensity
  if strcmp(fileName((separatorIdx(2)+1):(separatorIdx(3)-1)), '50') 
    continue;
  else
    disp(fileName);
  end

%   % check particular image block
%   if strcmp(fileName, 'hp6222_epson850_210_2_short.bmp_3.bmp')
%     disp(fileName);
%   else 
%     continue;
%   end

%   if data_collection_check{10} > 1.5
%     data_collection_temp = cell(1, 12);
%     data_collection_temp{1} = fileName;
%     data_collection_temp{2} = 0;
%     data_collection_temp{3} = 0;
%     data_collection_temp{4} = 0;
%     data_collection_temp{5} = 0;
%     data_collection_temp{6} = 0;
%     data_collection_temp{7} = 0; % N
%     data_collection_temp{8} = 0;
%     data_collection_temp{9} = 0;
%     data_collection_temp{10} = 0;
%     data_collection_temp{11} = 0;
%     data_collection_temp{12} = 0;
%     data_collection(ii, :) = data_collection_temp;
%     disp(data_collection_check{1})
%     continue;
%   else
%     continue;
%   end

%   % if the image has been processed, then continue
%   if ~isempty(data_collection_check{2}) && ~redo 
%     disp(data_collection_check{1})
%     continue;
%   else
%     disp(data_collection_check{1})
%   end
  %% read in the image
  imgInput = (imread([scanned_halftone_dir_name fileName]));
  % initialize data collection temp to store the data
  data_collection_temp = cell(1, 12);
  data_collection_temp{1} = fileName;
  % this is used in marking whether there are potential scanner issue
  scannerIssue = 0;
  kmeanIssue = 0;
  %% binarization
  % normalization
  imgInput_max = double(max(imgInput(:)));
  imgInput_min = double(min(imgInput(:)));
  imgInput = uint8(255 .* ((double(imgInput) - imgInput_min)) ./ (imgInput_max - imgInput_min));
  % show the scanned image input
  if parallel == 0
    figure;
    imshow(imgInput);
    set(gca, 'FontSize', 25, 'FontSmoothing', 'on');  
    set(gcf, 'units', 'pixels','OuterPosition', [0 0 600 600], 'Position', [0 0 600 600], 'Color', 'w');
    title('the scanned cropped image');
  end
  %  using adaptive threshold: foreground is bright, background is dark. 
  imgInputBinary = imbinarize(imgInput, adaptthresh(imgInput, 0.6, ...
                              'ForegroundPolarity', 'bright',...
                              'NeighborhoodSize', [31 31], 'Statistic', 'mean'));
  if parallel == 0
    figure;
    imshow(imgInputBinary)
    set(gca, 'FontSize', 25, 'FontSmoothing', 'on');  
    set(gcf, 'units', 'pixels','OuterPosition', [0 0 600 600], 'Position', [0 0 600 600], 'Color', 'w');
    title('binarized input image');  
  end
  % denoise the binary image
  imgInputBinaryDenoise = medfilt2(imgInputBinary, [3 3], 'symmetric');
  if parallel == 0
    figure;
    imshow(imgInputBinaryDenoise)
    title('image denoise median filter 1');
  end
  imgInputBinaryDenoise = medfilt2(imgInputBinaryDenoise, [3 3], 'symmetric');
  if parallel == 0
    figure;
    imshow(imgInputBinaryDenoise)
    title('image denoise median filter 2');
  end
  stats = regionprops(imgInputBinaryDenoise, 'Area');
  imgInputBinaryDenoise = ismember(labelmatrix(bwconncomp(imgInputBinaryDenoise)), find([stats.Area] > median([stats.Area]) / 2)); 
  imgInputBinaryDenoiseInv = logical(1 - imgInputBinaryDenoise);
  stats = regionprops(imgInputBinaryDenoiseInv, 'Area');
  imgInputBinaryDenoiseInv = ismember(labelmatrix(bwconncomp(imgInputBinaryDenoiseInv)), find([stats.Area] > median([stats.Area]) / 2));  
  imgInputBinaryDenoise = logical(1 - imgInputBinaryDenoiseInv);
  % show the binarization resutl
  if parallel == 0
    figure; 
    imshow(imgInputBinaryDenoise);
    title('image denoise region filter');
  end
  %% extract 1-D spatial domain info by searching in the vert direction
  % i.e. col by col, the output is how many rows 
  % the top bottom and center: pixel coordinate of the top bottom and center of halftone cells in the vertical direction
  % num_halftone_dots_col:     the number of halftone cells at each x axis
  % '2' means vert direction
  % the input image is actually the inverse of the binary denoised image
  [halftone_dot_top, ...
   halftone_dot_bottom, ...
   halftone_dot_col_width, ...
   halftone_dot_col_center, ...
   num_halftone_dots_col, ...
   halftone_x_coord] = feature_extraction(imgInputBinaryDenoiseInv, 2, 1);
  % if no halftone cells are detected, then return kmean issue
  if isempty(halftone_dot_col_center)
    close all;
    disp(['halftone dot detection issue vert' num2str(ii)]);
    kmeanIssue = 1;
    data_collection_temp{2} = scannerIssue;
    data_collection_temp{3} = kmeanIssue;
    data_collection_temp{4} = 0;
    data_collection_temp{5} = 0;
    data_collection_temp{6} = 0;
    data_collection_temp{7} = 0; % N
    data_collection_temp{8} = 0;
    data_collection_temp{9} = 0;
    data_collection_temp{10} = 0;
    data_collection_temp{11} = 0;
    data_collection_temp{12} = 0;
    data_collection(ii, :) = data_collection_temp;
    continue;
  end
  % plot the histogram of the halftone dot counts at the vertical direction
  halftone_dots_hist_edges_col = min(num_halftone_dots_col) - 0.5 : 1 : max(num_halftone_dots_col) + 1.5;
  if parallel == 0
    % plot the number of halftone dots vert
    figure;
    histogram(num_halftone_dots_col, halftone_dots_hist_edges_col);
    title('number of halftone dots hist at the vert dimension');
    set(gca, 'FontSize', 15, 'FontSmoothing', 'on');  
    title('num of halftone cells at each column');
  end
  % the first stage rough check: find the most common number of halftone cells
  [bin_count, bin_edges] = histcounts(num_halftone_dots_col, halftone_dots_hist_edges_col);
  bin_centers = (bin_edges(2 : end) + bin_edges(1 : end - 1)) ./ 2;
  [~, max_ind] = max(bin_count);
  rough_num_cells_vert = bin_centers(max_ind);
  % it is doubled due to the 45 degree rotation
  % uppber bound of checking is 2N+5
  % lower bound of checking is 1 or 2N-5
  if halftoneAngle == 45
    if 2 * rough_num_cells_vert < 6
      num_halftone_dots_col_trails = 1:(2 * rough_num_cells_vert + 5);
    else
      num_halftone_dots_col_trails = (2 * rough_num_cells_vert - 5):(2 * rough_num_cells_vert + 5);
    end
  else
    if rough_num_cells_vert < 6
      num_halftone_dots_col_trails = 1:(rough_num_cells_vert + 5);
    else
      num_halftone_dots_col_trails = (rough_num_cells_vert - 5):(rough_num_cells_vert + 5);
    end
  end
  % if the number of detected halftone cells in the vertical direction is less than the upper bound, return error
  if length(halftone_dot_col_center(1, :)) < max(num_halftone_dots_col_trails)
    close all;
    disp(['halftone dot detection issue vert: line ' 250]);
    kmeanIssue = 1;
    data_collection_temp{2} = scannerIssue;
    data_collection_temp{3} = kmeanIssue;
    data_collection_temp{4} = 0;
    data_collection_temp{5} = 0;
    data_collection_temp{6} = 0;
    data_collection_temp{7} = 0; % N
    data_collection_temp{8} = 0;
    data_collection_temp{9} = 0;
    data_collection_temp{10} = 0;
    data_collection_temp{11} = 0;
    data_collection_temp{12} = 0;
    data_collection(ii, :) = data_collection_temp;
    continue;
  end
  % initialize cluster results
  sumd_new_max = zeros(1, length(num_halftone_dots_col_trails));
  cluster_vert_idx = cell(1, length(num_halftone_dots_col_trails));
  % the sorted cluster centers and the sorting indices
  cluster_centers_new_vert = cell(1, length(num_halftone_dots_col_trails));
  cluster_center_ind_vert = cell(1, length(num_halftone_dots_col_trails));
  % for each specified num of kmean trials
  for i = 1:length(num_halftone_dots_col_trails)
    % do clustering to find the centers of the dots along the horizontal direction
    % cluster_vert_idx: the indices to the corresponding centers assigned from each sample
    [cluster_vert_idx{i}, cluster_col_centers, sumd] = ...
      kmeans(halftone_dot_col_center(1, :)', num_halftone_dots_col_trails(i), 'Display', 'off', 'Replicates', numKmeanTrials);   
    % sort the cluster centers
    [cluster_centers_new_vert{i}, cluster_center_ind_vert{i}] = sort(cluster_col_centers);
    % collect the number of halftone cells 
    num_dots_cluster_i = zeros(1, length(cluster_center_ind_vert{i}));
    % get the number of halftone cells corresponding to each cluster center
    for temp_i = 1:length(cluster_center_ind_vert{i})
      num_dots_cluster_i(temp_i) = length(find(cluster_vert_idx{i} == cluster_center_ind_vert{i}(temp_i)));
    end
    % get the maximum average sum error
    sumd_new_max(i) = max(sumd(cluster_center_ind_vert{i}) ./ num_dots_cluster_i');
  end
  % find the correct set of cluster centers: the 21 needs to be changed for 600 dpi. 
  est_clusters_ind = find(sumd_new_max < clusterErrorThres, 1, 'first');
  % if error is large
  if isempty(est_clusters_ind)
    close all;
    disp(['could not find the correct number in kmean: index ', num2str(ii)]);
    kmeanIssue = 1;
    data_collection_temp{2} = scannerIssue;
    data_collection_temp{3} = kmeanIssue;
    data_collection_temp{4} = 0;
    data_collection_temp{5} = 0;
    data_collection_temp{6} = 0;
    data_collection_temp{7} = 0; % N
    data_collection_temp{8} = 0;
    data_collection_temp{9} = 0;
    data_collection_temp{10} = 0;
    data_collection_temp{11} = 0;
    data_collection_temp{12} = 0;
    data_collection(ii, :) = data_collection_temp;
    continue;
  end
  % choose the correct set of clusters
  cluster_vert_idx_sel = cluster_vert_idx{est_clusters_ind};                  % represent which cluster each halftone cell center correspond to
  cluster_centers_new_vert_sel = cluster_centers_new_vert{est_clusters_ind};  % the sorted cluster centers
  cluster_center_ind_vert_sel = cluster_center_ind_vert{est_clusters_ind};    % the sorting index of the cluster centers
  % record and shift the centers, then plot the histogram
  halftone_dot_center_cluster_vert = cell(1, max(cluster_vert_idx_sel));      % stores the samples in clusters 
  halftone_dot_center_cluster_vert_x = cell(1, max(cluster_vert_idx_sel));    % stores the samples in clusters (the x coordinate)
  halftone_dot_top_cluster_vert = cell(1, max(cluster_vert_idx_sel));
  halftone_dot_bottom_cluster_vert = cell(1, max(cluster_vert_idx_sel));
  halftone_dot_center_sample_std_vert = zeros(1, max(cluster_vert_idx_sel));  % the std of each cluster
%   halftone_dot_center_cluster_shifted_col = [];

  if parallel == 0
    figure;
  end
  % for each cluster
  for i = 1 : length(cluster_centers_new_vert_sel)
    % group the halftone cells into clusters
    halftone_dot_center_cluster_vert{i} = halftone_dot_col_center(cluster_vert_idx_sel == cluster_center_ind_vert_sel(i));
    halftone_dot_center_cluster_vert_x{i} = halftone_x_coord(cluster_vert_idx_sel == cluster_center_ind_vert_sel(i));
    halftone_dot_top_cluster_vert{i} = halftone_dot_top(cluster_vert_idx_sel == cluster_center_ind_vert_sel(i));
    halftone_dot_bottom_cluster_vert{i} = halftone_dot_bottom(cluster_vert_idx_sel == cluster_center_ind_vert_sel(i));
    % collect the std of the cluster (might not be used)
    halftone_dot_center_sample_std_vert(i) = std(halftone_dot_center_cluster_vert{i});

    if parallel == 0
      histogram(halftone_dot_center_cluster_vert{i}, min(halftone_dot_col_center) - 0.5 : 1 : max(halftone_dot_col_center) + 0.5);
      hold on;
      plot(halftone_dot_center_cluster_vert{i}, zeros(1, length(halftone_dot_center_cluster_vert{i})), '*');
      stem(cluster_centers_new_vert_sel(i), 50, 'LineWidth', 2);
    end
  end
  if parallel == 0
    hold off;
    xlabel('$l_c$', 'Interpreter', 'latex');
    set(gca, 'FontName', 'Times', 'FontSize', 25, 'FontSmoothing', 'on');  
    set(gcf, 'units', 'pixels', 'OuterPosition', [0 0 1000 600], 'Position', [0 0 1000 600], 'Color', 'w');
    title('Clustering Result in Vertical Direction');
  end
  % plot the halftone cell extraction result in input image
  if parallel == 0
    figure;
    imshow(imgInput);
%     imshow(imgInputBinaryDenoise);
    hold on;
    % for each cluster
    for i = 2 : length(cluster_centers_new_vert_sel) - 1
      % draw the row center
%       plot(1:size(imgInput, 2), ones(1, size(imgInput, 2)) .* cluster_centers_new_vert_sel(i), 'b', 'LineWidth', 2);
      halftone_dot_center_cluster_vert{i} = halftone_dot_col_center(cluster_vert_idx_sel == cluster_center_ind_vert_sel(i));
      halftone_dot_center_cluster_vert_x{i} = halftone_x_coord(cluster_vert_idx_sel == cluster_center_ind_vert_sel(i));
      plot(halftone_dot_center_cluster_vert_x{i}, halftone_dot_center_cluster_vert{i}, 'bs', 'MarkerSize', 5, 'MarkerFaceColor', 'b');
      plot(halftone_dot_center_cluster_vert_x{i}, halftone_dot_top_cluster_vert{i}, 'rs', 'MarkerSize', 5, 'MarkerFaceColor', 'r');
      plot(halftone_dot_center_cluster_vert_x{i}, halftone_dot_bottom_cluster_vert{i}, 'rs', 'MarkerSize', 5, 'MarkerFaceColor', 'r');
    end
    axis on;
    xlabel('$k_r$', 'Interpreter', 'latex');
    ylabel('$l_r$', 'Interpreter', 'latex');
    set(gca, 'FontName', 'Times', 'FontSize', 25, 'FontSmoothing', 'on');  
    set(gcf, 'units', 'pixels', 'OuterPosition', [0 0 1000 600], 'Position', [0 0 1000 600], 'Color', 'w');
    title('the halftone cell extraction result');
  end
  %% extract 1-D spatial domain info by searching at the horiz direction
  if halftoneAngle == 90
    rowCenterToCheckRaw = cluster_centers_new_vert_sel(2:(end - 1));
    rowCenterToCheck = [];
    for checkIdx = 1:length(rowCenterToCheckRaw) - 1
      rowCenterToCheckStep = (rowCenterToCheckRaw(checkIdx + 1) - rowCenterToCheckRaw(checkIdx)) / 4;
      temp = rowCenterToCheckRaw(checkIdx):rowCenterToCheckStep:rowCenterToCheckRaw(checkIdx + 1);
      rowCenterToCheck = [rowCenterToCheck temp(1 : end - 1)];
    end
    rowCenterToCheck = [rowCenterToCheck rowCenterToCheckRaw(end)];
  else
    rowCenterToCheck = cluster_centers_new_vert_sel(2 : end - 1);
  end
  % i.e.  row by row, except the first and the last rows
  [~, ~, halftone_dot_row_width, ...
   halftone_dot_row_center, ...
   num_halftone_dots_row, ~] = feature_extraction(imgInputBinaryDenoiseInv, 1, round(rowCenterToCheck));
  % if no halftone cell centers are found
  if isempty(halftone_dot_row_center)
    close all;
    disp(['halftone dot detection issue horiz ' num2str(ii)]);
    kmeanIssue = 1;
    data_collection_temp{2} = scannerIssue;
    data_collection_temp{3} = kmeanIssue;
    data_collection_temp{4} = 0;
    data_collection_temp{5} = 0;
    data_collection_temp{6} = 0;
    data_collection_temp{7} = 0; % N
    data_collection_temp{8} = 0;
    data_collection_temp{9} = 0;
    data_collection_temp{10} = 0;
    data_collection_temp{11} = 0;
    data_collection_temp{12} = 0;
    data_collection(ii, :) = data_collection_temp;
    continue;
  end
  % get the rough number of halftone cells per row
  halftone_dots_hist_edges_row = min(num_halftone_dots_row) - 0.5 : 1 : max(num_halftone_dots_row) + 0.5;
  if isempty(halftone_dots_hist_edges_row)
    close all;
    disp('halftone dot detection issue horiz');
    kmeanIssue = 1;
    data_collection_temp{2} = scannerIssue;
    data_collection_temp{3} = kmeanIssue;
    data_collection_temp{4} = 0;
    data_collection_temp{5} = 0;
    data_collection_temp{6} = 0;
    data_collection_temp{7} = 0; % N
    data_collection_temp{8} = 0;
    data_collection_temp{9} = 0;
    data_collection_temp{10} = 0;
    data_collection_temp{11} = 0;
    data_collection_temp{12} = 0;
    data_collection(ii, :) = data_collection_temp;
    continue;
  end
  
  % the first stage rough check: the rough is obtained from the histogram
  [bin_count, bin_edges] = histcounts(num_halftone_dots_row, halftone_dots_hist_edges_row);
  % find the most common number of dots: this is the mostly observed number of halftone dots
  bin_centers = (bin_edges(2 : end) + bin_edges(1 : end - 1)) ./ 2;
  [~, max_ind] = max(bin_count);
  rough_num_cells_horiz = bin_centers(max_ind);
  % if there are too many rows with small number of halftone dots, the current image block cannot be used. 
  if halftoneAngle == 45
    num_halftone_cells_row_rough = floor(imgBlkSize / cellSize / 2);
    if 2 * rough_num_cells_horiz + 5 < num_halftone_cells_row_rough
      % the number of trials should cover the rough number of cells per row
      close all;
      disp(['halftone dot detection issue horiz: line ' 382]);
      kmeanIssue = 1;
      data_collection_temp{2} = scannerIssue;
      data_collection_temp{3} = kmeanIssue;
      data_collection_temp{4} = 0;
      data_collection_temp{5} = 0;
      data_collection_temp{6} = 0;
      data_collection_temp{7} = 0; % N
      data_collection_temp{8} = 0;
      data_collection_temp{9} = 0;
      data_collection_temp{10} = 0;
      data_collection_temp{11} = 0;
      data_collection_temp{12} = 0;
      data_collection(ii, :) = data_collection_temp;
      continue;
    end
  else
    num_halftone_cells_row_rough = floor(imgBlkSize / cellSize);
    if rough_num_cells_horiz + 5 < num_halftone_cells_row_rough
      close all;
      disp(['halftone dot detection issue horiz: line ' 382]);
      kmeanIssue = 1;
      data_collection_temp{2} = scannerIssue;
      data_collection_temp{3} = kmeanIssue;
      data_collection_temp{4} = 0;
      data_collection_temp{5} = 0;
      data_collection_temp{6} = 0;
      data_collection_temp{7} = 0; % N
      data_collection_temp{8} = 0;
      data_collection_temp{9} = 0;
      data_collection_temp{10} = 0;
      data_collection_temp{11} = 0;
      data_collection_temp{12} = 0;
      data_collection(ii, :) = data_collection_temp;
      continue;
    end
  end
  % determine the range of trails (considering two angles), the number of trials is at least 5
  if halftoneAngle == 45
    if (2 * rough_num_cells_horiz - 5) < 5
      num_halftone_dots_row_trails = 5:(2 * rough_num_cells_horiz + 5);
    else
      num_halftone_dots_row_trails = (2 * rough_num_cells_horiz - 5):(2 * rough_num_cells_horiz + 5);
    end
  else
    if (rough_num_cells_horiz - 5) < 5
      num_halftone_dots_row_trails = 5:(rough_num_cells_horiz + 5);
    else
      num_halftone_dots_row_trails = (rough_num_cells_horiz - 5):(rough_num_cells_horiz + 5);
    end
  end
  % to make sure there is at least one sample per cluster.
  if length(halftone_dot_row_center(1, :)) < max(num_halftone_dots_row_trails)
    close all;
    disp(['halftone dot detection issue horiz: line ' num2str(382)]);
    kmeanIssue = 1;
    data_collection_temp{2} = scannerIssue;
    data_collection_temp{3} = kmeanIssue;
    data_collection_temp{4} = 0;
    data_collection_temp{5} = 0;
    data_collection_temp{6} = 0;
    data_collection_temp{7} = 0; % N
    data_collection_temp{8} = 0;
    data_collection_temp{9} = 0;
    data_collection_temp{10} = 0;
    data_collection_temp{11} = 0;
    data_collection_temp{12} = 0;
    data_collection(ii, :) = data_collection_temp;
    continue;
  end
  % do kmean 
  sumd_new_max = zeros(1, length(num_halftone_dots_row_trails));
  cluster_horiz_idx = cell(1, length(num_halftone_dots_row_trails));
  cluster_row_centers = cell(1, length(num_halftone_dots_row_trails));
  cluster_centers_new_horiz = cell(1, length(num_halftone_dots_row_trails));
  cluster_center_ind_horiz = cell(1, length(num_halftone_dots_row_trails));
  for i = 1:length(num_halftone_dots_row_trails)
    % do clustering to find the centers of the dots along the horizontal direction
    % cluster_horiz_idx: the indices to the centers assigned from each sample
    [cluster_horiz_idx{i}, cluster_row_centers, sumd] = ...
                    kmeans(halftone_dot_row_center(1, :)', ...
                           num_halftone_dots_row_trails(i), ...
                           'Display', 'off', 'Replicates', numKmeanTrials);   
    % sort the cluster centers
    [cluster_centers_new_horiz{i}, cluster_center_ind_horiz{i}] = sort(cluster_row_centers);

    % collect the number of dots
    num_dots_cluster_i = zeros(1, length(cluster_center_ind_horiz{i}));
    for temp_i = 1:length(cluster_center_ind_horiz{i})
      num_dots_cluster_i(temp_i) = ...
            length(find(cluster_horiz_idx{i} == cluster_center_ind_horiz{i}(temp_i)));
    end
    % get the average sum
    sumd_new_max(i) = max(sumd(cluster_center_ind_horiz{i}) ./ num_dots_cluster_i');
  end
  % locate the correct number of clusters 
  est_clusters_ind = find(sumd_new_max < clusterErrorThres, 1);
  if isempty(est_clusters_ind)
    close all;
    disp(['could not find the correct number in kmean: index ', num2str(ii)]);
    kmeanIssue = 1;
    data_collection_temp{2} = scannerIssue;
    data_collection_temp{3} = kmeanIssue;
    data_collection_temp{4} = 0;
    data_collection_temp{5} = 0;
    data_collection_temp{6} = 0;
    data_collection_temp{7} = 0; % N
    data_collection_temp{8} = 0;
    data_collection_temp{9} = 0;
    data_collection_temp{10} = 0;
    data_collection_temp{11} = 0;
    data_collection_temp{12} = 0;
    data_collection(ii, :) = data_collection_temp;
    continue;
  end
  % get the final result corresponding to the correct number of clusters
  cluster_horiz_idx = cluster_horiz_idx{est_clusters_ind};
  cluster_center_ind_horiz = cluster_center_ind_horiz{est_clusters_ind};
  % remove the head and tail clusters
  cluster_centers_new_horiz = cluster_centers_new_horiz{est_clusters_ind}(2 : end - 1);
  halftone_dot_row_center(:,(cluster_horiz_idx == cluster_center_ind_horiz(1)) | (cluster_horiz_idx == cluster_center_ind_horiz(end))) = [];
  halftone_dot_row_width(:,(cluster_horiz_idx == cluster_center_ind_horiz(1)) | (cluster_horiz_idx == cluster_center_ind_horiz(end))) = [];
  cluster_horiz_idx((cluster_horiz_idx == cluster_center_ind_horiz(1)) | (cluster_horiz_idx == cluster_center_ind_horiz(end))) = [];
  cluster_center_ind_horiz = cluster_center_ind_horiz(2 : end - 1);

  halftone_dot_center_cluster_horiz = cell(1, length(cluster_center_ind_horiz));
  halftone_dot_center_cluster_shifted_horiz = [];
  halftone_dot_center_cluster_horiz_matrix = [];
  halftone_dot_center_shifted_horiz_matrix = [];
  halftone_dot_width_cluster_horiz = cell(1, max(cluster_horiz_idx));
  halftone_dot_width_row_matrix = [];

  % for each cluster center (halftone dot per row),  collect the width and center information
  if parallel == 0
    figure;
  end
  % for each halftone cluster centers
  for i = 1 : length(cluster_centers_new_horiz)
    % record the halftone centers (3xN)
    halftone_dot_center_cluster_horiz{i} = halftone_dot_row_center(:, cluster_horiz_idx == cluster_center_ind_horiz(i));
    halftone_dot_center_cluster_horiz_matrix = [halftone_dot_center_cluster_horiz_matrix halftone_dot_center_cluster_horiz{i}];
    % record the halftone width (3xN)
    halftone_dot_width_cluster_horiz{i} = halftone_dot_row_width(:, cluster_horiz_idx == cluster_center_ind_horiz(i));
    halftone_dot_width_row_matrix = [halftone_dot_width_row_matrix halftone_dot_width_cluster_horiz{i}];
    % record the halftone shifted centers (3xN)
    % this will be wrong if the halftone dot cluster centers are not obtained correctly
    halftone_dot_center_shifted_horiz_matrix = ...
          [halftone_dot_center_shifted_horiz_matrix ...
           [halftone_dot_center_cluster_horiz{i}(1, :) - mean(halftone_dot_center_cluster_horiz{i}(1, :));...
            halftone_dot_center_cluster_horiz{i}(2, :); ...
            halftone_dot_center_cluster_horiz{i}(3, :)]];
    % show the kmean result
    if parallel == 0
      histogram(halftone_dot_center_cluster_horiz{i}(1, :), ...
                min(halftone_dot_row_center(1,:)) - 0.5 : 1 : max(halftone_dot_row_center(1,:)) + 0.5);
      hold on;
      plot(halftone_dot_center_cluster_horiz{i}(1, :), zeros(1,length(halftone_dot_center_cluster_horiz{i}(1, :))), '*');
      stem(cluster_centers_new_horiz(i), 2, 'LineWidth', 2);
    end
  end
  % show the kmean result
  if parallel == 0
    xlabel('$k_c$', 'Interpreter', 'latex');
    set(gca, 'FontName', 'Times', 'FontSize', 25, 'FontSmoothing', 'on');  
    set(gcf, 'units', 'pixels','OuterPosition', [0 0 1000 600], 'Position', [0 0 1000 600], 'Color', 'w');
    title('Clustering Result in Horizontal Direction');
  end
  % sort in terms of the row indices
  [halftone_dot_center_cluster_horiz_sorted, ~] = sort(halftone_dot_center_cluster_horiz_matrix(2, :));
  % get the possible rows of halftone dots in the image 
  possible_rows = unique(halftone_dot_center_cluster_horiz_sorted);
  num_halftone_cells_horiz = zeros(1, length(possible_rows));
  for i = 1:length(possible_rows)
    num_halftone_cells_horiz(i) = length(find(halftone_dot_center_cluster_horiz_sorted == possible_rows(i)));
  end

%   if parallel == 0
%     % plot the histogram of the number of halftone dots horiz
%     figure;
%     histogram(num_halftone_cells_horiz, min(num_halftone_cells_horiz) - 0.5 : ...
%               1 : max(num_halftone_cells_horiz) + 0.5);
%     title('number of halftone dots hist at the horiz dimension');
%     set(gca,'FontSize', 15, 'FontSmoothing','on');  
%   end

  % #### this is the calculated number of halftone cells #### 
  num_halftone_cells_histEdges = min(num_halftone_cells_horiz) - 0.5 : 1 : max(num_halftone_cells_horiz) + 0.5;
  if isempty(num_halftone_cells_histEdges)
    close all;
    disp('halftone dot detection issue horiz halftone counts');
    kmeanIssue = 1;
    data_collection_temp{2} = scannerIssue;
    data_collection_temp{3} = kmeanIssue;
    data_collection_temp{4} = 0;
    data_collection_temp{5} = 0;
    data_collection_temp{6} = 0;
    data_collection_temp{7} = 0; % N
    data_collection_temp{8} = 0;
    data_collection_temp{9} = 0;
    data_collection_temp{10} = 0;
    data_collection_temp{11} = 0;
    data_collection_temp{12} = 0;
    data_collection(ii, :) = data_collection_temp;
    continue;
  end
  
  [bin_count, bin_edges] = histcounts(num_halftone_cells_horiz, num_halftone_cells_histEdges);
  bin_centers = (bin_edges(2 : end) + bin_edges(1 : end - 1)) ./ 2;
  [~, max_ind] = max(bin_count);
  [~, ic] = sort(bin_count, 'descend');
  % halftone period T here is calculated as the double of the mean cluster distances
  if halftoneAngle == 45
    sampleT = mean(diff(cluster_centers_new_horiz)) * 2;
  else
    sampleT = mean(diff(cluster_centers_new_horiz));
  end
  %% plot the original histogram of the halftone dots WITH outliers.

%   bin_edges_halftonewidth_origin = min(halftone_dot_width_row_matrix(1,:)) - 5 : 1 :...
%                                    max(halftone_dot_width_row_matrix(1,:)) + 5;
%           
%   bin_centers_halftonewidth_origin = (bin_edges_halftonewidth_origin(1 : end - 1)+...
%                                       bin_edges_halftonewidth_origin(2 : end)) ./ 2;
%   figure;
%   h_width = histogram(halftone_dot_width_row_matrix(1, :), bin_edges_halftonewidth_origin, 'Normalization', 'pdf');
%   xlabel('halftone dot width ');
%   title('original width hist');
%   set(gca,'FontSize', 15, 'FontSmoothing', 'on');  

%   % plot the original histogram with outliers.
%   bin_edges_halftoneshiftedcenter_origin = ...
%                         min(halftone_dot_center_shifted_horiz_matrix(1,:)) - 5 : 1:...
%                         max(halftone_dot_center_shifted_horiz_matrix(1,:)) + 5;
%                       
%   bin_centers_halftoneshiftedcenter_origin=...
%                         (bin_edges_halftoneshiftedcenter_origin(1:end-1) + ...
%                         bin_edges_halftoneshiftedcenter_origin(2:end))./2;
%   figure;
%   h_width = histogram(halftone_dot_center_shifted_horiz_matrix(1, :), ...
%                       bin_centers_halftoneshiftedcenter_origin, 'Normalization', 'pdf');
%   xlabel('halftone dot center in pixels');
%   title('original plaement error hist');
%   set(gca, 'FontSize', 15, 'FontSmoothing', 'on');  
  %% remove the outliers of the halftone width
  cutoffCoeffWidth = 2; % used as the multiplicity of the IQR
  % the cutoff width is set to be the IQR of all the recorded width
  % + 1 to avoid embarrasing 0 case.
  cutoffWidth = round(iqr(halftone_dot_width_row_matrix(1, :)) + 1);
  halftoneDotRowWidthQuantile = quantile(halftone_dot_width_row_matrix(1, :), [0.25, 0.75]);
  % do not use halftone_dot_width_row_matrix directly.
  halftone_dot_width_row_matrix_bak = halftone_dot_width_row_matrix;
  % the left and right bounds of the halftone cell width
  halftone_dot_widthOutlierRight_ind = ...
    find(halftone_dot_width_row_matrix_bak(1, :) > (halftoneDotRowWidthQuantile(2) + cutoffCoeffWidth * cutoffWidth));
  halftone_dot_widthOutlierLeft_ind = ...
    find(halftone_dot_width_row_matrix_bak(1, :) < (halftoneDotRowWidthQuantile(1) - cutoffCoeffWidth * cutoffWidth));
  %% remove the outliers of the center placement error
  cutoffCoeffPlacement = 2;
  halftone_dot_center_shifted_row_matrix_bak = halftone_dot_center_shifted_horiz_matrix;   
  halftone_dot_center_cluster_row_matrix_bak = halftone_dot_center_cluster_horiz_matrix;    
  % again, calculate the IQR and the cutoff quantile
  cutoffPlacement = iqr(halftone_dot_center_shifted_row_matrix_bak(1, :));
  halftone_dot_row_placement_quantile = quantile(halftone_dot_center_shifted_row_matrix_bak(1, :), [0.25, 0.75]);
  % the left and right bounds of the halftone cell center
  halftone_dot_placement_outlier_right_ind = ...
    find(halftone_dot_center_shifted_row_matrix_bak(1, :) > (halftone_dot_row_placement_quantile(2) + cutoffCoeffPlacement * cutoffPlacement));
  halftone_dot_placement_outlier_left_ind=...
    find(halftone_dot_center_shifted_row_matrix_bak(1, :) < (halftone_dot_row_placement_quantile(1) - cutoffCoeffPlacement * cutoffPlacement));
  %% show the outlier halftone cell locations
  if parallel == 0
    % show the potential outliers of the placement error
    figure;
    imshow(imgInputBinaryDenoiseInv);
    hold on;
    plot(halftone_dot_center_cluster_row_matrix_bak(1, ...
          unique([halftone_dot_widthOutlierRight_ind halftone_dot_widthOutlierLeft_ind ...
                  halftone_dot_placement_outlier_right_ind halftone_dot_placement_outlier_left_ind])), ...
                  halftone_dot_center_shifted_row_matrix_bak(2, ...
                      unique([halftone_dot_widthOutlierRight_ind ...
                              halftone_dot_widthOutlierLeft_ind ...
                              halftone_dot_placement_outlier_right_ind ...
                              halftone_dot_placement_outlier_left_ind])),'r*');
    title(' binary inv with outlier marked ');
  end
%   % remove the outliers for the shifted centers
%   halftone_dot_center_cluster_row_matrix_bak(:, ...
%                   unique([halftone_dot_widthOutlierRight_ind ...
%                           halftone_dot_widthOutlierLeft_ind ...
%                           halftone_dot_placement_outlier_right_ind ...
%                           halftone_dot_placement_outlier_left_ind])) = [];
%   % remove the outliers for the centers
%   halftone_dot_center_shifted_row_matrix_bak(:, ...
%                   unique([halftone_dot_widthOutlierRight_ind ...
%                           halftone_dot_widthOutlierLeft_ind ...
%                           halftone_dot_placement_outlier_right_ind ...
%                           halftone_dot_placement_outlier_left_ind])) = [];
%   % remove the outliers for the width 
%   halftone_dot_width_row_matrix_bak(:,...
%                   unique([halftone_dot_widthOutlierRight_ind ...
%                           halftone_dot_widthOutlierLeft_ind ...
%                           halftone_dot_placement_outlier_right_ind ...
%                           halftone_dot_placement_outlier_left_ind])) = [];
  %% plot the histograms of the width and the placement errors with outliers removed
%   % get the bin width and centers for displaying the histogram for plotting
%   bin_edges_halftonewidth = min(halftone_dot_width_row_matrix_bak(1, :)) - 5 : 1 :...
%                             max(halftone_dot_width_row_matrix_bak(1, :)) + 5;
%   % calculate the fitting errors for assuming the width follows Gaussian distribution
%   bin_centers_halftonewidth = (bin_edges_halftonewidth(1 : end - 1) + ...
%                                bin_edges_halftonewidth(2 : end)) ./ 2;
%   figure;
%   h_width = histogram(halftone_dot_width_row_matrix_bak(1,:), ...
%                       bin_edges_halftonewidth, 'Normalization', 'pdf');
%   pd = fitdist(halftone_dot_width_row_matrix_bak(1,:)','Normal');
%   pdfEst = pdf(pd,bin_centers_halftonewidth);
%   line(bin_centers_halftonewidth, pdfEst, 'Color', 'red', 'LineWidth', 3);
%   xlabel('halftone dot width in pixels');
%   title('the halftone dot width hist without outliers');
%   set(gca,'FontSize', 10, 'FontSmoothing', 'on');  

%   % fitting the Gaussian pdf to the histogram
%   hist_fitting_square_error = (h_width.Values - pdfEst).^2;
%   hist_fitting_width_MSE = mean(hist_fitting_square_error);

%   % get the sample mean and variance of the halftone width
%   halftone_dot_width_mean = mean(halftone_dot_width_row_matrix_bak(1, :));

%   % plot the center histogram
%   bin_edges_halftonecenter = min(halftone_dot_center_shifted_row_matrix_bak(1,:))-5:1:...
%                                max(halftone_dot_center_shifted_row_matrix_bak(1,:))+5;
%   bin_centers_halftonecenter = (bin_edges_halftonecenter(1:end-1)+bin_edges_halftonecenter(2:end))./2;

%   % fit the observed distribution with Gaussian (this step is not important)
%   figure;
%   h_center = histogram(halftone_dot_center_shifted_row_matrix_bak(1,:),...
%                        bin_edges_halftonecenter, 'Normalization', 'pdf');
%   pd = fitdist(halftone_dot_center_shifted_row_matrix_bak(1,:)', 'Normal');
%   pdfEst = pdf(pd, bin_centers_halftonecenter);
%   line(bin_centers_halftonecenter, pdfEst, 'Color', 'red', 'LineWidth', 3);
%   xlabel('halftone dot center in pixels');
%   title('the halftone dot center hist without outliers');
%   set(gca,'FontSize', 10, 'FontSmoothing', 'on');  

  %% extract the 1-D spectrum ( IMPORTANT )
  % initialize the halftone dot center information to collect
  halftone_dot_center_cluster_row_matrix_sorted = zeros(size(halftone_dot_center_cluster_horiz_matrix));
  % sort in terms of the row indices
  [halftone_dot_center_cluster_row_matrix_sorted(2, :), row_sorted_ind] = sort(halftone_dot_center_cluster_horiz_matrix(2, :));
  % extract the halftone dot center information
  halftone_dot_center_cluster_row_matrix_sorted(1, :) = halftone_dot_center_cluster_horiz_matrix(1, row_sorted_ind);
  halftone_dot_center_cluster_row_matrix_shifted_sorted = halftone_dot_center_shifted_horiz_matrix(1, row_sorted_ind);
  % extract the width information sorted by the row index
  halftone_dot_width_row_matrix_sorted = halftone_dot_width_row_matrix(:, row_sorted_ind);
  % get the possible rows of halftone dots in the image 
  possible_rows = unique(halftone_dot_center_cluster_row_matrix_sorted(2, :));
  % multiplier of the iqr 
  cutoffCoeffWidth = 2;
  cutoffCoeffPlacement = 2;
  % indicator for width and placement outsider
  widthOutside = 0;
  placementOutside = 0;
  % the rough number of horizontal halftone cells
  rough_num_cells_horiz_refine = bin_centers(ic(1));
  ic_ind = 1;
  % initialize the halftone parameters
  halftone_centers_shifted_whole = [];
  halftoneDotWidthWhole = [];
  num_halftone_dots_check = [];
  period = [];
  row_i = [];
  image_left_edge = [];
  image_right_edge = [];
  process_range = [];
  % TODO: the RHS should be changed to a custom value.There is no reason to be assigned
  % to such as specific value. 
  while length(row_i) < rough_num_cells_vert * 2
    % set the outlier conditions
    widthOutlierRight = halftoneDotRowWidthQuantile(2) + cutoffCoeffWidth * cutoffWidth;
    widthOutlierLeft = halftoneDotRowWidthQuantile(1) - cutoffCoeffWidth * cutoffWidth;
    centerOutlierRight = halftone_dot_row_placement_quantile(2) + cutoffCoeffPlacement * cutoffPlacement;
    centerOutlierLeft = halftone_dot_row_placement_quantile(1) - cutoffCoeffPlacement * cutoffPlacement;
    % initialize the halftone parameters
    halftone_centers_shifted_whole = [];
    halftoneDotWidthWhole = [];
    num_halftone_dots_check = [];
    period = [];
    row_i = [];
    image_left_edge = [];
    image_right_edge = [];
    process_range = [];
    % process each possible row
    for i = 1 : length(possible_rows)
      % the index of the row to process
      current_row_ind = find(halftone_dot_center_cluster_row_matrix_sorted(2, :) == possible_rows(i));
      % the centers of the current row halftone dots
      current_row_halftone_centers = halftone_dot_center_cluster_row_matrix_sorted(1, current_row_ind);
      % the shifted centers for the current row halftone dots
      current_row_halftone_centers_shifted = halftone_dot_center_cluster_row_matrix_shifted_sorted(current_row_ind);
      % the width for the current row halftone dots
      current_row_halftone_width = halftone_dot_width_row_matrix_sorted(1, current_row_ind);

%       % the number of dots per row: this is not used for doc images
%       num_halftone_dots_check = [num_halftone_dots_check ...
%                                  length(current_row_halftone_width)];

      % check the criterias
      if any(current_row_halftone_width > widthOutlierRight) || ...
         any(current_row_halftone_width < widthOutlierLeft) || ...
         any(current_row_halftone_centers_shifted > centerOutlierRight) || ...
         any(current_row_halftone_centers_shifted < centerOutlierLeft) || ...
         length(current_row_halftone_width) ~= (rough_num_cells_horiz_refine)
        continue;
      end
      % calculate the start points for the processed image
      row_i = [row_i possible_rows(i)];
      if floor(min(current_row_halftone_centers) - max(current_row_halftone_width) / 2) < 1
        start_point = 1;
      else
        start_point = floor(min(current_row_halftone_centers) - max(current_row_halftone_width) / 2);
      end
      % calculate the end points for the processed image
      if ceil(max(current_row_halftone_centers) + max(current_row_halftone_width) / 2) > size(imgInputBinaryDenoiseInv, 2)
        end_point = size(imgInputBinaryDenoiseInv, 2);
      else
        end_point = ceil(max(current_row_halftone_centers) + max(current_row_halftone_width) / 2);
      end
      % append the results
      process_range = [process_range; [start_point end_point]];
      halftone_centers_shifted_whole = [halftone_centers_shifted_whole current_row_halftone_centers_shifted];
      halftoneDotWidthWhole = [halftoneDotWidthWhole current_row_halftone_width];
    end
    % if enough width and placement error are collected, break
    if length(row_i) >= minNumRows
      break;
    end
    % if the number of rows used is not enough, then enlarge the range 
    if ~(((halftoneDotRowWidthQuantile(2) + (cutoffCoeffWidth + 1) * cutoffWidth) > sampleT) || ...
         ((halftoneDotRowWidthQuantile(1) - (cutoffCoeffWidth + 1) * cutoffWidth) < 0)) && (cutoffWidth ~= 0)
      cutoffCoeffWidth = cutoffCoeffWidth + 1;
    else
      widthOutside = 1;
    end
    if ~(((halftone_dot_row_placement_quantile(2) + ...
          (cutoffCoeffPlacement + 1) * cutoffPlacement) > sampleT / 2) || ...
          ((halftone_dot_row_placement_quantile(1) - ...
          (cutoffCoeffPlacement + 1) * cutoffPlacement) < -sampleT / 2)) && ...
          (cutoffPlacement ~= 0)
      cutoffCoeffPlacement = cutoffCoeffPlacement + 1;
    else
      placementOutside = 1;
    end
    % if not enough rows meeting the criteria, then use different number of dots
    if widthOutside == 1 && placementOutside == 1
      if length(ic) > 1 && ic_ind == 1 
        ic_ind = 2;
        rough_num_cells_horiz_refine = bin_centers(ic(ic_ind));
        cutoffCoeffWidth = 2;
        cutoffCoeffPlacement = 2;
        widthOutside = 0;
        placementOutside = 0;
        continue;
      else
        disp('unresolvable: cannot extract enough rows of halftone cells');
        data_collection_temp{2} = scannerIssue;
        data_collection_temp{3} = kmeanIssue;
        data_collection_temp{4} = 0;
        data_collection_temp{5} = 0;
        data_collection_temp{6} = 0;
        data_collection_temp{7} = 0; % N
        data_collection_temp{8} = 0;
        data_collection_temp{9} = 0;
        data_collection_temp{10} = 0;
        data_collection_temp{11} = 0;
        data_collection_temp{12} = 0;
        data_collection(ii, :) = data_collection_temp;
        break;
      end
    end
  end
  % if the number of rows used to calculate the PSD is less than minNumRows
  if length(row_i) < minNumRows
    close all;
    disp('unresolvable: the number of rows used to calculate the PSD is less than minNumRows');
    data_collection_temp{2} = scannerIssue;
    data_collection_temp{3} = kmeanIssue;
    data_collection_temp{4} = 0;
    data_collection_temp{5} = 0;
    data_collection_temp{6} = 0;
    data_collection_temp{7} = 0; % N
    data_collection_temp{8} = 0;
    data_collection_temp{9} = 0;
    data_collection_temp{10} = 0;
    data_collection_temp{11} = 0;
    data_collection_temp{12} = 0;
    data_collection(ii, :) = data_collection_temp;
    continue;
  end
  % collect the 1D image segments: note that not all parts of the row are included. 
  num_rows_used = length(row_i);
  % find the left and right edge of the image to process
  left_most_position = min(process_range(:,1));
  right_most_position = max(process_range(:,2));
  % find the length between the left and right points among all rows used
  row_length = right_most_position - left_most_position + 1;
  % row lenght cannot be too small
  if row_length < floor(size(imgInputBinaryDenoiseInv, 2) / 2)
    close all;
    disp('unresolvable: row_length too small');
    data_collection_temp{2} = scannerIssue;
    data_collection_temp{3} = kmeanIssue;
    data_collection_temp{4} = 0;
    data_collection_temp{5} = 0;
    data_collection_temp{6} = 0;
    data_collection_temp{7} = 0; % N
    data_collection_temp{8} = 0;
    data_collection_temp{9} = 0;
    data_collection_temp{10} = 0;
    data_collection_temp{11} = 0;
    data_collection_temp{12} = 0;
    data_collection(ii, :) = data_collection_temp;
    continue;
  end
  % halftone width cannot be too large
  if any(abs(diff(sort(halftoneDotWidthWhole, 'descend'))) > (sampleT / 2))
    close all;
    disp('unresolvable: halftone cell width changes too much');
    data_collection_temp{2} = scannerIssue;
    data_collection_temp{3} = kmeanIssue;
    data_collection_temp{4} = 0;
    data_collection_temp{5} = 0;
    data_collection_temp{6} = 0;
    data_collection_temp{7} = 0; % N
    data_collection_temp{8} = 0;
    data_collection_temp{9} = 0;
    data_collection_temp{10} = 0;
    data_collection_temp{11} = 0;
    data_collection_temp{12} = 0;
    data_collection(ii, :) = data_collection_temp;
    continue;
  end
  % extract the rows of halftone dots that are under test
  img_test = zeros(num_rows_used, row_length);
  for row_ind = 1 : num_rows_used
    img_test(row_ind, process_range(row_ind, 1):process_range(row_ind, 2)) = ...
      imgInputBinaryDenoiseInv(row_i(row_ind), process_range(row_ind, 1) : process_range(row_ind, 2));
  end
  %% if there is no image match the criteria, then continue
  if isempty(img_test)
    close all;
    disp('unresolvable: isempty(img_test)');
    data_collection_temp{2} = scannerIssue;
    data_collection_temp{3} = kmeanIssue;
    data_collection_temp{4} = 0;
    data_collection_temp{5} = 0;
    data_collection_temp{6} = 0;
    data_collection_temp{7} = 0; % N
    data_collection_temp{8} = 0;
    data_collection_temp{9} = 0;
    data_collection_temp{10} = 0;
    data_collection_temp{11} = 0;
    data_collection_temp{12} = 0;
    data_collection(ii, :) = data_collection_temp;
    continue;
  end
  % plot the processed halftone dot rows
  if parallel == 0
    figure;
    imshow(img_test);
    title('utilized image');

    figure;
    imshow(imgInput);
    hold on;
    for row_ind = 1:length(possible_rows)
      plot(1:size(imgInput,2), ones(1, size(imgInput,2)).*possible_rows(row_ind), 'r', 'LineWidth', 2);
      hold on;
    end
    for col_ind = 1:length(cluster_centers_new_horiz)
      plot(ones(1, size(imgInput,1)) .* cluster_centers_new_horiz(col_ind), 1:size(imgInput,1), 'b', 'LineWidth', 2);
      hold on;
    end
  end
  % show image
  if parallel == 0
    % plot the histogram of the centers
    bin_edges_halftonecenter = min(halftone_centers_shifted_whole(1, :)) - 5:0.5:max(halftone_centers_shifted_whole(1, :)) + 5;
    figure;
    histogram(halftone_centers_shifted_whole, bin_edges_halftonecenter, 'Normalization', 'pdf');
    title('the shift error histogram utilized');
    % plot the histogram of the width 
    bin_edges_halftonewidth = min(halftoneDotWidthWhole(1, :)) - 5 : 1 : max(halftoneDotWidthWhole(1, :)) + 5;
    figure;
    histogram(halftoneDotWidthWhole, bin_edges_halftonewidth, 'Normalization','pdf');
    title('the dot width histogram utilized');
  end
  % the sample values of the parameters
  sigma_a = std(halftone_centers_shifted_whole);
  sigma_b = std(halftoneDotWidthWhole);
  halftone_dot_width_mean = mean(halftoneDotWidthWhole);
  % calculate the spectrum power expectation
  halftone_spectrum_power_row = zeros(size(img_test, 1), 2^15);
  for i = 1:size(img_test, 1)
    halftone_spectrum_power_row(i, :) = fftshift(fft(img_test(i, :), 2^15)) .* conj(fftshift(fft(img_test(i, :), 2^15)));
  end  
  % calculate the sample mean of the spectrum power
  halftone_dot_spectrum_mean = mean(halftone_spectrum_power_row, 1);
  halftone_dot_spectrum_mean_log = log(halftone_dot_spectrum_mean + 1);
  %% prepare the calculation of the specturm power expression
  % frequency indices
  f = -0.5:(1 / length(halftone_dot_spectrum_mean)):(0.5 - 1 / length(halftone_dot_spectrum_mean));
  % initialize the halftone dot index 
  N_sum_ind = 1:rough_num_cells_horiz_refine;
  %% search for peaks 
  coarse_search_locs = (-numPeaks:numPeaks) .* (1 / sampleT);
  % set the search range
  freq_res = 1 / length(f);
  search_range = round((1 / sampleT) / freq_res / 10);
  searchError = 0;
  % initialize the peak and the index of the peaks in the psd
  peak_value_log = zeros(1, 2 * numPeaks + 1);
  peak_f_idx = zeros(1, 2 * numPeaks + 1);
  for i = 1:length(coarse_search_locs)
    % search aroud the corase locations for peak in the PSD
    [~, peak_search_ind] = min(abs(f - coarse_search_locs(i)));    
    if ((peak_search_ind - search_range) < 1) || (peak_search_ind + search_range) > length(halftone_dot_spectrum_mean_log)
      searchError = 1;
      break;
    end
    % get the local search region
    local_search_range_ind = peak_search_ind - search_range : peak_search_ind + search_range;
    % if using the peaks in the signal to get the period
    [peak_value_log(i), idx] = max(halftone_dot_spectrum_mean_log(local_search_range_ind));
    peak_f_idx(i) = peak_search_ind - search_range + idx - 1;
  end
  % in case where the PSD peaks are not found 
  if searchError == 1
    disp('PSD peak search error');
    data_collection_temp{2} = scannerIssue;
    data_collection_temp{3} = kmeanIssue;
    data_collection_temp{4} = 0;
    data_collection_temp{5} = 0;
    data_collection_temp{6} = 0;
    data_collection_temp{7} = 0; % N
    data_collection_temp{8} = 0;
    data_collection_temp{9} = 0;
    data_collection_temp{10} = 0;
    data_collection_temp{11} = 0;
    data_collection_temp{12} = 0;
    data_collection(ii, :) = data_collection_temp;
    continue;
  end
  peak_value = exp(peak_value_log) - 1;
  %% calculate analytical values using the proposed model
  % initialize the peak indices
  peakIndex = -numPeaks : numPeaks;
  T = sampleT;
  % calculate the X values (The recipracal of T)
  peakFreq = f(peak_f_idx);
%   peakFreq = (-numPeaks:numPeaks)./T;
  XValues = peakFreq ./ peakIndex;
  % initialize the analytical peak values 
  analytical_value = zeros(1, length(peakIndex));
  analytical_expression_error_analysis_log = cell(1, 2 * numPeaks + 1);
  analytical_expression_error_analysis_log_p1 = cell(1, 2 * numPeaks + 1);
  analytical_expression_error_analysis_log_p2 = cell(1, 2 * numPeaks + 1);
  analytical_expression_error_analysis = cell(1, 2 * numPeaks + 1);
  analytical_expression_error_analysis_p1 = cell(1, 2 * numPeaks + 1);
  analytical_expression_error_analysis_p2 = cell(1, 2 * numPeaks + 1);
  % initialize the cosine term
  cos_sum_error_analysis = cell(1, 2 * numPeaks + 1);
  peak_search_ind_error_analysis = zeros(size(XValues));
  % For each X value, calculate the whole model spectrum, but only choose one peak to calculate the error. 
  % When storing the data, should only store the mean and variances of the width and placement errors. 
  for i = 1 : length(XValues)
    % DC component
    if abs(XValues(i)) == Inf || isnan(XValues(i))
      % process the DC component
      peak_search_ind_error_analysis(i) = find(f == peakFreq(i));
      analytical_value(i) = length(N_sum_ind) .* sigma_b^2 + length(N_sum_ind)^2 * halftone_dot_width_mean^2;
    % non-DC component
    else
      cos_sum_error_analysis{i} = zeros(1, length(f));
      % calculate the cosine sum here
      for n = 1 : length(N_sum_ind)
        for m = 1 : length(N_sum_ind)
          if m ~= n
            % here the cos sum term must be constant N(N-1) at the peak frequency. 
            % Since the frequency is not continuous in FFT, the peak frequency does not match exactly to n/T, and I must use
            % 1/XValues here to let cos_sum be N(N-1) at peak frequencies. If you do not compare peaks, then use the next expression
            cos_sum_error_analysis{i} = cos_sum_error_analysis{i} + cos(2*pi.*f.*(1/XValues(i)).*(N_sum_ind(n)-N_sum_ind(m)));
          end
        end
      end
      % calculate the first part of PSD
      analytical_expression_error_analysis_p1{i} = ...
                            (length(N_sum_ind)./(2.*(pi.*f).^2)).*...
                            (1-cos(2*pi.*f.*halftone_dot_width_mean).*...
                            exp(-2.*(sigma_b.*f.*pi).^2));
      % calculate the second part of PSD
      analytical_expression_error_analysis_p2{i}=...
                            sinc_modified(halftone_dot_width_mean,f).^2.*...
                            exp(-(sigma_b.*f.*pi).^2).*...
                            exp(-4.*(sigma_a.*f.*pi).^2).*...
                            cos_sum_error_analysis{i};
      % combine together
      analytical_expression_error_analysis{i} = analytical_expression_error_analysis_p1{i} + analytical_expression_error_analysis_p2{i};
      % get the corresponding peak
      peak_search_ind_error_analysis(i) = find(f == peakFreq(i));
      % the peaks from the model
      analytical_value(i) = analytical_expression_error_analysis{i}(peak_search_ind_error_analysis(i));
    end
  end
  % convert to log scale
  analytical_value_log = log(analytical_value + 1);
  %% calculate the analytical PSD without considering peaks
  % the only difference is the using of the T terms
  cos_sum = zeros(1, length(f));
  % sum up the cosine values
  for n = 1 : length(N_sum_ind)
    for m = 1 : length(N_sum_ind)
      if m ~= n
        cos_sum = cos_sum+cos(2*pi.*f.*T.*(N_sum_ind(n)-N_sum_ind(m)));
      end
    end
  end
  % calculate the first part
  analytical_expression_p1 = (length(N_sum_ind)./(2.*(pi.*f).^2)).*...
                              (1-cos(2*pi.*f.*halftone_dot_width_mean).*...
                              exp(-2.*(sigma_b.*f.*pi).^2));
  % process DC component for the first part of the model
  f_fine_center_index = find(abs(f) == 0);
  if ~isnan(f_fine_center_index)
    analytical_expression_p1(f_fine_center_index) =...
                        length(N_sum_ind).*(sigma_b^2+halftone_dot_width_mean^2);
  end
  % calculate the second part
  analytical_expression_p2 = sinc_modified(halftone_dot_width_mean,f).^2.*...
                              exp(-(sigma_b.*f.*pi).^2) .*...
                              exp(-4.*(sigma_a.*f.*pi).^2) .* cos_sum;
  % process DC component for ther second part of the model
  if ~isnan(f_fine_center_index)
    analytical_expression_p2(f_fine_center_index) = length(N_sum_ind) .* (length(N_sum_ind) - 1) .* (halftone_dot_width_mean^2);
  end
  % these values do not seem to be used though
  analytical_expression = analytical_expression_p1 + analytical_expression_p2;
  analytical_expression_log = log(analytical_expression + 1);
  %% plot the signal spectrum power expectation
  if parallel == 0
    % plot in log scale
    figure;
    plot(f, halftone_dot_spectrum_mean_log, 'r', 'LineWidth', 1.5);   % the signal
    hold on;
  %   plot(f, analytical_expression_log, 'k', 'LineWidth', 1.5);      % the model values
  %   plot(peakFreq, peak_value_log, 'Color', [0.6350 0.0780 0.1840], 'LineStyle', 'none', 'Marker', '*', 'MarkerSize', 20);           % the signal peaks
    cos_sum_analytical = [];
    for i = 1 : length(peakIndex)    % plot the model spectrum peaks
      stem(peakFreq(i), analytical_value_log(i), 'Color', [0.6350 0.0780 0.1840], ...
            'LineStyle', 'none', 'Marker', 'x', 'LineWidth', 2, 'MarkerSize', 20);  % the model peaks
      if ~isnan(cos_sum_error_analysis{i})    % to exclude the DC component
        cos_sum_analytical = [cos_sum_analytical cos_sum_error_analysis{i}(peak_search_ind_error_analysis(i))];
      end
    end
    hold off;
    grid on;
    xlabel('normalized frequency');
    ylabel('$\tilde{E}(f)$', 'Interpreter', 'latex'); 
    legend('PSD (Genuine)', 'Model Value (Genuine)');
    set(gca, 'FontName', 'times', 'XLimMode', 'manual', 'XLim', [-8 * (1 / T) 8 * (1 / T)], 'FontSize', 26, 'FontSmoothing', 'on');  
    set(gcf, 'units', 'pixels','OuterPosition', [0 0 1300 900], 'Position', [0 0 1300 900], 'Color', 'w');
  end
  %% refine using the optimization
  center_peak = ceil(length(peak_value) / 2);
  numPeaks_optimization = numPeaks;
  [x_7_sqrt, y_7_sqrt, c_7, minLoss] = ...
    optimize_parameters_three_var(...
      halftone_dot_width_mean,...
      sigma_b,...
      sigma_a,...
      rough_num_cells_horiz_refine,...
      peak_value(center_peak - numPeaks_optimization : center_peak - 1),...
      peakFreq(center_peak - numPeaks_optimization : center_peak - 1),...
      numPeaks_optimization, 1, fileName);
  % if the parameter is not refined
  if isempty(x_7_sqrt)
    disp('sample error');
    data_collection_temp{2} = scannerIssue;
    data_collection_temp{3} = kmeanIssue;
    data_collection_temp{4} = 0;
    data_collection_temp{5} = 0;
    data_collection_temp{6} = 0;
    data_collection_temp{7} = 0; % N
    data_collection_temp{8} = 0;
    data_collection_temp{9} = 0;
    data_collection_temp{10} = 0;
    data_collection_temp{11} = 0;
    data_collection_temp{12} = 0;
    data_collection(ii, :) = data_collection_temp;
    continue;
  end
  %% calculate the analytical spectrum power expectation using optimal parameter value
  sigma_a_refined = x_7_sqrt;
  sigma_b_refined = y_7_sqrt;
  halftone_dot_width_mean_refined = c_7;
  %% plot PSD using the optimal parameters
  if parallel == 0
    % plot in log scale
    figure;
    % plot the signal
    semilogy(f, exp(halftone_dot_spectrum_mean_log).^log(10), 'r', 'LineWidth', 1.5);      
    hold on;
    % initialize the analytical values
    analytical_value_refine = zeros(1, length(peakIndex));
    analytical_value_refine_log = zeros(1, length(peakIndex));
    for i = 1 : length(peakIndex)                                      % the model peaks
      if ~isnan(cos_sum_error_analysis{i})    % to exclude the DC component
        analytical_expression_refine_peaks_p1 = ...
          (length(N_sum_ind)./(2.*sin(pi.*peakFreq(i)).^2)).*...
          (1-cos(2*pi.*peakFreq(i).*halftone_dot_width_mean_refined).*exp(-2.*(sigma_b_refined.*peakFreq(i).*pi).^2));
        analytical_expression_refine_peaks_p2 = ...
          sinc_modified(halftone_dot_width_mean_refined, peakFreq(i)).^2.*...
          exp(-(sigma_b_refined.*peakFreq(i).*pi).^2).*exp(-4.*(sigma_a_refined.*peakFreq(i).*pi).^2).*cos_sum_analytical(1);
        analytical_value_refine(i) = analytical_expression_refine_peaks_p1 + analytical_expression_refine_peaks_p2;
      else % DC
        analytical_value_refine(i) = length(N_sum_ind) .* sigma_b_refined^2 + length(N_sum_ind)^2 * halftone_dot_width_mean_refined^2;
      end
      analytical_value_refine_log(i) = log(analytical_value_refine(i));
    end
    semilogy(peakFreq, analytical_value_refine.^log(10), ...
             'Color', 'red', ...
             'LineStyle', 'none', ...
             'LineWidth', 1.5, ...
             'Marker', '*', 'MarkerSize', 20);  
    hold off;
    grid on;
    legend('PSD (Genuine)', 'Model Value (Genuine)')
    set(gca, 'FontName', 'times', 'XLimMode', 'manual', ...
             'XLim', [-8 * (1 / T) 8 * (1 / T)], 'YLim', [1 10^9+500000], 'FontSize', 26, 'FontSmoothing', 'on');  
    set(gcf, 'units', 'pixels','OuterPosition', [0 0 1300 900], 'Position', [0 0 1300 900], 'Color', 'w');
    xlabel('normalized frequency');
    ylabel('$\tilde{E}(f)$', 'Interpreter', 'latex');  
  end
  %% collect data # parallel #
  data_collection_temp{2} = scannerIssue;
  data_collection_temp{3} = kmeanIssue;
  data_collection_temp{4} = sigma_a;
  data_collection_temp{5} = sigma_b;
  data_collection_temp{6} = halftone_dot_width_mean;
  data_collection_temp{7} = rough_num_cells_horiz_refine; % N
  data_collection_temp{8} = minLoss;
  data_collection_temp{9} = peakFreq;
  data_collection_temp{10} = sigma_a_refined;
  data_collection_temp{11} = sigma_b_refined;
  data_collection_temp{12} = halftone_dot_width_mean_refined;
  data_collection(ii, :) = data_collection_temp;
  close all;
end
%% save data
save(dataFileName, 'data_collection');
