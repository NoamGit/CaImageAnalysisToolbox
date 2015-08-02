function redraw(obj, frame)
% this function should have a different impementation for each video type
% I implemented only tiff stack files

    % Read frame
    f = imread(obj.videoFileName,'Index',frame, 'Info', obj.infoImage);

    % Display
    imagesc(f); 
    colormap(gray)
    axis image off
end

