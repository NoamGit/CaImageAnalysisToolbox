function redraw(frame, vidPath, info)
% REDRAW  Process a particular frame of the video
%   REDRAW(FRAME, VIDOBJ)
%       frame  - frame number to process
%       vidObj - VideoReader object

% Read frame
f = imread(vidPath,'Index',frame, 'Info', info);

% % Get edge
% f2 = edge(rgb2gray(f), 'canny');

% % Overlay edge on original image
% f3 = bsxfun(@plus, f,  uint8(255*f2));

% Display
imagesc(f); 
colormap(gray)
axis image off
end

%% original code
% function redraw(frame, vidObj)
%     % Read frame
%     f = vidObj.read(frame);
% 
%     % Get edge
%     f2 = edge(rgb2gray(f), 'canny');
% 
%     % Overlay edge on original image
%     f3 = bsxfun(@plus, f,  uint8(255*f2));
% 
%     % Display
%     image(f3); axis image off
% end