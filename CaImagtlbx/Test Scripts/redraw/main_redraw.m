% vid = VideoReader('rhinos.avi');
vidpath = 'D:\# Projects (Noam)\# SLITE\# DATA\150720Rtina - ANALYSIS\FLASH_20msON_20Hz_SLITE_1.tif';
InfoImage = imfinfo(vidpath);
NumberOfFrames = numel(InfoImage);

% Set up video figure window
videofig(NumberOfFrames, @(frm) redraw(frm, vidpath, InfoImage));

% Display initial frame
redraw(1, vidpath, InfoImage);