function varargout = main_gui(varargin)
% MAIN_GUI MATLAB code for main_gui.fig
%      MAIN_GUI, by itself, creates a new MAIN_GUI or raises the existing
%      singleton*.
%
%      H = MAIN_GUI returns the handle to a new MAIN_GUI or the handle to
%      the existing singleton*.
%
%      MAIN_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MAIN_GUI.M with the given input arguments.
%
%      MAIN_GUI('Property','Value',...) creates a new MAIN_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before main_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to main_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help main_gui

% Last Modified by GUIDE v2.5 04-Jul-2015 17:09:10

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @main_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @main_gui_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before main_gui is made visible.
function main_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to main_gui (see VARARGIN)

% Choose default command line output for main_gui
handles.output = hObject;

axes(handles.axesLogo); imshow('Logo.jpg');
axes(handles.axesTechion); imshow('Technion.jpg');

% User Data:
handles.operationalState = 'not loaded';
Acc_UpdateOperationalState(handles);
handles.nPlanes = 1;
handles.iPlane = 1;
handles.removeArtifacts = 0;
handles.hLineArray = [];
handles.hNumArray = [];
handles.selCellArray = [];
handles.cellList = [];
handles.cellPlaneList = [];
S = get(handles.TextBox_DistBetweenPlanes, 'string');
val = fix(str2double(S));
handles.planesDistance = val;
S = get(handles.TextBox_MinValue, 'string');
val = fix(str2double(S));
handles.minVal2display = val;
S = get(handles.TextBox_MaxValue, 'string');
val = fix(str2double(S));
handles.maxVal2display = val;
S = get(handles.TextBox_grid_M, 'string');
val = fix(str2double(S));
handles.grid_M = val;
S = get(handles.TextBox_grid_N, 'string');
val = fix(str2double(S));
handles.grid_N = val;
S = get(handles.TextBox_WaveMinFrame, 'string');
val = str2double(S);
handles.WaveMinTime = val;
S = get(handles.TextBox_WaveMaxFrame, 'string');
val = str2double(S);
handles.WaveMaxTime = val;
%Acc_restoreState(hObject, handles, 'last_setting.mat');
handles = Acc_loadSetupFile(handles);

% Update handles structure
guidata(hObject, handles);


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, ~, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
Acc_saveState(handles, 'last_setting.mat');
delete(hObject);


% --- Outputs from this function are returned to the command line.
function varargout = main_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% ---------------------------------------------------------------------%
% ---------------------------------------------------------------------%
% -------------------- Accessory Functions ----------------------------%
% ---------------------------------------------------------------------%
% ---------------------------------------------------------------------%
function handles = Acc_loadSetupFile(handles)
%-----------------------------------------------
% Define Default Values for setup parameters:
%-----------------------------------------------
handles.SegmentationMethod = 1;
handles.ArtifactRemovalMethod = 1;
handles.PeakDetectionMethod = 3;

handles.CellCircleRadius = 10; % units = [pixels]
handles.SegmentationThresholdMargin = 2; % units = [sigma]
handles.PeakDetectThreshold = 0.5;
handles.ArtifactRemovalBaseSigma = 1;
handles.ArtifactRemovalSubtractionFactor = 0.8;
handles.NormalizeWindowSizeSamples = 100;
handles.lalala = 33.3; % you can add additional parameters...
%-----------------------------------------------

if exist('Setup_Params.txt', 'file')  
    fileID = fopen('Setup_Params.txt', 'r', 'n', 'US-ASCII');
    C = textscan(fileID,'%s %f');
    for i=1: length(C{1})
        if strcmp(C{1}(i), 'SegmentationMethod')
            handles.SegmentationMethod = C{2}(i);
        end
        if strcmp(C{1}(i), 'ArtifactRemovalMethod')
            handles.ArtifactRemovalMethod = C{2}(i);
        end
        if strcmp(C{1}(i), 'PeakDetectionMethod')
            handles.PeakDetectionMethod = C{2}(i);
        end
        if strcmp(C{1}(i), 'CellCircleRadius')
            handles.CellCircleRadius = C{2}(i);
        end
        if strcmp(C{1}(i), 'SegmentationThresholdMargin')
            handles.SegmentationThresholdMargin = C{2}(i);
        end
        if strcmp(C{1}(i), 'PeakDetectThreshold')
            handles.PeakDetectThreshold = C{2}(i);
        end
        if strcmp(C{1}(i), 'ArtifactRemovalBaseSigma')
            handles.ArtifactRemovalBaseSigma = C{2}(i);
        end
        if strcmp(C{1}(i), 'ArtifactRemovalSubtractionFactor')
            handles.ArtifactRemovalSubtractionFactor = C{2}(i);
        end
        if strcmp(C{1}(i), 'NormalizeWindowSizeSamples')
            handles.NormalizeWindowSizeSamples = C{2}(i);
        end

        if strcmp(C{1}(i), 'lalala')
            handles.lalala = C{2}(i);
        end
    end
    fclose(fileID);
end


function Acc_saveActivityMaps(handles, filename)
%create the matrix - each line is a cell    
    nRows = length(handles.cellList);
    nCols = handles.engine.planeArray(handles.cellPlaneList(1)).cellArray(1).dataCount();

    activityMat_raw = zeros(nRows,nCols);
    activityMat_norm = zeros(nRows,nCols);
    
    for iCell = 1:nRows        
        cellNo = handles.cellList(iCell);
        planeNo = handles.cellPlaneList(iCell);
        activityMat_raw(iCell,:) = handles.engine.planeArray(planeNo).cellArray(cellNo).rawData;
        activityMat_norm(iCell,:) = handles.engine.planeArray(planeNo).cellArray(cellNo).normData;
    end
    
    save(filename, 'activityMat_raw', '-append');
    save(filename, 'activityMat_norm', '-append');
    
%     [pathstr,name,~] = fileparts(filename);
%     filename_raw_data = sprintf('%s%s_raw_data.mat', pathstr, name);
%     filename_norm_data = sprintf('%s%s_norm_data.mat', pathstr, name);
%     save(filename_raw_data, 'activityMat_raw');
%     save(filename_norm_data, 'activityMat_norm');
%     
    
function Acc_saveState(handles, filename)

state.fileType = Acc_GetFileType(handles);
state.minVal2display = handles.minVal2display;
state.maxVal2display = handles.maxVal2display;
state.operationalState = handles.operationalState;
state.WaveMinTime = handles.WaveMinTime;
state.WaveMaxTime = handles.WaveMaxTime;

if isfield(handles,'videoFullName') 
    state.videoFullName = handles.videoFullName;
    state.TextBox_vidFileName = get(handles.TextBox_vidFileName, 'string'); 
end
if isfield(handles,'nPlanes') 
    state.nPlanes = handles.nPlanes;
end
if isfield(handles,'frameRate') 
     state.frameRate = handles.frameRate;
end
if isfield(handles,'planesDistance') 
     state.planesDistance = handles.planesDistance;
end
if isfield(handles,'MaxFrameNum') 
    state.MaxFrameNum = handles.MaxFrameNum;
end
if isfield(handles,'removeArtifacts') 
    state.removeArtifacts = handles.removeArtifacts; 
end
if isfield(handles,'engine')  
    state.engine = handles.engine;
    state.iPlane = handles.iPlane;
end
if isfield(handles,'ProcessFromFrame')
    state.ProcessFromFrame = handles.ProcessFromFrame;
    state.ProcessUpToFrame = handles.ProcessUpToFrame;    
end
if isfield(handles,'grid_M')
    state.grid_M = handles.grid_M;
end
if isfield(handles,'grid_N')
    state.grid_N = handles.grid_N;
end
if (exist('state', 'var') == 1)
    save(filename, 'state');
end

% Save the 'Activity Map' of all cells (can be done only if already loaded)
if strcmp(handles.operationalState, 'cells loaded')    
    Acc_saveActivityMaps(handles, filename)    
end


function handles = Acc_restoreState(hObject, handles, filename)
if exist(filename, 'file')    
    load (filename);    
    % Restore File Type:
    if (state.fileType == 1) %'AVI/MP4'
        set(handles.radiobutton_ImageSourceAvi, 'value', 1);
    end
    if (state.fileType == 2) %'MultipleImageTif'
        set(handles.radiobutton_ImageSourceMultipleTif, 'value', 1);
    end      
    if (state.fileType == 3) %'SingleImageTif'
        set(handles.radiobutton_ImageSourceSingleTifs, 'value', 1);
    end
    handles.operationalState = state.operationalState;        
    handles.minVal2display = state.minVal2display;
    handles.maxVal2display = state.maxVal2display;
    set(handles.TextBox_MinValue, 'string', num2str(state.minVal2display));
    set(handles.TextBox_MaxValue, 'string', num2str(state.maxVal2display));
    if isfield(state,'WaveMinTime') 
        handles.WaveMinTime = state.WaveMinTime;
        set(handles.TextBox_WaveMinFrame, 'string', num2str(state.WaveMinTime));
    end
    if isfield(state,'WaveMaxTime') 
        handles.WaveMaxTime = state.WaveMaxTime;
        set(handles.TextBox_WaveMaxFrame, 'string', num2str(state.WaveMaxTime));
    end

    % Restore File Name:
    if isfield(state,'videoFullName') 
        handles.videoFullName = state.videoFullName;
        set(handles.TextBox_vidFileName, 'string', state.TextBox_vidFileName); 
        [tmp_frameRate, tmp_numFrames] = Acc_UpdateVidAttrib(handles, state.fileType, state.videoFullName);
        % save the reader object, for faster access
        if(state.fileType == 1) %'AVI/MP4'
            handles.readerObj = VideoReader(handles.videoFullName);
        end
    end
    if isfield(state,'frameRate') 
        handles.frameRate = state.frameRate;        
        if isfield(state,'MaxFrameNum')
            FilmDuration = state.MaxFrameNum/state.frameRate;
        else
            FilmDuration = tmp_numFrames/state.frameRate;
        end
        set(handles.TextBox_FrameRate, 'string', num2str(state.frameRate));
        set (handles.TextBox_FilmDuration, 'string', num2str(FilmDuration));
        
    end
    if isfield(state,'planesDistance') 
        handles.planesDistance = state.planesDistance;
        set(handles.TextBox_DistBetweenPlanes, 'string', num2str(state.planesDistance));
    end    
    if isfield(state,'nPlanes') 
        handles.nPlanes = state.nPlanes;
        set(handles.TextBox_numOfPlanes, 'string', num2str(state.nPlanes));
    end
    if isfield(state,'MaxFrameNum') 
        handles.MaxFrameNum = state.MaxFrameNum;
    end
    if isfield(state,'grid_M')
        handles.grid_M = state.grid_M;
        set(handles.TextBox_grid_M, 'string', num2str(state.grid_M));
    end
    if isfield(state,'grid_N')
        handles.grid_N = state.grid_N;
        set(handles.TextBox_grid_N, 'string', num2str(state.grid_N));
    end
    if isfield(state,'ProcessFromFrame')
        handles.ProcessFromFrame = state.ProcessFromFrame;
        handles.ProcessUpToFrame = state.ProcessUpToFrame;
        set(handles.TextBox_ProcessFromFrame, 'string', num2str(state.ProcessFromFrame));
        set(handles.TextBox_ProcessUpToFrame, 'string', num2str(state.ProcessUpToFrame));
    end
    if isfield(state,'removeArtifacts')
        handles.removeArtifacts = state.removeArtifacts; 
        set(handles.checkbox_remove_artifacts, 'value', state.removeArtifacts);
    end
    if isfield(state,'engine')  
        handles.engine = state.engine;                
        handles.iPlane = state.iPlane;                   
                               
        [handles.cellList, handles.cellPlaneList] = Acc_UpdateCellDisplay(handles);
        Acc_UpdatePlaneDisplay(handles);  
    end   
    
    handles.selCellArray = [];
    handles.hLineArray = [];
    handles.hNumArray = [];
    set(handles.TextBox_SelectedCells, 'string', '');
end


function handles = Acc_UpdateOperationalState(handles)
switch (handles.operationalState)
    case 'not loaded'            
        set(handles.pushbutton_nextPlane,'Enable','off');
        set(handles.pushbutton_prevPlane,'Enable','off');
        set(handles.pushbutton_GoToTime,'Enable','off');
        set(handles.pushbutton_OneFrameUp,'Enable','off');
        set(handles.pushbutton_OneFrameDown,'Enable','off');
        set(handles.pushbutton1_AutoSegment,'Enable','off');
        set(handles.pushbutton_AddCell,'Enable','off');
        set(handles.pushbutton_AddCellsPoints,'Enable','off');
        set(handles.pushbutton_DeleteCell,'Enable','off');
        set(handles.pushbutton_LoadCellData,'Enable','off');
        set(handles.pushbutton_Calc_dF_F,'Enable','off');        
        set(handles.pushbutton_ActivityAnalysis,'Enable','off');
        set(handles.pushbutton_Waves,'Enable','off');           
        set(handles.TextBox_SporadicPeaks, 'string', '');
        set(handles.TextBox_NumberOfBursts, 'string', '');
                        
        %Update the status for the user:  
        set (handles.StatusText, 'string', 'Ready for Video Load.');
        set (handles.StatusText, 'ForegroundColor', 'k');


    case 'movie loaded'
        set(handles.pushbutton_nextPlane,'Enable','on');
        set(handles.pushbutton_prevPlane,'Enable','on');
        set(handles.pushbutton_GoToTime,'Enable','on');
        set(handles.pushbutton_OneFrameUp,'Enable','on');
        set(handles.pushbutton_OneFrameDown,'Enable','on');
        set(handles.pushbutton1_AutoSegment,'Enable','on');
        set(handles.pushbutton_AddCell,'Enable','on');
        set(handles.pushbutton_AddCellsPoints,'Enable','on');
        set(handles.pushbutton_DeleteCell,'Enable','on');
        set(handles.pushbutton_LoadCellData,'Enable','on');
        set(handles.pushbutton_Calc_dF_F,'Enable','off');        
        set(handles.pushbutton_ActivityAnalysis,'Enable','off');
        set(handles.pushbutton_Waves,'Enable','off');
        set(handles.TextBox_SporadicPeaks, 'string', '');
        set(handles.TextBox_NumberOfBursts, 'string', '');

          
        %Update the status for the user:          
        set (handles.StatusText, 'string', 'Ready for Cell Load.');
        set (handles.StatusText, 'ForegroundColor', 'k');


    case 'cells loaded'
        set(handles.pushbutton_nextPlane,'Enable','on');
        set(handles.pushbutton_prevPlane,'Enable','on');
        set(handles.pushbutton_GoToTime,'Enable','on');
        set(handles.pushbutton_OneFrameUp,'Enable','on');
        set(handles.pushbutton_OneFrameDown,'Enable','on');
        set(handles.pushbutton1_AutoSegment,'Enable','on');
        set(handles.pushbutton_AddCell,'Enable','on');
        set(handles.pushbutton_AddCellsPoints,'Enable','on');
        set(handles.pushbutton_DeleteCell,'Enable','on');
        set(handles.pushbutton_LoadCellData,'Enable','on');
        set(handles.pushbutton_Calc_dF_F,'Enable','on');        
        set(handles.pushbutton_ActivityAnalysis,'Enable','on');
        set(handles.pushbutton_Waves,'Enable','on'); 
        set(handles.TextBox_SporadicPeaks, 'string', '');
        set(handles.TextBox_NumberOfBursts, 'string', '');

        %Update the status for the user:  
        set (handles.StatusText, 'string', 'Ready.');
        set (handles.StatusText, 'ForegroundColor', 'k');
end
drawnow();


function fileType = Acc_GetFileType(handles)
if (get(handles.radiobutton_ImageSourceAvi, 'value') == 1)
        fileType = 1; %'AVI/MP4'
else if (get(handles.radiobutton_ImageSourceMultipleTif, 'value') == 1)
        fileType = 2; %'MultipleImageTif'
    else
        fileType = 3; %'SingleImageTif'
    end
end


function color = Acc_getColor(planeNo)
switch planeNo
        case 1
            color = 'g'; %green
        case 2
            color = 'b'; %blue
        case 3
            color = 'y'; %yellow            
        case 4
            color = 'm'; %magenta
        case 5
            color = 'c'; %cyan
        case 6
            color = 'r'; %red
        otherwise
            color = 'k'; %black
end


function [frameRate, numFrames] = Acc_UpdateVidAttrib(handles, fileType, FullFilename)
switch(fileType)
    case 1 %AVI/MP4 Video file
        readerobj = VideoReader(FullFilename);
        numFrames = readerobj.NumberOfFrames;
        frameRate = readerobj.FrameRate;
        FilmDuration = readerobj.Duration;
        width = readerobj.Width;
        height = readerobj.Height;
        
    case 2 %Multiple images Tif file
        InfoImage=imfinfo(FullFilename);
        numFrames = length(InfoImage);
        frameRate = 1; % Aribitrary value..
        FilmDuration = numFrames / frameRate;
        width = InfoImage(1).Width;
        height = InfoImage(1).Height;
        
    case 3 %Single image Tif files
        numFrames = length(FullFilename);
        InfoImage=imfinfo(FullFilename{1,1});
        frameRate = 1; % Aribitrary value..
        FilmDuration = numFrames / frameRate;
        width = InfoImage(1).Width;
        height = InfoImage(1).Height;
end

set (handles.TextBox_NumFrames, 'string', num2str(numFrames));
set (handles.TextBox_FrameRate, 'string', num2str(frameRate));
set (handles.TextBox_FrameWidth, 'string', num2str(width));
set (handles.TextBox_FrameHeight, 'string', num2str(height));
set (handles.TextBox_FilmDuration, 'string', num2str(FilmDuration));


function Acc_clearAllTextBox(handles)
set (handles.TextBox_vidFileName, 'string', '');
set (handles.TextBox_ProcessFromFrame, 'string', '1');
set (handles.TextBox_ProcessUpToFrame, 'string', '1');
set (handles.TextBox_jumpToTime, 'string', '');

set (handles.TextBox_NumFrames, 'string', '');
set (handles.TextBox_FrameRate, 'string', '');
set (handles.TextBox_FrameWidth, 'string', '');
set (handles.TextBox_FrameHeight, 'string', '');
set (handles.TextBox_FilmDuration, 'string', '');
set (handles.TextBox_DistBetweenPlanes, 'string', '50');
set (handles.checkbox_remove_artifacts, 'value', 0);


function Acc_clearCellDisplay(handles)
set(handles.TextBox_NumOfCells, 'string', '0');
set(handles.TextBox_SelectedCells, 'string', '0');
set(handles.listboxCells,'string','');
set(handles.listboxCells,'value',1);


function Acc_clearCurrCellMarks(handles)
for iCell = 1:length(handles.selCellArray)    
    delete(handles.hLineArray(iCell));
    delete(handles.hNumArray(iCell));
end
set(handles.TextBox_SelectedCells, 'string', '');


function Acc_clearImage(handles)
axes(handles.Axes_Main);
imagesc(zeros(10));
colormap(gray);
set(handles.Image_Text, 'string', 'not loaded yet');


function [cellList, cellPlaneList] = Acc_UpdateCellDisplay(handles)
% Update the cell display:
numPlanes = handles.nPlanes;
totalCellNum = 0;
cellListStr = '';

cellList = [];
cellPlaneList = [];

for iPlane = 1:numPlanes
    numCells = handles.engine.planeArray(iPlane).cellCount();
    for iCell = 1:numCells
        desc = handles.engine.planeArray(iPlane).cellArray(iCell).getDescription();
        cellStr = sprintf('Plane#%d, Cell#%4d : %s' ,iPlane, iCell, desc);
        cellListStr = [cellListStr; cellStr];
        totalCellNum = totalCellNum + 1;
        cellList(totalCellNum) = iCell;
        cellPlaneList(totalCellNum) = iPlane;
    end
end

set(handles.TextBox_NumOfCells, 'string', num2str(totalCellNum));
set(handles.TextBox_SelectedCells, 'string', '');
set(handles.listboxCells,'string',cellListStr);
set(handles.listboxCells,'value',1);


function [hLineArray, hNumArray] = Acc_DisplaySelectedCells(handles, selCellArray)
nCells = length(selCellArray);
hLineArray = zeros(nCells,1);
hNumArray = zeros(nCells,1);
for iCell = 1:nCells    
    idx2display = selCellArray(iCell);
    cellNo = handles.cellList(idx2display);
    planeNo = handles.cellPlaneList(idx2display);    
    
    position = handles.engine.planeArray(planeNo).cellArray(cellNo).getCircumferenceLine();
    [xmin, ymin, ~, ~] = handles.engine.planeArray(planeNo).cellArray(cellNo).getPosition();
    color = Acc_getColor(planeNo);
    hLineArray(iCell) = line(position(:,1) ,position(:,2), 'LineWidth',2,'Color',color);
    hNumArray(iCell) = text(double(xmin), double(ymin), num2str(cellNo));
end
set(handles.TextBox_SelectedCells, 'string', num2str(nCells));


function Acc_UpdateImageDisplay(handles)
fileType = Acc_GetFileType(handles);
switch(fileType)
    case 1 %AVI/MP4 Video file        
        readFrame = handles.readerObj.read(handles.jump2Frame);        
        
    case 2 %Multiple images Tif file
        InfoImage=imfinfo(handles.videoFullName);
        readFrame = imread(handles.videoFullName,'Index',handles.jump2Frame, 'Info',InfoImage);
       
    case 3 %Single image Tif files
        readFrame = imread(handles.videoFullName{handles.jump2Frame});                       
end

axes(handles.Axes_Main);
imagesc(readFrame);
axis equal;
colormap(gray);
iPlane = mod( (handles.jump2Frame - handles.ProcessFromFrame) , handles.nPlanes) + 1;
image_desc_str = sprintf('Frame No: %d (Plane %d)', handles.jump2Frame, iPlane);
set(handles.Image_Text, 'string', image_desc_str);


function Acc_UpdatePlaneDisplay(handles)
%% this function aims to update the main axes of the gui

planeNo = handles.iPlane;
removeArtifacts = handles.removeArtifacts;

set(handles.TextBox_PlaneForDisplay, 'string', num2str(planeNo));
set(handles.TextBox_PlaneForDisplay, 'backgroundColor', Acc_getColor(planeNo));
if isfield(handles,'engine') 
    axes(handles.Axes_Main);
    
    if (removeArtifacts == 1)
        imagesc(handles.engine.planeArray(planeNo).meanImageClean);
    else 
        imagesc(handles.engine.planeArray(planeNo).meanImage);    
    end
    axis equal;
    image_desc_str = sprintf('Average Image of Plane %d', planeNo);
    
    colormap(gray);
    set(handles.Image_Text, 'string', image_desc_str);
else
    Acc_clearImage(handles) 
end


function Acc_Plot_dF_F_Mult(handles)

nCells = length(handles.selCellArray);
nFrames = handles.engine.planeArray(handles.cellPlaneList(1)).cellArray(handles.cellList(1)).dataCount();
nPlanes = handles.nPlanes;
fTimeSample = 1/handles.frameRate;
fStartTime = (handles.ProcessFromFrame -1)/ handles.frameRate;
axisTime = fStartTime + (0:nFrames-1)*fTimeSample*nPlanes;

figure;
m = handles.grid_M;
n = handles.grid_N;
minVal = handles.minVal2display;
maxVal = handles.maxVal2display;
numGraph = min(nCells,m*n);
for iCell = 1:numGraph    
    idx2plot = handles.selCellArray(iCell);
    cellNo = handles.cellList(idx2plot);
    planeNo = handles.cellPlaneList(idx2plot);      
    subplot(m,n,iCell);
    normData = handles.engine.planeArray(planeNo).cellArray(cellNo).normData;
    normData(normData < minVal) = minVal;
    normData(normData > maxVal) = maxVal;
    plot(axisTime,normData);
    sTitle = sprintf('Plane#%d, Cell #%d Fluorescence Activity (Normalized)', planeNo, cellNo);
    title(sTitle);
    xlabel('Time [Sec]'); ylabel('Fluorescence');
    axis([0 axisTime(end) -inf inf])
    
    %add a mark of peaks detected by SW
    bShowPeaks = get(handles.checkbox_Show_Peaks, 'value');
    if (bShowPeaks)
        hold on    
        peaksData = handles.engine.planeArray(planeNo).cellArray(cellNo).peaksData;     
        peaksData (peaksData == 1) = normData(peaksData == 1);
        peaksData (peaksData == 0) = NaN;
        plot(axisTime, peaksData, 'k^', 'markerfacecolor', 'r');
        hold off;
    end
end


function Acc_Plot_Waves(handles, fStartTime, fEndTime)

%distance between samples in "cell-data"
fTimeSampleCell = 1/handles.frameRate * handles.nPlanes;

handles.ProcessFromFrame;

%from which data point in the cell should we start ?
nStartCellData = floor(fStartTime/fTimeSampleCell) +1 - (handles.ProcessFromFrame - 1);
nEndCellData = floor(fEndTime/fTimeSampleCell) +1 - (handles.ProcessFromFrame - 1);

%waves are only detected at current plane
planeNo = handles.iPlane;
nCells = handles.engine.planeArray(planeNo).cellCount();
nData = handles.engine.planeArray(planeNo).cellArray(1).dataCount();

%update end-time is necessary
nEndCellData = min(nEndCellData,nData);

%calc number of frames in each window 
numWindow = min(nEndCellData-nStartCellData,64);
sizeWindow = floor((nEndCellData-nStartCellData)/numWindow);

%total data of cell we are going to use
dataSizeUsed = numWindow * sizeWindow;
nEndCellData = nStartCellData + dataSizeUsed - 1;

%waves are plotted in a different window
figure;

%plot the mean image
if (handles.removeArtifacts == 1)
    imagesc(handles.engine.planeArray(planeNo).meanImageClean);
else
    imagesc(handles.engine.planeArray(planeNo).meanImage);
end
axis equal;
colormap(gray);
title(sprintf('Plane#%d, Waves Analysis In Time Window: %.3f [sec] - %.3f [sec]', planeNo,fStartTime,fEndTime) );

%create color-map for drawing
wavesColorMap = jet; %can change to HSV,hot,cool

%if there are less than 64 windows - use indexes 1, 8, 16 etc. not 1..3
wavesColorScale = (length(wavesColorMap)/numWindow);

for iCell = 1:nCells
    %reshape cell data to number of windows, and check if there are peak in
    %any of them
    peaksDataCut = handles.engine.planeArray(planeNo).cellArray(iCell).peaksData(nStartCellData:nEndCellData);
    peaksDataWnd = reshape(peaksDataCut,sizeWindow,numWindow);
    peaksDataWndSum = sum(peaksDataWnd,1);
    nCellFirstActiveWnd = min(find(peaksDataWndSum > 0));
    
    %if cell activity found in any window...
    if (~isempty(nCellFirstActiveWnd))
        %draw the cell in the selected color
        
        position = handles.engine.planeArray(planeNo).cellArray(iCell).getCircumferenceLine();
        color = wavesColorMap(floor(nCellFirstActiveWnd*wavesColorScale),:);
        line(position(:,1) ,position(:,2), 'LineWidth',2,'Color',color);
    end
end

% ---------------------------------------------------------------------%
% ---------------------------------------------------------------------%
% -------------------- Buttons Callback Functions ---------------------%
% ---------------------------------------------------------------------%
% ---------------------------------------------------------------------%
% --- Executes on button press in pushbutton_xxx.
% hObject    handle to pushbutton_xxx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


%% --- Executes on button press in pushbutton_browseForMovie.
function pushbutton_browseForMovie_Callback(hObject, eventdata, handles)
    fileType = Acc_GetFileType(handles);
    switch fileType
        case 1 %AVI/MP4 Video file
           [filename, pathname] = uigetfile({'*.avi';'*.mp4'}, 'Pick a Video');
           FullFileName = [pathname '\' filename];
            if isequal(filename, 0)
                return;
            end              
        case 2 %Multiple images Tif file
           [filename, pathname] = uigetfile('*.tif', 'Pick a File');
           FullFileName = [pathname '\' filename];
           if isequal(filename, 0)
            return;
            end

        case 3 %Single image Tif files
           [filename, pathname] = uigetfile('*.tif', 'Pick Multiple Files', 'MultiSelect', 'on');
           if isequal(filename, 0)
                return;
           end
           if ~iscellstr(filename)
                errordlg('Please Select multiple images', 'Files Selection', 'modal')
                return;
            end

           FullFileName = cell(1,length(filename));       
           for i=1:length(filename)
               FullFileName{i} = [pathname '\' filename{1,i}];
           end      
    end

    set (handles.StatusText, 'string', 'Set new Video. Please Wait...');
    set (handles.StatusText, 'ForegroundColor', 'r');
    drawnow();

    [frameRate, numFrames] = Acc_UpdateVidAttrib(handles, fileType, FullFileName);
    % Add some parameters as application data to the GUI 
    handles.videoFullName = FullFileName;
    handles.frameRate = frameRate;
    handles.MaxFrameNum = numFrames;
    handles.ProcessFromFrame = 1;
    handles.ProcessUpToFrame = numFrames;
    handles.cellList = [];
    handles.cellPlaneList = [];
    handles.selCellArray = [];
    handles.hLineArray = [];
    handles.hNumArray = [];
    handles.ProcessFromFrame = 1;
    handles.iPlane = 1; 
    set(handles.TextBox_vidFileName, 'string', filename);
    set(handles.TextBox_ProcessFromFrame, 'string', num2str(1));
    set(handles.TextBox_ProcessUpToFrame, 'string', num2str(numFrames));

    handles.operationalState = 'not loaded';
    Acc_UpdateOperationalState(handles);
    Acc_UpdatePlaneDisplay(handles);        
    Acc_clearImage(handles);        
    Acc_clearCellDisplay(handles);
    guidata(hObject, handles); % Save the data.


%% --- Executes on button press in pushbutton_numPlanesUp.
function pushbutton_numPlanesUp_Callback(hObject, eventdata, handles)
val = get (handles.TextBox_numOfPlanes, 'string');
numPlanes = str2double(val);
set (handles.TextBox_numOfPlanes, 'string', num2str(numPlanes+1));

handles.nPlanes = numPlanes+1;

handles.operationalState = 'not loaded';
Acc_UpdateOperationalState(handles);

guidata(hObject, handles); % Save the number of planes.


% --- Executes on button press in pushbutton_numPlanesDown.
function pushbutton_numPlanesDown_Callback(hObject, eventdata, handles)
val = get (handles.TextBox_numOfPlanes, 'string');
numPlanes = str2double(val);
if numPlanes > 1
    set (handles.TextBox_numOfPlanes, 'string', num2str(numPlanes-1));
    handles.nPlanes = numPlanes-1;
    
    handles.operationalState = 'not loaded';
    Acc_UpdateOperationalState(handles);

    guidata(hObject, handles); % Save the number of planes.
end


%% --- Executes on button press in pushbutton_LoadVideo.
function pushbutton_LoadVideo_Callback(hObject, eventdata, handles)
% error checking
    if ~isfield(handles,'videoFullName')    
         errordlg('Select a Video first..', 'Sequence Matters!', 'modal');
         return;
    end

    if (handles.nPlanes > 1 && handles.planesDistance == 0)
        errordlg('Please Update distance between frames.', 'Sequence Matters!', 'modal');
        return;
    end

    % status update
    set (handles.StatusText, 'string', 'Loading Video. Please Wait...');
    set (handles.StatusText, 'ForegroundColor', 'r');
    drawnow();

    ProcessFromFrame = str2double(get (handles.TextBox_ProcessFromFrame, 'string'));
    ProcessUpToFrame = str2double(get (handles.TextBox_ProcessUpToFrame, 'string'));
    fileType = Acc_GetFileType(handles);

    % h = waitbar(0,'Loading Video. Please Wait...');
    % perc = 50;
    % waitbar(perc/100,h,sprintf('Loading Video... %d%% ...',perc))
    % close(h);
    
    switch fileType    
        case 2 % if file is a stack of tiff images
            engine = StackTiff(handles.videoFullName, handles.nPlanes, handles.frameRate);
        otherwise
            engine = Engine(fileType, handles.videoFullName, handles.nPlanes);
    end;
    engine.createPlanesMeanImageOnFrameRange(ProcessFromFrame, ProcessUpToFrame);
    engine.removePlanesArtifacts(handles.ArtifactRemovalMethod,...
                                    handles.planesDistance,...
                                    handles.ArtifactRemovalBaseSigma,...
                                    handles.ArtifactRemovalSubtractionFactor);

    % save the reader object, for faster access
    if(fileType == 1) %'AVI/MP4'
        handles.readerObj = VideoReader(handles.videoFullName);
    end

    % create uicontrol video panel with slider
    % Set up video figure window
    [vidfig] = videofig(engine.nFrames, @(frm) engine.redraw(frm), engine.frameRate,30);
    % Display initial frame
    engine.redraw(1);
    
    % Add the new data as application data to the GUI
    handles.videofig = vidfig;
    handles.engine = engine;
    handles.iPlane = 1;
    handles.cellList = [];
    handles.cellPlaneList = [];
    handles.selCellArray = [];
    handles.hLineArray = [];
    handles.hNumArray = [];
    handles.operationalState = 'movie loaded';
    Acc_UpdateOperationalState(handles);
    guidata(hObject, handles); % Save the data.
     
    Acc_UpdatePlaneDisplay(handles);
    Acc_clearCellDisplay(handles);


%% --- Executes on button press in pushbutton_nextPlane.
function pushbutton_nextPlane_Callback(hObject, eventdata, handles)
% Sanity Checks:
% if ~isfield(handles,'engine') 
if strcmp(handles.operationalState, 'not loaded')    
     errordlg('Load the Video first..', 'Sequence Matters!', 'modal')
     return;
end
if handles.iPlane < handles.nPlanes    
    handles.iPlane = handles.iPlane + 1;      
    guidata(hObject, handles); % Save the updated plane.         
end
Acc_UpdatePlaneDisplay(handles);
[handles.hLineArray, handles.hNumArray] = Acc_DisplaySelectedCells(handles, handles.selCellArray);
guidata(hObject, handles); % Save the cell marks.


% --- Executes on button press in pushbutton_prevPlane.
function pushbutton_prevPlane_Callback(hObject, eventdata, handles)
% Sanity Checks:
% if ~isfield(handles,'engine')
if strcmp(handles.operationalState, 'not loaded')    
     errordlg('Load the Video first..', 'Sequence Matters!', 'modal')
     return;
end    
if handles.iPlane > 1
    handles.iPlane = handles.iPlane - 1;        
    guidata(hObject, handles); % Save the updated plane.            
end
Acc_UpdatePlaneDisplay(handles);
[handles.hLineArray, handles.hNumArray] = Acc_DisplaySelectedCells(handles, handles.selCellArray);
guidata(hObject, handles); % Save the cell marks.


% --- Executes on button press in pushbutton_GoToTime.
function pushbutton_GoToTime_Callback(hObject, eventdata, handles)
if strcmp(handles.operationalState, 'not loaded')
     errordlg('Load the Video first..', 'Sequence Matters!', 'modal')
     return;
end
S = get(handles.TextBox_jumpToTime, 'string');
jump2Time = str2double(S);
if isnan(jump2Time) || jump2Time < 0
    errordlg('You must enter a positive numeric value','Bad Input','modal')    
    set (handles.TextBox_jumpToTime, 'string', '');
    return;
end
jump2Frame = round(handles.frameRate * jump2Time);    

if (jump2Frame > handles.MaxFrameNum)||(jump2Frame < 0)
    errordlg('Out of Limit','Bad Input','modal')
    return;
end
if (jump2Frame == 0) % first frame
    jump2Frame = 1;
end
handles.jump2Frame = jump2Frame;

Acc_UpdateImageDisplay(handles);
[handles.hLineArray, handles.hNumArray] = Acc_DisplaySelectedCells(handles, handles.selCellArray);
guidata(hObject, handles); % Save the cell marks. (& jump2Frame field).


% --- Executes on button press in pushbutton_OneFrameUp.
function pushbutton_OneFrameUp_Callback(hObject, eventdata, handles)
% if ~isfield(handles,'engine')    
if strcmp(handles.operationalState, 'not loaded')    
     errordlg('Load the Video first..', 'Sequence Matters!', 'modal')
     return;
end
if ~isfield(handles,'jump2Frame') 
     errordlg('Select time to jump to..', 'Sequence Matters!', 'modal')
     return;
end 
if handles.jump2Frame < handles.MaxFrameNum
    handles.jump2Frame = handles.jump2Frame + 1;        
    Acc_UpdateImageDisplay(handles);   
    [handles.hLineArray, handles.hNumArray] = Acc_DisplaySelectedCells(handles, handles.selCellArray);
    guidata(hObject, handles); % Save the data.
end


% --- Executes on button press in pushbutton_OneFrameDown.
function pushbutton_OneFrameDown_Callback(hObject, eventdata, handles)
% if ~isfield(handles,'engine')   
if strcmp(handles.operationalState, 'not loaded')    
     errordlg('Load the Video first..', 'Sequence Matters!', 'modal')
     return;
end
if ~isfield(handles,'jump2Frame') 
     errordlg('Select time to jump to..', 'Sequence Matters!', 'modal')
     return;
end 
if handles.jump2Frame >= 2
    handles.jump2Frame = handles.jump2Frame - 1;    
    Acc_UpdateImageDisplay(handles);
    [handles.hLineArray, handles.hNumArray] = Acc_DisplaySelectedCells(handles, handles.selCellArray);
    guidata(hObject, handles); % Save the data.
end


% --- Executes on button press in pushbutton1_AutoSegment.
function pushbutton1_AutoSegment_Callback(hObject, eventdata, handles)
% Sanity Checks:
% if ~isfield(handles,'engine') 
if strcmp(handles.operationalState, 'not loaded')    
     errordlg('Load the Video first..', 'Sequence Matters!', 'modal')
     return;
end 
if isfield(handles,'cellList') && ~isempty(handles.cellList)
    choice = questdlg('All Cells will be deleted. Are you sure?','Auto Segment','Yes','No','No');
    if strcmp(choice, 'No')
    	return;
    end
end

Acc_clearCurrCellMarks(handles);
handles.hLineArray = [];
handles.hNumArray = [];
handles.selCellArray = [];

for iPlane = 1:handles.nPlanes
    handles.engine.planeArray(iPlane).clearAllCells();
    switch (handles.SegmentationMethod)
        case 1
            handles.engine.planeArray(iPlane).segment_Method1(handles.removeArtifacts, handles.SegmentationThresholdMargin);
        case 2
            handles.engine.planeArray(iPlane).segment_Method2(handles.removeArtifacts, handles.SegmentationThresholdMargin);
    end
    [handles.cellList, handles.cellPlaneList] = Acc_UpdateCellDisplay(handles);
end

handles.operationalState = 'movie loaded';
Acc_UpdateOperationalState(handles);

guidata(hObject, handles); % Save the data.


% --- Executes on button press in pushbutton_AddCell.
function pushbutton_AddCell_Callback(hObject, eventdata, handles)
% Sanity Checks: 
if strcmp(handles.operationalState, 'not loaded')    
     errordlg('Load the Video first..', 'Sequence Matters!', 'modal')
     return;
end 
%cellRoi = imellipse;
cellRoi = imfreehand('Closed', true);
wait(cellRoi);
                
cellMask = uint8(cellRoi.createMask);
position = cellRoi.getPosition();
% xmin = uint32(position(1));
% ymin = uint32(position(2));
% width = uint32(position(3));
% heigth = uint32(position(4));
xmin = uint32(min(position(:,1)));
ymin = uint32(min(position(:,2)));
xmax = uint32(max(position(:,1)));
ymax = uint32(max(position(:,2)));

width = xmax-xmin;
heigth = ymax-ymin;

% Add this cell to the plane
handles.engine.planeArray(handles.iPlane).addCell(Cell(cellMask, xmin, ymin, width, heigth, position));

handles.operationalState = 'movie loaded';
Acc_UpdateOperationalState(handles);
Acc_clearCurrCellMarks(handles);
handles.hLineArray = [];
handles.hNumArray = [];
handles.selCellArray = [];

% Re-draw the iamge
Acc_UpdatePlaneDisplay(handles);

% Finally, update the cell display with the new cell:
[handles.cellList, handles.cellPlaneList] = Acc_UpdateCellDisplay(handles);
guidata(hObject, handles); % Save the data.


% --- Executes on button press in pushbutton_AddCellsPoints.
function pushbutton_AddCellsPoints_Callback(hObject, eventdata, handles)
% Sanity Checks: 
if strcmp(handles.operationalState, 'not loaded')    
     errordlg('Load the Video first..', 'Sequence Matters!', 'modal')
     return;
end 
helpstring = sprintf('Select cells by clicking on their centers. Press Enter when done.');
set (handles.StatusText, 'string', helpstring);
set (handles.StatusText, 'ForegroundColor', 'r');
drawnow();
axes(handles.Axes_Main);
R = handles.CellCircleRadius;
[x, y] = ginput;
phi=(pi/50:pi/50:2*pi)'; % arbitrary angle
circle_points = (R * ([cos(phi),sin(phi)]));
[maxHeight,maxWidth] = size(handles.engine.planeArray(handles.iPlane).meanImage);                                                               
width = 2*R;
height = 2*R;  
for iCell=1:length(x)
    xmin = uint32(x(iCell)-R) + 1;
    ymin = uint32(y(iCell)-R) + 1;                      
    circumference(:,1) = circle_points(:,1) + x(iCell);
    circumference(:,2) = circle_points(:,2) + y(iCell);
    if (xmin + width > maxWidth)
        width = maxWidth - xmin;
    end
                
    if (ymin + height > maxHeight)
        height = maxHeight - ymin;
    end
    cellMask = uint8(zeros(size(handles.engine.planeArray(handles.iPlane).meanImage))); 
    cellMask(ymin:ymin+height, xmin:xmin+width) = 1;
                
    % Add this cell to the plane
    if ((width > 1) && (height > 1)) 
        handles.engine.planeArray(handles.iPlane).addCell(Cell(cellMask, xmin, ymin, width, height, circumference));
    end
end

handles.operationalState = 'movie loaded';
Acc_UpdateOperationalState(handles);
Acc_clearCurrCellMarks(handles);
handles.hLineArray = [];
handles.hNumArray = [];
handles.selCellArray = [];

% Re-draw the iamge
Acc_UpdatePlaneDisplay(handles);

% Finally, update the cell display with the new cell:
[handles.cellList, handles.cellPlaneList] = Acc_UpdateCellDisplay(handles);
guidata(hObject, handles); % Save the data.


% --- Executes on button press in pushbutton_DeleteCell.
function pushbutton_DeleteCell_Callback(hObject, eventdata, handles)
% Sanity Checks:
% if ~isfield(handles,'engine')
if strcmp(handles.operationalState, 'not loaded')    
     errordlg('Load the Video first..', 'Sequence Matters!', 'modal')
     return;
end 
if (isempty(handles.selCellArray))
    errordlg('Please Select a Cell..', 'Sequence Matters!', 'modal');
    return;
end
    
%delete in reverse order
for iCell = length(handles.selCellArray):-1:1
    idx2delete = handles.selCellArray(iCell);
    cellNo = handles.cellList(idx2delete);
    planeNo = handles.cellPlaneList(idx2delete);
    handles.engine.planeArray(planeNo).deleteCell(cellNo);
end

Acc_clearCurrCellMarks(handles);
handles.hLineArray = [];
handles.hNumArray = [];
handles.selCellArray = [];
handles.operationalState = 'movie loaded';
Acc_UpdateOperationalState(handles);

[handles.cellList, handles.cellPlaneList] = Acc_UpdateCellDisplay(handles);
guidata(hObject, handles); % Save the data.


% --- Executes on selection change in listboxCells.
function listboxCells_Callback(hObject, eventdata, handles)

% Hints: contents = cellstr(get(hObject,'String')) returns listboxCells contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listboxCells
% Sanity Checks:
if strcmp(handles.operationalState, 'not loaded')    
     errordlg('Load the Video first..', 'Sequence Matters!', 'modal')
     return;
end 
Acc_clearCurrCellMarks(handles); % do this before the 'get'!
handles.selCellArray = get(hObject,'Value');
[handles.hLineArray, handles.hNumArray] = Acc_DisplaySelectedCells(handles, handles.selCellArray);

guidata(hObject, handles); % Save the rectangles.


% --- Executes on button press in pushbutton_LoadCellData.
function pushbutton_LoadCellData_Callback(hObject, eventdata, handles)
% Sanity Checks:
%if ~isfield(handles,'engine')    
if strcmp(handles.operationalState, 'not loaded')    
     errordlg('Load the Video first..', 'Sequence Matters!', 'modal')
     return;     
end

if (isempty(handles.cellList))
    errordlg('Define Cells First..', 'Sequence Matters!', 'modal');
    return;
end
tic
set (handles.StatusText, 'string', 'Loading Cells Data. Please Wait...');
set (handles.StatusText, 'ForegroundColor', 'r');
drawnow();
handles.engine.loadPartialCellsDataForFrameRange(handles.ProcessFromFrame,...
                                                handles.ProcessUpToFrame,...
                                                handles.removeArtifacts,...
                                                handles.planesDistance,...
                                                handles.ArtifactRemovalBaseSigma,...
                                                handles.ArtifactRemovalSubtractionFactor);
% Iterate over cells - detrend & norm each
fTimeSample = 1/handles.frameRate;
fTimeSampleCell = fTimeSample * handles.nPlanes; %time between each cell points

for iCell = 1:length(handles.cellList)    
    cellNo = handles.cellList(iCell);
    planeNo = handles.cellPlaneList(iCell);    

    handles.engine.planeArray(planeNo).cellArray(cellNo).detrend();
    handles.engine.planeArray(planeNo).cellArray(cellNo).normalize_Method1(handles.NormalizeWindowSizeSamples);
    th = handles.PeakDetectThreshold;
    switch(handles.PeakDetectionMethod)
        case 1
            handles.engine.planeArray(planeNo).cellArray(cellNo).calcPeaks_Method1(fTimeSampleCell, th);
        case 2
            handles.engine.planeArray(planeNo).cellArray(cellNo).calcPeaks_Method2(fTimeSampleCell, th);
        case 3
            handles.engine.planeArray(planeNo).cellArray(cellNo).calcPeaks_Method3(fTimeSampleCell, th);
        case 4
            handles.engine.planeArray(planeNo).cellArray(cellNo).calcPeaks_Method4(fTimeSampleCell, th);            
    end
end
toc
handles.operationalState = 'cells loaded';
Acc_UpdateOperationalState(handles);
guidata(hObject, handles); % Save the data.


% --- Executes on button press in pushbutton_Calc_dF_F.
function pushbutton_Calc_dF_F_Callback(hObject, eventdata, handles)
% Sanity Checks:
%if ~isfield(handles,'engine')    
if strcmp(handles.operationalState, 'not loaded')    
     errordlg('Load the Video first..', 'Sequence Matters!', 'modal')
     return;
end
if ~isfield(handles,'selCellArray') || (isempty(handles.selCellArray))
    errordlg('Please Select a Cell..', 'Sequence Matters!', 'modal');
    return;
end
   
if ~handles.engine.isLoaded
errordlg('Please Load Cell Data first..', 'Sequence Matters!', 'modal');
    return;
end

if ~isfield(handles,'grid_M') || ~isfield(handles,'grid_N')
    errordlg('Please Select a Grid for display..', 'Sequence Matters!', 'modal');
    return;
end

if handles.frameRate == 0
    errordlg('Please Update Frame Rate.', 'Sequence Matters!', 'modal');
    return;
end

Acc_Plot_dF_F_Mult(handles);


% --- Executes on button press in pushbutton_ActivityAnalysis.
function pushbutton_ActivityAnalysis_Callback(hObject, eventdata, handles)
% Sanity Checks:
% if ~isfield(handles,'engine')
if strcmp(handles.operationalState, 'not loaded')    
     errordlg('Load the Video first..', 'Sequence Matters!', 'modal')
     return;
end
if ~isfield(handles,'selCellArray') || (isempty(handles.selCellArray))
    errordlg('Please Select a Cell..', 'Sequence Matters!', 'modal');
    return;
end
   
if ~handles.engine.isLoaded
errordlg('Please Load Cell Data first..', 'Sequence Matters!', 'modal');
    return;
end

%create a matrix - each line is a different cell (out of selected cells only)
nRows = length(handles.selCellArray);
nCols = handles.engine.planeArray(handles.cellPlaneList(1)).cellArray(1).dataCount();

activityMat = zeros(nRows,nCols);
peaksMat = zeros(nRows,nCols);

for iCell = 1:nRows
    idx = handles.selCellArray(iCell);
    cellNo = handles.cellList(idx);
    planeNo = handles.cellPlaneList(idx);
    
    activityMat(iCell,:) = handles.engine.planeArray(planeNo).cellArray(cellNo).normData;
    peaksMat(iCell,:) = handles.engine.planeArray(planeNo).cellArray(cellNo).peaksData;
end

figure; imagesc(activityMat);
title('Activity plot of selected cells'); 

nFrames = handles.engine.planeArray(handles.cellPlaneList(1)).cellArray(handles.cellList(1)).dataCount();
nPlanes = handles.nPlanes;
fTimeSample = 1/handles.frameRate;
fStartTime = (handles.ProcessFromFrame -1) * fTimeSample;
fEndTime = fStartTime + (nFrames-1)* nPlanes * fTimeSample;

%we will have 6 ticks on X label
axisLimits = axis; % get the current limits
currX = linspace(axisLimits(1), axisLimits(2), 6);
axisTime = linspace(fStartTime, fEndTime, 6);

set(gca,'XTickMode','manual');
set(gca,'XTick',currX);
set(gca,'XtickLabel',axisTime);
xlabel('Time [Sec]')

%display additional statistics: count how many times more than 60 of cells fired

[nBursts nSporadic] = handles.engine.calcActivityStats(peaksMat);
set(handles.TextBox_SporadicPeaks, 'string', num2str(nSporadic));
set(handles.TextBox_NumberOfBursts, 'string', num2str(nBursts));


% --- Executes on button press in pushbutton_Waves.
function pushbutton_Waves_Callback(hObject, eventdata, handles)

fStartTime = handles.WaveMinTime;
fromFrame = floor(handles.frameRate * fStartTime) + 1;
if isnan(fromFrame) || (fromFrame < handles.ProcessFromFrame) || (fromFrame > handles.ProcessUpToFrame)
    errordlg('You must enter a valid numeric value in Time (min) Range','Bad Input','modal')
    fStartTime = (handles.ProcessFromFrame -1)/ handles.frameRate;
    set(handles.TextBox_WaveMinFrame, 'string', num2str(fStartTime));
    handles.WaveMinTime = fStartTime;
    guidata(hObject, handles); % Save the data.
    return;
end

fEndTime = handles.WaveMaxTime;
uptoFrame = floor(handles.frameRate * fEndTime);
if isnan(uptoFrame) || (uptoFrame <= fromFrame) || (uptoFrame > handles.ProcessUpToFrame)
    errordlg('You must enter a valid numeric value in Time (max) Range','Bad Input','modal')
    fEndTime = (handles.ProcessUpToFrame -1)/ handles.frameRate;
    set(handles.TextBox_WaveMaxFrame, 'string', num2str(fEndTime));
    handles.WaveMaxTime = fEndTime;
    guidata(hObject, handles); % Save the data.
    return;
end

if (handles.engine.planeArray(handles.iPlane).cellCount() == 0)
    errordlg('There are no defined cells in the current plane', 'Waves Analysis', 'modal');
    return;
end  

Acc_Plot_Waves(handles,fStartTime,fEndTime);


% --- Executes on button press in checkbox_remove_artifacts.
function checkbox_remove_artifacts_Callback(hObject, eventdata, handles)  

handles.removeArtifacts = get(hObject,'Value');
Acc_UpdatePlaneDisplay(handles);
[handles.hLineArray, handles.hNumArray] = Acc_DisplaySelectedCells(handles, handles.selCellArray);
guidata(hObject, handles); % Save the rectangles.


% --- Executes on button press in pushbutton_UpdateParams.
function pushbutton_UpdateParams_Callback(hObject, eventdata, handles)

setup_params.SegmentationMethod = handles.SegmentationMethod;
setup_params.ArtifactRemovalMethod = handles.ArtifactRemovalMethod;
setup_params.PeakDetectionMethod = handles.PeakDetectionMethod;
setup_params.CellCircleRadius = handles.CellCircleRadius;
setup_params.SegmentationThresholdMargin = handles.SegmentationThresholdMargin;
setup_params.PeakDetectThreshold = handles.PeakDetectThreshold;
setup_params.ArtifactRemovalBaseSigma = handles.ArtifactRemovalBaseSigma;
setup_params.ArtifactRemovalSubtractionFactor = handles.ArtifactRemovalSubtractionFactor;
setup_params.NormalizeWindowSizeSamples = handles.NormalizeWindowSizeSamples;
setup_params.update = false;

setup_params = param_gui(setup_params);
if (setup_params.update == true)
    handles.SegmentationMethod = setup_params.SegmentationMethod;
    handles.ArtifactRemovalMethod = setup_params.ArtifactRemovalMethod;
    handles.PeakDetectionMethod = setup_params.PeakDetectionMethod;
    handles.CellCircleRadius = setup_params.CellCircleRadius;
    handles.SegmentationThresholdMargin = setup_params.SegmentationThresholdMargin;
    handles.PeakDetectThreshold = setup_params.PeakDetectThreshold;
    handles.ArtifactRemovalBaseSigma = setup_params.ArtifactRemovalBaseSigma;
    handles.ArtifactRemovalSubtractionFactor = setup_params.ArtifactRemovalSubtractionFactor;
    handles.NormalizeWindowSizeSamples = setup_params.NormalizeWindowSizeSamples;
    guidata(hObject, handles);
end

% ---------------------------------------------------------------------%
% ---------------------------------------------------------------------%
% -------------------- TextBox Callback Functions ---------------------%
% ---------------------------------------------------------------------%
% ---------------------------------------------------------------------%
% hObject    handle to TextBox_xxx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of TextBox_xxx as text
%        str2double(get(hObject,'String')) returns contents of TextBox_xxx as a double


function TextBox_FrameRate_Callback(hObject, eventdata, handles)
S = get(hObject, 'string');
frameRate = str2double(S);
if isnan(frameRate) || (frameRate <= 0)
    errordlg('You must enter a positie numeric value','Bad Input','modal')
    frameRate = 1;
    set(handles.TextBox_FrameRate, 'string', num2str(frameRate));
end
handles.frameRate = frameRate;
FilmDuration = handles.MaxFrameNum/frameRate;
set (handles.TextBox_FilmDuration, 'string', num2str(FilmDuration));
guidata(hObject, handles); % Save the data.


function TextBox_DistBetweenPlanes_Callback(hObject, eventdata, handles)

S = get(hObject, 'string');
planesDistance = str2double(S);
if isnan(planesDistance) || (planesDistance <= 0)
    errordlg('You must enter a positie numeric value','Bad Input','modal')
    planesDistance = 50;
    set(handles.TextBox_DistBetweenPlanes, 'string', num2str(planesDistance));
end
handles.planesDistance = planesDistance;
guidata(hObject, handles); % Save the data.


function TextBox_ProcessFromFrame_Callback(hObject, eventdata, handles)
S = get(hObject, 'string');
value = fix(str2double(S));
if isnan(value) || value < 1 ||  value > handles.MaxFrameNum
    errordlg('You must enter a valid numeric value','Bad Input','modal')
    value = 1;
end
if (value > handles.ProcessUpToFrame)
    errordlg('Ilegal Process Range. Value must be less than upper limit', 'Bad Input', 'modal');
    value = 1;
end
set(handles.TextBox_ProcessFromFrame, 'string', num2str(value));
handles.ProcessFromFrame = value;
guidata(hObject, handles); % Save the data.


function TextBox_ProcessUpToFrame_Callback(hObject, eventdata, handles)
S = get(hObject, 'string');
value = fix(str2double(S));

if (isnan(value) || value < 1 || value > handles.MaxFrameNum)
    errordlg('You must enter a valid numeric value','Bad Input','modal')
    value = handles.MaxFrameNum;
end
if (value < handles.ProcessFromFrame)
    errordlg('Ilegal Process Range. Value must be more than lower limit', 'Bad Input', 'modal');
    value = handles.MaxFrameNum;
end

set (handles.TextBox_ProcessUpToFrame, 'string', num2str(value));
handles.ProcessUpToFrame = value;
guidata(hObject, handles); % Save the data.


function TextBox_grid_M_Callback(hObject, eventdata, handles)
S = get(hObject, 'string');
grid_M = fix(str2double(S));
if isnan(grid_M) || grid_M < 1
    errordlg('You must enter a positive integer value','Bad Input','modal')
    grid_M = 1;
end
set (handles.TextBox_grid_M, 'string', num2str(grid_M));
handles.grid_M = grid_M;
guidata(hObject, handles); % Save the data.


function TextBox_grid_N_Callback(hObject, eventdata, handles)
S = get(hObject, 'string');
grid_N = fix(str2double(S));
if isnan(grid_N) || grid_N < 1
    errordlg('You must enter a positive integer value','Bad Input','modal')
    grid_N = 1;
end
set (handles.TextBox_grid_N, 'string', num2str(grid_N));   
handles.grid_N = grid_N;
guidata(hObject, handles); % Save the data.


function TextBox_MinValue_Callback(hObject, eventdata, handles)
S = get(hObject, 'string');
value = str2double(S);
if isnan(value)
    errordlg('You must enter a numeric value','Bad Input','modal')    
    value = -1000;
    set (handles.TextBox_MinValue, 'string', num2str(value));
end
handles.minVal2display = value;
guidata(hObject, handles); % Save the data.


function TextBox_MaxValue_Callback(hObject, eventdata, handles)
S = get(hObject, 'string');
value = str2double(S);
if isnan(value)
    errordlg('You must enter a numeric value','Bad Input','modal')    
    value = 1000;
    set (handles.TextBox_MaxValue, 'string', num2str(value));
end
handles.maxVal2display = value;
guidata(hObject, handles); % Save the data.


function TextBox_WaveMinFrame_Callback(hObject, eventdata, handles)
S = get(hObject, 'string');
fStartTime = str2double(S);
fromFrame = floor(handles.frameRate * fStartTime) + 1;
if isnan(fromFrame) || (fromFrame < handles.ProcessFromFrame) || (fromFrame > handles.ProcessUpToFrame)
    errordlg('You must enter a valid numeric value in Time (min) Range','Bad Input','modal')
    fStartTime = (handles.ProcessFromFrame -1)/ handles.frameRate;
    set(handles.TextBox_WaveMinFrame, 'string', num2str(fStartTime));
end
handles.WaveMinTime = fStartTime;
guidata(hObject, handles); % Save the data.


function TextBox_WaveMaxFrame_Callback(hObject, eventdata, handles)
S = get(hObject, 'string');
fEndTime = str2double(S);
uptoFrame = floor(handles.frameRate * fEndTime);
if isnan(uptoFrame) || (uptoFrame <= handles.ProcessFromFrame) || (uptoFrame > handles.ProcessUpToFrame)
    errordlg('You must enter a valid numeric value in Time (max) Range','Bad Input','modal')
    fEndTime = (handles.ProcessUpToFrame -1)/ handles.frameRate;
    set(handles.TextBox_WaveMaxFrame, 'string', num2str(fEndTime));
end
handles.WaveMaxTime = fEndTime;
guidata(hObject, handles); % Save the data.



% ---------------------------------------------------------------------%
% ---------------------------------------------------------------------%
% ---------------------- Toolbar Functions-----------------------------%
% ---------------------------------------------------------------------%
% ---------------------------------------------------------------------%


% --------------------------------------------------------------------
function uipushSaveSetup_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to uipushtool_SaveSetup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename,pathname] = uiputfile('myWork.mat','Save Current Project');
if isequal(filename, 0)
    return;
end
confFullName = [pathname '\' filename];
Acc_saveState(handles, confFullName);

% --------------------------------------------------------------------
function uipushOpenSetup_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to uipushtool_OpenSetup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename, pathname] = uigetfile('*.mat', 'Open Existing Project');
if isequal(filename, 0)
    return;
end
confFullName = [pathname '\' filename];
set (handles.StatusText, 'string', 'Loadind from File. Please Wait...');
set (handles.StatusText, 'ForegroundColor', 'r');
drawnow();
handles = Acc_restoreState(hObject, handles, confFullName);
handles = Acc_UpdateOperationalState(handles);
guidata(hObject, handles); % Save the data.

% --------------------------------------------------------------------
function uipushNewSetup_ClickedCallback(hObject, eventdata, handles)
choice = questdlg('Current setup will be cleared. Are you sure?','New project','Yes','No','No');
switch choice
  case 'Yes'        
    if isfield(handles,'engine')    
        handles = rmfield(handles, 'engine');
    end                   
    handles.operationalState = 'not loaded';
    handles = Acc_UpdateOperationalState(handles);
    handles.hLineArray = [];
    handles.hNumArray = [];
    handles.iPlane = 1;
    handles.removeArtifacts = 0;
    handles.planesDistance = 50;
    handles.selCellArray = [];
    handles.cellList = [];
    handles.cellPlaneList = [];
  
    Acc_UpdatePlaneDisplay(handles);
    Acc_clearAllTextBox(handles);
    Acc_clearImage(handles);        
    Acc_clearCellDisplay(handles);

    guidata(hObject, handles); % Save the data.
  case 'No'
	return;
end
