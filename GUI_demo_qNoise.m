function varargout = GUI_demo_qNoise(varargin)
% GUI_DEMO_YNOISE MATLAB code for GUI_demo_yNoise.fig
%      GUI_DEMO_YNOISE, by itself, creates a new GUI_DEMO_YNOISE or raises the existing
%      singleton*.
%
%      H = GUI_DEMO_YNOISE returns the handle to a new GUI_DEMO_YNOISE or the handle to
%      the existing singleton*.
%
%      GUI_DEMO_YNOISE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI_DEMO_YNOISE.M with the given input arguments.
%
%      GUI_DEMO_YNOISE('Property','Value',...) creates a new GUI_DEMO_YNOISE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GUI_demo_yNoise_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GUI_demo_yNoise_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GUI_demo_yNoise

% Last Modified by GUIDE v2.5 04-Apr-2016 11:33:02

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GUI_demo_yNoise_OpeningFcn, ...
                   'gui_OutputFcn',  @GUI_demo_yNoise_OutputFcn, ...
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


% --- Executes just before GUI_demo_yNoise is made visible.
function GUI_demo_yNoise_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GUI_demo_yNoise (see VARARGIN)

% Choose default command line output for GUI_demo_yNoise
handles.output = hObject;


% Update handles structure
guidata(hObject, handles);

% UIWAIT makes GUI_demo_yNoise wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = GUI_demo_yNoise_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

addpath(genpath('slra-slra-c3aa24c'),'data');
% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in push_start.
function push_start_Callback(hObject, eventdata, handles)

addpath(genpath('slra-slra-c3aa24c'),'data');

tstra = get(handles.edit1, 'string');
tstrb = get(handles.edit2, 'string');
tstrN = get(handles.edit4, 'string');
tstrf = get(handles.edit3, 'string');

N = str2double(tstrN); % Monte-Carlo iteration number

addpath(genpath('slra-slra-c3aa24c'),'data');
a = str2double(tstra);
b = str2double(tstrb);  
xini = -1; % state space 
ub = 2; % ubar is the constant input step function
T = 200; % DT time pts 

Ts = 0.2; % sampling rate
sensor = @(a) c2d(ss(-a, b, 1, 0), Ts); sys = sensor(a); %build the system

coff.g = dcgain(sys); p = size(coff.g, 1); n = size(sys, 'order'); 
coff.n = 1;
coff.ff = str2double(tstrf);

% simulate the step response
y0 = lsim(sys, ones(T, 1) * ub, [], xini);
% define est_error function
est_error = @(uh) sum(abs(ub - uh), 2); opt = [];

%% quantization the data
quantization
for i=2:8
    e(i,:)=y0(:)-y(i,:)';
    plot(handles.axes1,y(i,:)); 
    hold(handles.axes1,'on');

%     plot(handles.axes3,e(i,:)); 
%     hold(handles.axes3,'on');
    uh_dd(:,i) = lsdd(y(i,:)', coff.g, coff.n, coff.ff);
	e_dd(i,:) = est_error(uh_dd(:,i));
end

% plot Y-bits, X-time
contourf(handles.axes3,e_dd)
axis([4 50 2 8]);
ylabel('Bits'); xlabel('time'); title('Error');

%% apply moving average to quantizated data, to smooth it
fw = [1/4 1/4 1/4 1/4];

for i=2:8
    yf(i,:) = avgf(y(i,:),4,fw);
    ef(i,:)=y0(:)-yf(i,:)';
    plot(handles.axes4,yf(i,:)); hold(handles.axes4,'on');
%     figure(5)
%     plot(ef(i,:)); hold on;
    uh_ddf(:,i) = lsdd(yf(i,:)', coff.g, coff.n, coff.ff);
	e_ddf(i,:) = est_error(uh_ddf(:,i));
end

contourf(handles.axes5,e_ddf)
axis([4 50 2 8])
% hObject    handle to push_start (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over push_start.
function push_start_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to push_start (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double


% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit4_Callback(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit4 as text
%        str2double(get(hObject,'String')) returns contents of edit4 as a double


% --- Executes during object creation, after setting all properties.
function edit4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit3_Callback(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit3 as text
%        str2double(get(hObject,'String')) returns contents of edit3 as a double


% --- Executes during object creation, after setting all properties.
function edit3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
