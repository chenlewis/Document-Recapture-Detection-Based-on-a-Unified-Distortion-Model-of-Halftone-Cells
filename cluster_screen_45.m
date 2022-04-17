% generate the screen for the whole image 
function screen_out = cluster_screen_45(img_height, ...
                                        img_width, ...
                                        cell_half_diagonal, ...
                                        cell_screen)
  % initialize the screen that covering the whole image (it is larger than input image for easier programming)
  screen = zeros(img_height + cell_half_diagonal * 2, img_width + cell_half_diagonal * 2);
  % the indicator of odd rows
  odd_row = -1;
  % generate the halftone screen in row-wise order
  for i = 1 : cell_half_diagonal : (size(screen, 1) - cell_half_diagonal * 2 + 1)
    odd_row = -odd_row;
    if odd_row == 1   % if processing the odd rows
      for j = 1 : (2 * cell_half_diagonal) : (size(screen, 2) - cell_half_diagonal * 2 + 1)
        screen(i : (i + cell_half_diagonal * 2 - 1), j : (j + cell_half_diagonal * 2 - 1)) = ...
          screen(i : (i + cell_half_diagonal * 2 - 1), j : (j + cell_half_diagonal * 2 - 1)) + double(cell_screen);
      end
    else  % if proessing the even rows
      for j = (cell_half_diagonal + 1) : (2 * cell_half_diagonal) : (size(screen, 2) - cell_half_diagonal * 2 + 1)
        screen(i : i + cell_half_diagonal * 2 - 1, j : j + cell_half_diagonal * 2 - 1) = ...
          screen(i : i + cell_half_diagonal * 2 - 1, j : j + cell_half_diagonal * 2 - 1) + double(cell_screen);
      end
    end
  end
  % the final output screen has the same size as the grayscale input image
  screen_out = screen((cell_half_diagonal + 1) : (img_height + cell_half_diagonal),...
                      (cell_half_diagonal + 1) : (img_width + cell_half_diagonal));
end