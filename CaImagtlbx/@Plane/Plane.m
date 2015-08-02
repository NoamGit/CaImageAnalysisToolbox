classdef Plane < handle
% stack data structures for several images

    %------------------------------------------------------------------
    % Properties
    %------------------------------------------------------------------
    
    properties
        cellArray = [];
        meanImage = [];
        meanImageClean = [];
        planeArtifacts = [];
    end
    
    %------------------------------------------------------------------
    % Methods
    %------------------------------------------------------------------
    
    methods
        
        %Constructor
        function obj = Plane()            
            obj.cellArray = Cell.empty();
        end
        
        function clearAllCells(obj)
            obj.cellArray = Cell.empty();
        end
        
        function addCell(obj, cell)
            obj.cellArray = [ obj.cellArray , cell ];
        end

        function deleteCell(obj, indx)
            obj.cellArray(indx) = [];
        end
        
        function count = cellCount(obj)
            count = length(obj.cellArray);
        end
        
        function segment_Method1(obj, useCleanImage, marginSize)
            %% Segmentation using a naive algorithems
            
            %figure;
            
            %Step 1: Read Image
            if useCleanImage == 1
                I = double(obj.meanImageClean);
            else
                I = double(obj.meanImage);
            end

            th = mean2(I) + marginSize*std2(I);           
            bw = zeros(size(I));
            bw(I>th) = 1;

            %Step 6: Identify Objects in the Image
            cc = bwconncomp(bw, 4);
            
            %Step 8: View All Objects
            labeled = labelmatrix(cc);
            RGB_label = label2rgb(labeled, @spring, 'c', 'shuffle');
            %subplot(3,3,7), imshow(RGB_label), title('7.Final');;
            
            %Step 9: get some advanced props
            BoundingBoxArray = regionprops(labeled,'BoundingBox');
            BoundingLineArray = regionprops(labeled,'ConvexHull');
            
            for iCell = 1:length(BoundingBoxArray)
                [maxHeight,maxWidth] = size(obj.meanImage);
                
                mask = uint8(zeros(size(obj.meanImage)));                               
                xmin = uint32(BoundingBoxArray(iCell).BoundingBox(1));
                ymin = uint32(BoundingBoxArray(iCell).BoundingBox(2));
                width = uint32(BoundingBoxArray(iCell).BoundingBox(3));
                height = uint32(BoundingBoxArray(iCell).BoundingBox(4));
                circumference = uint32(BoundingLineArray(iCell).ConvexHull);
                if (xmin + width > maxWidth)
                    width = maxWidth - xmin;
                end
                
                 if (ymin + height > maxHeight)
                    height = maxHeight - ymin;
                end
                mask(ymin:ymin+height, xmin:xmin+width) = 1;
                
                if ((width > 1) && (height > 1)) 
                    obj.addCell(Cell(mask, xmin, ymin, width, height, circumference));
                end
            end
            
            obj.filterCells();
                
%             figure;
%             subplot(1,3,1), imshow(I), title('1.original');
%             subplot(1,3,2), imshow(bw), title('2.remove background');
%             subplot(1,3,3), imshow(RGB_label), title('7.Final');;
             
            
%             a = regionprops(labeled,'BoundingBox');
%             b = regionprops(labeled,'Centroid');
%             c = regionprops(labeled,'Image');
%             d = regionprops(labeled,'MajorAxisLength');
%             e = regionprops(labeled,'MinorAxisLength');
%             

        end
        
        function segment_Method2(obj, useCleanImage, marginSize)
            %% Segmentation using matlab's algorithems
            
            
            %Step 1: Read Image
            if useCleanImage == 1
                I = double(obj.meanImageClean);
            else
                I = double(obj.meanImage);
            end
            
            %can be done here or later
            %I = (I-min(min(I)))/(max(max(I)));
            
            %Step 2: Use Morphological Opening to Estimate the Background
            background = imopen(I,strel('disk',15));
            
            %Step 3: Subtract the Background Image from the Original Image
            I2_nobg = I - background;
            
            %NOTE: Note that step 2 and step 3 together could be replaced by a single
            %step using imtophat which first calculates the morphological opening and then subtracts it from the original image
            %I2 = imtophat(I,strel('disk',15));
            
            %Step 4: Increase the Image Contrast
            %Note: Image should be normzlied before we do this
            I2 = (I2_nobg-min(min(I2_nobg)))/(max(max(I2_nobg)));
            
            I3 = imadjust(I2);
            
            %Step 5: Threshold the Image
            level = graythresh(I3);
            bw = im2bw(I3,level);
            
            bw = bwareaopen(bw, 50);
            
            %Step 6: Identify Objects in the Image
            cc = bwconncomp(bw, 4);
            
            %Step 8: View All Objects
            labeled = labelmatrix(cc);
            RGB_label = label2rgb(labeled, @spring, 'c', 'shuffle');
            
           
            %Step 9: get some advanced props
            BoundingBoxArray = regionprops(labeled,'BoundingBox');
            BoundingLineArray = regionprops(labeled,'ConvexHull');
            
            
            for iCell = 1:length(BoundingBoxArray)
                [maxHeight,maxWidth] = size(obj.meanImage);
                
                mask = uint8(zeros(size(obj.meanImage)));                               
                xmin = uint32(BoundingBoxArray(iCell).BoundingBox(1));
                ymin = uint32(BoundingBoxArray(iCell).BoundingBox(2));
                width = uint32(BoundingBoxArray(iCell).BoundingBox(3));
                height = uint32(BoundingBoxArray(iCell).BoundingBox(4));
                circumference = uint32(BoundingLineArray(iCell).ConvexHull);
                if (xmin + width > maxWidth)
                    width = maxWidth - xmin;
                end
                
                 if (ymin + height > maxHeight)
                    height = maxHeight - ymin;
                end
                mask(ymin:ymin+height, xmin:xmin+width) = 1;
                
                if ((width > 1) && (height > 1)) 
                    obj.addCell(Cell(mask, xmin, ymin, width, height, circumference));
                end
            end
            
%             figure;
%             subplot(3,3,1), imshow(I), title('1.original');
%             subplot(3,3,2), imshow(I2), title('2.remove background');
%             subplot(3,3,3), imshow(I2), title('3.normalized');
%             subplot(3,3,4), imshow(I3), title('4.increase contrast');
%             subplot(3,3,5), imshow(bw), title('5.Threshold');
%             subplot(3,3,6), imshow(bw), title('6.Opened');
%             subplot(3,3,7), imshow(RGB_label), title('7.Final');;
            
            
            obj.filterCells();
                
%             a = regionprops(labeled,'BoundingBox');
%             b = regionprops(labeled,'Centroid');
%             c = regionprops(labeled,'Image');
%             d = regionprops(labeled,'MajorAxisLength');
%             e = regionprops(labeled,'MinorAxisLength');
%             
        end
        
        function filterCells(obj)
            %go over cell array, calc mean area and remove illeage cells
            widthArray = zeros(1,obj.cellCount());
            heightArray = zeros(1,obj.cellCount());
            areaArray = zeros(1,obj.cellCount());
            
            
            for iCell = 1:obj.cellCount()
                widthArray(iCell) = obj.cellArray(iCell).width;
                heightArray(iCell) = obj.cellArray(iCell).height;
                areaArray(iCell) = obj.cellArray(iCell).width * obj.cellArray(iCell).height;
            end
            
            meanWidth = mean(widthArray); stdWidth = std(widthArray);
            meanHeight = mean(heightArray); stdHeight = std(heightArray);
            meanArea = mean(areaArray); stdArea = std(areaArray);
            
            %remove all cells whos area is outside of 3xSD from the mean
            filtFact = 2; %how many SDs to take arroudn the mean
            minWidth = meanWidth - filtFact*stdWidth; maxWidth = meanWidth + filtFact*stdWidth;
            minHeight = meanHeight - filtFact*stdHeight; maxHeight = meanHeight + filtFact*stdHeight;
            minArea = meanArea - filtFact*stdArea; maxArea = meanArea + filtFact*stdArea;
            
            deleteIndexArray = find ((widthArray < minWidth) | (widthArray > maxWidth) | ...
                                     (heightArray < minHeight) | (heightArray > maxHeight) | ...
                                     (areaArray < minArea) | (areaArray > maxArea));
            
            for iDeleteCell = length(deleteIndexArray):-1:1
                obj.deleteCell(deleteIndexArray(iDeleteCell));
            end
        end
       
    end
end
