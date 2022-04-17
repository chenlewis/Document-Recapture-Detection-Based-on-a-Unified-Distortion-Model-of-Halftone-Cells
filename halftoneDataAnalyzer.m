classdef halftoneDataAnalyzer
  
  properties
        
    dataCollectionBaseline              % the baseline image data collection
    dataCollectionTest                  % the test image data collection
    filenameCollectionBaseline          % the baseline image filenames
    filenameCollectionTest              % the test image filenames
    numBaselineImageBlks                % the number of baseline images
    numTestImageBlks                    % the number of the test images blocks
    numBaselineIntensities              % the number of the baseline image intensities
    numPrinters                         % the number of printers 
    numScanners                         % the number of scanners
    testImgType                         % 1: genuine doc, 2: recapture doc, the ref images are all genuine
    %% baseline image parameters
    
    % sigma a and width containers
    sampleSigmaABaselineArray
    sampleSigmaABaselineCell
    optSigmaABaselineCell
    
    % sigma b containers
    sampleSigmaBBaselineCell
    sampleHalftoneCellNumBaselineCell
    
    % PSD containers
    sampleHalftonePSDBaselineCell
    sampleHalftonePSDFBaselineCell
    
    sampleHalftoneWidthBaselineArray
    sampleHalftoneWidthBaselineCell
    
    % tstate result containers
    sampleSigmaABaselineTstatGroupArrayWidth
    sampleSigmaABaselineTstatGroupArrayPrinterWidth
    sampleSigmaABaselineTstatGroupArrayScannerWidth
    sampleSigmaABaselineTstatGroupArrayPrinterScannerWidth   
    sampleSigmaABaselineTstatGroupArrayWidthRot
    sampleSigmaABaselineTstatGroupArrayPrinterWidthRot
    sampleSigmaABaselineTstatGroupArrayScannerWidthRot
    sampleSigmaABaselineTstatGroupArrayPrinterScannerWidthRot   
    
    % width result containers
    sampleHalftoneWidthBaselineGroupArrayWidth
    sampleHalftoneWidthBaselineGroupArrayPrinterWidth
    sampleHalftoneWidthBaselineGroupArrayScannerWidth
    sampleHalftoneWidthBaselineGroupArrayPrinterScannerWidth
    sampleHalftoneWidthBaselineGroupArrayWidthRot
    sampleHalftoneWidthBaselineGroupArrayPrinterWidthRot
    sampleHalftoneWidthBaselineGroupArrayScannerWidthRot
    sampleHalftoneWidthBaselineGroupArrayPrinterScannerWidthRot
    
    %% test image parameters
    % sigma a and width containers
    sampleSigmaATestArray
    sampleSigmaATestCell
    optSigmaATestCell
    % sigma b containers
    sampleSigmaBTestCell
    % number of cell containers
    sampleHalftoneCellNumTestCell
    % PSD containers
    sampleHalftonePSDTestCell
    sampleHalftonePSDFTestCell
    % halftone cell width containers
    sampleHalftoneWidthTestArray
    sampleHalftoneWidthTestCell
    % tstate result containers (horizontal)
    sampleSigmaATestTstatGroupArrayWidth
    sampleSigmaATestTstatGroupArrayPrinterWidth
    sampleSigmaATestTstatGroupArrayScannerWidth
    sampleSigmaATestTstatGroupArrayPrinterScannerWidth
    % tstate result containers (vertical)
    sampleSigmaATestTstatGroupArrayWidthRot
    sampleSigmaATestTstatGroupArrayPrinterWidthRot
    sampleSigmaATestTstatGroupArrayScannerWidthRot
    sampleSigmaATestTstatGroupArrayPrinterScannerWidthRot
    % width result containers (horizontal)
    sampleHalftoneWidthTestGroupArrayWidth
    sampleHalftoneWidthTestGroupArrayPrinterWidth
    sampleHalftoneWidthTestGroupArrayScannerWidth
    sampleHalftoneWidthTestGroupArrayPrinterScannerWidth
    % width result containers (vertical)
    sampleHalftoneWidthTestGroupArrayWidthRot
    sampleHalftoneWidthTestGroupArrayPrinterWidthRot
    sampleHalftoneWidthTestGroupArrayScannerWidthRot
    sampleHalftoneWidthTestGroupArrayPrinterScannerWidthRot
    % doc test result containers
    sigmaATestTstatDocArray
    sigmaATestTstatDocArrayScanner
    sigmaATestTstatDocArrayPrinterScanner
    sigmaATestTstatDocArrayPrinterTypeScanner
    sigmaATestTstatDocArrayRot
    sigmaATestTstatDocArrayScannerRot
    sigmaATestTstatDocArrayPrinterScannerRot
    sigmaATestTstatDocArrayPrinterTypeScannerRot
    %% hypothesis testing parameter
    
    halfoneMeanWidthEdges = 0 : 30 : 60;
%     halfoneMeanWidthEdges = 1;
  
    % the H0 from baseline images
    H0BaselineWidth
    H0BaselineWidthRot
    H0BaselineWidthPrinter
    H0BaselineWidthPrinterRot
    
    H0BaselineWidthScanner          % for realistic
    H0BaselineWidthScannerRot
    H0VarBaselineWidthScanner
    H0VarBaselineWidthScannerRot
    
    H0BaselineWidthPrinterScanner     % for baseline 
    H0BaselineWidthPrinterScannerRot  % for baseline
    H0VarBaselineWidthPrinterScanner
    H0VarBaselineWidthPrinterScannerRot
    
    H0BaselineWidthPrinterTypeScanner     % for semi-controlled
    H0BaselineWidthPrinterTypeScannerRot  % for semi-controlled
    H0VarBaselineWidthPrinterTypeScanner
    H0VarBaselineWidthPrinterTypeScannerRot
    
    H0BaselineWidthPrinterTypeScannerType       % not used 
    H0BaselineWidthPrinterTypeScannerTypeRot    % not used
    
    % the default sample size
    sampleSize = 5;      
    %% hypothesis testing error terms
    
    % they are not used.
    FNErrorPrinterScannerSample
    FPErrorPrinterScannerSample
    
    FNErrorScannerSample
    FPErrorScannerSample
    
    FNErrorPrinterSample
    FPErrorPrinterSample
    
    FNErrorSample
    FPErrorSample
  end
  
  methods
    %% the constructor: baseline is loaded
    % the test image type is one of the following
    % 1: genuine reference with genuine document
    % 2: genuine reference with recaptured document
    % 3: genuine reference with recaptured reference
    function obj = halftoneDataAnalyzer(baselineDataCollectionPath, testImageDataCollectionPath, testImgType)
                                        
      %% collect the data collection
      % collect the baseline data
      temp = load(baselineDataCollectionPath, 'data_collection');
      obj.dataCollectionBaseline = temp.data_collection;
      % collect the test data
      temp = load(testImageDataCollectionPath, 'data_collection');
      obj.dataCollectionTest = temp.data_collection;
      % extract the baseline and the test file names
      obj.filenameCollectionBaseline = obj.dataCollectionBaseline(:, 1); 
      obj.filenameCollectionTest = obj.dataCollectionTest(:, 1); 
      % the sigma a from the baseline and the test images
      obj.sampleSigmaABaselineCell = obj.dataCollectionBaseline(:, 4);
      obj.sampleSigmaATestCell = obj.dataCollectionTest(:, 4);
      obj.optSigmaABaselineCell = obj.dataCollectionBaseline(:, 10);
      obj.optSigmaATestCell = obj.dataCollectionTest(:, 10);
      % the sigma b from the baseline and the test images
      obj.sampleSigmaBBaselineCell = obj.dataCollectionBaseline(:, 11);
      obj.sampleSigmaBTestCell = obj.dataCollectionTest(:, 11);
      % the halftone width from the baseline and the test images
      obj.sampleHalftoneWidthBaselineCell = obj.dataCollectionBaseline(:, 12);
      obj.sampleHalftoneWidthTestCell = obj.dataCollectionTest(:, 12);
      % the halftone cell number from the baseline and the test images
      obj.sampleHalftoneCellNumBaselineCell = obj.dataCollectionBaseline(:, 7);
      obj.sampleHalftoneCellNumTestCell = obj.dataCollectionTest(:, 7);
      % the spectral component values from the baseline and the test images
      obj.sampleHalftonePSDBaselineCell = obj.dataCollectionBaseline(:, 8);
      obj.sampleHalftonePSDTestCell = obj.dataCollectionTest(:, 8);
      % the spectral component locations from the baseline and the test images
      obj.sampleHalftonePSDFBaselineCell = obj.dataCollectionBaseline(:, 9);
      obj.sampleHalftonePSDFTestCell = obj.dataCollectionTest(:, 9);
      % the number of the image blocks from the test and the baseline images
      obj.numBaselineImageBlks = length(obj.filenameCollectionBaseline);
      obj.numTestImageBlks = length(obj.filenameCollectionTest);
      % initialize the sigma_a and halftone width arrays
      obj.sampleSigmaABaselineArray = [];
      obj.sampleHalftoneWidthBaselineArray = [];
      obj.sampleSigmaATestArray = [];
      obj.sampleHalftoneWidthTestArray = [];
      % separators: find _ and .
      separatorIdxBaseline = strfind(obj.filenameCollectionBaseline, '_');
      separatorIdxTest = strfind(obj.filenameCollectionTest, '_');
      extIdxBaseline = strfind(obj.filenameCollectionBaseline, '.');
      extIdxTest = strfind(obj.filenameCollectionTest, '.');
      % the number of printer and scanners
      obj.numPrinters = 9;
      obj.numScanners = 3;
      % 1: first print test
      % 2: second print test
      obj.testImgType = testImgType;
      % numBaselineIntensities
      obj.numBaselineIntensities = 50:20:230;
      %% initialize the H0 hypothesis array
      % H0 based on width only
      obj.H0BaselineWidth = zeros(1, length(obj.halfoneMeanWidthEdges));
      obj.H0BaselineWidthRot = zeros(1, length(obj.halfoneMeanWidthEdges));
      % H0 based on width and printer
      obj.H0BaselineWidthPrinter = zeros(obj.numPrinters, length(obj.halfoneMeanWidthEdges));
      obj.H0BaselineWidthPrinterRot = zeros(obj.numPrinters, length(obj.halfoneMeanWidthEdges));
      % H0 based on width and scanner (realistic)
      obj.H0BaselineWidthScanner = zeros(obj.numScanners, length(obj.halfoneMeanWidthEdges));
      obj.H0BaselineWidthScannerRot = zeros(obj.numScanners, length(obj.halfoneMeanWidthEdges));
      obj.H0VarBaselineWidthScanner = zeros(obj.numScanners, length(obj.halfoneMeanWidthEdges));
      obj.H0VarBaselineWidthScannerRot = zeros(obj.numScanners, length(obj.halfoneMeanWidthEdges));
      % H0 based on width, printer and scanner (baseline)
      obj.H0BaselineWidthPrinterScanner = zeros(obj.numPrinters, obj.numScanners, length(obj.halfoneMeanWidthEdges));
      obj.H0BaselineWidthPrinterScannerRot = zeros(obj.numPrinters, obj.numScanners, length(obj.halfoneMeanWidthEdges));
      obj.H0VarBaselineWidthPrinterScanner = zeros(obj.numPrinters, obj.numScanners, length(obj.halfoneMeanWidthEdges));
      obj.H0VarBaselineWidthPrinterScannerRot = zeros(obj.numPrinters, obj.numScanners, length(obj.halfoneMeanWidthEdges));
      % H0 based on width, printer type and scanner
      obj.H0BaselineWidthPrinterTypeScanner = zeros(2, obj.numScanners, length(obj.halfoneMeanWidthEdges));
      obj.H0BaselineWidthPrinterTypeScannerRot = zeros(2, obj.numScanners, length(obj.halfoneMeanWidthEdges));			
      obj.H0VarBaselineWidthPrinterTypeScanner = zeros(2, obj.numScanners, length(obj.halfoneMeanWidthEdges));
      obj.H0VarBaselineWidthPrinterTypeScannerRot = zeros(2, obj.numScanners, length(obj.halfoneMeanWidthEdges));	
      %% organize the baseline image blocks
      for i = 1:obj.numBaselineImageBlks
        if ~isempty(obj.sampleSigmaABaselineCell{i}) 
          if obj.optSigmaABaselineCell{i} ~= 0
            % assign the printer idx: from 1 to the 1st separator
            printerName = obj.filenameCollectionBaseline{i}(1:(separatorIdxBaseline{i}(1) - 1));
            sampleSigmaABaselineArray = zeros(1, 8);
            sampleHalftoneWidthBaselineArray = zeros(1, 8);
            switch printerName
              case 'hp258'
                sampleSigmaABaselineArray(1) = 1;
                sampleHalftoneWidthBaselineArray(1) = 1;
              case 'hp6222'
                % initialize the sigma a and width containers
                sampleSigmaABaselineArray(1) = 3;
                sampleHalftoneWidthBaselineArray(1) = 3;
              case 'hpm401n'
                % initialize the sigma a and width containers
                sampleSigmaABaselineArray(1) = 4;
                sampleHalftoneWidthBaselineArray(1) = 4;
              otherwise
                continue
            end
            % assign the scanner idx
            scannerName = obj.filenameCollectionBaseline{i}...
                          ((separatorIdxBaseline{i}(1) + 1):(separatorIdxBaseline{i}(2) - 1));
            switch scannerName
              case 'epson850'
                sampleSigmaABaselineArray(2) = 1;
                sampleHalftoneWidthBaselineArray(2) = 1;
              case 'hp6222'
                sampleSigmaABaselineArray(2) = 3;
                sampleHalftoneWidthBaselineArray(2) = 3;
              case 'realmegtneo'
                sampleSigmaABaselineArray(2) = 2;
                sampleHalftoneWidthBaselineArray(2) = 2;
              otherwise
                continue
            end
            % assign the intensity (from the ref image)
            intensityBaseline = ...
              str2double(obj.filenameCollectionBaseline{i}...
                        ((separatorIdxBaseline{i}(2) + 1):(separatorIdxBaseline{i}(3) - 1)));
            sampleSigmaABaselineArray(3) = intensityBaseline;
            sampleHalftoneWidthBaselineArray(3) = intensityBaseline;
            
%             % avoid using extreme values
%             if intensityBaseline >= 190 || intensityBaseline <= 90
%               continue;
%             end

            % assign the copy idx
            copyIdx = str2double(obj.filenameCollectionBaseline{i}...
                                ((separatorIdxBaseline{i}(3) + 1):(separatorIdxBaseline{i}(4) - 1)));
%             copyIdx = str2double(obj.filenameCollectionBaseline{i}...
%                                 ((separatorIdxBaseline{i}(3) + 1):(extIdxBaseline{i}(1) - 1)));
            
            sampleSigmaABaselineArray(4) = copyIdx;
            sampleHalftoneWidthBaselineArray(4) = copyIdx;
            % assign the block idx: with and without rotation
            if length(separatorIdxBaseline{i}) == 5     % without rot
              blockIdx = str2double(obj.filenameCollectionBaseline{i}...
                                   ((separatorIdxBaseline{i}(5) + 1):(extIdxBaseline{i}(2) - 1)));
              sampleSigmaABaselineArray(8) = 0;
              sampleHalftoneWidthBaselineArray(7) = 0;
            elseif length(separatorIdxBaseline{i}) == 6 % with rot
              blockIdx = str2double(obj.filenameCollectionBaseline{i}...
                                   ((separatorIdxBaseline{i}(5) + 1):(separatorIdxBaseline{i}(6) - 1)));
              sampleSigmaABaselineArray(8) = 1;
              sampleHalftoneWidthBaselineArray(7) = 1;
            end
            % assign block index
            sampleSigmaABaselineArray(5) = blockIdx;
            sampleHalftoneWidthBaselineArray(5) = blockIdx;
            % assign the sample sigma a value 
            sampleSigmaABaselineArray(6) = obj.sampleSigmaABaselineCell{i};
            sampleSigmaABaselineArray(7) = obj.optSigmaABaselineCell{i};
            % assign the sample width value
            sampleHalftoneWidthBaselineArray(6) = obj.sampleHalftoneWidthBaselineCell{i};
            sampleHalftoneWidthBaselineArray(8) = obj.sampleSigmaBBaselineCell{i};
            % copy the data
            obj.sampleSigmaABaselineArray(end + 1, :) = sampleSigmaABaselineArray;
            obj.sampleHalftoneWidthBaselineArray(end + 1, :) = sampleHalftoneWidthBaselineArray;
            % debug
            if isnan(obj.sampleSigmaABaselineArray(end, 7)) || ~isreal(obj.sampleSigmaABaselineArray(end, 7))
              disp('debug');
            end
          end
        end
      end
      %% organize the test image blocks
      count_all = 0;
      switch obj.testImgType
        case 1  % genuine document image (not used for camera capture)
          for i = 1:obj.numTestImageBlks
            if ~isempty(obj.sampleSigmaATestCell{i})
              if obj.optSigmaATestCell{i} ~= 0
                sampleSigmaATestArray = zeros(1, 9);
                sampleHalftoneWidthTestArray = zeros(1, 8);
                % assign the printer 1
                switch obj.filenameCollectionTest{i}(1:(separatorIdxTest{i}(1) - 1))
                  case 'hp258'
                    sampleSigmaATestArray(1) = 1;
                    sampleHalftoneWidthTestArray(1) = 1;
                  case 'hp6222'
                    sampleSigmaATestArray(1) = 3;
                    sampleHalftoneWidthTestArray(1) = 3;
                  case 'hpm401n'
                    sampleSigmaATestArray(1) = 4;
                    sampleHalftoneWidthTestArray(1) = 4;
                  case 'kyoceram2530dn'
                    sampleSigmaATestArray(1) = 5;
                    sampleHalftoneWidthTestArray(1) = 5;
                  case 'hpm251n'
                    sampleSigmaATestArray(1) = 6;
                    sampleHalftoneWidthTestArray(1) = 6;
                  case 'canong3800'
                    sampleSigmaATestArray(1) = 8;
                    sampleHalftoneWidthTestArray(1) = 8;
                  case 'hpm176'
                    sampleSigmaATestArray(1) = 9;
                    sampleHalftoneWidthTestArray(1) = 9;
                  case 'fujip335d'
                    sampleSigmaATestArray(1) = 10;
                    sampleHalftoneWidthTestArray(1) = 10;
                  case 'hp2138'
                    sampleSigmaATestArray(end, 1) = 11;
                    sampleHalftoneWidthTestArray(end, 1) = 11;
                  otherwise
                    continue;
                end
                % assign the scanner 1
                switch obj.filenameCollectionTest{i}((separatorIdxTest{i}(1) + 1):(separatorIdxTest{i}(2) - 1))
                  case 'epson850'
                    sampleSigmaATestArray(4) = 1;
                    sampleHalftoneWidthTestArray(4) = 1;
                  case 'hp6222'
                    sampleSigmaATestArray(4) = 3;
                    sampleHalftoneWidthTestArray(4) = 3;
                  otherwise
                    continue;
                end           
                % assign the doc idx
                sampleSigmaATestArray(5) = ...
                  str2double(obj.filenameCollectionTest{i}((separatorIdxTest{i}(2) + 1):(extIdxTest{i}(1) - 1)));
                sampleHalftoneWidthTestArray(5) = ...
                  str2double(obj.filenameCollectionTest{i}((separatorIdxTest{i}(2) + 1):(extIdxTest{i}(1) - 1)));
                % assign the copy idx: with and without rotation
                if length(separatorIdxTest{i}) == 3
                  sampleSigmaATestArray(6) = ....
                    str2double(obj.filenameCollectionTest{i}((separatorIdxTest{i}(3) + 1):(extIdxTest{i}(2) - 1)));
                  sampleHalftoneWidthTestArray(6) = str2double(...
                    obj.filenameCollectionTest{i}((separatorIdxTest{i}(3) + 1):(extIdxTest{i}(2) - 1)));
                  sampleSigmaATestArray(9) = 0;
                  sampleHalftoneWidthTestArray(8) = 0;
                elseif length(separatorIdxTest{i}) == 4
                  sampleSigmaATestArray(6) = ...
                    str2double(obj.filenameCollectionTest{i}((separatorIdxTest{i}(3) + 1):(separatorIdxTest{i}(4) - 1)));
                  sampleHalftoneWidthTestArray(6) = ...
                    str2double(obj.filenameCollectionTest{i}((separatorIdxTest{i}(3) + 1):(separatorIdxTest{i}(4) - 1)));
                  sampleSigmaATestArray(9) = 1;
                  sampleHalftoneWidthTestArray(8) = 1;
                end
                % assign the sample sigma a value 
                sampleSigmaATestArray(7) = obj.sampleSigmaATestCell{i};
                % assign the optimal sigma a value 
                try
                  sampleSigmaATestArray(8) = obj.optSigmaATestCell{i};
                catch
                  disp('except debug');
                end
                % assign the optimal width value
                sampleHalftoneWidthTestArray(7) = obj.sampleHalftoneWidthTestCell{i};
                sampleHalftoneWidthTestArray(9) = obj.sampleSigmaBTestCell{i};
                obj.sampleSigmaATestArray(end + 1, :) = sampleSigmaATestArray;
                obj.sampleHalftoneWidthTestArray(end + 1, :) = sampleHalftoneWidthTestArray;
              end
              count_all = count_all + 1;
            end
          end
        case 2  % recaptured document image (not used for camera capture)
          for i = 1:obj.numTestImageBlks
            if ~isempty(obj.sampleSigmaATestCell{i})
              if obj.optSigmaATestCell{i} ~= 0
                % initialize the data containers for sigmaA and halftone widht for a whole 
                sampleSigmaATestArray = zeros(1, 9);
                sampleHalftoneWidthTestArray = zeros(1, 8);
                % assign the printer 1
                switch obj.filenameCollectionTest{i}(1:(separatorIdxTest{i}(1) - 1))
                  case 'hp258'
                    sampleSigmaATestArray(1) = 1;
                    sampleHalftoneWidthTestArray(1) = 1;
                  case 'hp6222'
                    sampleSigmaATestArray(1) = 3;
                    sampleHalftoneWidthTestArray(1) = 3;
                  case 'hpm401n'
                    sampleSigmaATestArray(1) = 4;
                    sampleHalftoneWidthTestArray(1) = 4;
                  case 'kyoceram2530dn'
                    sampleSigmaATestArray(1) = 5;
                    sampleHalftoneWidthTestArray(1) = 5;
                  case 'hpm251n'
                    sampleSigmaATestArray(1) = 6;
                    sampleHalftoneWidthTestArray(1) = 6;
                  case 'canong3800'
                    sampleSigmaATestArray(1) = 8;
                    sampleHalftoneWidthTestArray(1) = 8;
                  case 'hpm176'
                    sampleSigmaATestArray(1) = 9;
                    sampleHalftoneWidthTestArray(1) = 9;
                  case 'fujip335d'
                    sampleSigmaATestArray(1) = 10;
                    sampleHalftoneWidthTestArray(1) = 10;
                  case 'hp2138'
                    sampleSigmaATestArray(end, 1) = 11;
                    sampleHalftoneWidthTestArray(end, 1) = 11;
                  otherwise
                    continue;
                end
                % assign the printer 2
                switch obj.filenameCollectionTest{i}((separatorIdxTest{i}(2) + 1):...
                                                     (separatorIdxTest{i}(3) - 1))
                  case 'hp258'
                    sampleSigmaATestArray(2) = 1;
                    sampleHalftoneWidthTestArray(2) = 1;
                  case 'hp6222'
                    sampleSigmaATestArray(2) = 3;
                    sampleHalftoneWidthTestArray(2) = 3;
                  case 'hpm401n'
                    sampleSigmaATestArray(2) = 4;
                    sampleHalftoneWidthTestArray(2) = 4;
                  case 'kyoceram2530dn'
                    sampleSigmaATestArray(2) = 5;
                    sampleHalftoneWidthTestArray(2) = 5;
                  case 'hpm251n'
                    sampleSigmaATestArray(2) = 6;
                    sampleHalftoneWidthTestArray(2) = 6;
                  case 'canong3800'
                    sampleSigmaATestArray(2) = 8;
                    sampleHalftoneWidthTestArray(2) = 8;
                  case 'hpm176'
                    sampleSigmaATestArray(2) = 9;
                    sampleHalftoneWidthTestArray(2) = 9;
                  case 'fujip335d'
                    sampleSigmaATestArray(2) = 10;
                    sampleHalftoneWidthTestArray(2) = 10;
                  case 'hp2138'
                    sampleSigmaATestArray(end, 1) = 11;
                    sampleHalftoneWidthTestArray(end, 1) = 11;
                  otherwise
                    continue;
                end
                % assign the scanner 1
                switch obj.filenameCollectionTest{i}((separatorIdxTest{i}(1) + 1):(separatorIdxTest{i}(2) - 1))
                  case 'epson850'
                    sampleSigmaATestArray(3) = 1;
                    sampleHalftoneWidthTestArray(3) = 1;
                  case 'hp6222'
                    sampleSigmaATestArray(3) = 3;
                    sampleHalftoneWidthTestArray(3) = 3;
                  otherwise
                    continue;
                end
                % assign the scanner 2
                switch obj.filenameCollectionTest{i}((separatorIdxTest{i}(3) + 1):(separatorIdxTest{i}(4) - 1))
                  case 'epson850'
                    sampleSigmaATestArray(4) = 1;
                    sampleHalftoneWidthTestArray(4) = 1;
                  case 'hp6222'
                    sampleSigmaATestArray(4) = 3;
                    sampleHalftoneWidthTestArray(4) = 3;
                  otherwise
                    continue;
                end
                % assign the doc idx
                sampleSigmaATestArray(5) = ...
                  str2double(obj.filenameCollectionTest{i}((separatorIdxTest{i}(4) + 1):(extIdxTest{i}(1) - 1)));
                sampleHalftoneWidthTestArray(5) = ...
                  str2double(obj.filenameCollectionTest{i}((separatorIdxTest{i}(4) + 1):(extIdxTest{i}(1) - 1)));
                % assign the copy idx
                if length(separatorIdxTest{i}) == 5
                  sampleSigmaATestArray(6) = ...
                    str2double(obj.filenameCollectionTest{i}((separatorIdxTest{i}(5) + 1):(extIdxTest{i}(2) - 1)));
                  sampleHalftoneWidthTestArray(6) = ...
                    str2double(obj.filenameCollectionTest{i}((separatorIdxTest{i}(5) + 1):(extIdxTest{i}(2) - 1)));
                  sampleSigmaATestArray(9) = 0;
                  sampleHalftoneWidthTestArray(8) = 0;
                elseif length(separatorIdxTest{i}) == 6
                  sampleSigmaATestArray(6) = ...
                    str2double(obj.filenameCollectionTest{i}((separatorIdxTest{i}(5) + 1):(separatorIdxTest{i}(6) - 1)));
                  sampleHalftoneWidthTestArray(6) = ...
                    str2double(obj.filenameCollectionTest{i}((separatorIdxTest{i}(5) + 1):(separatorIdxTest{i}(6) - 1)));
                  sampleSigmaATestArray(9) = 1;
                  sampleHalftoneWidthTestArray(8) = 1;
                end
                % assign the sample and optimal sigma a value 
                sampleSigmaATestArray(7) = obj.sampleSigmaATestCell{i};
                sampleSigmaATestArray(8) = obj.optSigmaATestCell{i};
                if sampleSigmaATestArray(4) == 0
                  disp([obj.filenameCollectionTest{i} num2str(obj.sampleSigmaATestArray(end, 8))]);
                end
                % assign the sample width value (these are the optimal mean and std)
                sampleHalftoneWidthTestArray(7) = obj.sampleHalftoneWidthTestCell{i};
                sampleHalftoneWidthTestArray(9) = obj.sampleSigmaBTestCell{i};
                % copy the value
                obj.sampleSigmaATestArray(end + 1, :) = sampleSigmaATestArray;
                obj.sampleHalftoneWidthTestArray(end + 1, :) = sampleHalftoneWidthTestArray;
              end
              count_all = count_all + 1;
            end
          end
        case 3  % genuine reference images as test set
          for i = 1:obj.numTestImageBlks
            if ~isempty(obj.sampleSigmaATestCell{i})
              if obj.optSigmaATestCell{i} ~= 0
                % initialize the data containers for sigmaA and halftone widht for a whole 
                sampleSigmaATestArray = zeros(1, 9);
                sampleHalftoneWidthTestArray = zeros(1, 8);
                % assign the printer 1
                switch obj.filenameCollectionTest{i}(1:(separatorIdxTest{i}(1) - 1))
                  case 'hp258'
                    sampleSigmaATestArray(1) = 1;
                    sampleHalftoneWidthTestArray(1) = 1;
                  case 'hp6222'
                    sampleSigmaATestArray(1) = 3;
                    sampleHalftoneWidthTestArray(1) = 3;
                  case 'hpm401n'
                    sampleSigmaATestArray(1) = 4;
                    sampleHalftoneWidthTestArray(1) = 4;
                  case 'kyoceram2530dn'
                    sampleSigmaATestArray(1) = 5;
                    sampleHalftoneWidthTestArray(1) = 5;
                  case 'hpm251n'
                    sampleSigmaATestArray(1) = 6;
                    sampleHalftoneWidthTestArray(1) = 6;
                  case 'canong3800'
                    sampleSigmaATestArray(1) = 8;
                    sampleHalftoneWidthTestArray(1) = 8;
                  case 'hpm176'
                    sampleSigmaATestArray(1) = 9;
                    sampleHalftoneWidthTestArray(1) = 9;
                  case 'fujip335d'
                    sampleSigmaATestArray(1) = 10;
                    sampleHalftoneWidthTestArray(1) = 10;
                  case 'hp2138'
                    sampleSigmaATestArray(end, 1) = 11;
                    sampleHalftoneWidthTestArray(end, 1) = 11;
                  otherwise
                    continue;
                end
                % assign the scanner 1
                switch obj.filenameCollectionTest{i}((separatorIdxTest{i}(1) + 1):(separatorIdxTest{i}(2) - 1))
                  case 'epson850'
                    sampleSigmaATestArray(4) = 1;
                    sampleHalftoneWidthTestArray(3) = 1;
                  case 'realmegtneo'
                    sampleSigmaATestArray(4) = 2;
                    sampleHalftoneWidthTestArray(4) = 2;
                  case 'hp6222'
                    sampleSigmaATestArray(4) = 3;
                    sampleHalftoneWidthTestArray(4) = 3;
                  otherwise
                    continue;
                end
                % assign the intensity
                sampleSigmaATestArray(5) = ...
                  str2double(obj.filenameCollectionTest{i}((separatorIdxTest{i}(2) + 1):(separatorIdxTest{i}(3) - 1)));
                sampleHalftoneWidthTestArray(5) = ...
                  str2double(obj.filenameCollectionTest{i}((separatorIdxTest{i}(2) + 1):(separatorIdxTest{i}(3) - 1)));
                % assign the block idx (copy index is not included, though)
                if length(separatorIdxTest{i}) == 4 % without rotation
                  sampleSigmaATestArray(6) = ...
                    str2double(obj.filenameCollectionTest{i}((separatorIdxTest{i}(4) + 1):(extIdxTest{i}(2) - 1)));
                  sampleHalftoneWidthTestArray(6) = ...
                    str2double(obj.filenameCollectionTest{i}((separatorIdxTest{i}(4) + 1):(extIdxTest{i}(2) - 1)));
                  sampleSigmaATestArray(9) = 0; % assign rotation flag
                  sampleHalftoneWidthTestArray(8) = 0; % assign rotation flag
                elseif length(separatorIdxTest{i}) == 5 % with rotation
                  sampleSigmaATestArray(6) = ...
                    str2double(obj.filenameCollectionTest{i}((separatorIdxTest{i}(4) + 1):(separatorIdxTest{i}(5) - 1)));
                  sampleHalftoneWidthTestArray(6) = ...
                    str2double(obj.filenameCollectionTest{i}((separatorIdxTest{i}(4) + 1):(separatorIdxTest{i}(5) - 1)));
                  sampleSigmaATestArray(9) = 1; % assign rotation flag
                  sampleHalftoneWidthTestArray(8) = 1; % assign rotation flag
                end
                % assign the sample and optimal sigma a value 
                sampleSigmaATestArray(7) = obj.sampleSigmaATestCell{i}; % sample sigmaA
                sampleSigmaATestArray(8) = obj.optSigmaATestCell{i}; % optimal sigmaA
                % debug purpose
                if sampleSigmaATestArray(4) == 0
                  disp([obj.filenameCollectionTest{i} num2str(obj.sampleSigmaATestArray(end, 8))]);
                end
                % assign the sample width value (these are the optimal mean and std)
                sampleHalftoneWidthTestArray(7) = obj.sampleHalftoneWidthTestCell{i};  % width mean (optimal)
                sampleHalftoneWidthTestArray(9) = obj.sampleSigmaBTestCell{i};         % widht std (optimal)
                % copy the value
                obj.sampleSigmaATestArray(end + 1, :) = sampleSigmaATestArray;
                obj.sampleHalftoneWidthTestArray(end + 1, :) = sampleHalftoneWidthTestArray;
              end
              count_all = count_all + 1;
            end % end if on invalid estimates
          end % end for loop on image blocks
        case 4  % recaptured reference images 
          for i = 1:obj.numTestImageBlks
            if ~isempty(obj.sampleSigmaATestCell{i})
              if obj.optSigmaATestCell{i} ~= 0
                % initialize the data containers for sigmaA and halftone widht for a whole 
                sampleSigmaATestArray = zeros(1, 9);
                sampleHalftoneWidthTestArray = zeros(1, 8);
                % assign the printer 1
                switch obj.filenameCollectionTest{i}(1:(separatorIdxTest{i}(1) - 1))
                  case 'hp258'
                    sampleSigmaATestArray(1) = 1;
                    sampleHalftoneWidthTestArray(1) = 1;
                  case 'hp6222'
                    sampleSigmaATestArray(1) = 3;
                    sampleHalftoneWidthTestArray(1) = 3;
                  case 'hpm401n'
                    sampleSigmaATestArray(1) = 4;
                    sampleHalftoneWidthTestArray(1) = 4;
                  case 'kyoceram2530dn'
                    sampleSigmaATestArray(1) = 5;
                    sampleHalftoneWidthTestArray(1) = 5;
                  case 'hpm251n'
                    sampleSigmaATestArray(1) = 6;
                    sampleHalftoneWidthTestArray(1) = 6;
                  case 'canong3800'
                    sampleSigmaATestArray(1) = 8;
                    sampleHalftoneWidthTestArray(1) = 8;
                  case 'hpm176'
                    sampleSigmaATestArray(1) = 9;
                    sampleHalftoneWidthTestArray(1) = 9;
                  case 'fujip335d'
                    sampleSigmaATestArray(1) = 10;
                    sampleHalftoneWidthTestArray(1) = 10;
                  case 'hp2138'
                    sampleSigmaATestArray(end, 1) = 11;
                    sampleHalftoneWidthTestArray(end, 1) = 11;
                  otherwise
                    continue;
                end
                % assign the printer 2
                switch obj.filenameCollectionTest{i}((separatorIdxTest{i}(2) + 1):...
                                                     (separatorIdxTest{i}(3) - 1))
                  case 'hp258'
                    sampleSigmaATestArray(2) = 1;
                    sampleHalftoneWidthTestArray(2) = 1;
                  case 'hp6222'
                    sampleSigmaATestArray(2) = 3;
                    sampleHalftoneWidthTestArray(2) = 3;
                  case 'hpm401n'
                    sampleSigmaATestArray(2) = 4;
                    sampleHalftoneWidthTestArray(2) = 4;
                  case 'kyoceram2530dn'
                    sampleSigmaATestArray(2) = 5;
                    sampleHalftoneWidthTestArray(2) = 5;
                  case 'hpm251n'
                    sampleSigmaATestArray(2) = 6;
                    sampleHalftoneWidthTestArray(2) = 6;
                  case 'canong3800'
                    sampleSigmaATestArray(2) = 8;
                    sampleHalftoneWidthTestArray(2) = 8;
                  case 'hpm176'
                    sampleSigmaATestArray(2) = 9;
                    sampleHalftoneWidthTestArray(2) = 9;
                  case 'fujip335d'
                    sampleSigmaATestArray(2) = 10;
                    sampleHalftoneWidthTestArray(2) = 10;
                  case 'hp2138'
                    sampleSigmaATestArray(end, 1) = 11;
                    sampleHalftoneWidthTestArray(end, 1) = 11;
                  otherwise
                    continue;
                end
                % assign the scanner 1
                switch obj.filenameCollectionTest{i}((separatorIdxTest{i}(1) + 1):(separatorIdxTest{i}(2) - 1))
                  case 'epson850'
                    sampleSigmaATestArray(3) = 1;
                    sampleHalftoneWidthTestArray(3) = 1;
                  case 'realmegtneo'
                    sampleSigmaATestArray(3) = 2;
                    sampleHalftoneWidthTestArray(3) = 2;
                  case 'hp6222'
                    sampleSigmaATestArray(3) = 3;
                    sampleHalftoneWidthTestArray(3) = 3;
                  otherwise
                    continue;
                end
                % assign the scanner 2
                switch obj.filenameCollectionTest{i}((separatorIdxTest{i}(3) + 1):(separatorIdxTest{i}(4) - 1))
                  case 'epson850'
                    sampleSigmaATestArray(4) = 1;
                    sampleHalftoneWidthTestArray(4) = 1;
                  case 'realmegtneo'
                    sampleSigmaATestArray(4) = 2;
                    sampleHalftoneWidthTestArray(4) = 2;
                  case 'hp6222'
                    sampleSigmaATestArray(4) = 3;
                    sampleHalftoneWidthTestArray(4) = 3;
                  otherwise
                    continue;
                end
                % assign the intensity
                sampleSigmaATestArray(5) = ...
                  str2double(obj.filenameCollectionTest{i}((separatorIdxTest{i}(4) + 1):(separatorIdxTest{i}(5) - 1)));
                sampleHalftoneWidthTestArray(5) = ...
                  str2double(obj.filenameCollectionTest{i}((separatorIdxTest{i}(4) + 1):(separatorIdxTest{i}(5) - 1)));
                % assign the block idx (copy index is not included, though)
                if length(separatorIdxTest{i}) == 6 % without rotation
                  sampleSigmaATestArray(6) = ...
                    str2double(obj.filenameCollectionTest{i}((separatorIdxTest{i}(6) + 1):(extIdxTest{i}(2) - 1)));
                  sampleHalftoneWidthTestArray(6) = ...
                    str2double(obj.filenameCollectionTest{i}((separatorIdxTest{i}(6) + 1):(extIdxTest{i}(2) - 1)));
                  sampleSigmaATestArray(9) = 0; % assign rotation flag
                  sampleHalftoneWidthTestArray(8) = 0; % assign rotation flag
                elseif length(separatorIdxTest{i}) == 7 % with rotation
                  sampleSigmaATestArray(6) = ...
                    str2double(obj.filenameCollectionTest{i}((separatorIdxTest{i}(6) + 1):(separatorIdxTest{i}(7) - 1)));
                  sampleHalftoneWidthTestArray(6) = ...
                    str2double(obj.filenameCollectionTest{i}((separatorIdxTest{i}(6) + 1):(separatorIdxTest{i}(7) - 1)));
                  sampleSigmaATestArray(9) = 1; % assign rotation flag
                  sampleHalftoneWidthTestArray(8) = 1; % assign rotation flag
                end
                % assign the sample and optimal sigma a value 
                sampleSigmaATestArray(7) = obj.sampleSigmaATestCell{i}; % sample sigmaA
                sampleSigmaATestArray(8) = obj.optSigmaATestCell{i}; % optimal sigmaA
                % debug purpose
                if sampleSigmaATestArray(4) == 0
                  disp([obj.filenameCollectionTest{i} num2str(obj.sampleSigmaATestArray(end, 8))]);
                end
                % assign the sample width value (these are the optimal mean and std)
                sampleHalftoneWidthTestArray(7) = obj.sampleHalftoneWidthTestCell{i};  % width mean (optimal)
                sampleHalftoneWidthTestArray(9) = obj.sampleSigmaBTestCell{i};         % widht std (optimal)
                % copy the value
                obj.sampleSigmaATestArray(end + 1, :) = sampleSigmaATestArray;
                obj.sampleHalftoneWidthTestArray(end + 1, :) = sampleHalftoneWidthTestArray;
              end
              count_all = count_all + 1;
            end % end if on invalid estimates
          end % end for loop on image blocks
      end % end switch
      disp(count_all);
    end
    
    %% show sigma_a histogram only
    function obj = checkSigmaAHistogram(obj)

      %% show the baseline sigma a distribution
      histBinEdges = 0.01:0.05:3;
      obj.sampleSigmaABaselineArray(:) = real(obj.sampleSigmaABaselineArray(:));
      obj.sampleSigmaATestArray(:) = real(obj.sampleSigmaATestArray(:));
      
      % show overall histogram of optimal sigma a 
      figure;
      histogram(real(obj.sampleSigmaABaselineArray(:, 7)), histBinEdges, 'Normalization', 'probability');
      hold on;
      % show optimal values all scanners
      histogram(real(obj.sampleSigmaATestArray(:, 8)), histBinEdges, 'Normalization', 'probability');
      set(gca, 'FontName', 'Times', 'FontSize', 25, 'FontSmoothing', 'on');  
      set(gcf, 'InnerPosition', [0 0 800 800], 'OuterPosition', [0 0 800 800], 'color', 'w');  
      legend('genuine reference image', 'genuine document image');
%       title('baseline optimal $\sigma_a$ values', 'Interpreter', 'latex');
      
%       % show overall histogram of sample sigma a 
%       figure;
%       histogram(obj.sampleSigmaABaselineArray(:, 6), histBinEdges, 'Normalization', 'probability');
%       hold on;
%       histogram(obj.sampleSigmaATestArray(:, 7), histBinEdges, 'Normalization', 'probability');
%       set(gca, 'FontName', 'Times', 'FontSize', 25, 'FontSmoothing', 'on');  
%       set(gcf, 'InnerPosition', [0 0 800 800], 'OuterPosition', [0 0 800 800], 'color', 'w');  
%       legend('reference image', 'recaptured document image');
% %       title('baseline sample \sigma_a values');

      %% show baseline sample sigma a values for different scanners
%       sampleSigmaABaselineArrayP1 = ...
%           obj.sampleSigmaABaselineArray(obj.sampleSigmaABaselineArray(:, 2) == 1, :);
% 
%       sampleSigmaABaselineArrayP2 = ...
%           obj.sampleSigmaABaselineArray(obj.sampleSigmaABaselineArray(:, 2) == 2, :);
% 
%       sampleSigmaABaselineArrayP3 = ...
%           obj.sampleSigmaABaselineArray(obj.sampleSigmaABaselineArray(:, 2) == 3, :);
% 
%       figure;
%       histogram(sampleSigmaABaselineArrayP1(:, 7), histBinEdges, 'Normalization', 'probability');
%       hold on;
%       histogram(sampleSigmaABaselineArrayP2(:, 7), histBinEdges, 'Normalization', 'probability');
%       histogram(sampleSigmaABaselineArrayP3(:, 7), histBinEdges, 'Normalization', 'probability');
%       hold off;
%       legend('epson850', 'hp2138', 'hp6222');
%       set(gca, 'FontSize', 15, 'FontSmoothing','on');  
%       set(gcf, 'InnerPosition', [0 0 800 800]);  
%       set(gcf, 'OuterPosition', [0 0 800 800]); 
%       title('baseline sample sigma a values for different scanners');
      
      %% show baseline sample sigma a values for different intensities (GT)
%       figure;
%       subplot(2, 5, 1);
%       histogram(sampleSigmaABaselineArrayP1(sampleSigmaABaselineArrayP1(:, 3) == 50, 6), histBinEdges, 'Normalization', 'probability');
%       hold on;
%       histogram(sampleSigmaABaselineArrayP2(sampleSigmaABaselineArrayP2(:, 3) == 50, 6), histBinEdges, 'Normalization', 'probability');
%       histogram(sampleSigmaABaselineArrayP3(sampleSigmaABaselineArrayP3(:, 3) == 50, 6), histBinEdges, 'Normalization', 'probability');
%       hold off;
%       legend('epson850', 'hp2138', 'hp6222');
%       set(gca, 'FontSize', 10, 'FontSmoothing','on');  
%       title('50');
% 
%       subplot(2, 5, 2);
%       histogram(sampleSigmaABaselineArrayP1(sampleSigmaABaselineArrayP1(:, 3) == 70, 6), histBinEdges, 'Normalization', 'probability');
%       hold on;
%       histogram(sampleSigmaABaselineArrayP2(sampleSigmaABaselineArrayP2(:, 3) == 70, 6), histBinEdges, 'Normalization', 'probability');
%       histogram(sampleSigmaABaselineArrayP3(sampleSigmaABaselineArrayP3(:, 3) == 70, 6), histBinEdges, 'Normalization', 'probability');
%       hold off;
%       legend('epson850', 'hp2138', 'hp6222');
%       set(gca, 'FontSize', 10, 'FontSmoothing','on');  
%       title('70');
% 
%       subplot(2, 5, 3);
%       histogram(sampleSigmaABaselineArrayP1(sampleSigmaABaselineArrayP1(:, 3) == 90, 6), histBinEdges, 'Normalization', 'probability');
%       hold on;
%       histogram(sampleSigmaABaselineArrayP2(sampleSigmaABaselineArrayP2(:, 3) == 90, 6), histBinEdges, 'Normalization', 'probability');
%       histogram(sampleSigmaABaselineArrayP3(sampleSigmaABaselineArrayP3(:, 3) == 90, 6), histBinEdges, 'Normalization', 'probability');
%       hold off;
%       legend('epson850', 'hp2138', 'hp6222');
%       set(gca, 'FontSize', 10, 'FontSmoothing','on');  
%       title('90');
% 
%       subplot(2, 5, 4);
%       histogram(sampleSigmaABaselineArrayP1(sampleSigmaABaselineArrayP1(:, 3) == 110, 6), histBinEdges, 'Normalization', 'probability');
%       hold on;
%       histogram(sampleSigmaABaselineArrayP2(sampleSigmaABaselineArrayP2(:, 3) == 110, 6), histBinEdges, 'Normalization', 'probability');
%       histogram(sampleSigmaABaselineArrayP3(sampleSigmaABaselineArrayP3(:, 3) == 110, 6), histBinEdges, 'Normalization', 'probability');
%       hold off;
%       legend('epson850', 'hp2138', 'hp6222');
%       set(gca, 'FontSize', 10, 'FontSmoothing','on');  
%       title('110');
% 
%       subplot(2, 5, 5);
%       histogram(sampleSigmaABaselineArrayP1(sampleSigmaABaselineArrayP1(:, 3) == 130, 6), histBinEdges, 'Normalization', 'probability');
%       hold on;
%       histogram(sampleSigmaABaselineArrayP2(sampleSigmaABaselineArrayP2(:, 3) == 130, 6), histBinEdges, 'Normalization', 'probability');
%       histogram(sampleSigmaABaselineArrayP3(sampleSigmaABaselineArrayP3(:, 3) == 130, 6), histBinEdges, 'Normalization', 'probability');
%       hold off;
%       legend('epson850', 'hp2138', 'hp6222');
%       set(gca, 'FontSize', 10, 'FontSmoothing','on');  
%       title('130');
% 
%       subplot(2, 5, 6);
%       histogram(sampleSigmaABaselineArrayP1(sampleSigmaABaselineArrayP1(:, 3) == 150, 6), histBinEdges, 'Normalization', 'probability');
%       hold on;
%       histogram(sampleSigmaABaselineArrayP2(sampleSigmaABaselineArrayP2(:, 3) == 150, 6), histBinEdges, 'Normalization', 'probability');
%       histogram(sampleSigmaABaselineArrayP3(sampleSigmaABaselineArrayP3(:, 3) == 150, 6), histBinEdges, 'Normalization', 'probability');
%       hold off;
%       legend('epson850', 'hp2138', 'hp6222');
%       set(gca, 'FontSize', 10, 'FontSmoothing','on');  
%       title('150');
% 
%       subplot(2, 5, 7);
%       histogram(sampleSigmaABaselineArrayP1(sampleSigmaABaselineArrayP1(:, 3) == 170, 6), histBinEdges, 'Normalization', 'probability');
%       hold on;
%       histogram(sampleSigmaABaselineArrayP2(sampleSigmaABaselineArrayP2(:, 3) == 170, 6), histBinEdges, 'Normalization', 'probability');
%       histogram(sampleSigmaABaselineArrayP3(sampleSigmaABaselineArrayP3(:, 3) == 170, 6), histBinEdges, 'Normalization', 'probability');
%       hold off;
%       legend('epson850', 'hp2138', 'hp6222');
%       set(gca, 'FontSize', 10, 'FontSmoothing','on');  
%       title('170');
% 
%       subplot(2, 5, 8);
%       histogram(sampleSigmaABaselineArrayP1(sampleSigmaABaselineArrayP1(:, 3) == 190, 6), histBinEdges, 'Normalization', 'probability');
%       hold on;
%       histogram(sampleSigmaABaselineArrayP2(sampleSigmaABaselineArrayP2(:, 3) == 190, 6), histBinEdges, 'Normalization', 'probability');
%       histogram(sampleSigmaABaselineArrayP3(sampleSigmaABaselineArrayP3(:, 3) == 190, 6), histBinEdges, 'Normalization', 'probability');
%       hold off;
%       legend('epson850', 'hp2138', 'hp6222');
%       set(gca, 'FontSize', 10, 'FontSmoothing','on');  
%       title('190');
% 
%       subplot(2, 5, 9);
%       histogram(sampleSigmaABaselineArrayP1(sampleSigmaABaselineArrayP1(:, 3) == 210, 6), histBinEdges, 'Normalization', 'probability');
%       hold on;
%       histogram(sampleSigmaABaselineArrayP2(sampleSigmaABaselineArrayP2(:, 3) == 210, 6), histBinEdges, 'Normalization', 'probability');
%       histogram(sampleSigmaABaselineArrayP3(sampleSigmaABaselineArrayP3(:, 3) == 210, 6), histBinEdges, 'Normalization', 'probability');
%       hold off;
%       legend('epson850', 'hp2138', 'hp6222');
%       set(gca, 'FontSize', 10, 'FontSmoothing','on');  
%       title('210');
% 
%       subplot(2, 5, 10);
%       histogram(sampleSigmaABaselineArrayP1(sampleSigmaABaselineArrayP1(:, 3) == 230, 6), histBinEdges, 'Normalization', 'probability');
%       hold on;
%       histogram(sampleSigmaABaselineArrayP2(sampleSigmaABaselineArrayP2(:, 3) == 230, 6), histBinEdges, 'Normalization', 'probability');
%       histogram(sampleSigmaABaselineArrayP3(sampleSigmaABaselineArrayP3(:, 3) == 230, 6), histBinEdges, 'Normalization', 'probability');
%       hold off;
%       legend('epson850', 'hp2138', 'hp6222');
%       set(gca, 'FontSize', 10, 'FontSmoothing','on');  
%       title('230');
%       
      %% show test image sample sigma a values for different scanners
      
%       sampleSigmaATestArrayP1 = obj.sampleSigmaATestArray(obj.sampleSigmaATestArray(:, 4) == 1, :);
%       sampleSigmaATestArrayP2 = obj.sampleSigmaATestArray(obj.sampleSigmaATestArray(:, 4) == 2, :);
%       sampleSigmaATestArrayP3 = obj.sampleSigmaATestArray(obj.sampleSigmaATestArray(:, 4) == 3, :);
%       
%       figure;
%       histogram(sampleSigmaATestArrayP1(:, 8), histBinEdges, 'Normalization', 'probability');
%       hold on;
%       histogram(sampleSigmaATestArrayP2(:, 8), histBinEdges, 'Normalization', 'probability');
%       histogram(sampleSigmaATestArrayP3(:, 8), histBinEdges, 'Normalization', 'probability');
%       hold off;
%       legend('epson850', 'hp2138', 'hp6222');
%       set(gca, 'FontSize', 15, 'FontSmoothing','on');  
%       set(gcf, 'InnerPosition', [0 0 800 800]);  
%       set(gcf, 'OuterPosition', [0 0 800 800]); 
%       title('test sample sigma a values for different scanners');
    end
    
    %% calculate the t-statistics for the baseline images
    function obj = getTStatBaseLine(obj)
      
      sampleSigmaATempInkjetScannerWidthAccum = [];
      sampleSigmaATempInkjetScannerWidthAccumRot = [];
      
      sampleSigmaATempLaserScannerWidthAccum = [];
      sampleSigmaATempLaserScannerWidthAccumRot = [];

      %% initialize the result arrays: with and without rot
      obj.sampleSigmaABaselineTstatGroupArrayWidth = [];
      obj.sampleSigmaABaselineTstatGroupArrayPrinterWidth = [];
      obj.sampleSigmaABaselineTstatGroupArrayScannerWidth = [];
      obj.sampleSigmaABaselineTstatGroupArrayPrinterScannerWidth = [];
      obj.sampleSigmaABaselineTstatGroupArrayWidthRot = [];
      obj.sampleSigmaABaselineTstatGroupArrayPrinterWidthRot = [];
      obj.sampleSigmaABaselineTstatGroupArrayScannerWidthRot = [];
      obj.sampleSigmaABaselineTstatGroupArrayPrinterScannerWidthRot = [];
    
      obj.sampleHalftoneWidthBaselineGroupArrayWidth = [];
      obj.sampleHalftoneWidthBaselineGroupArrayPrinterWidth = [];
      obj.sampleHalftoneWidthBaselineGroupArrayScannerWidth = [];
      obj.sampleHalftoneWidthBaselineGroupArrayPrinterScannerWidth = [];
      obj.sampleHalftoneWidthBaselineGroupArrayWidthRot = [];
      obj.sampleHalftoneWidthBaselineGroupArrayPrinterWidthRot = [];
      obj.sampleHalftoneWidthBaselineGroupArrayScannerWidthRot = [];
      obj.sampleHalftoneWidthBaselineGroupArrayPrinterScannerWidthRot = [];

      %% initialize the H0 hypothesis
      obj.H0BaselineWidth(isnan(obj.H0BaselineWidth)) = 0;
      obj.H0BaselineWidthRot(isnan(obj.H0BaselineWidth)) = 0;
      obj.H0BaselineWidthPrinter(isnan(obj.H0BaselineWidthPrinter)) = 0;
      obj.H0BaselineWidthPrinterRot(isnan(obj.H0BaselineWidthPrinter)) = 0;
      obj.H0BaselineWidthPrinterScanner(isnan(obj.H0BaselineWidthPrinterScanner)) = 0;
      obj.H0BaselineWidthPrinterScannerRot(isnan(obj.H0BaselineWidthPrinterScanner)) = 0;
      obj.H0BaselineWidthScanner(isnan(obj.H0BaselineWidthScanner)) = 0;
      obj.H0BaselineWidthScannerRot(isnan(obj.H0BaselineWidthScanner)) = 0;
      obj.H0BaselineWidthPrinterTypeScanner(isnan(obj.H0BaselineWidthPrinterTypeScanner)) = 0;
      obj.H0BaselineWidthPrinterTypeScannerRot(isnan(obj.H0BaselineWidthPrinterTypeScannerRot)) = 0;

      %% classify sigma_a samples according to halftone width only
      [~, ~, sampleWidthBaselineArrayBins] = histcounts(obj.sampleHalftoneWidthBaselineArray(:, 6), obj.halfoneMeanWidthEdges);
      sampleWidthBaselineArrayBinsUnique = unique(sampleWidthBaselineArrayBins);
      sampleWidthBaselineArrayBinsUnique(sampleWidthBaselineArrayBinsUnique == 0) = [];
      sampleWidthBaselineArrayWidthUnique = obj.halfoneMeanWidthEdges(sampleWidthBaselineArrayBinsUnique);

      %% iterate through different widths (not used)
      for k = 1:length(sampleWidthBaselineArrayBinsUnique)
        % sigma_a to process with and without rotation
        sampleSigmaATempWidth = ...
          obj.sampleSigmaABaselineArray(sampleWidthBaselineArrayBins == ...
                                       (sampleWidthBaselineArrayBinsUnique(k)) & ...
                                        obj.sampleSigmaABaselineArray(:, 8) == 0, :);
        sampleSigmaATempWidthRot = ...
          obj.sampleSigmaABaselineArray(sampleWidthBaselineArrayBins == ...
                                       (sampleWidthBaselineArrayBinsUnique(k)) & ...
                                        obj.sampleSigmaABaselineArray(:, 8) == 1, :);
        % width to process with and without rotation
        sampleWidthTempWidth = ...
          obj.sampleHalftoneWidthBaselineArray(sampleWidthBaselineArrayBins == ...
                                              (sampleWidthBaselineArrayBinsUnique(k)) & ...
                                               obj.sampleHalftoneWidthBaselineArray(:, 7) == 0, :);
        sampleWidthTempWidthRot = ...
          obj.sampleHalftoneWidthBaselineArray(sampleWidthBaselineArrayBins == ...
                                              (sampleWidthBaselineArrayBinsUnique(k)) & ...
                                               obj.sampleHalftoneWidthBaselineArray(:, 7) == 1, :);
        % the sample is multiple-image blocks constructing a t-statistics
        numSampleData = floor(size(sampleSigmaATempWidth, 1) / obj.sampleSize);
        numSampleDataRot = floor(size(sampleSigmaATempWidthRot, 1) / obj.sampleSize);
        % get the H0 hypothesis based on the width
        if numSampleData >= 1
          obj.H0BaselineWidth(sampleWidthBaselineArrayBinsUnique(k)) = mean(sampleSigmaATempWidth(:, 7));    
        end
        if numSampleDataRot >=1
          obj.H0BaselineWidthRot(sampleWidthBaselineArrayBinsUnique(k)) = mean(sampleSigmaATempWidthRot(:, 7));    
        end

        %% iterate through each data block batch (without rotation)
        for kk = 1:numSampleData
          % extract the sigma_a
          sampleSigmaATempSample = ...
            sampleSigmaATempWidth((obj.sampleSize * (kk - 1) + 1):(kk * obj.sampleSize), :);
					% extract the halftone cell width
          sampleHalftoneWidthTempSample = ...
            sampleWidthTempWidth((obj.sampleSize * (kk - 1) + 1):(kk * obj.sampleSize), :);
          % do t-test
          if obj.H0BaselineWidth(sampleWidthBaselineArrayBinsUnique(k)) ~= 0
            % calculate the single ttest for the first print (optimal values)
            [~, ~, ~, sampleSigmaATstat] = ttest(sampleSigmaATempSample(:, 7), ...
                                                 obj.H0BaselineWidth(sampleWidthBaselineArrayBinsUnique(k)), ...
                                                 'Tail', 'right');
            % collect the tstat data
            obj.sampleSigmaABaselineTstatGroupArrayWidth(end + 1, :) = ...
              [sampleWidthBaselineArrayWidthUnique(k) sampleSigmaATstat.tstat];
            obj.sampleHalftoneWidthBaselineGroupArrayWidth(end + 1, :) = ...
              [sampleWidthBaselineArrayWidthUnique(k) mean(sampleHalftoneWidthTempSample(:, 6))];
          end
        end
        %% iterate through each datablock batch (with rotation)
        for kk = 1:numSampleDataRot
          % extract the sigma_a
          sampleSigmaATempSampleRot = sampleSigmaATempWidthRot((obj.sampleSize * (kk - 1) + 1):(kk * obj.sampleSize), :);
          % extract the halftone cell width
          sampleHalftoneWidthTempSampleRot = ...
            sampleWidthTempWidthRot((obj.sampleSize * (kk - 1) + 1):(kk * obj.sampleSize), :);
          % calculate t-stat of baseline images
          if obj.H0BaselineWidthRot(sampleWidthBaselineArrayBinsUnique(k)) ~= 0
            % calculate the single ttest for the first print (optimal values)
            [~, ~, ~, sampleSigmaATstatRot] = ttest(sampleSigmaATempSampleRot(:, 7), ...
                                                    obj.H0BaselineWidthRot(sampleWidthBaselineArrayBinsUnique(k)), ...
                                                    'Tail', 'right');
            % collect the tstat data
            obj.sampleSigmaABaselineTstatGroupArrayWidthRot(end + 1, :) = ...
                [sampleWidthBaselineArrayWidthUnique(k) sampleSigmaATstatRot.tstat];

            obj.sampleHalftoneWidthBaselineGroupArrayWidthRot(end + 1, :) = ...
                [sampleWidthBaselineArrayWidthUnique(k) mean(sampleHalftoneWidthTempSampleRot(:, 6))];
          end
        end
      end
      %% for each printer
      printerIdxList = [1 3 4];
      scannerIdxList = [1 2 3];
      for i = 1:length(printerIdxList)
        % extract sigma_a w.r.t to printers
        sampleSigmaABaselineArrayPrinter = obj.sampleSigmaABaselineArray(obj.sampleSigmaABaselineArray(:, 1) == printerIdxList(i), :);  	
				% extract width w.r.t to printers
        sampleWidthBaselineArrayPrinter = ...
          obj.sampleHalftoneWidthBaselineArray(obj.sampleHalftoneWidthBaselineArray(:, 1) == printerIdxList(i), :);  
				% histcount the width
        [~, ~, sampleWidthBaselineArrayPrinterBins] = histcounts(sampleWidthBaselineArrayPrinter(:, 6), obj.halfoneMeanWidthEdges);
        sampleWidthBaselineArrayPrinterBinsUnique = unique(sampleWidthBaselineArrayPrinterBins);
        sampleWidthBaselineArrayPrinterBinsUnique(sampleWidthBaselineArrayPrinterBinsUnique == 0) = [];
        sampleWidthBaselineArrayPrinterWidthUnique = obj.halfoneMeanWidthEdges(sampleWidthBaselineArrayPrinterBinsUnique);

				% for different halftone cell width
        for k = 1:length(sampleWidthBaselineArrayPrinterBinsUnique)
					% extract sigma_a with and without rot
          sampleSigmaATempPrinterWidth = ...
            sampleSigmaABaselineArrayPrinter(sampleWidthBaselineArrayPrinterBins == ...
                                            (sampleWidthBaselineArrayPrinterBinsUnique(k)) & ...
																						 sampleSigmaABaselineArrayPrinter(:, 8) == 0, :);
					sampleSigmaATempPrinterWidthRot = ...
            sampleSigmaABaselineArrayPrinter(sampleWidthBaselineArrayPrinterBins == ...
                                            (sampleWidthBaselineArrayPrinterBinsUnique(k)) & ...
																						 sampleSigmaABaselineArrayPrinter(:, 8) == 1, :);
          % extract halftone cell width with and without rot                                         
          sampleWidthATempPrinterWidth = ...
            sampleWidthBaselineArrayPrinter(sampleWidthBaselineArrayPrinterBins == ...
                                            (sampleWidthBaselineArrayPrinterBinsUnique(k)) & ...
																						 sampleWidthBaselineArrayPrinter(:, 7) == 0, :);
					sampleWidthATempPrinterWidthRot = ...
            sampleWidthBaselineArrayPrinter(sampleWidthBaselineArrayPrinterBins == ...
                                            (sampleWidthBaselineArrayPrinterBinsUnique(k)) & ...
																						 sampleWidthBaselineArrayPrinter(:, 7) == 1, :);
          % the sample is multiple-image blocks constructing a t-statistics
          numSampleData = floor(size(sampleSigmaATempPrinterWidth, 1) / obj.sampleSize);
          numSampleDataRot = floor(size(sampleSigmaATempPrinterWidthRot, 1) / obj.sampleSize);
					% get H0 from with and without rot
          if numSampleData >= 1
            obj.H0BaselineWidthPrinter(...
              printerIdxList(i), ...
              sampleWidthBaselineArrayPrinterBinsUnique(k)) = mean(sampleSigmaATempPrinterWidth(:, 7));
          end
					if numSampleDataRot >= 1
            obj.H0BaselineWidthPrinterRot(...
              printerIdxList(i), ...
              sampleWidthBaselineArrayPrinterBinsUnique(k)) = mean(sampleSigmaATempPrinterWidth(:, 7));
          end
          % iterate through each datablock batch (without rot)
          for kk = 1:numSampleData
            % extract the sigma_a
            sampleSigmaATempSample = sampleSigmaATempPrinterWidth((obj.sampleSize * (kk - 1) + 1):(kk * obj.sampleSize), :);
						% extract the halftone cell width
            sampleHalftoneWidthTempSample = sampleWidthATempPrinterWidth((obj.sampleSize * (kk - 1) + 1):(kk * obj.sampleSize), :);
						% if H0 exists
            if obj.H0BaselineWidthPrinter(...
                printerIdxList(i), sampleWidthBaselineArrayPrinterBinsUnique(k)) ~= 0
              try
                 % calculate the single ttest for the first print (sample values)
                  [~, ~, ~, sampleSigmaATstat] = ...
                    ttest(sampleSigmaATempSample(:, 7), ...
                          real(obj.H0BaselineWidthPrinter(...
                               printerIdxList(i), sampleWidthBaselineArrayPrinterBinsUnique(k))), ...
                               'Tail', 'right');
              catch
                disp('debug');
              end
              % collect the tstat data
              obj.sampleSigmaABaselineTstatGroupArrayPrinterWidth(end + 1, :) = ...
                  [printerIdxList(i) sampleWidthBaselineArrayPrinterWidthUnique(k) sampleSigmaATstat.tstat];
							% collect the mean halftone cell width
              obj.sampleHalftoneWidthBaselineGroupArrayPrinterWidth(end + 1, :) = ...
                [printerIdxList(i) ...
                 sampleWidthBaselineArrayPrinterWidthUnique(k) ...
                 mean(sampleHalftoneWidthTempSample(:, 6))];
            end
          end
					% iterate through each datablock batch (with rot)
          for kk = 1:numSampleDataRot
            % extract the sigma_a
            sampleSigmaATempSampleRot = ...
              sampleSigmaATempPrinterWidthRot((obj.sampleSize * (kk - 1) + 1):(kk * obj.sampleSize), :);
						% extract the halftone cell width
            sampleHalftoneWidthTempSampleRot = ...
              sampleWidthATempPrinterWidthRot((obj.sampleSize * (kk - 1) + 1):(kk * obj.sampleSize), :);
						% if H0 exists
            if obj.H0BaselineWidthPrinterRot(...
                printerIdxList(i), ...
                sampleWidthBaselineArrayPrinterBinsUnique(k)) ~= 0
              try
                % calculate the single ttest for the first print (sample values)
                [~, ~, ~, sampleSigmaATstatRot] = ...
                  ttest(sampleSigmaATempSampleRot(:, 7), ...
                        real(obj.H0BaselineWidthPrinterRot(...
                           printerIdxList(i), sampleWidthBaselineArrayPrinterBinsUnique(k))), 'Tail', 'right');
              catch
                disp('debug');
              end
              % collect the tstat data
              obj.sampleSigmaABaselineTstatGroupArrayPrinterWidthRot(end + 1, :) = ...
                  [printerIdxList(i) ...
                   sampleWidthBaselineArrayPrinterWidthUnique(k) ...
                   sampleSigmaATstatRot.tstat];
							% collect the mean halftone cell width
              obj.sampleHalftoneWidthBaselineGroupArrayPrinterWidthRot(end + 1, :) = ...
                  [printerIdxList(i) ...
                   sampleWidthBaselineArrayPrinterWidthUnique(k) ...
                   mean(sampleHalftoneWidthTempSampleRot(:, 6))];
            end
          end
        end
        %% for each printer/scanner pair
        for j = 1:length(scannerIdxList)
          % extract sigma_a
          sampleSigmaABaselineArrayPrinterScanner = ...
            sampleSigmaABaselineArrayPrinter(sampleSigmaABaselineArrayPrinter(:, 2) == scannerIdxList(j), :);
					% extract halftone cell width
          sampleWidthBaselineArrayPrinterScanner = ...
            sampleWidthBaselineArrayPrinter(sampleWidthBaselineArrayPrinter(:, 2) == scannerIdxList(j), :);
          % histcount the width
          [~, ~, sampleWidthBaselineArrayPrinterScannerBins] = histcounts(sampleWidthBaselineArrayPrinterScanner(:, 6), obj.halfoneMeanWidthEdges);
          sampleWidthBaselineArrayPrinterScannerBinsUnique = unique(sampleWidthBaselineArrayPrinterScannerBins);
          sampleWidthBaselineArrayPrinterScannerBinsUnique(sampleWidthBaselineArrayPrinterScannerBinsUnique == 0) = [];
          sampleWidthBaselineArrayPrinterScannerWidthUnique = obj.halfoneMeanWidthEdges(sampleWidthBaselineArrayPrinterScannerBinsUnique);
          % iterate through halftone width bins
          for k = 1:length(sampleWidthBaselineArrayPrinterScannerBinsUnique)
            % extract the sigma_a with and without rotation
            sampleSigmaATempPrinterScannerWidth = ...
              sampleSigmaABaselineArrayPrinterScanner(...
								(sampleWidthBaselineArrayPrinterScannerBins == (sampleWidthBaselineArrayPrinterScannerBinsUnique(k))) & ...
								(sampleSigmaABaselineArrayPrinterScanner(:, 8) == 0), :);
						sampleSigmaATempPrinterScannerWidthRot = ...
              sampleSigmaABaselineArrayPrinterScanner(...
								(sampleWidthBaselineArrayPrinterScannerBins == (sampleWidthBaselineArrayPrinterScannerBinsUnique(k))) & ...
								(sampleSigmaABaselineArrayPrinterScanner(:, 8) == 1), :);
						% extract the halftone cell width with and without rotation
            sampleWidthTempPrinterScannerWidth = ...
              sampleWidthBaselineArrayPrinterScanner(...
                (sampleWidthBaselineArrayPrinterScannerBins == (sampleWidthBaselineArrayPrinterScannerBinsUnique(k))) & ...
								(sampleWidthBaselineArrayPrinterScanner(:, 7) == 0), :);
						sampleWidthTempPrinterScannerWidthRot = ...
              sampleWidthBaselineArrayPrinterScanner(...
                (sampleWidthBaselineArrayPrinterScannerBins == (sampleWidthBaselineArrayPrinterScannerBinsUnique(k))) & ...
								(sampleWidthBaselineArrayPrinterScanner(:, 7) == 1), :);
              
%             if sampleWidthBaselineArrayPrinterScannerBinsUnique(k) == 12 && printerIdxList(i) == 4 && scannerIdxList(j) == 1
%                 disp([num2str(printerIdxList(i)) ' ' num2str(scannerIdxList(j)) ' ' ...
%                       num2str(sampleSigmaATstat.tstat) ' ' ...
%                       num2str(obj.H0BaselineWidthPrinterScanner(...
%                               printerIdxList(i), scannerIdxList(j), sampleWidthBaselineArrayPrinterScannerBinsUnique(k))) ' ' ...
%                       num2str(sampleWidthBaselineArrayPrinterScannerBinsUnique(k))]);
%                 disp('debug');
%             end
            
%             if sampleSigmaATstat.tstat > 10 && printerIdxList(i) == 4
%               disp([num2str(printerIdxList(i)) ' ' num2str(scannerIdxList(j)) ' '...
%                     num2str(sampleWidthTestArrayPrinterScannerBinsUnique(k)) ' '...
%                     num2str(sampleSigmaATstat.tstat) ' '...
%                     num2str(obj.H0BaselineWidthPrinterScanner(...
%                             printerIdxList(i), scannerIdxList(j), sampleWidthTestArrayPrinterScannerBinsUnique(k))) ' ' ...
%                     num2str(sampleWidthTestArrayPrinterScannerBinsUnique(k))]);
%               disp('abnormal' );
%             end

            % the sample is multiple-image blocks constructing a t-statistics
            numSampleData = floor(size(sampleWidthTempPrinterScannerWidth, 1) / obj.sampleSize);
						numSampleDataRot = floor(size(sampleWidthTempPrinterScannerWidthRot, 1) / obj.sampleSize);
						% obtain H0 hypothesis without rot
            if numSampleData >= 1
              obj.H0BaselineWidthPrinterScanner(...
                printerIdxList(i), ...
                scannerIdxList(j), ...
                sampleWidthBaselineArrayPrinterScannerBinsUnique(k)) = mean(sampleSigmaATempPrinterScannerWidth(:, 7));  
              obj.H0VarBaselineWidthPrinterScanner(...
                printerIdxList(i), ...
                scannerIdxList(j), ...
                sampleWidthBaselineArrayPrinterScannerBinsUnique(k)) = var(sampleSigmaATempPrinterScannerWidth(:, 7));  
                % collect the inkjet printers results
                if printerIdxList(i) < 4
                  sampleSigmaATempInkjetScannerWidthAccum = ...
                    [sampleSigmaATempInkjetScannerWidthAccum; ...
                     [scannerIdxList(j) * ones(length(sampleSigmaATempPrinterScannerWidth(:, 7)), 1) ...
                      sampleWidthBaselineArrayPrinterScannerBinsUnique(k) * ones(length(sampleSigmaATempPrinterScannerWidth(:, 7)), 1) ...
                      sampleSigmaATempPrinterScannerWidth(:, 7)]];
                % collect the laser printers result
                else
                  sampleSigmaATempLaserScannerWidthAccum = ...
                    [sampleSigmaATempLaserScannerWidthAccum;  ...
                     [scannerIdxList(j) * ones(length(sampleSigmaATempPrinterScannerWidth(:, 7)), 1) ...
                      sampleWidthBaselineArrayPrinterScannerBinsUnique(k) * ones(length(sampleSigmaATempPrinterScannerWidth(:, 7)), 1) ...
                      sampleSigmaATempPrinterScannerWidth(:, 7)]];
                end
            end 
            % obtain H0 hypothesis with rot
						if numSampleDataRot >= 1
              obj.H0BaselineWidthPrinterScannerRot(...
                printerIdxList(i), ...
                scannerIdxList(j), ...
                sampleWidthBaselineArrayPrinterScannerBinsUnique(k)) = mean(sampleSigmaATempPrinterScannerWidthRot(:, 7)); 
              obj.H0VarBaselineWidthPrinterScannerRot(...
                printerIdxList(i), ...
                scannerIdxList(j), ...
                sampleWidthBaselineArrayPrinterScannerBinsUnique(k)) = var(sampleSigmaATempPrinterScannerWidthRot(:, 7)); 
              if printerIdxList(i) < 4
                sampleSigmaATempInkjetScannerWidthAccumRot = ...
                  [sampleSigmaATempInkjetScannerWidthAccumRot; ...
                  [scannerIdxList(j) * ones(length(sampleSigmaATempPrinterScannerWidthRot(:, 7)), 1) ...
                   sampleWidthBaselineArrayPrinterScannerBinsUnique(k) * ones(length(sampleSigmaATempPrinterScannerWidthRot(:, 7)), 1) ...
                   sampleSigmaATempPrinterScannerWidthRot(:, 7)]];
              else
                sampleSigmaATempLaserScannerWidthAccumRot = ...
                  [sampleSigmaATempLaserScannerWidthAccumRot;  ...
                   [scannerIdxList(j) * ones(length(sampleSigmaATempPrinterScannerWidthRot(:, 7)), 1) ...
                    sampleWidthBaselineArrayPrinterScannerBinsUnique(k) * ones(length(sampleSigmaATempPrinterScannerWidthRot(:, 7)), 1) ...
                    sampleSigmaATempPrinterScannerWidthRot(:, 7)]];
              end
            end
            %% iterate through each datablock batch without rot
            for kk = 1:numSampleData
              % extract the sigma_a
              sampleSigmaATempSample = sampleSigmaATempPrinterScannerWidth((obj.sampleSize * (kk - 1) + 1):(kk * obj.sampleSize), :);
							% extract the halftone cell width
              sampleHalftoneWidthTempSample = sampleWidthTempPrinterScannerWidth((obj.sampleSize * (kk - 1) + 1):(kk * obj.sampleSize), :);
							% if there is H0 hypothesis
              if obj.H0BaselineWidthPrinterScanner(printerIdxList(i), ...
                                                   scannerIdxList(j), ...
                                                   sampleWidthBaselineArrayPrinterScannerBinsUnique(k)) ~= 0
                % calculate the ttest
                [~, ~, ~, sampleSigmaATstat] = ...
                  ttest(sampleSigmaATempSample(:, 7), ...
                        obj.H0BaselineWidthPrinterScanner(...
                            printerIdxList(i), ...
                            scannerIdxList(j), ...
                            sampleWidthBaselineArrayPrinterScannerBinsUnique(k)), 'Tail', 'right');
                          
                % collect the tstat data
                obj.sampleSigmaABaselineTstatGroupArrayPrinterScannerWidth(end + 1, :) = ...
                    [printerIdxList(i) scannerIdxList(j) sampleWidthBaselineArrayPrinterScannerWidthUnique(k) sampleSigmaATstat.tstat];
								% collect the mean of the halftone cell width
                obj.sampleHalftoneWidthBaselineGroupArrayPrinterScannerWidth(end + 1, :) = ...
                    [printerIdxList(i) scannerIdxList(j) ...
                      sampleWidthBaselineArrayPrinterScannerWidthUnique(k) mean(sampleHalftoneWidthTempSample(:, 6))];
              end
            end
						%% iterate through each datablock batch with rot
            for kk = 1:numSampleDataRot
              % extract the sigma_a
              sampleSigmaATempSampleRot = ...
                sampleSigmaATempPrinterScannerWidthRot((obj.sampleSize * (kk - 1) + 1):(kk * obj.sampleSize), :);
							% extract the halftone cell width
              sampleHalftoneWidthTempSampleRot = ...
                sampleWidthTempPrinterScannerWidthRot((obj.sampleSize * (kk - 1) + 1):(kk * obj.sampleSize), :);
							% if there is H0 hypothesis
              if obj.H0BaselineWidthPrinterScannerRot(...
                          printerIdxList(i), ...
                          scannerIdxList(j), ...
                          sampleWidthBaselineArrayPrinterScannerBinsUnique(k)) ~= 0
                % calculate the ttest 
                [~, ~, ~, sampleSigmaATstatRot] = ...
                  ttest(sampleSigmaATempSampleRot(:, 7), ...
                        obj.H0BaselineWidthPrinterScannerRot(...
                            printerIdxList(i), ...
                            scannerIdxList(j), ...
                            sampleWidthBaselineArrayPrinterScannerBinsUnique(k)), 'Tail', 'right');
                % collect the tstat data
                obj.sampleSigmaABaselineTstatGroupArrayPrinterScannerWidthRot(end + 1, :) = ...
                    [printerIdxList(i) scannerIdxList(j) ...
											sampleWidthBaselineArrayPrinterScannerWidthUnique(k) sampleSigmaATstatRot.tstat];
								% collect the mean of the halftone cell width
                obj.sampleHalftoneWidthBaselineGroupArrayPrinterScannerWidthRot(end + 1, :) = ...
                    [printerIdxList(i) scannerIdxList(j) ...
											sampleWidthBaselineArrayPrinterScannerWidthUnique(k) mean(sampleHalftoneWidthTempSampleRot(:, 6))];
              end
            end
          end
        end
      end
      %% for each scanner, prepare the H0 for the semi-controlled experiments
      for j = 1:length(scannerIdxList)
        for k = 1:length(obj.halfoneMeanWidthEdges)
          % calculate H0 for inkjet printers without rotation
          temp = sampleSigmaATempInkjetScannerWidthAccum(...
                  (sampleSigmaATempInkjetScannerWidthAccum(:, 1) == scannerIdxList(j)) & ...
                  (sampleSigmaATempInkjetScannerWidthAccum(:, 2) == k), 3); 
          if ~isempty(temp)
            obj.H0BaselineWidthPrinterTypeScanner(1, scannerIdxList(j), k) = mean(temp);
            obj.H0VarBaselineWidthPrinterTypeScanner(1, scannerIdxList(j), k) = var(temp);
          end
          % calculate H0 for inkjet printers with rotation
          temp = sampleSigmaATempInkjetScannerWidthAccumRot(...
                  (sampleSigmaATempInkjetScannerWidthAccumRot(:, 1) == scannerIdxList(j)) & ...
                  (sampleSigmaATempInkjetScannerWidthAccumRot(:, 2) == k), 3); 
          if ~isempty(temp)
            obj.H0BaselineWidthPrinterTypeScannerRot(1, scannerIdxList(j), k) = mean(temp);
            obj.H0VarBaselineWidthPrinterTypeScannerRot(1, scannerIdxList(j), k) = var(temp);
          end
          % calculate H0 for laser printers without rotation
          temp = sampleSigmaATempLaserScannerWidthAccum(...
                  (sampleSigmaATempLaserScannerWidthAccum(:, 1) == scannerIdxList(j)) & ...
                  (sampleSigmaATempLaserScannerWidthAccum(:, 2) == k), 3);
          if ~isempty(temp)
            obj.H0BaselineWidthPrinterTypeScanner(2, scannerIdxList(j), k) = mean(temp);
            obj.H0VarBaselineWidthPrinterTypeScanner(2, scannerIdxList(j), k) = var(temp);
          end
          % calculate H0 for laser printers with rotation
          temp = sampleSigmaATempLaserScannerWidthAccumRot(...
                  (sampleSigmaATempLaserScannerWidthAccumRot(:, 1) == scannerIdxList(j)) & ...
                  (sampleSigmaATempLaserScannerWidthAccumRot(:, 2) == k), 3);
          if ~isempty(temp)
            obj.H0BaselineWidthPrinterTypeScannerRot(2, scannerIdxList(j), k) = mean(temp);
            obj.H0VarBaselineWidthPrinterTypeScannerRot(2, scannerIdxList(j), k) = var(temp);
          end
        end
      end
      %% for each scanner, calculate the H0 and the t-stat (for realistic test)
      for j = 1:length(scannerIdxList)
        % extract sigma_a 
        sampleSigmaABaselineArrayScanner = obj.sampleSigmaABaselineArray(obj.sampleSigmaABaselineArray(:, 2) == scannerIdxList(j), :);  
				% extract halftone cell width
        sampleWidthBaselineArrayScanner = obj.sampleHalftoneWidthBaselineArray(obj.sampleHalftoneWidthBaselineArray(:, 2) == scannerIdxList(j), :);  
        % histcount the cell with
        [~, ~, sampleWidthBaselineArrayScannerBins] = histcounts(sampleWidthBaselineArrayScanner(:, 6), obj.halfoneMeanWidthEdges);
        sampleWidthBaselineArrayScannerBinsUnique = unique(sampleWidthBaselineArrayScannerBins);
        sampleWidthBaselineArrayScannerBinsUnique(sampleWidthBaselineArrayScannerBinsUnique == 0) = [];
        sampleWidthBaselineArrayScannerWidthUnique = obj.halfoneMeanWidthEdges(sampleWidthBaselineArrayScannerBinsUnique);
        % iterate through halftone width
        for k = 1:length(sampleWidthBaselineArrayScannerBinsUnique)
          % extract the sigma a with and without rot
          sampleSigmaATempScannerWidth = ...
            sampleSigmaABaselineArrayScanner(...
              (sampleWidthBaselineArrayScannerBins == (sampleWidthBaselineArrayScannerBinsUnique(k))) & ...
							(sampleSigmaABaselineArrayScanner(:, 8) == 0), :);
          sampleSigmaATempScannerWidthRot = ...
            sampleSigmaABaselineArrayScanner(...
              (sampleWidthBaselineArrayScannerBins == (sampleWidthBaselineArrayScannerBinsUnique(k))) & ...
							(sampleSigmaABaselineArrayScanner(:, 8) == 1), :);
					% extract the halftone cell width with and without rot		
          sampleWidthTempScannerWidth = ...
              sampleWidthBaselineArrayScanner(...
							(sampleWidthBaselineArrayScannerBins == (sampleWidthBaselineArrayScannerBinsUnique(k))) & ...
							(sampleWidthBaselineArrayScanner(:, 7) == 0), :);
					sampleWidthTempScannerWidthRot = ...
              sampleWidthBaselineArrayScanner(...
							(sampleWidthBaselineArrayScannerBins == (sampleWidthBaselineArrayScannerBinsUnique(k))) & ...
							(sampleWidthBaselineArrayScanner(:, 7) == 1), :);
          % the sample is multiple-image blocks constructing a t-statistics
          numSampleData = floor(size(sampleWidthTempScannerWidth, 1) / obj.sampleSize);
          numSampleDataRot = floor(size(sampleWidthTempScannerWidthRot, 1) / obj.sampleSize);
					% assign H0 with and without rotation
          if numSampleData >= 1
            obj.H0BaselineWidthScanner(scannerIdxList(j), sampleWidthBaselineArrayScannerBinsUnique(k)) = ...
              mean(sampleSigmaATempScannerWidth(:, 7));
            obj.H0VarBaselineWidthScanner(scannerIdxList(j), sampleWidthBaselineArrayScannerBinsUnique(k)) = ...
              var(sampleSigmaATempScannerWidth(:, 7));
          end
					if numSampleDataRot >= 1
            obj.H0BaselineWidthScannerRot(scannerIdxList(j), sampleWidthBaselineArrayScannerBinsUnique(k)) = ...
              mean(sampleSigmaATempScannerWidthRot(:, 7));  
            obj.H0VarBaselineWidthScannerRot(scannerIdxList(j), sampleWidthBaselineArrayScannerBinsUnique(k)) = ...
              var(sampleSigmaATempScannerWidthRot(:, 7));  
          end
          %% iterate through each datablock batch
          for kk = 1:numSampleData
            % extract the sigma_a samples
            sampleSigmaATempSample = sampleSigmaATempScannerWidth((obj.sampleSize * (kk - 1) + 1):(kk * obj.sampleSize), :);
						% extract the halftone cell width samples
            sampleHalftoneWidthTempSample = sampleWidthTempScannerWidth((obj.sampleSize * (kk - 1) + 1):(kk * obj.sampleSize), :);
						% if there is H0
            if obj.H0BaselineWidthScanner(scannerIdxList(j), sampleWidthBaselineArrayScannerBinsUnique(k)) ~= 0
              % calculate the single ttest for the first print (sample values)
              [~, ~, ~, sampleSigmaATstat] = ...
                ttest(sampleSigmaATempSample(:, 7), ...
                      obj.H0BaselineWidthScanner(scannerIdxList(j), sampleWidthBaselineArrayScannerBinsUnique(k)), 'Tail', 'right');
              % collect the tstat data
              obj.sampleSigmaABaselineTstatGroupArrayScannerWidth(end + 1, :) = ...
                  [scannerIdxList(j) sampleWidthBaselineArrayScannerWidthUnique(k) sampleSigmaATstat.tstat];
							% collect the halftone cell width data
              obj.sampleHalftoneWidthBaselineGroupArrayScannerWidth(end + 1, :) = ...
                  [scannerIdxList(j) sampleWidthBaselineArrayScannerWidthUnique(k) mean(sampleHalftoneWidthTempSample(:, 6))];
            end
          end
					%% iterate through each datablock batch rot
          for kk = 1:numSampleDataRot
            % extract the sigma_a samples
            sampleSigmaATempSampleRot = sampleSigmaATempScannerWidthRot((obj.sampleSize * (kk - 1) + 1):(kk * obj.sampleSize), :);
						% extract the halftone cell width samples
            sampleHalftoneWidthTempSampleRot = sampleWidthTempScannerWidthRot((obj.sampleSize * (kk - 1) + 1):(kk * obj.sampleSize), :);
						% if there is H0
            if obj.H0BaselineWidthScannerRot(scannerIdxList(j), sampleWidthBaselineArrayScannerBinsUnique(k)) ~= 0
              % calculate the single ttest for the first print (sample values)
              [~, ~, ~, sampleSigmaATstatRot] = ...
                ttest(sampleSigmaATempSampleRot(:, 7), ...
                      obj.H0BaselineWidthScannerRot(scannerIdxList(j), sampleWidthBaselineArrayScannerBinsUnique(k)), 'Tail', 'right');
              % collect the tstat data
              obj.sampleSigmaABaselineTstatGroupArrayScannerWidthRot(end + 1, :) = ...
                  [scannerIdxList(j) sampleWidthBaselineArrayScannerWidthUnique(k) sampleSigmaATstatRot.tstat];
							% collect the halftone cell width data
              obj.sampleHalftoneWidthBaselineGroupArrayScannerWidthRot(end + 1, :) = ...
                  [scannerIdxList(j) sampleWidthBaselineArrayScannerWidthUnique(k) mean(sampleHalftoneWidthTempSampleRot(:, 6))];
            end
          end
        end
      end
    end
    
    %% calculate the t-statistics for the test images
    function obj = getTStatTest(obj)
      
      %% initialize the result arrays (with and without rot)
      obj.sampleSigmaATestTstatGroupArrayWidth = [];
      obj.sampleSigmaATestTstatGroupArrayPrinterWidth = [];
      obj.sampleSigmaATestTstatGroupArrayScannerWidth = [];
      obj.sampleSigmaATestTstatGroupArrayPrinterScannerWidth = [];
			obj.sampleSigmaATestTstatGroupArrayWidthRot = [];
      obj.sampleSigmaATestTstatGroupArrayPrinterWidthRot = [];
      obj.sampleSigmaATestTstatGroupArrayScannerWidthRot = [];
      obj.sampleSigmaATestTstatGroupArrayPrinterScannerWidthRot = [];
      
      obj.sampleHalftoneWidthTestGroupArrayWidth = [];
      obj.sampleHalftoneWidthTestGroupArrayPrinterWidth = [];
      obj.sampleHalftoneWidthTestGroupArrayScannerWidth = [];
      obj.sampleHalftoneWidthTestGroupArrayPrinterScannerWidth = [];
			obj.sampleHalftoneWidthTestGroupArrayWidthRot = [];
      obj.sampleHalftoneWidthTestGroupArrayPrinterWidthRot = [];
      obj.sampleHalftoneWidthTestGroupArrayScannerWidthRot = [];
      obj.sampleHalftoneWidthTestGroupArrayPrinterScannerWidthRot = [];
      %% classify sigma_a w.r.t width only
      [~, ~, sampleWidthTestArrayBins] = histcounts(obj.sampleHalftoneWidthTestArray(:, 7), obj.halfoneMeanWidthEdges);
      sampleWidthTestArrayBinsUnique = unique(sampleWidthTestArrayBins);
      sampleWidthTestArrayBinsUnique(sampleWidthTestArrayBinsUnique == 0) = [];
      sampleWidthTestArrayWidthUnique = obj.halfoneMeanWidthEdges(sampleWidthTestArrayBinsUnique);
      %% for different widths (not used)
      for k = 1:length(sampleWidthTestArrayBinsUnique)
        %% get sigma_a with and without rot
        sampleSigmaATempWidth = obj.sampleSigmaATestArray(sampleWidthTestArrayBins == (sampleWidthTestArrayBinsUnique(k)) & ...
                                                          obj.sampleSigmaATestArray(:, 9) == 0, :);
        sampleSigmaATempWidthRot = obj.sampleSigmaATestArray(sampleWidthTestArrayBins == (sampleWidthTestArrayBinsUnique(k)) & ...
                                                             obj.sampleSigmaATestArray(:, 9) == 1, :);
        %% get halftone cell width with and without rot
        sampleWidthTempWidth = obj.sampleHalftoneWidthTestArray(sampleWidthTestArrayBins == (sampleWidthTestArrayBinsUnique(k))& ...
                                                                obj.sampleHalftoneWidthTestArray(:, 8) == 0, :);
        sampleWidthTempWidthRot = obj.sampleHalftoneWidthTestArray(sampleWidthTestArrayBins == (sampleWidthTestArrayBinsUnique(k)) & ...
                                                                   obj.sampleHalftoneWidthTestArray(:, 8) == 1, :);
        % the number of sample for t-test with and without rot
        numSampleData = floor(size(sampleSigmaATempWidth, 1) / obj.sampleSize);
        numSampleDataRot = floor(size(sampleSigmaATempWidthRot, 1) / obj.sampleSize);
        % iterate through each datablock batch without rot
        for kk = 1:numSampleData
          % extract the sigma_a
          sampleSigmaATempSample = sampleSigmaATempWidth((obj.sampleSize * (kk - 1) + 1):(kk * obj.sampleSize), :);
          % extract the halftone cell width
          sampleHalftoneWidthTempSample = sampleWidthTempWidth((obj.sampleSize * (kk - 1) + 1):(kk * obj.sampleSize), :);
          % calculate the ttest
          if obj.H0BaselineWidth(sampleWidthTestArrayBinsUnique(k)) ~= 0
            % calculate the t-stat
            [~, ~, ~, sampleSigmaATstat] = ttest(sampleSigmaATempSample(:, 8), ...
                                                 obj.H0BaselineWidth(sampleWidthTestArrayBinsUnique(k)), 'Tail', 'right');
            % collect the tstat data
            obj.sampleSigmaATestTstatGroupArrayWidth(end + 1, :) = ...
              [sampleWidthTestArrayWidthUnique(k) sampleSigmaATstat.tstat];
            % collect the halftone cell width data
            obj.sampleHalftoneWidthTestGroupArrayWidth(end + 1, :) = ...
              [sampleWidthTestArrayWidthUnique(k) mean(sampleHalftoneWidthTempSample(:, 7))];
          end
        end
        % iterate through each datablock batch with rot
        for kk = 1:numSampleDataRot
          % extract the sigma_a
          sampleSigmaATempSampleRot = sampleSigmaATempWidthRot((obj.sampleSize * (kk - 1) + 1):(kk * obj.sampleSize), :);
          % extract the halftone cell width
          sampleHalftoneWidthTempSampleRot = sampleWidthTempWidthRot((obj.sampleSize * (kk - 1) + 1):(kk * obj.sampleSize), :);
          % calculate the ttest
          if obj.H0BaselineWidthRot(sampleWidthTestArrayBinsUnique(k)) ~= 0
            % calculate the t-stat
            [~, ~, ~, sampleSigmaATstatRot] = ...
              ttest(sampleSigmaATempSampleRot(:, 8), obj.H0BaselineWidthRot(sampleWidthTestArrayBinsUnique(k)), 'Tail', 'right');
            % collect the tstat data
            obj.sampleSigmaATestTstatGroupArrayWidthRot(end + 1, :) = ...
                [sampleWidthTestArrayWidthUnique(k) sampleSigmaATstatRot.tstat];
            % collect the halftone cell width data
            obj.sampleHalftoneWidthTestGroupArrayWidthRot(end + 1, :) = ...
                [sampleWidthTestArrayWidthUnique(k) mean(sampleHalftoneWidthTempSampleRot(:, 7))];
          end
        end
      end
      %% classify sigma_a w.r.t width and printers
      printerIdxList = [1 3 4 5 6 8 9 10 11];
      scannerIdxList = [1 2 3];
      for i = 1:length(printerIdxList)
        % get sigma_a w.r.t printers
        sampleSigmaATestArrayPrinter = obj.sampleSigmaATestArray(obj.sampleSigmaATestArray(:, 1) == printerIdxList(i), :);  
        % halftone cell width w.r.t printers
        sampleWidthTestArrayPrinter = obj.sampleHalftoneWidthTestArray(obj.sampleHalftoneWidthTestArray(:, 1) == printerIdxList(i), :);  
        % group the halftone cell widths
        [~, ~, sampleWidthTestArrayPrinterBins] = histcounts(sampleWidthTestArrayPrinter(:, 7), obj.halfoneMeanWidthEdges);
        sampleWidthTestArrayPrinterBinsUnique = unique(sampleWidthTestArrayPrinterBins);
        sampleWidthTestArrayPrinterBinsUnique(sampleWidthTestArrayPrinterBinsUnique == 0) = [];
        sampleWidthTestArrayPrinterWidthUnique = obj.halfoneMeanWidthEdges(sampleWidthTestArrayPrinterBinsUnique);
				% itearate through the width bins
        for k = 1:length(sampleWidthTestArrayPrinterBinsUnique)
          % extract the sigma_a with and without rot
          sampleSigmaATempPrinterWidth = ...
            sampleSigmaATestArrayPrinter(sampleWidthTestArrayPrinterBins == (sampleWidthTestArrayPrinterBinsUnique(k)) & ...
                                         sampleSigmaATestArrayPrinter(:, 9) == 0, :);
          sampleSigmaATempPrinterWidthRot = ...
            sampleSigmaATestArrayPrinter(sampleWidthTestArrayPrinterBins == (sampleWidthTestArrayPrinterBinsUnique(k)) & ...
                                         sampleSigmaATestArrayPrinter(:, 9) == 1, :);
          % extract the halftone cell width with and without rot
          sampleWidthATempPrinterWidth = ...
						sampleWidthTestArrayPrinter(sampleWidthTestArrayPrinterBins == (sampleWidthTestArrayPrinterBinsUnique(k)) & ...
                                        sampleWidthTestArrayPrinter(:, 8) == 0, :);
          sampleWidthATempPrinterWidthRot = ...
						sampleWidthTestArrayPrinter(sampleWidthTestArrayPrinterBins == (sampleWidthTestArrayPrinterBinsUnique(k)) & ...
                                        sampleWidthTestArrayPrinter(:, 8) == 1, :);
          % the number of samples for the t-test with and without rot
          numSampleData = floor(size(sampleSigmaATempPrinterWidth, 1) / obj.sampleSize);
          numSampleDataRot = floor(size(sampleSigmaATempPrinterWidthRot, 1) / obj.sampleSize);
          % iterate through each datablock batch according to the width bins (without rot)
          for kk = 1:numSampleData
            % extract the sigma_a data
            sampleSigmaATempSample = sampleSigmaATempPrinterWidth((obj.sampleSize * (kk - 1) + 1):(kk * obj.sampleSize), :);
            % extract the halftone cell width
            sampleHalftoneWidthTempSample = sampleWidthATempPrinterWidth((obj.sampleSize * (kk - 1) + 1):(kk * obj.sampleSize), :);
						% only proceed if there are H0 value from the baseline
            if (printerIdxList(i) <= 4) && (obj.H0BaselineWidthPrinter(printerIdxList(i), sampleWidthTestArrayPrinterBinsUnique(k)) ~= 0)
              % calculate the single ttest for the first print (sample values)
              [~, ~, ~, sampleSigmaATstat] = ...
                ttest(sampleSigmaATempSample(:, 8), ...
                      obj.H0BaselineWidthPrinter(printerIdxList(i), sampleWidthTestArrayPrinterBinsUnique(k)), 'Tail', 'right');
              % collect the tstat data
              obj.sampleSigmaATestTstatGroupArrayPrinterWidth(end + 1, :) = ...
                  [printerIdxList(i) sampleWidthTestArrayPrinterWidthUnique(k) sampleSigmaATstat.tstat];
              % collect the halftone cell width data
              obj.sampleHalftoneWidthTestGroupArrayPrinterWidth(end + 1, :) = ...
                  [printerIdxList(i) sampleWidthTestArrayPrinterWidthUnique(k) mean(sampleHalftoneWidthTempSample(:, 7))];
            end
          end
          % iterate through each datablock batch according to the width bins (with rot)
          for kk = 1:numSampleDataRot
            % extract the sigma_a data
            sampleSigmaATempSampleRot = sampleSigmaATempPrinterWidthRot((obj.sampleSize * (kk - 1) + 1):(kk * obj.sampleSize), :);
            % extract the halftone cell width
            sampleHalftoneWidthTempSampleRot = sampleWidthATempPrinterWidthRot((obj.sampleSize * (kk - 1) + 1):(kk * obj.sampleSize), :);
						% only proceed if there are H0 value from the baseline
            if (printerIdxList(i) <= 4) && (obj.H0BaselineWidthPrinterRot(printerIdxList(i), sampleWidthTestArrayPrinterBinsUnique(k)) ~= 0)
              % calculate the single ttest for the first print (sample values)
              [~, ~, ~, sampleSigmaATstatRot] = ...
                ttest(sampleSigmaATempSampleRot(:, 8), ...
                      obj.H0BaselineWidthPrinterRot(printerIdxList(i), sampleWidthTestArrayPrinterBinsUnique(k)), 'Tail', 'right');
              % collect the tstat data
              obj.sampleSigmaATestTstatGroupArrayPrinterWidthRot(end + 1, :) = ...
                  [printerIdxList(i) sampleWidthTestArrayPrinterWidthUnique(k) sampleSigmaATstatRot.tstat];
              % collect the halftone cell width data
              obj.sampleHalftoneWidthTestGroupArrayPrinterWidthRot(end + 1, :) = ...
                  [printerIdxList(i) sampleWidthTestArrayPrinterWidthUnique(k) mean(sampleHalftoneWidthTempSampleRot(:, 7))];
            end
          end
        end
        %% for each printer/scanner pair
        for j = 1:length(scannerIdxList)
          % sigma_a w.r.t printer/scanner/width
          sampleSigmaATestArrayPrinterScanner = sampleSigmaATestArrayPrinter(sampleSigmaATestArrayPrinter(:, 4) == scannerIdxList(j), :);  
          % halftone cell width w.r.t printer/scanner/width
          sampleWidthTestArrayPrinterScanner = sampleWidthTestArrayPrinter(sampleWidthTestArrayPrinter(:, 4) == scannerIdxList(j), :);  
          % group in terms of halftone cell width
          [~, ~, sampleWidthTestArrayPrinterScannerBins] = histcounts(sampleWidthTestArrayPrinterScanner(:, 7), obj.halfoneMeanWidthEdges);
          sampleWidthTestArrayPrinterScannerBinsUnique = unique(sampleWidthTestArrayPrinterScannerBins);
          sampleWidthTestArrayPrinterScannerBinsUnique(sampleWidthTestArrayPrinterScannerBinsUnique == 0) = [];
          sampleWidthTestArrayPrinterScannerWidthUnique = obj.halfoneMeanWidthEdges(sampleWidthTestArrayPrinterScannerBinsUnique);
          % iterate through halftone width
          for k = 1:length(sampleWidthTestArrayPrinterScannerBinsUnique)
            % extract the sigma_a with and without rot
            sampleSigmaATempPrinterScannerWidth = ...
              sampleSigmaATestArrayPrinterScanner((sampleWidthTestArrayPrinterScannerBins == ...
                                                  (sampleWidthTestArrayPrinterScannerBinsUnique(k))) & ...
                                                  (sampleSigmaATestArrayPrinterScanner(:, 9) == 0), :);
            sampleSigmaATempPrinterScannerWidthRot = ...
              sampleSigmaATestArrayPrinterScanner((sampleWidthTestArrayPrinterScannerBins == ...
                                                  (sampleWidthTestArrayPrinterScannerBinsUnique(k))) & ...
                                                  (sampleSigmaATestArrayPrinterScanner(:, 9) == 1), :);
            % extract the halftone cell width with and without rot                                     
            sampleWidthTempPrinterScannerWidth = ...
              sampleWidthTestArrayPrinterScanner((sampleWidthTestArrayPrinterScannerBins == ...
                                                 (sampleWidthTestArrayPrinterScannerBinsUnique(k))) & ...
                                                 (sampleWidthTestArrayPrinterScanner(:, 8) == 0), :);
            sampleWidthTempPrinterScannerWidthRot = ...
              sampleWidthTestArrayPrinterScanner((sampleWidthTestArrayPrinterScannerBins == ...
                                                 (sampleWidthTestArrayPrinterScannerBinsUnique(k))) & ...
                                                 (sampleWidthTestArrayPrinterScanner(:, 8) == 1), :);

            % the number of t-stat data with and without rot
            numSampleData = floor(size(sampleWidthTempPrinterScannerWidth, 1) / obj.sampleSize);
            numSampleDataRot = floor(size(sampleWidthTempPrinterScannerWidthRot, 1) / obj.sampleSize);
            % iterate through each datablock batch without rot
            for kk = 1:numSampleData
              % extract the sigma_a samples
              sampleSigmaATempSample = sampleSigmaATempPrinterScannerWidth((obj.sampleSize * (kk - 1) + 1):(kk * obj.sampleSize), :);
              % extract the halftone cell width samples
              sampleHalftoneWidthTempSample = sampleWidthTempPrinterScannerWidth((obj.sampleSize * (kk - 1) + 1):(kk * obj.sampleSize), :);
              % if there is H0
              if (printerIdxList(i) <= 4) && ...
                  (obj.H0BaselineWidthPrinterScanner(printerIdxList(i), scannerIdxList(j), sampleWidthTestArrayPrinterScannerBinsUnique(k)) ~= 0)
                % calculate the single ttest 
                [~, ~, ~, sampleSigmaATstat] = ...
                  ttest(sampleSigmaATempSample(:, 8), ...
                        obj.H0BaselineWidthPrinterScanner(...
                          printerIdxList(i), scannerIdxList(j), sampleWidthTestArrayPrinterScannerBinsUnique(k)), 'Tail', 'right');

%                 if sampleSigmaATstat.tstat > 10 && printerIdxList(i) == 4
%                   disp([num2str(printerIdxList(i)) ' ' num2str(scannerIdxList(j)) ' '...
%                         num2str(sampleWidthTestArrayPrinterScannerBinsUnique(k)) ' '...
%                         num2str(sampleSigmaATstat.tstat) ' '...
%                         num2str(obj.H0BaselineWidthPrinterScanner(...
%                                 printerIdxList(i), scannerIdxList(j), sampleWidthTestArrayPrinterScannerBinsUnique(k))) ' ' ...
%                         num2str(sampleWidthTestArrayPrinterScannerBinsUnique(k))]);
%                   disp('abnormal' );
%                 end
                  
                % collect the tstat 
                obj.sampleSigmaATestTstatGroupArrayPrinterScannerWidth(end + 1, :) = ...
                  [printerIdxList(i) scannerIdxList(j) sampleWidthTestArrayPrinterScannerWidthUnique(k) sampleSigmaATstat.tstat];
                % collect the halftone cell width 
                obj.sampleHalftoneWidthTestGroupArrayPrinterScannerWidth(end + 1, :) = ...
                  [printerIdxList(i) scannerIdxList(j) ...
                   sampleWidthTestArrayPrinterScannerWidthUnique(k) mean(sampleHalftoneWidthTempSample(:, 7))];
              end
            end
            % iterate through each datablock batch with rot
            for kk = 1:numSampleDataRot
              % extract the sigma_a samples
              sampleSigmaATempSampleRot = sampleSigmaATempPrinterScannerWidthRot((obj.sampleSize * (kk - 1) + 1):(kk * obj.sampleSize), :);
              % extract the halftone cell width samples
              sampleHalftoneWidthTempSampleRot = ...
                sampleWidthTempPrinterScannerWidthRot((obj.sampleSize * (kk - 1) + 1):(kk * obj.sampleSize), :);
              % if there is H0
              if (printerIdxList(i) <= 4) && ...
                  (obj.H0BaselineWidthPrinterScannerRot(printerIdxList(i), scannerIdxList(j), ...
                                                        sampleWidthTestArrayPrinterScannerBinsUnique(k)) ~= 0)
                % calculate the single ttest 
                [~, ~, ~, sampleSigmaATstatRot] = ...
                  ttest(sampleSigmaATempSampleRot(:, 8), ...
                    obj.H0BaselineWidthPrinterScannerRot(printerIdxList(i), scannerIdxList(j), ...
                                                         sampleWidthTestArrayPrinterScannerBinsUnique(k)), 'Tail', 'right');
                              
%                 sampleSigmaATstatRot.tstat = mean(sampleSigmaATempSampleRot(:, 8)) - ...
%                                                   obj.H0BaselineWidthPrinterScannerRot(...
%                                                   printerIdxList(i), scannerIdxList(j), sampleWidthTestArrayPrinterScannerBinsUnique(k));
                % collect the tstat 
                obj.sampleSigmaATestTstatGroupArrayPrinterScannerWidthRot(end + 1, :) = ...
                    [printerIdxList(i) scannerIdxList(j) sampleWidthTestArrayPrinterScannerWidthUnique(k) sampleSigmaATstatRot.tstat];
                % collect the halftone cell width 
                obj.sampleHalftoneWidthTestGroupArrayPrinterScannerWidthRot(end + 1, :) = ...
                    [printerIdxList(i) scannerIdxList(j) ...
                    sampleWidthTestArrayPrinterScannerWidthUnique(k) mean(sampleHalftoneWidthTempSampleRot(:, 7))];
%                 if sampleSigmaATstat.tstat > 15 && printerIdxList(i) == 4
%                   disp([num2str(printerIdxList(i)) ' ' num2str(scannerIdxList(j)) ' '...
%                         num2str(sampleWidthTestArrayPrinterScannerBinsUnique(k)) ' '...
%                         num2str(sampleSigmaATstat.tstat) ' '...
%                         num2str(obj.H0BaselineWidthPrinterScanner(...
%                                 printerIdxList(i), scannerIdxList(j), sampleWidthTestArrayPrinterScannerBinsUnique(k))) ' ' ...
%                         num2str(sampleWidthTestArrayPrinterScannerBinsUnique(k))]);
%                   disp('abnormal' );
%                 end
              end
            end
          end
        end
      end
      %% for each scanner (including the realistic and the in the wild experiments)
      for j = 1:length(scannerIdxList)
        % extract sigma_a w.r.t scanner and width
        sampleSigmaATestArrayScanner = obj.sampleSigmaATestArray(obj.sampleSigmaATestArray(:, 4) == scannerIdxList(j), :);  
        % extract halftone cell width w.r.t scanner
        sampleWidthTestArrayScanner = obj.sampleHalftoneWidthTestArray(obj.sampleHalftoneWidthTestArray(:, 4) == scannerIdxList(j), :);  
        % histcount the halftone cell width
        [~, ~, sampleWidthTestArrayScannerBins] = histcounts(sampleWidthTestArrayScanner(:, 7), obj.halfoneMeanWidthEdges);
        sampleWidthTestArrayScannerBinsUnique = unique(sampleWidthTestArrayScannerBins);
        sampleWidthTestArrayScannerBinsUnique(sampleWidthTestArrayScannerBinsUnique == 0) = [];
        sampleWidthTestArrayScannerWidthUnique = obj.halfoneMeanWidthEdges(sampleWidthTestArrayScannerBinsUnique);
        % iterate through halftone width
        for k = 1:length(sampleWidthTestArrayScannerBinsUnique)
          % extract the sigma_a with and without rot
          sampleSigmaATempScannerWidth = ...
            sampleSigmaATestArrayScanner(sampleWidthTestArrayScannerBins == (sampleWidthTestArrayScannerBinsUnique(k)) & ...
                                         sampleSigmaATestArrayScanner(:, 9) == 0, :);
          sampleSigmaATempScannerWidthRot = ...
            sampleSigmaATestArrayScanner(sampleWidthTestArrayScannerBins == (sampleWidthTestArrayScannerBinsUnique(k)) & ...
                                         sampleSigmaATestArrayScanner(:, 9) == 1, :);
          % extract the halftone cell width with and without rot
          sampleWidthTempScannerWidth = ...
            sampleWidthTestArrayScanner(sampleWidthTestArrayScannerBins == (sampleWidthTestArrayScannerBinsUnique(k)) & ...
                                        sampleWidthTestArrayScanner(:, 8) == 0, :);
          sampleWidthTempScannerWidthRot = ...
            sampleWidthTestArrayScanner(sampleWidthTestArrayScannerBins == (sampleWidthTestArrayScannerBinsUnique(k)) & ...
                                        sampleWidthTestArrayScanner(:, 8) == 1, :);
          % the t-stat samples with and without rot
          numSampleData = floor(size(sampleWidthTempScannerWidth, 1) / obj.sampleSize);
          numSampleDataRot = floor(size(sampleWidthTempScannerWidthRot, 1) / obj.sampleSize);
          % iterate through each datablock batch
          for kk = 1:numSampleData
            % extract the sigma_a samples
            sampleSigmaATempSample = sampleSigmaATempScannerWidth((obj.sampleSize * (kk - 1) + 1):(kk * obj.sampleSize), :);
            % extract the halftone cell width samples
            sampleHalftoneWidthTempSample = sampleWidthTempScannerWidth((obj.sampleSize * (kk - 1) + 1):(kk * obj.sampleSize), :);
            % calculate the ttest without rot
            if obj.H0BaselineWidthScanner(scannerIdxList(j), sampleWidthTestArrayScannerBinsUnique(k)) ~= 0
              % calculate the t-stat
              [~, ~, ~, sampleSigmaATstat] = ...
                ttest(sampleSigmaATempSample(:, 8), ...
                      obj.H0BaselineWidthScanner(scannerIdxList(j), sampleWidthTestArrayScannerBinsUnique(k)), 'Tail', 'right');
              % collect the tstat 
              obj.sampleSigmaATestTstatGroupArrayScannerWidth(end + 1, :) = ...
                  [scannerIdxList(j) sampleWidthTestArrayScannerWidthUnique(k) sampleSigmaATstat.tstat];
              % collect the halftone width  
              obj.sampleHalftoneWidthTestGroupArrayScannerWidth(end + 1, :) = ...
                  [scannerIdxList(j) sampleWidthTestArrayScannerWidthUnique(k) mean(sampleHalftoneWidthTempSample(:, 7))];
            end
          end
          % iterate through each datablock batch with rot
          for kk = 1:numSampleDataRot
            % extract the sigma_a samples
            sampleSigmaATempSampleRot = sampleSigmaATempScannerWidthRot((obj.sampleSize * (kk - 1) + 1):(kk * obj.sampleSize), :);
            % extract the halftone cell width samples
            sampleHalftoneWidthTempSampleRot = sampleWidthTempScannerWidthRot((obj.sampleSize * (kk - 1) + 1):(kk * obj.sampleSize), :);
            % calculate the ttest without rot
            if obj.H0BaselineWidthScannerRot(scannerIdxList(j), sampleWidthTestArrayScannerBinsUnique(k)) ~= 0
              % calculate the t-stat
              [~, ~, ~, sampleSigmaATstatRot] = ...
                ttest(sampleSigmaATempSampleRot(:, 8), ...
                      obj.H0BaselineWidthScannerRot(scannerIdxList(j), sampleWidthTestArrayScannerBinsUnique(k)), 'Tail', 'right');
              % collect the tstat 
              obj.sampleSigmaATestTstatGroupArrayScannerWidthRot(end + 1, :) = ...
                  [scannerIdxList(j) sampleWidthTestArrayScannerWidthUnique(k) sampleSigmaATstatRot.tstat];
              % collect the halftone width  
              obj.sampleHalftoneWidthTestGroupArrayScannerWidthRot(end + 1, :) = ...
                  [scannerIdxList(j) sampleWidthTestArrayScannerWidthUnique(k) mean(sampleHalftoneWidthTempSampleRot(:, 7))];
            end
          end
        end
      end
    end 
    
    %% test the images in terms of the documents: group the t-stats (this is very important)
    function obj = testTStat(obj)
      % the doc index from all document image crops
      docIdx = unique(obj.sampleSigmaATestArray(:, 5));
      % initialize the result containers: fast and slow directions
      obj.sigmaATestTstatDocArrayPrinterScanner = [];
      obj.sigmaATestTstatDocArrayPrinterScannerRot = [];
      % initialize the result containers: fast and slow direction
      obj.sigmaATestTstatDocArrayPrinterTypeScanner = [];
      obj.sigmaATestTstatDocArrayPrinterTypeScannerRot = [];
      % index of the laser and inkjet printers
      inkjet_idx_lst = [1 3 8 11];
      laser_idx_lst = [4 5 6 9 10];
      %% process document by document
      for k = 1 : length(docIdx)
        % sigma_a w.r.t doc
        sampleSigmaATempDoc = obj.sampleSigmaATestArray(obj.sampleSigmaATestArray(:, 5) == docIdx(k), :);
        % halftone cell width w.r.t doc
        sampleHalftoneWidthTempDoc = obj.sampleHalftoneWidthTestArray(obj.sampleHalftoneWidthTestArray(:, 5) == docIdx(k), :);
        %% for each device combination
        device_info = sampleSigmaATempDoc(:, 1:4);
        device_info_list = unique(device_info, 'row');
        % for each device combination for that particular document
        for i = 1 : size(device_info_list, 1)
          % extract the location of the device combinations in the database
          device_info_idx = device_info_extract(device_info_list(i, :),  sampleSigmaATempDoc(:, 1:4));
          % classify sigma_a samples according to printer
          sampleSigmaADocArrayDevicePair = sampleSigmaATempDoc(device_info_idx, :);  
          sampleWidthDocArrayDevicePair = sampleHalftoneWidthTempDoc(device_info_idx, :);  
          % classify sigma_a samples according to printer/scanner/width
          if isempty(sampleSigmaADocArrayDevicePair) || isempty(sampleWidthDocArrayDevicePair)
            continue
          end
          
          % get the width bins.
          [~, ~, sampleWidthDocArrayPrinterScannerBins] = histcounts(sampleWidthDocArrayDevicePair(:, 7), obj.halfoneMeanWidthEdges);
          sampleWidthDocArrayPrinterScannerBinsUnique = unique(sampleWidthDocArrayPrinterScannerBins);
          sampleWidthDocArrayPrinterScannerBinsUnique(sampleWidthDocArrayPrinterScannerBinsUnique == 0) = [];
          sampleWidthDocArrayPrinterScannerWidthUnique = obj.halfoneMeanWidthEdges(sampleWidthDocArrayPrinterScannerBinsUnique);
          %% iterate through halftone width with and without rot
          for l = 1 : length(sampleWidthDocArrayPrinterScannerBinsUnique)
            % extract the sigma_a: the last entry indicates rotation
            sampleSigmaATempDocArrayDevicePair = ...
              sampleSigmaADocArrayDevicePair(sampleWidthDocArrayPrinterScannerBins == sampleWidthDocArrayPrinterScannerBinsUnique(l) & ...
                                             sampleSigmaADocArrayDevicePair(:, 9) == 0, :);
            sampleSigmaATempDocArrayDevicePairRot = ...
              sampleSigmaADocArrayDevicePair(sampleWidthDocArrayPrinterScannerBins == sampleWidthDocArrayPrinterScannerBinsUnique(l) & ...
                                             sampleSigmaADocArrayDevicePair(:, 9) == 1, :);
            % extract the halftone cell width: the last entry indicates rotation
            sampleWidthTempDocArrayDevicePair = ...
              sampleWidthDocArrayDevicePair(sampleWidthDocArrayPrinterScannerBins == sampleWidthDocArrayPrinterScannerBinsUnique(l) & ...
                                            sampleWidthDocArrayDevicePair(:, 8) == 0, :);
            sampleWidthTempDocArrayDevicePairRot = ...
              sampleWidthDocArrayDevicePair(sampleWidthDocArrayPrinterScannerBins == sampleWidthDocArrayPrinterScannerBinsUnique(l) & ...
                                            sampleWidthDocArrayDevicePair(:, 8) == 1, :);
            % the sample is multiple-image blocks constructing a t-statistics
            numSampleData = floor(size(sampleWidthTempDocArrayDevicePair, 1) / obj.sampleSize);
%             disp(['device list: ', num2str(device_info_list(i, :)), ' doc idx: ', num2str(docIdx(k)), ' numSamples: ', num2str(numSampleData)])
            numSampleDataRot = floor(size(sampleWidthTempDocArrayDevicePairRot, 1) / obj.sampleSize);
            if numSampleData == 0 || numSampleDataRot == 0
              disp([' numSamples: ', num2str(size(sampleWidthTempDocArrayDevicePair, 1)), ...
                    ' numSamplesRot: ', num2str(size(sampleWidthTempDocArrayDevicePairRot, 1)), ...
                    ' doc idx: ', num2str(docIdx(k)), ' device info: ', num2str(reshape(device_info_list(i, :), 1, []))]);
            end
            % iterate through halftone cell sample (without rot)
            for kk = 1:numSampleData
              % extract the sigma_a
              sampleSigmaATempSample = sampleSigmaATempDocArrayDevicePair((obj.sampleSize * (kk - 1) + 1):(kk * obj.sampleSize), :);
              % extract the halftone cell width
              sampleHalftoneWidthTempSample = sampleWidthTempDocArrayDevicePair((obj.sampleSize * (kk - 1) + 1):(kk * obj.sampleSize), :);
              if docIdx(k) == 6 && isequal(device_info_list(i, :), [3 1 3 1])
                disp('debug');
              end
              %% w.r.t width only (not used, written here for completeness only)
              if (device_info_list(i, 1) <= 4) && obj.H0BaselineWidth(sampleWidthDocArrayPrinterScannerBinsUnique(l)) ~= 0
                % calculate the t-stat 
                [~, ~, ~, sampleSigmaATstat] = ...
                  ttest(sampleSigmaATempSample(:, 8), obj.H0BaselineWidth(sampleWidthDocArrayPrinterScannerBinsUnique(l)), 'Tail', 'right');
                % collect the halftone cell data
                obj.sigmaATestTstatDocArray(end + 1, :) = ...
                  [docIdx(k) sampleWidthDocArrayPrinterScannerWidthUnique(l) mean(sampleHalftoneWidthTempSample(:, 7)) sampleSigmaATstat.tstat];
              end
              %% w.r.t printer/scanner (for baseline experiment)
              if (device_info_list(i, 1) <= 4) && ...
                 (obj.H0BaselineWidthPrinterScanner(device_info_list(i, 1), device_info_list(i, 4), ...
                                                    sampleWidthDocArrayPrinterScannerBinsUnique(l)) ~= 0)
                [~, ~, ~, sampleSigmaATstat] = ...
                  ttest(sampleSigmaATempSample(:, 8), ...
                        obj.H0BaselineWidthPrinterScanner(device_info_list(i, 1), device_info_list(i, 4), ...
                                                          sampleWidthDocArrayPrinterScannerBinsUnique(l)), 'Tail', 'right');
                % collect the tstat data and the mean width
                obj.sigmaATestTstatDocArrayPrinterScanner(end + 1, :) = ...
                  [device_info_list(i, 1:4) docIdx(k) sampleWidthDocArrayPrinterScannerWidthUnique(l) ...
                   mean(sampleHalftoneWidthTempSample(:, 7)) sampleSigmaATstat.tstat];
              end
              %% w.r.t printer type and scanner mode (for semi-controlled and in-the-wild experiment)
              if ismember(device_info_list(i, 1), inkjet_idx_lst)       % inkjet 
%                 if docIdx(k) == 17 && device_info_list(i, 1) == 4 && device_info_list(i, 4) == 1 
%                   disp('debug');
%                 end
                if obj.H0BaselineWidthPrinterTypeScanner(1, device_info_list(i, 4), sampleWidthDocArrayPrinterScannerBinsUnique(l)) ~= 0
                  % calculate the t-stats
                  [~, ~, ~, sampleSigmaATstat] = ...
                    ttest(sampleSigmaATempSample(:, 8), ...
                          obj.H0BaselineWidthPrinterTypeScanner(1, device_info_list(i, 4), ...
                                                                sampleWidthDocArrayPrinterScannerBinsUnique(l)), 'Tail', 'right');
%                   if docIdx(k) == 13 && device_info_list(i, 1) == 1 &&  device_info_list(i, 4) == 1 
%                     disp(['tstat is ' num2str(sampleSigmaATstat.tstat) ...
%                           ' h0 is ' num2str(obj.H0BaselineWidthPrinterTypeScanner(2, device_info_list(i, 4), ...
%                           sampleWidthDocArrayPrinterScannerBinsUnique(l)))]);
%                   end
                  % collect the tstat data
                  obj.sigmaATestTstatDocArrayPrinterTypeScanner(end + 1, :) = ...
                      [device_info_list(i, 1:4) docIdx(k) sampleWidthDocArrayPrinterScannerWidthUnique(l) ....
                       mean(sampleHalftoneWidthTempSample(:, 7)) sampleSigmaATstat.tstat];
                end
              elseif ismember(device_info_list(i, 1), laser_idx_lst)   % laser
                if obj.H0BaselineWidthPrinterTypeScanner(2, device_info_list(i, 4), sampleWidthDocArrayPrinterScannerBinsUnique(l)) ~= 0
                  % calculate the t-stats
                  [~, ~, ~, sampleSigmaATstat] = ...
                    ttest(sampleSigmaATempSample(:, 8), ...
                          obj.H0BaselineWidthPrinterTypeScanner(2, device_info_list(i, 4), ...
                                                                sampleWidthDocArrayPrinterScannerBinsUnique(l)), 'Tail', 'right');
%                   if docIdx(k) == 13 && device_info_list(i, 1) == 1 && device_info_list(i, 2) == 3 && device_info_list(i, 3) == 1 &&  device_info_list(i, 4) == 1 
%                     disp(['tstat is ' num2str(sampleSigmaATstat.tstat) ...
%                           ' h0 is ' num2str(obj.H0BaselineWidthPrinterTypeScanner(2, device_info_list(i, 4), sampleWidthDocArrayPrinterScannerBinsUnique(l)))]);
%                   end
                  % collect the tstat data
                  obj.sigmaATestTstatDocArrayPrinterTypeScanner(end + 1, :) = ...
                      [device_info_list(i, 1:4) docIdx(k) sampleWidthDocArrayPrinterScannerWidthUnique(l) ....
                       mean(sampleHalftoneWidthTempSample(:, 7)) sampleSigmaATstat.tstat];
                end
              end
              %%  for realistic and in-the-wild experiments
              if obj.H0BaselineWidthScanner(device_info_list(i, 4), sampleWidthDocArrayPrinterScannerBinsUnique(l)) ~= 0
                % calculate the ttest
                [~, ~, ~, sampleSigmaATstat] = ...
                  ttest(sampleSigmaATempSample(:, 8), ...
                        obj.H0BaselineWidthScanner(device_info_list(i, 4), sampleWidthDocArrayPrinterScannerBinsUnique(l)), 'Tail', 'right');
%                   if device_info_list(i, 1) == 3 && docIdx(k) == 2
%                     disp('debug 1712');
%                   end
                % collect the tstat data
                obj.sigmaATestTstatDocArrayScanner(end + 1, :) = [device_info_list(i, 1:4) docIdx(k) ...
                                                                  sampleWidthDocArrayPrinterScannerWidthUnique(l) ...
                                                                  mean(sampleHalftoneWidthTempSample(:, 7)) sampleSigmaATstat.tstat];
              end
            end
            % iterate through halftone cell sample (rot)
            for kk = 1:numSampleDataRot
              % extract the sigma_a
              sampleSigmaATempSampleRot = sampleSigmaATempDocArrayDevicePairRot((obj.sampleSize * (kk - 1) + 1):(kk * obj.sampleSize), :);
              % extract the halftone cell width
              sampleHalftoneWidthTempSampleRot = sampleWidthTempDocArrayDevicePairRot((obj.sampleSize * (kk - 1) + 1):(kk * obj.sampleSize), :);
              %% w.r.t width only (not used)
              if (device_info_list(i, 1) <= 4) && obj.H0BaselineWidthRot(sampleWidthDocArrayPrinterScannerBinsUnique(l)) ~= 0
                % calculate the t-stat 
                [~, ~, ~, sampleSigmaATstatRot] = ...
                  ttest(sampleSigmaATempSampleRot(:, 8), obj.H0BaselineWidthRot(sampleWidthDocArrayPrinterScannerBinsUnique(l)), 'Tail', 'right');
                % collect the halftone cell data
                obj.sigmaATestTstatDocArrayRot(end + 1, :) = ...
                  [docIdx(k) sampleWidthDocArrayPrinterScannerWidthUnique(l) mean(sampleHalftoneWidthTempSampleRot(:, 7)) sampleSigmaATstatRot.tstat];
              end
              %% w.r.t printer scanner models rot
              if (device_info_list(i, 1) <= 4) && ...
                  obj.H0BaselineWidthPrinterScannerRot(device_info_list(i, 1), device_info_list(i, 4), ...
                                                       sampleWidthDocArrayPrinterScannerBinsUnique(l)) ~= 0
                % calculate the t-stats
                [~, ~, ~, sampleSigmaATstatRot] = ...
                  ttest(sampleSigmaATempSampleRot(:, 8), ...
                        obj.H0BaselineWidthPrinterScannerRot(device_info_list(i, 1), ...
                                                             device_info_list(i, 4), ...
                                                             sampleWidthDocArrayPrinterScannerBinsUnique(l)), 'Tail', 'right');
                % collect the tstat data
                obj.sigmaATestTstatDocArrayPrinterScannerRot(end + 1, :) = ...
                    [device_info_list(i, 1:4) docIdx(k) sampleWidthDocArrayPrinterScannerWidthUnique(l) ....
                     mean(sampleHalftoneWidthTempSampleRot(:, 7)) sampleSigmaATstatRot.tstat];
              end  
              %% w.r.t printer type and scanner model rot (realistic and semi-controlledd)
              if ismember(device_info_list(i, 1), inkjet_idx_lst)       % inkjet
                if obj.H0BaselineWidthPrinterTypeScannerRot(1, device_info_list(i, 4), sampleWidthDocArrayPrinterScannerBinsUnique(l)) ~= 0
                % calculate the t-stats
                  [~, ~, ~, sampleSigmaATstatRot] = ...
                    ttest(sampleSigmaATempSampleRot(:, 8), ...
                          obj.H0BaselineWidthPrinterTypeScannerRot(1, device_info_list(i, 4), ...
                                                                   sampleWidthDocArrayPrinterScannerBinsUnique(l)), 'Tail', 'right');
                  % collect the tstat data
                  obj.sigmaATestTstatDocArrayPrinterTypeScannerRot(end + 1, :) = ...
                      [device_info_list(i, 1:4) docIdx(k) sampleWidthDocArrayPrinterScannerWidthUnique(l) ....
                       mean(sampleHalftoneWidthTempSampleRot(:, 7)) sampleSigmaATstatRot.tstat];
                end  
              elseif ismember(device_info_list(i, 1), laser_idx_lst)    % laser
                if obj.H0BaselineWidthPrinterTypeScannerRot(2, device_info_list(i, 4), ...
                                                            sampleWidthDocArrayPrinterScannerBinsUnique(l)) ~= 0
                  % calculate the t-stats
                  [~, ~, ~, sampleSigmaATstatRot] = ...
                    ttest(sampleSigmaATempSampleRot(:, 8), ...
                          obj.H0BaselineWidthPrinterTypeScannerRot(2, device_info_list(i, 4), ...
                          sampleWidthDocArrayPrinterScannerBinsUnique(l)), 'Tail', 'right');
                  % collect the tstat data
                  obj.sigmaATestTstatDocArrayPrinterTypeScannerRot(end + 1, :) = ...
                      [device_info_list(i, 1:4) docIdx(k) sampleWidthDocArrayPrinterScannerWidthUnique(l) ....
                       mean(sampleHalftoneWidthTempSampleRot(:, 7)) sampleSigmaATstatRot.tstat];
                end
              end
              %% w.r.t width and scanner rot (realistic and in-the-wild)
              if obj.H0BaselineWidthScannerRot(device_info_list(i, 4), sampleWidthDocArrayPrinterScannerBinsUnique(l)) ~= 0
                % calculate the ttest
                [~, ~, ~, sampleSigmaATstatRot] = ...
                  ttest(sampleSigmaATempSampleRot(:, 8), ...
                        obj.H0BaselineWidthScannerRot(device_info_list(i, 4), sampleWidthDocArrayPrinterScannerBinsUnique(l)), 'Tail', 'right');
                % collect the tstat data
                obj.sigmaATestTstatDocArrayScannerRot(end + 1, :) = ...
                    [device_info_list(i, 1:4) docIdx(k) sampleWidthDocArrayPrinterScannerWidthUnique(l) ...
                     mean(sampleHalftoneWidthTempSampleRot(:, 7)) sampleSigmaATstatRot.tstat];
              end
            end
          end
        end
      end
    end
    
    %% show the tstat results (show only)
    function obj = checkTStat(obj)
      histBinEdges = -30 : 1 : 30;
      %% fast direction w.r.t width only
%       figure;
%       histogram(obj.sampleSigmaABaselineTstatGroupArrayWidth(:, 2), histBinEdges, 'Normalization', 'probability');
%       hold on;
%       histogram(obj.sampleSigmaATestTstatGroupArrayWidth(:, 2), histBinEdges, 'Normalization', 'probability');
%       title('t-stat hist fast width');
%       legend('baseline', 'test');
%       set(gca, 'FontName', 'Times', 'FontSize', 25, 'FontSmoothing', 'on');  
%       set(gcf, 'InnerPosition', [0 0 1000 800]);  
%       set(gcf, 'OuterPosition', [0 0 1000 800]); 
%       ylim([0 0.25])
      %% slow direction
%       figure;
%       histogram(obj.sampleSigmaABaselineTstatGroupArrayWidthRot(:, 2), histBinEdges, 'Normalization', 'probability');
%       hold on;
%       histogram(obj.sampleSigmaATestTstatGroupArrayWidthRot(:, 2), histBinEdges, 'Normalization', 'probability');
%       title('\sigma_a t-statistic hist slow direction');
%       legend('baseline', 'test');
%       set(gca, 'FontName', 'Times', 'FontSize', 25, 'FontSmoothing', 'on');  
%       set(gcf, 'InnerPosition', [0 0 1000 800]);  
%       set(gcf, 'OuterPosition', [0 0 1000 800]); 
%       ylim([0 0.25])
      %% fast direction w.r.t printer
%       figure;
%       histogram(obj.sampleSigmaABaselineTstatGroupArrayPrinterWidth(:, 3), histBinEdges, 'Normalization', 'probability');
%       hold on;
%       histogram(obj.sampleSigmaATestTstatGroupArrayPrinterWidth(:, 3), histBinEdges, 'Normalization', 'probability');
%       title('t-stat hist fast width/printer');
%       legend('baseline', 'test');
%       set(gca, 'FontName', 'Times', 'FontSize', 25, 'FontSmoothing', 'on');  
%       set(gcf, 'InnerPosition', [0 0 1000 800]);  
%       set(gcf, 'OuterPosition', [0 0 1000 800]); 
%       ylim([0 0.25])
      %% slow direction w.r.t printer
%       figure;
%       histogram(obj.sampleSigmaABaselineTstatGroupArrayPrinterWidthRot(:, 3), histBinEdges, 'Normalization', 'probability');
%       hold on;
%       histogram(obj.sampleSigmaATestTstatGroupArrayPrinterWidthRot(:, 3), histBinEdges, 'Normalization', 'probability');
%       title('\sigma_a t-statistic hist w.r.t printer slow direction');
%       legend('baseline', 'test');
%       set(gca, 'FontName', 'Times', 'FontSize', 25, 'FontSmoothing', 'on');  
%       set(gcf, 'InnerPosition', [0 0 1000 800]);  
%       set(gcf, 'OuterPosition', [0 0 1000 800]); 
%       ylim([0 0.25])
      %% fast direction realistic
      figure;
      subplot(121);
      histogram(obj.sampleSigmaABaselineTstatGroupArrayScannerWidth(:, 3), histBinEdges, 'Normalization', 'probability');
      hold on;
      histogram(obj.sampleSigmaATestTstatGroupArrayScannerWidth(:, 3), histBinEdges, 'Normalization', 'probability');
      title('t-stat hist fast realistic');
%       legend('baseline', 'test');
%       set(gca, 'FontName', 'Times', 'FontSize', 25, 'FontSmoothing', 'on');  
%       set(gcf, 'InnerPosition', [0 0 1000 800]);  
%       set(gcf, 'OuterPosition', [0 0 1000 800]); 
      ylim([0 0.25]);
      %% slow direction realistic
      subplot(122);
      histogram(obj.sampleSigmaABaselineTstatGroupArrayScannerWidthRot(:, 3), histBinEdges, 'Normalization', 'probability');
      hold on;
      histogram(obj.sampleSigmaATestTstatGroupArrayScannerWidthRot(:, 3), histBinEdges, 'Normalization', 'probability');
      title('t-stat hist slow realistic');
      legend('baseline', 'test');
%       set(gca, 'FontName', 'Times', 'FontSize', 25, 'FontSmoothing', 'on');  
%       set(gcf, 'InnerPosition', [0 0 1000 800]);  
%       set(gcf, 'OuterPosition', [0 0 1000 800]); 
      ylim([0 0.25])
%%
%       %% fast direction realistic (laser)
%       figure;
%       histogram(obj.sampleSigmaABaselineTstatGroupArrayScannerWidth(...
%                 obj.sampleSigmaABaselineTstatGroupArrayScannerWidth(:, 1) == 4, 3), histBinEdges, 'Normalization', 'probability');
%       hold on;
%       histogram(obj.sampleSigmaATestTstatGroupArrayScannerWidth(...
%                 obj.sampleSigmaATestTstatGroupArrayScannerWidth(:, 1) == 4, 3), histBinEdges, 'Normalization', 'probability');
%       title('t-stat hist fast realistic (laser)');
%       legend('baseline', 'test');
%       set(gca, 'FontName', 'Times', 'FontSize', 25, 'FontSmoothing', 'on');  
%       set(gcf, 'InnerPosition', [0 0 1000 800]);  
%       set(gcf, 'OuterPosition', [0 0 1000 800]); 
%       ylim([0 0.25]);
      
     %% plot baseline t values for printer/scanner pair      
%       % the distribution fitting of the baseline images t-statistics
%       temp = find(obj.sampleSigmaABaselineTstatGroupArrayPrinterScannerWidth(:, 4)==-Inf);
%       obj.sampleSigmaABaselineTstatGroupArrayPrinterScannerWidth(temp,:)=[];
%       obj.sampleHalftoneWidthBaselineGroupArrayPrinterScannerWidth(temp,:)=[];
      
%       figure;
%       histfit(obj.sampleSigmaABaselineTstatGroupArrayPrinterScannerWidth(:, 4), ...
%               ceil(sqrt(length(obj.sampleSigmaABaselineTstatGroupArrayPrinterScannerWidth(:, 4)))), 'tlocationscale');
%       title('baseline t-stat histfit');
%       pdBaseline = fitdist(obj.sampleSigmaABaselineTstatGroupArrayPrinterScannerWidth(:, 4), 'tLocationScale');
      
%       % the distribution fitting of the test images t-statistics
%       temp = find(obj.sampleSigmaATestTstatGroupArrayPrinterScannerWidth(:, 4)==-Inf);
%       obj.sampleSigmaATestTstatGroupArrayPrinterScannerWidth(temp,:)=[];
%       obj.sampleHalftoneWidthTestGroupArrayPrinterScannerWidth(temp,:)=[];
      
%       figure;
%       histfit(obj.sampleSigmaATestTstatGroupArrayPrinterScannerWidth(:, 4), ...
%               ceil(sqrt(length(obj.sampleSigmaATestTstatGroupArrayPrinterScannerWidth(:, 4)))), 'tlocationscale');
%       title('test t-stat histfit');
%       pdTest = fitdist(obj.sampleSigmaATestTstatGroupArrayPrinterScannerWidth(:, 4), 'tLocationScale');
      
      %% slow direction w.r.t printer/scanner pair
%       figure;
%       histogram(obj.sampleSigmaABaselineTstatGroupArrayPrinterScannerWidthRot(:, 4), histBinEdges, 'Normalization', 'probability');
%       hold on;
%       histogram(obj.sampleSigmaATestTstatGroupArrayPrinterScannerWidthRot(:, 4), histBinEdges, 'Normalization', 'probability');
%       title('\sigma_a t-statistic hist w.r.t printer/scanner slow direction');
%       legend('baseline', 'test');
%       set(gca, 'FontName', 'Times', 'FontSize', 25, 'FontSmoothing', 'on');  
%       set(gcf, 'InnerPosition', [0 0 1000 800]);  
%       set(gcf, 'OuterPosition', [0 0 1000 800]);  
%       ylim([0 0.25])
      %% fast direction baseline
      figure;
      subplot(131);
      histogram(obj.sampleSigmaABaselineTstatGroupArrayPrinterScannerWidth(:, 4), histBinEdges, 'Normalization', 'probability');
      hold on;
      histogram(obj.sampleSigmaATestTstatGroupArrayPrinterScannerWidth(:, 4), histBinEdges, 'Normalization', 'probability');
      title('t-stat hist fast baseline');
      legend('baseline', 'test');
%       set(gca, 'FontName', 'Times', 'FontSize', 25, 'FontSmoothing', 'on');  
%       set(gcf, 'InnerPosition', [0 0 1000 800]);  
%       set(gcf, 'OuterPosition', [0 0 1000 800]);  
      ylim([0 0.25]);
      %% fast direction baseline (laser)
      subplot(132);
      histogram(obj.sampleSigmaABaselineTstatGroupArrayPrinterScannerWidth(...
                obj.sampleSigmaABaselineTstatGroupArrayPrinterScannerWidth(:, 1) == 4, 4), histBinEdges, 'Normalization', 'probability');
      hold on;
      histogram(obj.sampleSigmaATestTstatGroupArrayPrinterScannerWidth(...
                obj.sampleSigmaATestTstatGroupArrayPrinterScannerWidth(:, 1) == 4, 4), histBinEdges, 'Normalization', 'probability');
      title('t-stat hist fast baseline (laser)');
      legend('baseline', 'test');
%       set(gca, 'FontName', 'Times', 'FontSize', 25, 'FontSmoothing', 'on');  
%       set(gcf, 'InnerPosition', [0 0 1000 800]);  
%       set(gcf, 'OuterPosition', [0 0 1000 800]);  
      ylim([0 0.25]);
      %% fast direction baseline (inkjet)
      subplot(133);
      histogram(obj.sampleSigmaABaselineTstatGroupArrayPrinterScannerWidth(...
                obj.sampleSigmaABaselineTstatGroupArrayPrinterScannerWidth(:, 1) ~= 4, 4), histBinEdges, 'Normalization', 'probability');
      hold on;
      histogram(obj.sampleSigmaATestTstatGroupArrayPrinterScannerWidth(...
                obj.sampleSigmaATestTstatGroupArrayPrinterScannerWidth(:, 1) ~= 4, 4), histBinEdges, 'Normalization', 'probability');
      title('t-stat hist fast baseline (inkjet)');
      legend('baseline', 'test');
%       set(gca, 'FontName', 'Times', 'FontSize', 25, 'FontSmoothing', 'on');  
%       set(gcf, 'InnerPosition', [0 0 1000 800]);  
%       set(gcf, 'OuterPosition', [0 0 1000 800]);  
      ylim([0 0.25]);
      %% slow direction baseline
      figure;
      subplot(131);
      histogram(obj.sampleSigmaABaselineTstatGroupArrayPrinterScannerWidthRot(:, 4), histBinEdges, 'Normalization', 'probability');
      hold on;
      histogram(obj.sampleSigmaATestTstatGroupArrayPrinterScannerWidthRot(:, 4), histBinEdges, 'Normalization', 'probability');
      title('t-stat hist slow baseline');
      legend('baseline', 'test');
%       set(gca, 'FontName', 'Times', 'FontSize', 25, 'FontSmoothing', 'on');  
%       set(gcf, 'InnerPosition', [0 0 1000 800]);  
%       set(gcf, 'OuterPosition', [0 0 1000 800]);  
      ylim([0 0.25]);
      %% slow direction baseline (laser)
      subplot(132);
      histogram(obj.sampleSigmaABaselineTstatGroupArrayPrinterScannerWidthRot(...
                obj.sampleSigmaABaselineTstatGroupArrayPrinterScannerWidthRot(:, 1) == 4, 4), histBinEdges, 'Normalization', 'probability');
      hold on;
      histogram(obj.sampleSigmaATestTstatGroupArrayPrinterScannerWidthRot(...
                obj.sampleSigmaATestTstatGroupArrayPrinterScannerWidthRot(:, 1) == 4, 4), histBinEdges, 'Normalization', 'probability');
      title('t-stat hist slow baseline (laser)');
      legend('baseline', 'test');
%       set(gca, 'FontName', 'Times', 'FontSize', 25, 'FontSmoothing', 'on');  
%       set(gcf, 'InnerPosition', [0 0 1000 800]);  
%       set(gcf, 'OuterPosition', [0 0 1000 800]);  
      ylim([0 0.25]);
      %% slow direction baseline (inkjet)
      subplot(133);
      histogram(obj.sampleSigmaABaselineTstatGroupArrayPrinterScannerWidthRot(...
                obj.sampleSigmaABaselineTstatGroupArrayPrinterScannerWidthRot(:, 1) ~= 4, 4), histBinEdges, 'Normalization', 'probability');
      hold on;
      histogram(obj.sampleSigmaATestTstatGroupArrayPrinterScannerWidthRot(...
                obj.sampleSigmaATestTstatGroupArrayPrinterScannerWidthRot(:, 1) ~= 4, 4), histBinEdges, 'Normalization', 'probability');
      title('t-stat hist slow baseline (inkjet)');
      legend('baseline', 'test');
%       set(gca, 'FontName', 'Times', 'FontSize', 25, 'FontSmoothing', 'on');  
%       set(gcf, 'InnerPosition', [0 0 1000 800]);  
%       set(gcf, 'OuterPosition', [0 0 1000 800]);  
      ylim([0 0.25]);
      %% plot the sigma_a results w.r.t halftone width/printer/scanner
%       figure;
%       scatter(obj.sampleHalftoneWidthBaselineGroupArrayPrinterScannerWidth(:, 4), ...
%               obj.sampleSigmaABaselineTstatGroupArrayPrinterScannerWidth(:, 4), 'o');
%       hold on;
%       scatter(obj.sampleHalftoneWidthTestGroupArrayPrinterScannerWidth(:, 4), ...
%               obj.sampleSigmaATestTstatGroupArrayPrinterScannerWidth(:, 4), 'o');
%             
%       % rough estimate of the errors
%       if obj.testImgType == 2
%         obj.FNErrorPrinterScannerSample(1) = ...
%                 length(find(obj.sampleSigmaATestTstatGroupArrayPrinterScannerWidth(:, 4) < 1.17291)) / ...
%                 length(obj.sampleSigmaATestTstatGroupArrayPrinterScannerWidth(:, 4));
%         obj.FNErrorPrinterScannerSample(2) = ...
%                 length(find(obj.sampleSigmaATestTstatGroupArrayPrinterScannerWidth(:, 4) < 2.53948)) / ...
%                 length(obj.sampleSigmaATestTstatGroupArrayPrinterScannerWidth(:, 4));
% %         disp(['width/scanner/printer FN Error: ' num2str(obj.FNErrorPrinterScannerSample)]);
%       else
%         obj.FPErrorPrinterScannerSample(1) = ...
%                 length(find(obj.sampleSigmaATestTstatGroupArrayPrinterScannerWidth(:, 4) > 1.17291)) / ...
%                 length(obj.sampleSigmaATestTstatGroupArrayPrinterScannerWidth(:, 4));
%         obj.FPErrorPrinterScannerSample(2) = ...
%                 length(find(obj.sampleSigmaATestTstatGroupArrayPrinterScannerWidth(:, 4) > 2.53948)) / ...
%                 length(obj.sampleSigmaATestTstatGroupArrayPrinterScannerWidth(:, 4));
% %         disp(['width/scanner/printer FP Error: ' num2str(obj.FPErrorPrinterScannerSample)]);
%       end
%             
%       xlabel('mean width');
%       ylabel('\sigma_a tstat');
%       legend('baseline', 'test');
%       set(gca, 'FontName', 'Times', 'FontSize', 25, 'FontSmoothing', 'on');  
%       xlim([min([obj.sampleHalftoneWidthBaselineGroupArrayPrinterScannerWidth(:, 4); ...
%                  obj.sampleHalftoneWidthTestGroupArrayPrinterScannerWidth(:, 4)]), ...
%             max([obj.sampleHalftoneWidthBaselineGroupArrayPrinterScannerWidth(:, 4); ...
%                  obj.sampleHalftoneWidthTestGroupArrayPrinterScannerWidth(:, 4)])]);
%       ylim([-60 80]);
%       title('\sigma_a tstat wrt scanner/printer');
    end
  end
end

