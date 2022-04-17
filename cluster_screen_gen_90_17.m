%% 150 lpi, 90 degrees
%% clear workspace
close all;
clear;
clc;
%%
% the cell size
cell_side_length = 2;
inverse_screen_freq = cell_side_length * 2;
% the number of grayscale levels
num_gray_levels = inverse_screen_freq^2 + 1;
% calculat the distances (normalized)
[screen_cell_coord_x, screen_cell_coord_y] = meshgrid((-cell_side_length + 0.5):(cell_side_length - 0.5), ...
                                                      (cell_side_length - 0.5):-1:(-cell_side_length + 0.5));
screen_cell_dist = sqrt(screen_cell_coord_x.^2 + screen_cell_coord_y.^2);
screen_cell_dist_normal = screen_cell_dist ./ max(screen_cell_dist(:));
% this might be more reasonable
t = fliplr(round(linspace(0, 255 - (255 / (num_gray_levels - 1)), num_gray_levels - 1))) + 1;
% the single halftone cell
screen_cell = [t(13)  t(5)  t(6)  t(14); ...
               t(12)  t(1)  t(2)  t(7); ...
               t(11)  t(4)  t(3)  t(8);...
               t(16)  t(10)  t(9) t(15)];
% save the genreated screens
save('screen_cell_90_17.mat', 'screen_cell');