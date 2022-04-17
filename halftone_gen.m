%% only need to generate the halftone images for the first print

%% clear the workspace
clear; 
clc;
close all;
%% parameters definitions
load('screen_cell_45_73.mat', 'screen_cell');
%% the directory of the gray_scale images
input_dir_name = 'D:\Databases\HalftoneImageDatabase\digital\document_images\';
output_dir_name = 'D:\Databases\HalftoneImageDatabase\digital\demo_images\';
%% clear out the output diectory
% delete([output_dir_name '/*']);
%% get input directory
input_dir = dir(input_dir_name);
input_dir([input_dir.isdir]) = [];
%% read in images and convert to gray scale if it is not
for i = 1:length(input_dir)
  % document file name
  file_name = input_dir(i).name;
  % read in the gray scale image
  test_gray_img = imread([input_dir_name file_name]);
  % generate halftone screen: the generation logic is from the halftone textbook  
  % Lau, Daniel L. / Arce, Gonzalo R. Modern digital halftoning 2008, Second. edition 
  halftone_threshold = cluster_screen_45(size(test_gray_img, 1), size(test_gray_img, 2), 6, screen_cell);
%   halftone_threshold = cluster_screen_90(size(test_gray_img, 1), size(test_gray_img, 2), screen_cell);
  %% do thresholding and save the halftoned-images
  halftoneImg = test_gray_img > halftone_threshold;
  halftoneImgPath = [output_dir_name, file_name];
  imwrite(halftoneImg, halftoneImgPath);
end