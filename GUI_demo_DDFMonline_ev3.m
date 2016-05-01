function varargout = GUI_demo_DDFMonline_data(varargin)
% GUI_DEMO_DDFMONLINE_DATA MATLAB code for GUI_demo_DDFMonline_data.fig
%      GUI_DEMO_DDFMONLINE_DATA, by itself, creates a new GUI_DEMO_DDFMONLINE_DATA or raises the existing
%      singleton*.
%
%      H = GUI_DEMO_DDFMONLINE_DATA returns the handle to a new GUI_DEMO_DDFMONLINE_DATA or the handle to
%      the existing singleton*.
%
%      GUI_DEMO_DDFMONLINE_DATA('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI_DEMO_DDFMONLINE_DATA.M with the given input arguments.
%
%      GUI_DEMO_DDFMONLINE_DATA('Property','Value',...) creates a new GUI_DEMO_DDFMONLINE_DATA or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GUI_demo_DDFMonline_data_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GUI_demo_DDFMonline_data_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GUI_demo_DDFMonline_data

% Last Modified by GUIDE v2.5 04-Apr-2016 11:00:36

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GUI_demo_DDFMonline_data_OpeningFcn, ...
                   'gui_OutputFcn',  @GUI_demo_DDFMonline_data_OutputFcn, ...
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


% --- Executes just before GUI_demo_DDFMonline_data is made visible.
function GUI_demo_DDFMonline_data_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GUI_demo_DDFMonline_data (see VARARGIN)

% Choose default command line output for GUI_demo_DDFMonline_data
handles.output = hObject;


% Update handles structure
guidata(hObject, handles);

% UIWAIT makes GUI_demo_DDFMonline_data wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = GUI_demo_DDFMonline_data_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in push_start.
function push_start_Callback(hObject, eventdata, handles)


% Using system identification toolbox provided
addpath(genpath('slra-slra-c3aa24c'),'data');

% Initiate LEGO EV3
mylego = legoev3('usb');
sensorList = mylego.readInputDeviceList;
[~, inport] = ismember('NXT_TEMP',sensorList); % detect and recogize NXT_TEMP sensor
tempsens = tempSensor(mylego, inport);

%% Setting Expirement parameters 
Fs = 2; % setting sampling frequency to 10 Hz
Ts = 1/Fs;
tlen = 30;  % define the test time length
pts = tlen*Fs;
% yin = zeros(1,pts); %initial the measured data matrix
% tx = [1:pts]*Ts;
% 
% figure, axis([1 tlen 25 35]);


%y = data';
n = 5; % system order => 1 : known
g = 1; opt = []; % G mat => 1 : known 
f = 1; % [!] setting forgetting factor

finv = 1 / f;
%T = size(y,1);
nc = n+1;
%ur = y(T-10);
%% sampling the data through EV3 sensor
for i=1:pts
    tmp = tempsens.readTemp;
    y(i) = tmp;
    if i>=2
        dy(i-1)=y(i)-y(i-1);
        if i>n
            b(i-n)=y(i);
            A(i-n,:) = [g, dy(i-n:i-1)];
            if i==n*2+1
                Ai = A(1:nc, 1:nc);
                x(:,nc) = pinv(Ai) * (b(1:nc))';
                p = pinv(Ai' * Ai);
            elseif i>n*2+1
                ii = i-n;
                Ai = A(ii, :);
                k = finv * p * Ai' / (1 + finv * Ai * p * Ai');
                x(:, ii) = x(:, ii- 1) + k * (b(ii) - Ai * x(:, ii - 1));
                p  = 1 / f * (p - k * Ai * p);
                uh(i) = x(1,ii);
                %er_dd(i) = abs(uh(i)-ur);
                %er_nv(i) = abs(y(i)-ur);
                hold (handles.axes1,'on')
                plot(handles.axes1,i,y(i),'ro');
                plot(handles.axes1,i,uh(i),'bx');
                legend('Navie Method','DDFM');
                
%                hold (handles.axes2,'on')
%                plot(handles.axes2,i,er_nv(i),'ro');
%                plot(handles.axes2,i,er_dd(i),'bx');
                
                set(handles.fill_y, 'String', num2str(y(i)));
                set(handles.fill_ub, 'String', num2str(uh(i)));
%                 set(handles.fill_err, 'String', num2str(er_dd(i)));
%                 set(handles.fill_err2, 'String', num2str(er_nv(i)));
                
                pause(Ts); % sampling in certain frequency
            end
        end
    end
end


% hObject    handle to push_start (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
