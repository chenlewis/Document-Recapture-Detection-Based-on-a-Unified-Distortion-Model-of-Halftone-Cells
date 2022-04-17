%% lpi = 75, halftone angle = 45 degrees
%% clear workspace
close all;
clear;
clc;
%% 
% the cell size
cell_half_diag = 8;
inverse_screen_freq = cell_half_diag * 2;
% the number of grayscale levels
num_gray_levels = (cell_half_diag * sqrt(2))^2 + 1;

% the single halftone cell: only within the mask regions, there are values 16 x 16
screen_cell_mask = [0 0 0 0 0 0 0 1 1 0 0 0 0 0 0 0;...   % 1
                    0 0 0 0 0 0 1 1 1 1 0 0 0 0 0 0;...   % 2
                    0 0 0 0 0 1 1 1 1 1 1 0 0 0 0 0;...   % 3
                    0 0 0 0 1 1 1 1 1 1 1 1 0 0 0 0;...   % 4
                    0 0 0 1 1 1 1 1 1 1 1 1 1 0 0 0;...   % 5
                    0 0 1 1 1 1 1 1 1 1 1 1 1 1 0 0;...   % 6
                    0 1 1 1 1 1 1 1 1 1 1 1 1 1 1 0;...   % 7
                    1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1;...   % 8
                    0 1 1 1 1 1 1 1 1 1 1 1 1 1 1 0;...   % 9
                    0 0 1 1 1 1 1 1 1 1 1 1 1 1 0 0;...   % 10
                    0 0 0 1 1 1 1 1 1 1 1 1 1 0 0 0;...   % 11
                    0 0 0 0 1 1 1 1 1 1 1 1 0 0 0 0;...   % 12
                    0 0 0 0 0 1 1 1 1 1 1 0 0 0 0 0;...   % 13  
                    0 0 0 0 0 0 1 1 1 1 0 0 0 0 0 0;...   % 14
                    0 0 0 0 0 0 0 1 1 0 0 0 0 0 0 0;...   % 15
                    0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0];     % 16
% calculat the distances (normalized)
[screen_cell_coord_x, screen_cell_coord_y] = meshgrid((-cell_half_diag + 0.5):(cell_half_diag - 0.5), ...
                                                      (cell_half_diag - 1):-1:(-cell_half_diag + 1));
screen_cell_coord_x(end + 1, :) = 0;
screen_cell_coord_y(end + 1, :) = 0;
screen_cell_dist = sqrt(screen_cell_coord_x.^2 + screen_cell_coord_y.^2) .* screen_cell_mask;
screen_cell_dist_normal = screen_cell_dist ./ max(screen_cell_dist(:));
% initialize gray levels
t = fliplr(round(linspace(1, 255 - (255 / (num_gray_levels - 1)), num_gray_levels - 1)));
% the single halftone cell
screen_cell = [0      0      0      0     0     0      0      t(123) t(124) 0      0      0     0     0      0      0;...
               0      0      0      0     0     0      t(113) t(109) t(110) t(114) 0      0     0	    0	     0      0;...
               0      0      0      0     0     t(97)  t(83)  t(79)  t(80)  t(84)	 t(98)	0     0	    0	     0      0;...
               0      0      0      0     t(87) t(71)  t(57)  t(49)	 t(50)	t(58)	 t(72)	t(88) 0     0      0      0;...
               0      0      0      t(91) t(63) t(45)  t(35)  t(27)	 t(28)	t(36)	 t(46)	t(64) t(92) 0      0      0;...
               0      0      t(105) t(75) t(56) t(31)  t(17)  t(13)	 t(14)	t(18)	 t(32)	t(51) t(76) t(106) 0      0;...
               0      t(119) t(104) t(70) t(41) t(23)  t(9)   t(3)   t(4)	  t(10)	 t(24)	t(42) t(65) t(99)	 t(120) 0;...
               t(127) t(117) t(95)  t(61) t(39) t(22)  t(7)   t(1)   t(2)	  t(8)   t(19)	t(40) t(62) t(96)	 t(118) t(128);...
               0      t(122) t(103) t(69) t(44) t(26)  t(12)  t(6)   t(5)	  t(11)	 t(25)	t(43) t(66) t(100) t(121) 0;...
               0      0      t(108) t(78) t(55) t(34)  t(21)  t(16)	 t(15)	t(20)	 t(33)	t(52) t(77) t(107) 0      0;...
               0      0      0      t(94) t(68) t(48)  t(38)  t(30)	 t(29)	t(37)	 t(47)	t(67) t(93) 0      0      0;...
               0      0      0      0     t(90) t(74)  t(60)  t(54)	 t(53)  t(59)	 t(73)  t(89) 0	    0      0      0;...
               0      0      0      0     0	   t(102)	t(86)  t(82)	 t(81)	t(85)	 t(101) 0     0     0      0      0;...
               0      0      0      0     0     0      t(116) t(112) t(111) t(115) 0      0     0     0      0      0;...
               0      0      0      0     0     0      0      t(126) t(125) 0      0      0     0     0      0      0;...
               0      0      0      0     0     0      0      0      0      0      0      0     0     0      0   	  0];
% save the genreated screens
save('screen_cell_45_129.mat', 'screen_cell');