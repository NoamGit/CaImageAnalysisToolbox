function divideMovieToPlanes(videoFileName, nPlanes)
            %%Extracting & Saving of frames from a Video file through Matlab Code%%
            
            
            % if folder 'snaps' exists - do nothong.
            [pathStr,~,~] = fileparts(videoFileName);
            snapsPath = fullfile(pathStr, 'snaps');
            if exist(snapsPath,'dir')
                return;
            end
            
            tic
            opFolder=[];
            % set folder's names for each plane under 'snaps'
            for iPlane=1:nPlanes
                opFolder = [opFolder; fullfile(pathStr, ['snaps\plane',num2str(iPlane)])];
                if ~exist(opFolder(iPlane,:), 'dir')
                    mkdir(opFolder(iPlane,:));
                end
            end
            
            %reading a video file
            readerObj = VideoReader(videoFileName);
            
            %getting no of frames
            nFrames = readerObj.NumberOfFrames;
            disp(['reading ', num2str(nFrames), 'from a video file: '  videoFileName]);
            
            %setting current status of number of frames written to zero
            nFramesWritten = 0;
            nFramesToRead = floor(nFrames/nPlanes) * nPlanes;
            
            %read
            for iPlane = 1 : nPlanes : nFramesToRead
                for j=1:nPlanes
                    currFrame = read(readerObj, iPlane+j-1);    %reading individual frames
                    opBaseFileName = sprintf('%3.3d.jpg', floor(iPlane/nPlanes));
                    opFullFileName = fullfile(opFolder(j,:), opBaseFileName);
                    imwrite(currFrame, opFullFileName, 'jpg');   %saving as 'png' file
                end
                %indicating the current progress of the file/frame written
                progIndication = sprintf('Wrote frame %4d of %d.', iPlane, nFrames);
                disp(progIndication);
                nFramesWritten = nFramesWritten + 1;
            end      %end of 'for' loop
            progIndication = sprintf('Done.');
            disp(progIndication);
            toc
            %End of the code
            
            % Read more: http://www.divilabs.com/2013/11/extracting-saving-of-frames-from-video.html#ixzz3G02AiREY
            
        end