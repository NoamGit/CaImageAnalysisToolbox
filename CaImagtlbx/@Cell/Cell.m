classdef Cell < handle
% data structure for trimmed images location definng a cell    
    %------------------------------------------------------------------
    % Properties
    %------------------------------------------------------------------
    
    properties
        cellMask = [];
        % Blocking Rectangle:
        xmin = 0; ymin = 0; width = 0; height = 0;
        circumferenceLine = [];
        pixelNum = 0;
        rawData = [];
        detrendData = [];
        normData = [];
        peaksData = [];
    end
    
    %------------------------------------------------------------------
    % Methods
    %------------------------------------------------------------------
    
    methods
        
        %Constructor
        function obj = Cell(cellMask, xmin, ymin, width, height, circumference)
            
            obj.cellMask = cellMask;
            obj.xmin = xmin;
            obj.ymin = ymin;
            obj.width = width;
            obj.height = height;
            obj.circumferenceLine = circumference;
            obj.pixelNum = sum(sum(cellMask));
            obj.rawData = [];
            obj.detrendData = [];
            obj.normData = [];
            obj.peaksData = [];
        end
        
        % description(=location) of the cell
        function desc = getDescription(obj)
            desc = sprintf('At (%4d,%4d) W=%4d, H=%4d',obj.xmin, obj.ymin, obj.width, obj.height);
        end
        
        function [xmin, ymin, width, height] = getPosition(obj)
            xmin = obj.xmin;
            ymin = obj.ymin;
            width = obj.width;
            height = obj.height;
        end
        
        function circLine = getCircumferenceLine(obj)
            circLine = obj.circumferenceLine;
        end
        
        %add data from new frame - NOT Used
        function addFrameData(obj, fullFrame)
            %frameWithMask = fullFrame.*obj.cellMask;
            fullFrame(obj.cellMask == 0) = 0;
            %cell_roi = frame_with_mask(ymin:ymin+height,xmin:xmin+width);
            fVal = (sum(sum(fullFrame)))/obj.pixelNum;
            %add to list of valuse
            obj.rawData = [obj.rawData; fVal];
        end
        
        %Deterned
        function detrend(obj, nIntervalSize)
            %Our implementation
            %n = 1:length(obj.rawData);
            %polyCoefs = polyfit(n',obj.rawData,1);
            %trend=polyval(polyCoefs,n);
            %obj.detrendData = obj.rawData - trend';
            
            %Matlab built-in
            if (nargin == 1)
                nIntervalSize = obj.dataCount();
            end
            
            BP = 1:nIntervalSize:obj.dataCount();
            obj.detrendData = detrend(obj.rawData,'linear',BP);
            
            %minData = min(obj.detrendData);
            %if (minData < 0)
            %    obj.detrendData = obj.detrendData + abs(minData);
            %end
            
            %fow now - don't detrend
            obj.detrendData = obj.rawData;
        end
        
        %Normalize
        function normalize_Method1(obj, nIntervalSize)
            %f0 = prctile(obj.detrendData,5); %find perctile 5 of x
            
            obj.normData = zeros(obj.dataCount,1);
            
            if ((nargin == 1) || (nIntervalSize > obj.dataCount()))
                nIntervalSize = obj.dataCount();
            end
            
            %make sure interval is odd
            if (mod(nIntervalSize,2) == 0)
                nIntervalSize = nIntervalSize+1;
            end
            
            nIntervalHalfSize = (nIntervalSize-1)/2;
            
            %might need to chop data to use rehspae
            detrendDataInt = [obj.detrendData(1:nIntervalHalfSize); ...
                obj.detrendData; ...
                obj.detrendData(obj.dataCount()-nIntervalHalfSize:obj.dataCount())];
            
            for i = 1:obj.dataCount()
                pos = i + nIntervalHalfSize;
                f = detrendDataInt(pos);
                f0 = prctile(detrendDataInt(pos-nIntervalHalfSize:pos+nIntervalHalfSize),5);
                obj.normData(i) = (f-f0)/f0;
            end
            
            %prevent negative values
            %minData = min(obj.normData);
            %if (minData < 0)
            %    obj.normData = obj.normData + abs(minData);
            %end
        end
        
        function normalize_Method2(obj, nIntervalSize)
            %f0 = prctile(obj.detrendData,5); %find perctile 5 of x
            %obj.normData = obj.detrendData - f0;
            
            if (nargin == 1)
                nIntervalSize = obj.dataCount();
            end
            
            %might need to chop data to use rehspae
            if (nIntervalSize > obj.dataCount())
                rows = obj.dataCount();
                cols = 1;
            else
                rows = nIntervalSize;
                cols = floor(obj.dataCount() / rows);
            end
            
            effectiveSize = rows*cols;
            
            dataIntervals = reshape(obj.detrendData(1:effectiveSize),rows,cols);
            
            %calc mean for each interval
            f0 = mean(dataIntervals);
            
            %create matrix for easy usage
            f0Matrix = repmat(f0,rows,1);
            
            %calc df/f
            normIntervals = (dataIntervals - f0Matrix) ./ dataIntervals;
            
            %rehspae back to column
            obj.normData = reshape(normIntervals,effectiveSize,1);
            
            %handle places where we divided by 0
            %obj.normData(obj.normData == -Inf) = 0;
            
            %interpolate missing data using last element
            obj.normData(effectiveSize+1:obj.dataCount()) = obj.normData(effectiveSize);
            
            %add min value to make sure result is above zero
            minData = min(obj.normData);
            if (minData < 0)
                obj.normData = obj.normData + abs(minData);
            end
            
            %fow now - don't norm
            obj.normData = obj.detrendData;
        end
        
        % find peacks using basic naive approach
        function calcPeaks_Method1(obj, timeSampleSec, Threshold)
            
            peaks = zeros(1,obj.dataCount());
            obj.peaksData = zeros(1,obj.dataCount());
            
            %peaks are where the derivative is high enough
            dF = diff(obj.normData);
            peaks(dF > (Threshold * max(dF))) = 1;
            
            %if derivative is high for succsesive frames, consider it as one
            dPeaks = diff(peaks);
            obj.peaksData = peaks;
            obj.peaksData(dPeaks == 0) = 0;
            
            %             figure;
            %             subplot(4,1,1);
            %             plot(obj.normData);
            %             subplot(4,1,2);
            %             plot(dF);
            %             subplot(4,1,3);
            %             peaks(peaks == 0) = NaN;
            %             stem(peaks);
            %             subplot(4,1,4);
            %             obj.peaksData(obj.peaksData == 0) = NaN;
            %             stem(obj.peaksData);
        end
        
        % find peacks using semi-naive approach
        function calcPeaks_Method2(obj,timeSampleSec, Threshold)
            
            %some defines
            DIFF_PEAK_TH = Threshold;
            
            %state has -1 elements due to usage of diff function
            stateData = zeros(1,obj.dataCount());
            
            %call differential of data
            dF = diff(obj.normData);
            
            %detect peaks based on diff & treshold
            %the usage of abs() let's us capture peaks going up and
            %going down
            stateChanges = zeros(1,obj.dataCount());
            
            stateChanges(dF > DIFF_PEAK_TH) = 1;
            stateChanges(dF < -DIFF_PEAK_TH) = -1;
            
            %create state vector based on previous data
            stateData(1) = 0; %set first state ="IDLE"
            
            for iVal = 2:length(stateChanges)
                
                prevState = stateData(iVal-1);
                currChange = stateChanges(iVal);
                
                currState = 0; %the one we are looking for
                
                switch prevState
                    case 0 %no peak before
                        
                        switch currChange
                            case 0 %no change - keep current state
                                currState = 0;
                                
                            case 1 %going up - start new peak
                                currState = 1;
                                
                            case -1 %going down - shouldn't happen - will ignore it
                                currState = 0;
                        end
                        
                    case 1 %already in peak
                        switch currChange
                            case 0 %no change - keep current state
                                currState = 1;
                                
                            case 1 %going up - shouldn't happen - will ignore it
                                currState = 1;
                                
                            case -1 %going down - stop peak
                                currState = 0;
                        end
                end
                
                stateData(iVal) = currState;
            end
            
            %calc peaks based on state changes
            obj.peaksData = zeros(1,obj.dataCount());
            obj.peaksData(diff(stateData) == 1) = 1;
            
            %plot for debug
            %figure;
            %subplot(5,1,1); plot(obj.normData); title('Norm data');
            %subplot(5,1,2); plot(dF); title('dF');
            %subplot(5,1,3); plot(stateChanges); title('State changes');
            %subplot(5,1,4); plot(stateData); title('State data');
            %subplot(5,1,5); plot(obj.peaksData); title('Peaks data');
        end
        
        % find peaks using matlab's 'findpeaks' function
        function calcPeaks_Method3(obj,timeSampleSec, Threshold)
            
            minPeakHeight = max(obj.normData)/2; %minimum peak height
            minPeakDistance = ceil(100e-3/timeSampleSec); %base it on frame-rate compared to AP time
            thresh = Threshold; %peak difference from surrounding points
            
            [~, peaksIndex] = findpeaks(obj.normData,'MinPeakHeight',minPeakHeight,...
                'MinPeakDistance',minPeakDistance,...
                'Threshold', thresh);
            
            obj.peaksData = zeros(1,obj.dataCount());
            obj.peaksData(peaksIndex) = 1;
        end
        
        % find peaks using 'PeakFinder' function
        function calcPeaks_Method4(obj,timeSampleSec, Threshold)
            
            %   INPUTS:
            %       x0 - A real vector from the maxima will be found (required)
            %       sel - The amount above surrounding data for a peak to be
            %           identified (default = (max(x0)-min(x0))/4). Larger values mean
            %           the algorithm is more selective in finding peaks.
            %       thresh - A threshold value which peaks must be larger than to be
            %           maxima or smaller than to be minima.
            %       extrema - 1 if maxima are desired, -1 if minima are desired
            %           (default = maxima, 1)
            %       include_endpoints - If true the endpoints will be included as
            %           possible extrema otherwise they will not be included
            %           (default = true)
            
            sel = Threshold;
            thresh = max(obj.normData)/2;
            extrema = 1;
            include_endpoints = 1;
            
            peaksIndex = peakfinder(obj.normData, sel, thresh, extrema, include_endpoints);
            
            obj.peaksData = zeros(1,obj.dataCount());
            obj.peaksData(peaksIndex) = 1;
        end
        
        
        %clear all data (except position & mask)
        function clearData(obj)
            obj.rawData = [];
            obj.detrendData = [];
            obj.normData = [];
            obj.peaksData = [];
        end
        
        %number of frames
        function count = dataCount(obj)
            count = length(obj.rawData);
        end
        
    end
end