classdef Engine < handle
    
    %------------------------------------------------------------------
    % Properties
    %------------------------------------------------------------------
    
    properties
        planeArray = [];
        videoFileName;
        videoType = 1; %1='AVI', 2='MultipleImageTif', 3=SingleImageTif
        nFrames = 0;
        Height = 0;
        Width = 0;
        isLoaded = false;
    end
    
    %------------------------------------------------------------------
    % Methods
    %------------------------------------------------------------------
    
    methods
        
        %Constructor
        function obj = Engine(vidType, videoFullName, nPlanes)
            if nargin % constructor for this class. skips if it is a subclass
                obj.videoType = vidType;
                obj.videoFileName = videoFullName;
                obj.planeArray = Plane.empty(nPlanes, 0);
                for iPlane=1:nPlanes
                    % Create a plane:
                    obj.planeArray(iPlane) = Plane();
                end
                switch vidType
                    case 1  %'AVI'
                        readerObj = VideoReader(videoFullName);
                        obj.nFrames = readerObj.NumberOfFrames;
                        obj.Height = readerObj.Height;
                        obj.Width = readerObj.Width;
                    case 2  %'MultipleImageTif
                        FileTif = videoFullName;
                        InfoImage=imfinfo(FileTif);
                        obj.nFrames=length(InfoImage);
                        obj.Height = InfoImage(1).Height;
                        obj.Width = InfoImage(1).Width;
                    case 3  %SingleImageTif
                        InfoImage=imfinfo(videoFullName{1,1});
                        obj.nFrames = length(obj.videoFileName);                    
                        obj.Height = InfoImage(1).Height;
                        obj.Width = InfoImage(1).Width;
                    otherwise
                        obj.nFrames = 0;
                        obj.Height = 0;
                        obj.Width = 0;
                end  

                obj.isLoaded = false;
            end
        end
                              
        function loadPartialCellsDataForFrameRange(obj, FromFrame, UpToFrame, removeArtifacts,planeDistance,baseSigma,subFactor)
            %tic;
            
            % get the cell's data from the frames.                                  
            nPlanes = length(obj.planeArray);  
            
            if (UpToFrame > (obj.nFrames - nPlanes))
                UpToFrame = obj.nFrames - nPlanes;
            end
            nFramesToRead = UpToFrame - FromFrame + 1;           
            nFramesToReadPerPlane = ceil(nFramesToRead/nPlanes);
            
            % prepare reader objects:
            if obj.videoType == 1
                readerObj = VideoReader(obj.videoFileName);                              
            end
            if obj.videoType == 2
                FileTif = obj.videoFileName;
                InfoImage=imfinfo(FileTif);                
            end  
            
            %create cell of matrixes to hold rawdata
            cellRawDataMat = cell(nPlanes,1);
            
            %first - clear all existing cells data
            for iPlane=1:nPlanes
                nCells = obj.planeArray(iPlane).cellCount();
                for iCell = 1:nCells
                    obj.planeArray(iPlane).cellArray(iCell).clearData();                    
                end
                
                cellRawDataMat{iPlane} = zeros(nCells,nFramesToReadPerPlane);
            end
            
            %create mask of all cells (ONCE)
            cellMaskMat = CreateCellsMaskMat(obj)
         
            %in order to clean artifacts, we read 1 frame from each plane
            %and then work on all of them together
            [m,n] = size(obj.planeArray(1).meanImage);
            currFramesGroup = zeros(m,n,nPlanes);
            
            for iFrame = FromFrame:nPlanes:UpToFrame
                
                for iPlane=1:nPlanes
                    %reading individual 
                    if obj.videoType == 1
                        currFrame = readerObj.read(iFrame+iPlane-1);
                        if (ndims(currFrame) == 3)
                            currFrame = currFrame(:,:,1);
                        end
                        currFrame = im2double(currFrame);  
                    end
                    if obj.videoType == 2
                        currFrame = imread(FileTif,'Index',iFrame+iPlane-1, 'Info',InfoImage);
                        if (ndims(currFrame) == 3)
                            currFrame = currFrame(:,:,1);
                        end
                        currFrame = im2double(currFrame);  
                    end
                    if obj.videoType == 3
                        currFrame = imread(obj.videoFileName{iFrame+iPlane-1});                       
                        if (ndims(currFrame) == 3)
                            currFrame = currFrame(:,:,1);
                        end
                        currFrame = im2double(currFrame);  
                    end 
                    
                    %save image for artifacts cleaning
                    currFramesGroup(:,:,iPlane) = currFrame;                 
                end
                
                %go over all frames in group, do artifacts cleaning
                %and add to data to cells
                for iPlane=1:nPlanes
                    
                    currFrame = currFramesGroup(:,:,iPlane);
                    
                    if (removeArtifacts == 1)
                        for iDstPlane=1:nPlanes
                            
                            %don't update the current plane...
                            if (iDstPlane == iPlane)
                                continue;
                            end
                            
                            %calc distance between planes;
                            distance = abs(iDstPlane-iPlane) * planeDistance;
                            
                            %remove artifacts from plane based on distance
                            destPlaneArtifacts = obj.planeArray(iDstPlane).planeArtifacts;
                            
                            %multiply the mask in the current dest frame -
                            destPlaneArtifacts = destPlaneArtifacts.* currFramesGroup(:,:,iDstPlane);
                            
                            currFrame = obj.removeFrameArtifacts(currFrame,destPlaneArtifacts,distance,baseSigma,subFactor);
                    
                        end
                    end
                    
                    nCells = obj.planeArray(iPlane).cellCount();
                    
                    %older method - Not optimized
%                     for iCell = 1:nCells
%                         obj.planeArray(iPlane).cellArray(iCell).addFrameData(currFrame);
%                     end
                    
                    %new method - use 3-d matrix
                    currFrameMat = repmat(currFrame,[1,1,nCells]);
                    
                    %multiply both matrixes
                    cellActivityMat = cellMaskMat{iPlane}.*currFrameMat;
                    
                    %sum valid pixels for each cell
                    cellActivityArray = sum(sum(cellActivityMat));
                    
                    nIndex = ceil(iFrame/nPlanes);
                    
                    %store value for all cells
                    cellRawDataMat{iPlane} (:,nIndex) = cellActivityArray(1,1,:);
                    
                end
                
                progIndication = sprintf('Load Data: read %d frames out of %d.', iFrame-FromFrame+nPlanes, nFramesToRead);
                disp(progIndication);
            end
            
            %only here - iterate over all planes & cells and update data
            %structure;
            for iPlane=1:nPlanes
                nCells = obj.planeArray(iPlane).cellCount();
                
                for iCell = 1:nCells
                    obj.planeArray(iPlane).cellArray(iCell).rawData = (cellRawDataMat{iPlane} (iCell,:))';
                end
            end
            
            progIndication = sprintf('Done.');
            disp(progIndication);           
            obj.isLoaded = true;
            
            %toc;
        end
        
        function createPlanesMeanImageOnFrameRange(obj, FromFrame, UpToFrame)
            tic                      
            
            % set number of planes:
            nPlanes = length(obj.planeArray);  
            
            if (UpToFrame > (obj.nFrames - nPlanes))
                UpToFrame = obj.nFrames - nPlanes;
            end
            nFramesToRead = UpToFrame - FromFrame + 1;           
            nNumFramesToAverage = fix(nFramesToRead/nPlanes); 
            
            for iPlane=1:nPlanes
                obj.planeArray(iPlane).meanImage = zeros(obj.Height,obj.Width);
            end
               
            % prepare reader objects:
            if obj.videoType == 1
                readerObj = VideoReader(obj.videoFileName);                              
            end
            if obj.videoType == 2
                FileTif = obj.videoFileName;
                InfoImage=imfinfo(FileTif);                
            end  
            
            for iFrame = FromFrame:nPlanes:UpToFrame
                for iPlane=1:nPlanes
                    %reading individual frames
                    if obj.videoType == 1
                        currFrame = readerObj.read(iFrame+iPlane-1);
                        if (ndims(currFrame) == 3)
                            currFrame = currFrame(:,:,1);
                        end
                        currFrame = im2double(currFrame);  
                    end
                    if obj.videoType == 2
                        currFrame = imread(FileTif,'Index',iFrame+iPlane-1, 'Info',InfoImage);
                        if (ndims(currFrame) == 3)
                            currFrame = currFrame(:,:,1);
                        end
                        currFrame = im2double(currFrame);  
                    end
                    if obj.videoType == 3
                        currFrame = imread(obj.videoFileName{iFrame+iPlane-1});                       
                        if (ndims(currFrame) == 3)
                            currFrame = currFrame(:,:,1);
                        end
                        currFrame = im2double(currFrame);  
                    end                        
                    obj.planeArray(iPlane).meanImage = obj.planeArray(iPlane).meanImage + currFrame;
                end
                
                progIndication = sprintf('Average: read %d frames out of %d.', iFrame-FromFrame+nPlanes, nFramesToRead);
                disp(progIndication);
            end
                        
            for iPlane=1:nPlanes
                obj.planeArray(iPlane).meanImage = obj.planeArray(iPlane).meanImage / nNumFramesToAverage;
                
                I1 =  obj.planeArray(iPlane).meanImage;
                I2 = (I1-min(min(I1)))/(max(max(I1)));
                I3 = imadjust(I2);
                obj.planeArray(iPlane).meanImage = I3;
                % until cleaning is done, copy the same image to the cleaned image.
                obj.planeArray(iPlane).meanImageClean = I3;


            end 
            
                        
            toc
                        
        end  
                   
        function removePlanesArtifacts(obj,method,planeDistance,baseSigma,subFactor)
           
            %for each plane - create image of only "focused" cells and 
            %remove their Artifacts from all other planes
            nPlanes = length(obj.planeArray); 
            
            %first - segment all planes
            for iPlane=1:nPlanes
                obj.planeArray(iPlane).segment_Method1(0,2); %segment on non-clean image, use 2sigma margin
            end
            
            
            for iSrcPlane=1:nPlanes
                
                %choose segmentation based method or HPF based method
               
                switch(method)
                    case 1
                        srcPlaneArtifacts = obj.createPlaneArtifacts_Method1(iSrcPlane);
                    case 2
                        srcPlaneArtifacts = obj.createPlaneArtifacts_Method2(iSrcPlane);
                end
                
                for iDstPlane=1:nPlanes
                    
                    %don't update the current plane...
                    if (iDstPlane == iSrcPlane) 
                        continue; 
                    end
                    
                    %calc distance between planes;
                    distance = abs(iDstPlane-iSrcPlane) * planeDistance;
                    
                    %remove artifacts from plane based on distance & store
                    %mean image again
                    srcMeanImage = obj.planeArray(iDstPlane).meanImageClean;
                    obj.planeArray(iDstPlane).meanImageClean = obj.removeFrameArtifacts(srcMeanImage,...
                                                                                        srcPlaneArtifacts,...
                                                                                        distance,...
                                                                                        baseSigma,...
                                                                                        subFactor);
                end 
                
                %store plane Artifacts for later use when reading cells
                obj.planeArray(iSrcPlane).planeArtifacts = srcPlaneArtifacts; 
            end 
            
            %last - clear all segmentation results
            for iPlane=1:nPlanes
                obj.planeArray(iPlane).clearAllCells();
            end
            
        end  
        
        function planeArtifacts = createPlaneArtifacts_Method2(obj,iSrcPlane)
            
            srcPlane = obj.planeArray(iSrcPlane);
            
            planeArtifacts = zeros(size(obj.planeArray(iSrcPlane).meanImage));
            
            %for each cell in the source plane, go over ALL other planes
            %and try to find other cells that might be overlapping
            %when found - compare using focus measure to determine which
            %cell is in focus
            
            for iSrcCell = 1:srcPlane.cellCount()
                
                srcCell = srcPlane.cellArray(iSrcCell);
                
                cellIsPhantom = 0; %cell is phantom, another focused cell overlapping it
                
                for iDstPlane = 1:length(obj.planeArray)
                
                    %other cell found - break loop
                    if (cellIsPhantom == 1)
                        break;
                    end
                    
                    %ignore current plane
                    if (iDstPlane == iSrcPlane) 
                        continue; 
                    end
                    
                    dstPlane = obj.planeArray(iDstPlane);
                    
                    for iDstCell = 1:dstPlane.cellCount()
                                                
                        dstCell = dstPlane.cellArray(iDstCell);
                        
                        %check if cells overlapp
                        if (obj.checkCellsOverlapp(srcCell,dstCell) == 0)
                            continue;
                        end
                        
                        %check which cell is in focus (1 = src, 0 = dst)
                        if (obj.compareCellsFocus(srcPlane,srcCell,dstPlane,dstCell) == 0)
                            cellIsPhantom = 1; %break plane loop
                            break;
                        end
                    end
                end
                
                %if this appears to be a real cell - copy it's data to
                %final image
               
                if (cellIsPhantom == 0)
                  planeArtifacts(srcCell.ymin : srcCell.ymin+srcCell.height, ...
                                 srcCell.xmin : srcCell.xmin+srcCell.width) = ...                                 
                    planeArtifacts(srcCell.ymin : srcCell.ymin+srcCell.height, ...
                                 srcCell.xmin : srcCell.xmin+srcCell.width) + ...                             
                    srcPlane.meanImage (srcCell.ymin : srcCell.ymin+srcCell.height, ...
                                 srcCell.xmin : srcCell.xmin+srcCell.width);        
                                 
                end               
            end  
        end
        
        function result = compareCellsFocus(obj,srcPlane, srcCell,dstPlane, dstCell)
            
            srcRect = [srcCell.xmin, srcCell.ymin, srcCell.width, srcCell.height];
            dstRect = [dstCell.xmin, dstCell.ymin, dstCell.width, dstCell.height];
            
            %acumulate votes for each cell
            srcVotes = 0;
            dstVotes = 0;
            
            %go over all focus measures and check which cell is in "More
            %focus"
            
            %measures = ['ACMO' ; 'BREN' ; 'CONT' ; 'CURV' ; 'DCTE' ; 'DCTR' ; 'GDER' ; 'GLVA' ; ...
            %            'GLLV' ; 'GLVN' ; 'GRAE' ; 'GRAT' ; 'GRAS' ; 'HELM' ; 'HISE' ; 'HISR' ; ...
            %            'LAPE' ; 'LAPM' ; 'LAPV' ; 'LAPD' ; 'SFIL' ; 'SFRQ' ; 'TENG' ; 'TENV' ; ...
            %            'VOLA' ; 'WAVS' ; 'WAVV' ; 'WAVR'];
            
            measures = ['ACMO' ; 'BREN' ;          'CURV' ;                   'GDER' ; 'GLVA' ; ...
                        'GLLV' ; 'GLVN' ; 'GRAE' ; 'GRAT' ; 'GRAS' ; 'HELM' ; 'HISE' ; 'HISR' ; ...
                        'LAPE' ; 'LAPM' ; 'LAPV' ; 'LAPD' ; 'SFIL' ; 'SFRQ' ; 'TENG' ; 'TENV' ; ...
                        'VOLA' ; 'WAVS' ; 'WAVV' ; 'WAVR'];

            for iMeasure = 1:length(measures)
                srcMeasure = fmeasure(srcPlane.meanImage, measures(iMeasure,:), srcRect);
                dstMeasure = fmeasure(dstPlane.meanImage, measures(iMeasure,:), dstRect);
                
                if (srcMeasure > dstMeasure)
                    srcVotes = srcVotes + 1;
                else 
                    dstVotes = dstVotes + 1;
                end
            end
            
            result = (srcVotes > dstVotes);
        end
         
        function result = checkCellsOverlapp(obj,srcCell,dstCell)
            srcRect = [srcCell.xmin, srcCell.ymin, srcCell.width, srcCell.height];
            dstRect = [dstCell.xmin, dstCell.ymin, dstCell.width, dstCell.height];

            %compare overalpping area to the src rect area - only if
            %overlapping is more than 50% return true;
            overlappArea = rectint(srcRect,dstRect);
            srcArea = srcCell.width * srcCell.height;
            destArea = srcCell.width * srcCell.height;
            
            result = (overlappArea/srcArea > 0.5) && (overlappArea/destArea > 0.5);
       end
        
        function planeArtifacts = createPlaneArtifacts_Method1(obj,iSrcPlane)
            
            %close all;
            planeImage = obj.planeArray(iSrcPlane).meanImage;
            
            %Step 1: Read Image & Median filter
            I = medfilt2(planeImage);
            
            %Step 2: Detect Entire Cell
            BWs = edge(I,'sobel');

            %Step 3: Dilate the Image
            se90 = strel('line', 4, 90);
            se0 = strel('line', 4, 0);
            
            BWsdil = imdilate(BWs, [se90 se0]);
                        
            %Step 4: Fill Interior Gaps
            BWdfill = imfill(BWsdil, 'holes');
            
            %Step 5: Remove Connected Objects on Border
            BWnobord = imclearborder(BWdfill, 4);

            %Step 6: Smoothen the Object
            seD = strel('diamond',2);
            BWfinal = imerode(BWnobord,seD);
            BWfinal = imerode(BWfinal,seD);

            %figure;
            %subplot(2,3,1), imshow(I), title('1.original');
            %subplot(2,3,2), imshow(BWs), title('2.binary gradient mask');
            %subplot(2,3,3),imshow(BWsdil), title('3.dilated gradient mask');
            %subplot(2,3,4), imshow(BWdfill); title('4.binary image with filled holes');
            %subplot(2,3,5), imshow(BWnobord), title('5.cleared border image');
            %subplot(2,3,6), imshow(BWfinal), title('6.segmented image');

            %H = padarray(2,[2 2]) - fspecial('gaussian' ,[5 5],2); % create unsharp mask
            %sharpened = imfilter(I,H);  % create a sharpened version of the image using that mask
            
            %the artifacts botmap shoukld be in the range 0..255 to be
            %compatible with the other algorithm
            planeArtifacts = BWfinal .* planeImage;
        end
        
        function cleanImage = removeFrameArtifacts(obj,srcFrame,srcArtifacts,distance,baseSigma,subFactor)
          
             %close all;
            
             %calc sigma for convolution
             sigma = sqrt(distance)*baseSigma;
             
             %estimate the effect of distance on the src plane
             filtSize = 2*ceil(3*sigma)+1;
             H = fspecial('gaussian' ,[filtSize filtSize],sigma);
             
             %TBD: add additional exponential decay based on distance ?
             srcPhantom = imfilter(srcArtifacts,H);

             %multiply by factor? (unused for now)
             srcPhantom = srcPhantom * subFactor;
             
             %remove noise from current plane
             imageAfter = srcFrame - srcPhantom;
             
             %for now - prevent image from going black
             bgVal = min(min(srcFrame));
             imageAfter(imageAfter < bgVal) = bgVal;
             
             %see the results
             %figure, 
             %subplot(2,2,1); imshow(srcImage); title('Phantom');
             %subplot(2,2,2); imshow(srcPhantom); title('Noise');
             %subplot(2,2,3); imshow(obj.meanImageClean); title('Original');
             %subplot(2,2,4); imshow(imageAfter); title('Result');
             
             cleanImage = imageAfter;
         end
  
         function [nBursts nSporadic] = calcActivityStats(obj,peaksMat)
             
             [nCells,nWndSize] = size( peaksMat);
             
             %sum all columns
             peaksSum = sum(peaksMat);
             
             %check how many times more than 60% of cells fired
             burstsPos = peaksSum > (0.6 * nCells);
             
             %get number of bursts
             nBursts = sum(sum(burstsPos));
             
             %number of sporadic shooting is ALL but bursts
             peaksSumNoBursts = peaksSum;
             peaksSumNoBursts(burstsPos) = 0;
             
             nSporadic = sum(peaksSumNoBursts);
         end
         
           function cellMaskMat = CreateCellsMaskMat(obj)
               
               %since each plane has a different number of cells - use
               %cell-array
               
               nPlanes = length(obj.planeArray);
               cellMaskMat = cell(nPlanes,1);
               
               for iPlane = 1:nPlanes
                   
                   nCells = obj.planeArray(iPlane).cellCount();
                   [nHeight,nWidth] = size (obj.planeArray(iPlane).meanImage);
                   
                   %create empty matrix
                   cellMaskMatPlane = zeros(nHeight,nWidth,nCells);
                   
                   %fill with cell matrix
                   for iCell = 1:nCells
                       cellMaskMatPlane(:,:,iCell) = obj.planeArray(iPlane).cellArray(iCell).cellMask;
                   end
                   
                   %add to main cell
                   cellMaskMat{iPlane} = cellMaskMatPlane;
               end
           end
           
    end
    
end

