%% this script converts rgb images to gray in batch
%%
close all;
clear;
clc;

maindirName='D:\Databases\HalftoneImageDatabase\scanned\pc_ht_ref_45_73_600_1200';
savemaindirName='D:\Databases\HalftoneImageDatabase\scanned\pc_ht_ref_45_73_600_1200_gray';

%%
% delete the hidden files
delete([maindirName 'desktop.ini']); 
delete([maindirName 'Thumbs.db']);
delete([maindirName '/.*']);
% get the directory object
maindir = dir(maindirName);
% do not include the . and .. directories
maindir([maindir.isdir]) = [];

%%
savemaindir = dir(savemaindirName);
% do not include the . and .. directories
savemaindir([savemaindir.isdir]) = [];
% delete the previously existing files
delete([savemaindirName '/*']);

%%
for i = 1 : length(maindir)
  inputImgPath = fullfile(maindirName, maindir(i).name);
  img_gray = uint8(rgb2gray(imread(inputImgPath))); 
  imwrite(img_gray, fullfile(savemaindirName, maindir(i).name));
end

