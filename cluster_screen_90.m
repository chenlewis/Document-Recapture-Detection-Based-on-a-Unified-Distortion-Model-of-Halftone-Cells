% generate the screen for the whole image 
function screen_out = cluster_screen_90(img_height, img_width, cell_screen)
  cell_size = length(cell_screen);
  % initialize the screen that covering the whole image (it is larger than input image for easier programming)
  screen = zeros(img_height + cell_size * 2, img_width + cell_size * 2);
  % generate the halftone screen in row-wise order
  for i = 1 : cell_size : (size(screen, 1) - cell_size + 1)
    for j = 1 : cell_size : (size(screen, 2) - cell_size + 1)
      screen(i : (i + cell_size - 1), j : (j + cell_size - 1)) = screen(i : (i + cell_size - 1), j : (j + cell_size - 1)) + double(cell_screen);
    end
  end
  % the final output screen has the same size as the grayscale input image
  screen_out = screen((cell_size + 1) : (img_height + cell_size), (cell_size + 1) : (img_width + cell_size));
end