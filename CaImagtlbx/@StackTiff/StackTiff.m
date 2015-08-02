classdef StackTiff < Engine
    % Subclass of engine from type tiff
    
    properties 
        infoImage;
        frameRate;
    end
    
    methods
            function obj = StackTiff(videoFullName, nPlanes, framerate)
                % constructor function for stacktiff
                obj.videoType = 2;
                obj.videoFileName = videoFullName;
                obj.planeArray = Plane.empty(nPlanes, 0);
                for iPlane=1:nPlanes
                    % Create a plane:
                    obj.planeArray(iPlane) = Plane();
                end
                FileTif = videoFullName;
                InfoImage=imfinfo(FileTif);
                obj.nFrames=length(InfoImage);
                obj.Height = InfoImage(1).Height;
                obj.Width = InfoImage(1).Width;
                obj.infoImage = InfoImage;
                obj.isLoaded = false;
                obj.frameRate = framerate;
            end
            
            redraw(obj, frame)
    end
end

