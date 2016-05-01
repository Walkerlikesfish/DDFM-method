function varargout = GUI_demo_yNoise(varargin)
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

a = str2double(tstra);
b = str2double(tstrb); 
xini = -1; % state space 
ub = 2; % ubar is the constant input step function
T = 200; % DT time pts 
N = str2double(tstrN); % Monte-Carlo iteration number
sN = 20;

sensor = @(a) c2d(ss(-a, b, 1, 0), 1); sys = sensor(a); %build the system

coff.g = dcgain(sys); p = size(coff.g, 1); n = size(sys, 'order'); 
coff.n = 1;
coff.ff = str2double(tstrf);

% simulate the step response
y0 = lsim(sys, ones(T, 1) * ub, [], xini);
% define est_error function
est_error = @(uh) sum(abs(ub - uh), 2); opt = [];

% iterate sensor noise variance
s=0; ds=0.05;
xs = [s:ds:ds*(sN-1)];

for sit=1:sN

for it=1:N
    
%% add noise
yn = randn(size(y0)); sn = s / norm(yn) * norm(y0);  % Noraml distribution
if length(sn) ~= p, sn = sn * ones(1, p), end
y = y0 + yn * diag(sn);
% show the generated data
% figure(1)
% plot(y0,'g'); hold on; plot(y,'bo'); hold on;

%% DDFM Method
uh_dd(:,it) = lsdd(y, coff.g, coff.n, coff.ff);
e_dd(it,:) = est_error(uh_dd(:,it));
%plot(uh,'r');
% figure(2)
% plot(e_nv(4:end),'k')
% hold on;
% figure(3)
% plot(uh,'k'); hold on;
%% Kalman Filter
uh_kf(:,it) = stepid_kf(y, sys, diag(sn .^ 2));
e_kf(it,:) = est_error(uh_kf(:,it));
% figure(2)
% plot(e_nv(4:end),'g'); hold on;
% figure(3)
% plot(uh,'g'); hold on;
%% Naive Method
uh_nv(:,it) = y * pinv(coff.g');
e_nv(it,:) = est_error(uh_nv(:,it));
% figure(2)
% plot(e_nv,'b'); hold on;
% axis([4 inf 0 1])
% figure(3)
% plot(uh,'b'); hold on;
% axis([10 inf 0 3])

end
uh_dd_ = mean(uh_dd,2);
uh_kf_ = mean(uh_kf,2);
uh_nv_ = mean(uh_nv,2);

e_nv_ = mean(e_nv);
e_kf_ = mean(e_kf);
e_dd_ = mean(e_dd);

e100_dd(sit)=e_dd_(100);
e100_kf(sit)=e_kf_(100);
e100_nv(sit)=e_nv_(100);

s=s+ds;
end
plot(xs,e100_dd,'k'); hold on;
plot(xs,e100_kf,'g'); hold on;
plot(xs,e100_nv,'b'); hold on;
xlabel('Noise Variance')
ylabel('Error')


% uh_dd_ = mean(uh_dd,2);
% uh_kf_ = mean(uh_kf,2);
% uh_nv_ = mean(uh_nv,2);
% figure(2)
% plot(uh_dd_,'k'); hold on;
% plot(uh_kf_,'g'); hold on;
% plot(uh_nv_,'b'); hold on;
% axis([10 inf 0 3])
% 
% e_nv_ = mean(e_nv);
% e_kf_ = mean(e_kf);
% e_dd_ = mean(e_dd);
% figure(3)
% plot(e_dd_,'k'); hold on;
% plot(e_kf_,'g'); hold on;
% plot(e_nv_,'b'); hold on;
% axis([4 inf 0 1])

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
