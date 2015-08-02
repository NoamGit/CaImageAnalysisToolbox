%main program
clear all; close all; clc;

videoPath = 'C:\Users\Orit\Desktop\טכניון\פרוייקט ארז\סרטים';
%videoPath = 'C:\Users\Gal\Google Drive\BioMedical Project\Movies';
videoFilename = '14-mg+e18rat (4m,50ul) day 19 gcamp6 spont 8hzx20-5min base+100 um carbachol-wash4.avi';
videoFullname = [videoPath,'\',videoFilename];

PLANES_NUM = 3; %number of planes in image

engine = Engine(videoFullname, PLANES_NUM);

%% Extract images from vid to subdir 'snaps'

engine.divideMovieToPlanes();

%% prepare plane & cells config

if exist('setup.mat', 'file')
    load ('setup.mat');
else
    
    engine.preparePlanesWithCells();
    engine.loadCellsData();
    save('setup.mat', 'engine');
end


%% open movie file

readerobj = VideoReader(videoFullname);
nFrames = readerobj.NumberOfFrames;
fFrameRate = readerobj.FrameRate;
fDuration = readerobj.Duration;
fTimeSample = 1/fFrameRate;


%% Deternd & Normalize (calc dF/F)
for iPlane = 1 : PLANES_NUM
    
    %number of cells in this plane
    nCells = engine.planeArray(iPlane).cellCount();
    
    for iCell = 1: nCells
        engine.planeArray(iPlane).cellArray(iCell).detrend();
        engine.planeArray(iPlane).cellArray(iCell).normalize();
    end
end

%% For a single cell - plot response
plotPlaneNum = 2;
plotCellNum = 1;

engine.planeArray(plotPlaneNum).cellArray(plotCellNum).detrend(100*(fFrameRate/PLANES_NUM));
engine.planeArray(plotPlaneNum).cellArray(plotCellNum).normalize(100*(fFrameRate/PLANES_NUM));

axisTime = (0:engine.planeArray(plotPlaneNum).cellArray(plotCellNum).dataCount()-1)*fTimeSample*PLANES_NUM;

figure;
subplot(3,1,1);
plot(axisTime,engine.planeArray(plotPlaneNum).cellArray(plotCellNum).rawData);
title('Plane#3, Cell #0 Fluorescence Activity (Raw Data)');
xlabel('Time [s]'); ylabel('Fluorescence');

subplot(3,1,2);
plot(axisTime,engine.planeArray(plotPlaneNum).cellArray(plotCellNum).detrendData);
title('Plane#3, Cell #0 Fluorescence Activity (Detrend)');
xlabel('Time [s]'); ylabel('Fluorescence');

subplot(3,1,3);
plot(axisTime,engine.planeArray(plotPlaneNum).cellArray(plotCellNum).normData);
title('Plane#3, Cell #0 Fluorescence Activity (Normalized)');
xlabel('Time [s]'); ylabel('Fluorescence');

%% Mean Images
%engine.createPlaneMeanImage();
engine.createPlanesPartialMeanImage(100);

%% Plot result
segmentPlaneNum = 2;

figure;
imagesc(engine.planeArray(segmentPlaneNum).meanImage)
colormap(gray);

engine.planeArray(segmentPlaneNum).segment();

