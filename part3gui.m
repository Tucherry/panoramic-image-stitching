function varargout = part3gui(varargin)
% PART3GUI MATLAB code for part3gui.fig
%      PART3GUI, by itself, creates a new PART3GUI or raises the existing
%      singleton*.
%
%      H = PART3GUI returns the handle to a new PART3GUI or the handle to
%      the existing singleton*.
%
%      PART3GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PART3GUI.M with the given input arguments.
%
%      PART3GUI('Property','Value',...) creates a new PART3GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before part3gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to part3gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help part3gui

% Last Modified by GUIDE v2.5 08-Oct-2021 12:27:57

% Begin initialization code - DO NOT EDIT
loc_h1=[];
loc_h2=[];
points=[];
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @part3gui_OpeningFcn, ...
                   'gui_OutputFcn',  @part3gui_OutputFcn, ...
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


% --- Executes just before part3gui is made visible.
function part3gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to part3gui (see VARARGIN)

% Choose default command line output for part3gui
handles.output = hObject;
handles.loc_h1=[];
handles.loc_h2=[];
handles.points=[];
handles.I1=imread('.\h1.jpg');
axes(handles.axes1);
h1=imshow(handles.I1);
set(h1,'ButtonDownFcn',{@myimg1_ButtonDownFcn,handles});
handles.I2=imread('.\h2.jpg');
axes(handles.axes2);
h2=imshow(handles.I2);
set(h2,'ButtonDownFcn',{@myimg2_ButtonDownFcn,handles});
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes part3gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = part3gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


function clearbutton_Callback(hObject, eventdata, handles)
% hObject    handle to clearbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global loc_h1 loc_h2 points
loc_h1=[];
loc_h2=[];
for i=1:1:length(points)
    delete(points(i));
end
points=[];
set(handles.edit1,'string','');
set(handles.edit2,'string','');
set(handles.edit3,'string','');

% --- Executes on button press in h1h2button.
function h1h2button_Callback(hObject, eventdata, handles)
% hObject    handle to h1h2button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global loc_h1 loc_h2
h1_points=loc_h1;
h2_points=loc_h2;
H=findHomography(h1_points,h2_points);
set(handles.edit1,'string',['H=',num2str(H(1,:))]);
set(handles.edit2,'string',['  ',num2str(H(2,:))]);
set(handles.edit3,'string',['  ',num2str(H(3,:))]);
tform=projective2d(H.');
img_warp=imwarp(handles.I1,tform);
figure();
imshow(img_warp);

% --- Executes on button press in h2h1button.
function h2h1button_Callback(hObject, eventdata, handles)
% hObject    handle to h1h2button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global loc_h1 loc_h2
h1_points=loc_h1;
h2_points=loc_h2;
H=findHomography(h2_points,h1_points);
set(handles.edit1,'string',['H=',num2str(H(1,:))]);
set(handles.edit2,'string',['  ',num2str(H(2,:))]);
set(handles.edit3,'string',['  ',num2str(H(3,:))]);
tform=projective2d(H.');
img_warp=imwarp(handles.I2,tform);
figure();
imshow(img_warp);

%% functions
function H=findHomography(hp1,hp2)
homomatrix=zeros(8,9);
for i=1:1:4
    homomatrix(2*i-1,:)=[hp1(i,1) hp1(i,2) 1 0 0 0 -hp2(i,1)*hp1(i,1) -hp2(i,1)*hp1(i,2) -hp2(i,1)];
    homomatrix(2*i,:)=[0 0 0 hp1(i,1) hp1(i,2) 1 -hp2(i,2)*hp1(i,1) -hp2(i,2)*hp1(i,2) -hp2(i,2)];
end
[~,~,V]=svd(homomatrix);
H=reshape(V(:,end)/V(end,end),3,3)';


% --- Executes on mouse press over h1.
function myimg1_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to axes1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global loc_h1 points
pt=get(gca,'CurrentPoint');
x=pt(1,1);
y=pt(1,2);
loc_h1=[loc_h1;[x y]];
hold on;
points=[points plot(x,y,'*','color','r')];
set(handles.edit1,'string',['x=',num2str(x)]);
set(handles.edit2,'string',['y=',num2str(y)]);
set(handles.edit3,'string','');

% --- Executes on mouse press over h2.
function myimg2_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to axes1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global loc_h2 points
pt=get(gca,'CurrentPoint');
x=pt(1,1);
y=pt(1,2);
loc_h2=[loc_h2;[x,y]];
hold on;
points=[points plot(x,y,'*','color','b')];
set(handles.edit1,'string',['x=',num2str(x)]);
set(handles.edit2,'string',['y=',num2str(y)]);
set(handles.edit3,'string','');

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
