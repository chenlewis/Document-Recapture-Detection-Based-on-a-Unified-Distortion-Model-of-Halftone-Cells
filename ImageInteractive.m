classdef ImageInteractive
  
  methods
    % constructor
    function obj = ImageInteractive()
    end
  end
  
  methods (Static)
    % interactively rotate the image by 90 degrees
    function ImageRotationBy90(inputImage)
      outputImage = inputImage;
      % show the input image and keep refreshing
      inputImageFigure = figure(1);
      clf(inputImageFigure);
      imshow(outputImage.pixels);
      while true
        % get curse location and buttom
        [x, y, b] = ginput(1);
        switch b
          case 114    % letter r: do rotation by 90 degrees
            outputImage.pixels = rot90(outputImage.pixels);
          case 91     % '[': zoom out
            ax = axis; 
            width = ax(2) - ax(1); 
            height = ax(4) - ax(3);
            axis([x - width / 2 x + width / 2 y - height / 2 y + height / 2]);
            zoom(1 / 2);
          case 93     % '[': zoom in
            ax = axis; 
            width = ax(2) - ax(1); 
            height = ax(4) - ax(3);
            axis([x - width / 2 x + width / 2 y - height/2 y + height / 2]);
            zoom(2);    
          otherwise
            break
        end
        hold on;
      end
      return
    end
    %% select the ROI from input image
    % press s to select
    % press e to end selection and return the selected region (in rectangle format)
    function [outputImage, roiPosition] = SelectROI(inputImage)
      % the output image should have the same properties as the input image
      outputImage = inputImage;
      roiPosition = [];
      % initialize the 
      if size(inputImage, 3) == 1
        inputImageTemp = repmat(inputImage, 1, 1, 3);
      else
        inputImageTemp = inputImage;
      end
      % show image to process
      inputImageFigure = figure;
      selectedImageRegionFig = figure;
      % show the document image
      figure(inputImageFigure);
      clf(inputImageFigure);
      imshow(inputImageTemp);
      % show the input image
      while true
        figure(inputImageFigure);
        % get curse location and buttom
        [x, y, b] = ginput(1);
        if isempty(b)
          continue;
        end
        switch b
          case 91     % '[': zoom out
            ax = axis; 
            width = ax(2) - ax(1); 
            height = ax(4) - ax(3);
            axis([x - width / 2 x + width / 2 y - height / 2 y + height / 2]);
            zoom(1 / 2);  
          case 93     % '[': zoom in
            ax = axis; 
            width = ax(2) - ax(1); 
            height = ax(4) - ax(3);
            axis([x - width / 2 x + width / 2 y - height/2 y + height / 2]);
            zoom(2);    
          case 115    % 's': select rectangle region
            % select rectangle region
            r1 = drawrectangle('Color', [1 0 0]);
            % the corner points are in counter-clock order, (x, y) format, from TL corner
            cornerPoints = round(r1.Vertices);
            % construct the bounding box rectangle
            roiPosition(1) = cornerPoints(1, 1);    % xmin
            roiPosition(2) = cornerPoints(1, 2);    % ymin
            roiPosition(3) = cornerPoints(4, 1) - cornerPoints(1, 1) + 1;    % width
            roiPosition(4) = cornerPoints(2, 2) - cornerPoints(1, 2) + 1;    % height
            outputImage = inputImageTemp(cornerPoints(1, 2):cornerPoints(2, 2), cornerPoints(1, 1):cornerPoints(4, 1), :);
            % show the selected regions and break if needed
            figure(selectedImageRegionFig);
            clf(selectedImageRegionFig);
            imshow(outputImage);
            % get key strokes
            w = waitforbuttonpress;
            end_char = get(selectedImageRegionFig, 'CurrentCharacter');
            % end ROI extraction (e pressed)
            if strcmpi(end_char, 'e')
              % close the figures 
              close(inputImageFigure);
              close(selectedImageRegionFig);
              break;
            else % redo the selection
              figure(inputImageFigure);
              clf(inputImageFigure);
              imshow(inputImageTemp);
              clf(selectedImageRegionFig);
              continue;
            end
          case 101  % e is pressed: end the selection procedure
            % close the figures 
            close(inputImageFigure);
            close(selectedImageRegionFig);
            break;
          otherwise % other key is pressed: redo the selection
            figure(inputImageFigure);
            clf(inputImageFigure);
            imshow(inputImageTemp);
            clf(selectedImageRegionFig);
            continue;
        end
        hold on;
      end
      return;
    end
    %% return cursor location when mouse left click 
    function curserLocation = CursorLocation(inputImage)
      % initialize the 
      if inputImage.numColorChannel == 1
        inputImageTemp = Image.Image(repmat(inputImage.pixels, 1, 1, 3));
      else
        inputImageTemp = inputImage;
      end
      % show the input image
      inputImageFigure = figure;
      imshow(inputImageTemp.pixels);
      while true
        % get curse location and buttom
        [x, y, b] = ginput(1);
        switch b
          case 91     % '[': zoom out
            ax = axis; 
            width = ax(2) - ax(1); 
            height = ax(4) - ax(3);
            axis([x - width / 2 x + width / 2 ...
                  y - height / 2 y + height / 2]);
            zoom(1 / 2);
          case 93     % '[': zoom in
            ax = axis; 
            width = ax(2) - ax(1); 
            height = ax(4) - ax(3);
            axis([x - width / 2 x + width / 2 ...
                  y - height/2 y + height / 2]);
            zoom(2);    
          case 1    % mouse left click: 
            curserLocation = [x, y];
            break;
          case 101  % e is pressed
            curserLocation = [];
            break;
          otherwise
            continue;
        end
      end
      close(inputImageFigure);
    end
  end
end

