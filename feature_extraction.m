function [halftone_dot_left, ...
          halftone_dot_right, ...
          halftone_dot_width, ...
          halftone_dot_centers, ...
          halftone_nums, halftone_x_coord] =  feature_extraction(input_img, scan_dir, scan_ind)
        
  %% initialize result containers
  halftone_dot_left = [];     % the left edges
  halftone_dot_right = [];    % the right edges
  halftone_dot_width = [];    % the edge width
  halftone_dot_centers = [];  % the edge center
  halftone_nums = [];         % the halftone dot number counts
  halftone_x_coord = [];      % for the scan in vert direction only
  %% scan at the horizontal direction, row by row
  if scan_dir == 1  
%     if length(scan_ind) == 1
%       scan_ind = 1 : size(input_img, 1);
%     end
    % scan row by row: the width and centers here are 2 by N matrices
    for i = 1 : length(scan_ind)
      % the row of the halftone binarized image
      img_bin_inv_row = input_img(scan_ind(i), :);
      % the transitions of the halftone binarized image
      img_bin_inv_row_diff = img_bin_inv_row(2 : end) - ...
                             img_bin_inv_row(1 : end - 1);
      % positive transition indicates the left edge
      img_bin_inv_row_edge_pos = find(img_bin_inv_row_diff == 1);
      % negative transition indicates the right edge
      img_bin_inv_row_edge_neg = find(img_bin_inv_row_diff == -1);
      % if there are too few transitions, continue to the next row of pixels
      if length(img_bin_inv_row_edge_pos) < 2 || ...
         length(img_bin_inv_row_edge_neg) < 2
        continue;
      end
      % the 1st right transitions should be located 
      % at the right of the 1st left transitions
      if img_bin_inv_row_edge_neg(1) < img_bin_inv_row_edge_pos(1) + 1
        img_bin_inv_row_edge_neg = img_bin_inv_row_edge_neg(2 : end);
      end
      % the last right transitions should be located 
      % at the right of the last left transitions
      if img_bin_inv_row_edge_neg(end) < img_bin_inv_row_edge_pos(end) + 1
        img_bin_inv_row_edge_pos = img_bin_inv_row_edge_pos(1 : end - 1);
      end
      % the number of positive and negative transitions must be the same
      if length(img_bin_inv_row_edge_pos) ~= length(img_bin_inv_row_edge_neg)
          continue;
      end
      % record the left/right edges: the left edge is incremented by 1
      halftone_dot_left_current_row = img_bin_inv_row_edge_pos + 1;
      halftone_dot_right_current_row = img_bin_inv_row_edge_neg;
      % record the center and width of the halftone dots
      halftone_dot_center_current_row = (halftone_dot_left_current_row + halftone_dot_right_current_row) / 2;
      halftone_dot_width_current_row = halftone_dot_right_current_row - halftone_dot_left_current_row + 1;
            
      % accumulate the data
      halftone_nums = [halftone_nums length(halftone_dot_width_current_row)];
      halftone_dot_left = [halftone_dot_left halftone_dot_left_current_row];
      halftone_dot_right = [halftone_dot_right halftone_dot_right_current_row];
      % the width contains width, the current row, and the index if the halftone dot
      halftone_dot_width = ...  
                [halftone_dot_width ...
                  [halftone_dot_width_current_row; ...
                   scan_ind(i) .* ones(1, length(halftone_dot_width_current_row));...
                   1 : length(halftone_dot_width_current_row)]];
      % the center matrix contains center, the current row, and the index of the halftone dot
      halftone_dot_centers = ...
                [halftone_dot_centers ...
                 [halftone_dot_center_current_row; ...
                  scan_ind(i) .* ones(1, length(halftone_dot_center_current_row));...
                  1 : length(halftone_dot_center_current_row)]];
    end
  %% scan at the vertical direction, col by col
  elseif scan_dir == 2   
    % scan all pixels along the x-coordinate
    if length(scan_ind) == 1
      scan_ind = 1 : size(input_img, 2);
    end
    % scans col by col: along the x coordinate
    for i = 1 : size(input_img, 2)
      % the col of the halftone binarized image
      img_bin_inv_col = input_img(:, scan_ind(i));
      % the transitions of teh halftone binarized image
      img_bin_inv_col_diff = img_bin_inv_col(2 : end) - ...
                              img_bin_inv_col(1 : end - 1);
      % positive transition indicates the top edge
      img_bin_inv_col_edge_pos = find(img_bin_inv_col_diff == 1);
      % negative transition indicates the bottom edge
      img_bin_inv_col_edge_neg = find(img_bin_inv_col_diff == -1);
      % similar to the previous case
      if length(img_bin_inv_col_edge_pos) < 2 || length(img_bin_inv_col_edge_neg) < 2
        continue;
      end
      if img_bin_inv_col_edge_neg(1) < img_bin_inv_col_edge_pos(1) + 1
          img_bin_inv_col_edge_neg = img_bin_inv_col_edge_neg(2 : end);
      end
      if img_bin_inv_col_edge_neg(end) < img_bin_inv_col_edge_pos(end) + 1
          img_bin_inv_col_edge_pos = img_bin_inv_col_edge_pos(1: end - 1);
      end
      % the number of positive and negative transitions must be the same
      if length(img_bin_inv_col_edge_pos) ~= length(img_bin_inv_col_edge_neg)
        continue;
      end
      % record the top/bottom edges, width and the centers of the halftone dots
      halftone_dot_top_current_col = img_bin_inv_col_edge_pos + 1;
      halftone_dot_bottom_current_col = img_bin_inv_col_edge_neg;
      % get the center and width of the halftone dots
      halftone_dot_center_current_col = (halftone_dot_top_current_col + halftone_dot_bottom_current_col) / 2;
      halftone_dot_width_current_col = halftone_dot_bottom_current_col - halftone_dot_top_current_col + 1;
      % transpose 
      halftone_dot_top_current_col = halftone_dot_top_current_col';
      halftone_dot_bottom_current_col = halftone_dot_bottom_current_col';
      halftone_dot_width_current_col = halftone_dot_width_current_col';
      halftone_dot_center_current_col = halftone_dot_center_current_col';
      % accumulate the data
      halftone_nums = [halftone_nums length(halftone_dot_width_current_col)];
      % these two are equivalent to the top and the bottom edges
      halftone_dot_left = [halftone_dot_left halftone_dot_top_current_col];
      halftone_dot_right = [halftone_dot_right halftone_dot_bottom_current_col];
      % record the width and the centers: for vert direction, no need to get other
      % information like the horizontal.
      halftone_dot_width = [halftone_dot_width halftone_dot_width_current_col];
      halftone_dot_centers = [halftone_dot_centers halftone_dot_center_current_col];
      % record the x-coordinate of the h
      halftone_x_coord = [halftone_x_coord i * ones(1, length(halftone_dot_center_current_col))];
    end
  end
end



