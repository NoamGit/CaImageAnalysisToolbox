function varargout = param_gui(varargin)
% PARAM_GUI MATLAB code for param_gui.fig
%      PARAM_GUI, by itself, creates a new PARAM_GUI or raises the existing
%      singleton*.
%
%      H = PARAM_GUI returns the handle to a new PARAM_GUI or the handle to
%      the existing singleton*.
%
%      PARAM_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PARAM_GUI.M with the given input arguments.
%
%      PARAM_GUI('Property','Value',...) creates a new PARAM_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before param_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to param_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help param_gui

% Last Modified by GUIDE v2.5 10-Jul-2015 23:21:32

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @param_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @param_gui_OutputFcn, ...
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


% --- Executes just before param_gui is made visible.
function param_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to param_gui (see VARARGIN)

% Choose default command line output for param_gui
handles.setup_params = varargin{1};
handles.setup_params.update = false;

handles = AccPrm_loadSetup(handles);
handles.output = handles.setup_params;
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes param_gui wait for user response (see UIRESUME)
uiwait(handles.figure_paramsGUI);


% --- Outputs from this function are returned to the command line.
function varargout = param_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% The figure can be deleted now
delete(handles.figure_paramsGUI);


% --- Executes when user attempts to close figure_paramsGUI.
function figure_paramsGUI_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure_paramsGUI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
if isequal(get(hObject, 'waitstatus'), 'waiting')
% The GUI is still in UIWAIT, us UIRESUME
uiresume(hObject);
else
% The GUI is no longer waiting, just close it
delete(hObject);
end


% --- Accessory function to load setup from file
function handles = AccPrm_loadSetup(handles)

if (handles.setup_params.SegmentationMethod == 1)
    set(handles.radiobutton_SegmentationMethod1, 'value', 1);
else
    set(handles.radiobutton_SegmentationMethod2, 'value', 1);                
end
            
if (handles.setup_params.ArtifactRemovalMethod == 1)
    set(handles.radiobutton_ArtifactRemovalMethod1, 'value', 1);
else
    set(handles.radiobutton_ArtifactRemovalMethod2, 'value', 1);
end
            
if (handles.setup_params.PeakDetectionMethod == 1)
    set(handles.radiobutton_PeakDetectionMethod1, 'value', 1);
else if (handles.setup_params.PeakDetectionMethod == 2)
         set(handles.radiobutton_PeakDetectionMethod2, 'value', 1);
    else if (handles.setup_params.PeakDetectionMethod == 3)
              set(handles.radiobutton_PeakDetectionMethod3, 'value', 1);
         else
              set(handles.radiobutton_PeakDetectionMethod4, 'value', 1);
         end
    end                      
end

set(handles.edit_CellCircleRadius, 'string', num2str(handles.setup_params.CellCircleRadius));
set(handles.edit_SegmentationThresholdMargin, 'string', num2str(handles.setup_params.SegmentationThresholdMargin));
set(handles.edit_PeakDetectThreshold, 'string', num2str(handles.setup_params.PeakDetectThreshold));
set(handles.edit_ArtifactRemovalBaseSigma, 'string', num2str(handles.setup_params.ArtifactRemovalBaseSigma));
set(handles.edit_ArtifactRemovalSubtractionFactor, 'string', num2str(handles.setup_params.ArtifactRemovalSubtractionFactor));
set(handles.edit_NormalizeWindowSizeSamples, 'string', num2str(handles.setup_params.NormalizeWindowSizeSamples));

% --- Accessory function to update setup from file
function handles = Acc_updateSetupParams(handles)

%% NormalizeWindowSizeSamples:
S = get(handles.edit_NormalizeWindowSizeSamples, 'string');
val = fix(str2double(S));
if isnan(val) || val <= 0
    errordlg('You must enter a positive integer numeric value for Normalize Window Size','Bad Input','modal')    
    set (handles.edit_NormalizeWindowSizeSamples, 'string', num2str(handles.setup_params.NormalizeWindowSizeSamples));
    return;
else
    handles.setup_params.NormalizeWindowSizeSamples = val;
end

%% CellCircleRadius:
S = get(handles.edit_CellCircleRadius, 'string');
val = str2double(S);
if isnan(val) || val <= 0
    errordlg('You must enter a positive numeric value for Cell Radius','Bad Input','modal')    
    set (handles.edit_CellCircleRadius, 'string', num2str(handles.setup_params.CellCircleRadius));
    return;
else
    handles.setup_params.CellCircleRadius = val;
end

%% SegmentationMethod:
if (get(handles.radiobutton_SegmentationMethod1, 'value') == 1)
    handles.setup_params.SegmentationMethod = 1;
else
    handles.setup_params.SegmentationMethod = 2;
end

%% SegmentationThresholdMargin:
S = get(handles.edit_SegmentationThresholdMargin, 'string');
val = str2double(S);
if isnan(val) || val <= 0
    errordlg('You must enter a positive numeric value for Segmentation Threshold Margin','Bad Input','modal')    
    set (handles.edit_SegmentationThresholdMargin, 'string', num2str(handles.setup_params.SegmentationThresholdMargin));
    return;
else
    handles.setup_params.SegmentationThresholdMargin = val;
end

%% ArtifactRemovalMethod:
if (get(handles.radiobutton_ArtifactRemovalMethod1, 'value') == 1)
    handles.setup_params.ArtifactRemovalMethod = 1;
else
    handles.setup_params.ArtifactRemovalMethod = 2;
end

%% ArtifactRemovalBaseSigma:
S = get(handles.edit_ArtifactRemovalBaseSigma, 'string');
val = str2double(S);
if isnan(val) || val <= 0
    errordlg('You must enter a positive numeric value for Artifact Removal Base Sigma','Bad Input','modal')    
    set (handles.edit_ArtifactRemovalBaseSigma, 'string', num2str(handles.setup_params.ArtifactRemovalBaseSigma));
    return;
else
    handles.setup_params.ArtifactRemovalBaseSigma = val;
end

%% ArtifactRemovalSubtractionFactor:
S = get(handles.edit_ArtifactRemovalSubtractionFactor, 'string');
val = str2double(S);
if isnan(val) || val <= 0 || val > 1
    errordlg('You must enter a numeric value in range [0-1] for Artifact Removal Subtraction Factor','Bad Input','modal')    
    set (handles.edit_ArtifactRemovalSubtractionFactor, 'string', num2str(handles.setup_params.ArtifactRemovalSubtractionFactor));
    return;
else
    handles.setup_params.ArtifactRemovalSubtractionFactor = val;
end

%% PeakDetectionMethod:
if (get(handles.radiobutton_PeakDetectionMethod1, 'value') == 1)
    handles.setup_params.PeakDetectionMethod = 1;
else if (get(handles.radiobutton_PeakDetectionMethod2, 'value') == 1)
        handles.setup_params.PeakDetectionMethod = 2;
    else if (get(handles.radiobutton_PeakDetectionMethod3, 'value') == 1)
                handles.setup_params.PeakDetectionMethod = 3; 
        else
                handles.setup_params.PeakDetectionMethod = 4;
        end
    end
end

%% PeakDetectThreshold:
S = get(handles.edit_PeakDetectThreshold, 'string');
val = str2double(S);
if isnan(val) || val < 0
    errordlg('You must enter a positive numeric value for Peak Detection Threshold','Bad Input','modal')    
    set (handles.edit_PeakDetectThreshold, 'string', num2str(handles.setup_params.PeakDetectThreshold));
    return;
else
    handles.setup_params.PeakDetectThreshold = val;
end


% --- Executes on button press in pushbuttonCancel.
function pushbuttonCancel_Callback(hObject, eventdata, handles)
close(handles.figure_paramsGUI);


% --- Executes on button press in pushbuttonOK.
function pushbuttonOK_Callback(hObject, eventdata, handles)
%Save & Exit
handles = Acc_updateSetupParams(handles);
handles.setup_params.update = true;
handles.output = handles.setup_params;
guidata(hObject, handles); % save the data

close(handles.figure_paramsGUI);


% --- Executes on button press in pushbuttonSave.
function pushbuttonSave_Callback(hObject, eventdata, handles)
handles = Acc_updateSetupParams(handles);
guidata(hObject, handles); % save the data
fileID = fopen('Setup_Params.txt', 'w', 'n', 'US-ASCII');
fprintf(fileID,'NormalizeWindowSizeSamples        %d \r\n', handles.setup_params.NormalizeWindowSizeSamples);
fprintf(fileID,'CellCircleRadius                  %f \r\n', handles.setup_params.CellCircleRadius);
fprintf(fileID,'SegmentationMethod                %d \r\n', handles.setup_params.SegmentationMethod);
fprintf(fileID,'SegmentationThresholdMargin       %f \r\n', handles.setup_params.SegmentationThresholdMargin);
fprintf(fileID,'ArtifactRemovalMethod             %d \r\n', handles.setup_params.ArtifactRemovalMethod);
fprintf(fileID,'ArtifactRemovalBaseSigma          %f \r\n', handles.setup_params.ArtifactRemovalBaseSigma);
fprintf(fileID,'ArtifactRemovalSubtractionFactor  %f \r\n', handles.setup_params.ArtifactRemovalSubtractionFactor);
fprintf(fileID,'PeakDetectionMethod               %d \r\n', handles.setup_params.PeakDetectionMethod);
fprintf(fileID,'PeakDetectThreshold               %f \r\n', handles.setup_params.PeakDetectThreshold); 
fclose(fileID);
