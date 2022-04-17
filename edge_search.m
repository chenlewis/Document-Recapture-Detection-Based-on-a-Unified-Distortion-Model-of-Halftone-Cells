%% this function detects the edges of the input binary image.
function edgesFound = edge_search(imgInput)
  edgesFound = [];
  % obtain the parameters
  [imgHeight, imgWidth] = size(imgInput);
  INIT_SIZE = min([imgHeight - 50, imgWidth - 50]);
  leftEdge =floor((imgWidth - INIT_SIZE)/2);
  rightEdge = floor((imgWidth + INIT_SIZE)/2);	
  upEdge = floor((imgHeight - INIT_SIZE)/2);	
  downEdge = floor((imgHeight + INIT_SIZE) /2);	
  if (upEdge < 0 || leftEdge < 0 || ...
      downEdge >= imgHeight || rightEdge >= imgWidth) 
      return
  end
  %% try to find the edges
  edgeFound = true;
  while edgeFound
    edgeFound = false; 
    %% search right: sum along the vertical dimension
    sumBits = sum(imgInput(upEdge : downEdge, rightEdge : end));
    move = find(sumBits == 0, 1, 'first');
    if isempty(move)
      rightEdge = imgWidth;
    % only when move is greater than 1: move = 1 means the current boundary
    elseif move > 1
      rightEdge = rightEdge + move - 1;
      edgeFound = true;        
    end
    if (rightEdge > imgWidth) 
      edgesFound = [];
      return;
    end
    %% search down
    sumBits = sum(imgInput(downEdge : end, leftEdge : rightEdge), 2);
    move = find(sumBits == 0, 1, 'first');
    if isempty(move)
      downEdge = imgHeight;
    elseif move > 1
      downEdge = downEdge + move - 1;
      edgeFound = true;        
    end
    if (downEdge > imgHeight) 
      edgesFound = [];
      return;
    end
    %% search left
    sumBits = sum(imgInput(upEdge : downEdge, 1 : leftEdge));
    move = find(sumBits == 0, 1, 'last');
    if isempty(move)
      leftEdge = 1;
    elseif move < leftEdge
      leftEdge = move;
      edgeFound = true;        
    end
    %% search up
    sumBits = sum(imgInput(1 : upEdge, leftEdge: rightEdge), 2);
    move = find(sumBits == 0, 1, 'last');
    if isempty(move)
        upEdge = 1;
    elseif move < upEdge
        upEdge = move;
        edgeFound = true;        
    end
  end
  edgesFound = [upEdge downEdge leftEdge rightEdge];
end

