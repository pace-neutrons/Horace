function varargout = horace(varargin)
% HORACE M-file for horace.fig
%      HORACE, by itself, creates a new HORACE or raises the existing
%      singleton*.
%
%      H = HORACE returns the handle to a new HORACE or the handle to
%      the existing singleton*.
%
%      HORACE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in HORACE.M with the given input arguments.
%
%      HORACE('Property','Value',...) creates a new HORACE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before horace_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to horace_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help horace

% Last Modified by GUIDE v2.5 27-Nov-2008 12:13:59

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @horace_OpeningFcn, ...
                   'gui_OutputFcn',  @horace_OutputFcn, ...
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


% --- Executes just before horace is made visible.
function horace_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to horace (see VARARGIN)

% Choose default command line output for horace
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes horace wait for user response (see UIRESUME)
% uiwait(handles.HoraceGUI);


% --- Outputs from this function are returned to the command line.
function varargout = horace_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in select_obj_menu.
function select_obj_menu_Callback(hObject, eventdata, handles)
% hObject    handle to select_obj_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns select_obj_menu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from select_obj_menu

str = get(hObject, 'String');
val = get(hObject,'Value');
%
drawnow;
reqstring=str{val};
request=['whos(''',reqstring,''')'];
%determine what kind of object we are dealing with:
workobj=evalin('base',request);%returns a structure array with info about the object
%
object_name=workobj.name;
handles.object_name=object_name;
w_in=evalin('base',object_name);%get the data from the base workspace.
handles.w_in=w_in;%store the object in the handles structure
set(handles.RetainPixel_text,'Visible','off');
set(handles.RetainPixel_radio,'Visible','off');
set(handles.Smooth_panel,'Visible','on');
set(handles.proj_panel,'Visible','off');
if strcmp(workobj.class,'d0d');
    ndims=0;
    handles=hor_switchdims(handles,ndims);%this is a subroutine to update the GUI display
elseif strcmp(workobj.class,'d1d')
    ndims=1;
    handles=hor_switchdims(handles,ndims);
elseif strcmp(workobj.class,'d2d')
    ndims=2;
    handles=hor_switchdims(handles,ndims);
elseif strcmp(workobj.class,'d3d')
    ndims=3;
    handles=hor_switchdims(handles,ndims);
elseif strcmp(workobj.class,'d4d')
    ndims=4;
    handles=hor_switchdims(handles,ndims);
elseif strcmp(workobj.class,'sqw')
    %extra subroutine needed to determine dimensionality:
    [handles,ndims]=hor_sqwdims(handles);
    handles=hor_switchdims(handles,ndims);
    set(handles.RetainPixel_text,'Visible','on');
    set(handles.RetainPixel_radio,'Visible','on');
    set(handles.Smooth_panel,'Visible','off');
    set(handles.proj_panel,'Visible','on');
else
    disp('ERROR: selected dataset not a Horace data class');
    return
    %NB we will get this error message if we try to read an sqw object.
    %This should be fixed later.
end

% Save the handles structure.
guidata(hObject,handles);



% --- Executes during object creation, after setting all properties.
function select_obj_menu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to select_obj_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function SQW_filename_edit_Callback(hObject, eventdata, handles)
% hObject    handle to SQW_filename_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SQW_filename_edit as text
%        str2double(get(hObject,'String')) returns contents of SQW_filename_edit as a double


% --- Executes during object creation, after setting all properties.
function SQW_filename_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SQW_filename_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in axislabel_edit1.
function axislabel_edit1_Callback(hObject, eventdata, handles)
% hObject    handle to axislabel_edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns axislabel_edit1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from axislabel_edit1


% --- Executes during object creation, after setting all properties.
function axislabel_edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axislabel_edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in axislabel_edit2.
function axislabel_edit2_Callback(hObject, eventdata, handles)
% hObject    handle to axislabel_edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns axislabel_edit2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from axislabel_edit2


% --- Executes during object creation, after setting all properties.
function axislabel_edit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axislabel_edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in axislabel_edit3.
function axislabel_edit3_Callback(hObject, eventdata, handles)
% hObject    handle to axislabel_edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns axislabel_edit3 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from axislabel_edit3


% --- Executes during object creation, after setting all properties.
function axislabel_edit3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axislabel_edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in axislabel_edit4.
function axislabel_edit4_Callback(hObject, eventdata, handles)
% hObject    handle to axislabel_edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns axislabel_edit4 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from axislabel_edit4


% --- Executes during object creation, after setting all properties.
function axislabel_edit4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axislabel_edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function LoLim_Ax1_edit_Callback(hObject, eventdata, handles)
% hObject    handle to LoLim_Ax1_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of LoLim_Ax1_edit as text
%        str2double(get(hObject,'String')) returns contents of LoLim_Ax1_edit as a double


% --- Executes during object creation, after setting all properties.
function LoLim_Ax1_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to LoLim_Ax1_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function LoLim_Ax2_edit_Callback(hObject, eventdata, handles)
% hObject    handle to LoLim_Ax2_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of LoLim_Ax2_edit as text
%        str2double(get(hObject,'String')) returns contents of LoLim_Ax2_edit as a double


% --- Executes during object creation, after setting all properties.
function LoLim_Ax2_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to LoLim_Ax2_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function LoLim_Ax3_edit_Callback(hObject, eventdata, handles)
% hObject    handle to LoLim_Ax3_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of LoLim_Ax3_edit as text
%        str2double(get(hObject,'String')) returns contents of LoLim_Ax3_edit as a double


% --- Executes during object creation, after setting all properties.
function LoLim_Ax3_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to LoLim_Ax3_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function LoLim_Ax4_edit_Callback(hObject, eventdata, handles)
% hObject    handle to LoLim_Ax4_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of LoLim_Ax4_edit as text
%        str2double(get(hObject,'String')) returns contents of LoLim_Ax4_edit as a double


% --- Executes during object creation, after setting all properties.
function LoLim_Ax4_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to LoLim_Ax4_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Step_Ax1_edit_Callback(hObject, eventdata, handles)
% hObject    handle to Step_Ax1_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Step_Ax1_edit as text
%        str2double(get(hObject,'String')) returns contents of Step_Ax1_edit as a double


% --- Executes during object creation, after setting all properties.
function Step_Ax1_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Step_Ax1_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Step_Ax2_edit_Callback(hObject, eventdata, handles)
% hObject    handle to Step_Ax2_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Step_Ax2_edit as text
%        str2double(get(hObject,'String')) returns contents of Step_Ax2_edit as a double


% --- Executes during object creation, after setting all properties.
function Step_Ax2_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Step_Ax2_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Step_Ax3_edit_Callback(hObject, eventdata, handles)
% hObject    handle to Step_Ax3_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Step_Ax3_edit as text
%        str2double(get(hObject,'String')) returns contents of Step_Ax3_edit as a double


% --- Executes during object creation, after setting all properties.
function Step_Ax3_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Step_Ax3_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Step_Ax4_edit_Callback(hObject, eventdata, handles)
% hObject    handle to Step_Ax4_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Step_Ax4_edit as text
%        str2double(get(hObject,'String')) returns contents of Step_Ax4_edit as a double


% --- Executes during object creation, after setting all properties.
function Step_Ax4_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Step_Ax4_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function HiLim_Ax1_edit_Callback(hObject, eventdata, handles)
% hObject    handle to HiLim_Ax1_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of HiLim_Ax1_edit as text
%        str2double(get(hObject,'String')) returns contents of HiLim_Ax1_edit as a double


% --- Executes during object creation, after setting all properties.
function HiLim_Ax1_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to HiLim_Ax1_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function HiLim_Ax2_edit_Callback(hObject, eventdata, handles)
% hObject    handle to HiLim_Ax2_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of HiLim_Ax2_edit as text
%        str2double(get(hObject,'String')) returns contents of HiLim_Ax2_edit as a double


% --- Executes during object creation, after setting all properties.
function HiLim_Ax2_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to HiLim_Ax2_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function HiLim_Ax3_edit_Callback(hObject, eventdata, handles)
% hObject    handle to HiLim_Ax3_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of HiLim_Ax3_edit as text
%        str2double(get(hObject,'String')) returns contents of HiLim_Ax3_edit as a double


% --- Executes during object creation, after setting all properties.
function HiLim_Ax3_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to HiLim_Ax3_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function HiLim_Ax4_edit_Callback(hObject, eventdata, handles)
% hObject    handle to HiLim_Ax4_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of HiLim_Ax4_edit as text
%        str2double(get(hObject,'String')) returns contents of HiLim_Ax4_edit as a double


% --- Executes during object creation, after setting all properties.
function HiLim_Ax4_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to HiLim_Ax4_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function uo_h_edit_Callback(hObject, eventdata, handles)
% hObject    handle to uo_h_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of uo_h_edit as text
%        str2double(get(hObject,'String')) returns contents of uo_h_edit as a double


% --- Executes during object creation, after setting all properties.
function uo_h_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to uo_h_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function uo_k_edit_Callback(hObject, eventdata, handles)
% hObject    handle to uo_k_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of uo_k_edit as text
%        str2double(get(hObject,'String')) returns contents of uo_k_edit as a double


% --- Executes during object creation, after setting all properties.
function uo_k_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to uo_k_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function uo_l_edit_Callback(hObject, eventdata, handles)
% hObject    handle to uo_l_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of uo_l_edit as text
%        str2double(get(hObject,'String')) returns contents of uo_l_edit as a double


% --- Executes during object creation, after setting all properties.
function uo_l_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to uo_l_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function uo_e_edit_Callback(hObject, eventdata, handles)
% hObject    handle to uo_e_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of uo_e_edit as text
%        str2double(get(hObject,'String')) returns contents of uo_e_edit as a double


% --- Executes during object creation, after setting all properties.
function uo_e_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to uo_e_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function u1_h_edit_Callback(hObject, eventdata, handles)
% hObject    handle to u1_h_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of u1_h_edit as text
%        str2double(get(hObject,'String')) returns contents of u1_h_edit as a double


% --- Executes during object creation, after setting all properties.
function u1_h_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to u1_h_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function u1_k_edit_Callback(hObject, eventdata, handles)
% hObject    handle to u1_k_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of u1_k_edit as text
%        str2double(get(hObject,'String')) returns contents of u1_k_edit as a double


% --- Executes during object creation, after setting all properties.
function u1_k_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to u1_k_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function u1_l_edit_Callback(hObject, eventdata, handles)
% hObject    handle to u1_l_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of u1_l_edit as text
%        str2double(get(hObject,'String')) returns contents of u1_l_edit as a double


% --- Executes during object creation, after setting all properties.
function u1_l_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to u1_l_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




function u2_h_edit_Callback(hObject, eventdata, handles)
% hObject    handle to u2_h_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of u2_h_edit as text
%        str2double(get(hObject,'String')) returns contents of u2_h_edit as a double


% --- Executes during object creation, after setting all properties.
function u2_h_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to u2_h_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function u2_k_edit_Callback(hObject, eventdata, handles)
% hObject    handle to u2_k_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of u2_k_edit as text
%        str2double(get(hObject,'String')) returns contents of u2_k_edit as a double


% --- Executes during object creation, after setting all properties.
function u2_k_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to u2_k_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function u2_l_edit_Callback(hObject, eventdata, handles)
% hObject    handle to u2_l_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of u2_l_edit as text
%        str2double(get(hObject,'String')) returns contents of u2_l_edit as a double


% --- Executes during object creation, after setting all properties.
function u2_l_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to u2_l_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end






function u3_h_text_Callback(hObject, eventdata, handles)
% hObject    handle to u3_h_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of u3_h_text as text
%        str2double(get(hObject,'String')) returns contents of u3_h_text as a double


% --- Executes during object creation, after setting all properties.
function u3_h_text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to u3_h_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function u3_k_text_Callback(hObject, eventdata, handles)
% hObject    handle to u3_k_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of u3_k_text as text
%        str2double(get(hObject,'String')) returns contents of u3_k_text as a double


% --- Executes during object creation, after setting all properties.
function u3_k_text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to u3_k_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function u3_l_text_Callback(hObject, eventdata, handles)
% hObject    handle to u3_l_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of u3_l_text as text
%        str2double(get(hObject,'String')) returns contents of u3_l_text as a double


% --- Executes during object creation, after setting all properties.
function u3_l_text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to u3_l_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function u3_e_text_Callback(hObject, eventdata, handles)
% hObject    handle to u3_e_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of u3_e_text as text
%        str2double(get(hObject,'String')) returns contents of u3_e_text as a double


% --- Executes during object creation, after setting all properties.
function u3_e_text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to u3_e_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function u4_h_text_Callback(hObject, eventdata, handles)
% hObject    handle to u4_h_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of u4_h_text as text
%        str2double(get(hObject,'String')) returns contents of u4_h_text as a double


% --- Executes during object creation, after setting all properties.
function u4_h_text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to u4_h_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function u4_k_text_Callback(hObject, eventdata, handles)
% hObject    handle to u4_k_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of u4_k_text as text
%        str2double(get(hObject,'String')) returns contents of u4_k_text as a double


% --- Executes during object creation, after setting all properties.
function u4_k_text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to u4_k_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function u4_l_text_Callback(hObject, eventdata, handles)
% hObject    handle to u4_l_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of u4_l_text as text
%        str2double(get(hObject,'String')) returns contents of u4_l_text as a double


% --- Executes during object creation, after setting all properties.
function u4_l_text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to u4_l_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function u4_e_text_Callback(hObject, eventdata, handles)
% hObject    handle to u4_e_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of u4_e_text as text
%        str2double(get(hObject,'String')) returns contents of u4_e_text as a double


% --- Executes during object creation, after setting all properties.
function u4_e_text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to u4_e_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end








% --- Executes on button press in ax_label2_radio_label1_radio.
function ax_label1_radio_Callback(hObject, eventdata, handles)
% hObject    handle to ax_label2_radio_label1_radio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ax_label2_radio_label1_radio

button_state=get(hObject,'Value');
if button_state==get(hObject,'Max') && handles.data_workspace_flag==1
    %button is pressed and object is from workspace
    set(handles.Step_Ax1_edit,'Visible','off');
    set(handles.LoLim_Ax1_edit,'Visible','on');
    set(handles.HiLim_Ax1_edit,'Visible','on');
elseif button_state==get(hObject,'Max') && handles.data_file_flag==1
    set(handles.Step_Ax1_edit,'Visible','off');
    set(handles.LoLim_Ax1_edit,'Visible','on');
    set(handles.HiLim_Ax1_edit,'Visible','on');
elseif button_state==get(hObject,'Min') && handles.data_workspace_flag==1
    set(handles.Step_Ax1_edit,'Visible','on');
    set(handles.LoLim_Ax1_edit,'Visible','on');
    set(handles.HiLim_Ax1_edit,'Visible','on');
else
    set(handles.Step_Ax1_edit,'Visible','on');
    set(handles.LoLim_Ax1_edit,'Visible','on');
    set(handles.HiLim_Ax1_edit,'Visible','on');
end



guidata(gcbo, handles);


% --- Executes on button press in ax_label2_radio.
function ax_label2_radio_Callback(hObject, eventdata, handles)
% hObject    handle to ax_label2_radio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ax_label2_radio

button_state=get(hObject,'Value');
if button_state==get(hObject,'Max') && handles.data_workspace_flag==1
    %button is pressed and object is from workspace
    set(handles.Step_Ax2_edit,'Visible','off');
    set(handles.LoLim_Ax2_edit,'Visible','on');
    set(handles.HiLim_Ax2_edit,'Visible','on');
elseif button_state==get(hObject,'Max') && handles.data_file_flag==1
    set(handles.Step_Ax2_edit,'Visible','off');
    set(handles.LoLim_Ax2_edit,'Visible','on');
    set(handles.HiLim_Ax2_edit,'Visible','on');
elseif button_state==get(hObject,'Min') && handles.data_workspace_flag==1
    set(handles.Step_Ax2_edit,'Visible','on');
    set(handles.LoLim_Ax2_edit,'Visible','on');
    set(handles.HiLim_Ax2_edit,'Visible','on');
else
    set(handles.Step_Ax2_edit,'Visible','on');
    set(handles.LoLim_Ax2_edit,'Visible','on');
    set(handles.HiLim_Ax2_edit,'Visible','on');
end

guidata(gcbo, handles);

% --- Executes on button press in ax_label3_radio.
function ax_label3_radio_Callback(hObject, eventdata, handles)
% hObject    handle to ax_label3_radio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ax_label3_radio

button_state=get(hObject,'Value');
if button_state==get(hObject,'Max') && handles.data_workspace_flag==1
    %button is pressed and object is from workspace
    set(handles.Step_Ax3_edit,'Visible','off');
    set(handles.LoLim_Ax3_edit,'Visible','on');
    set(handles.HiLim_Ax3_edit,'Visible','on');
elseif button_state==get(hObject,'Max') && handles.data_file_flag==1
    set(handles.Step_Ax3_edit,'Visible','off');
    set(handles.LoLim_Ax3_edit,'Visible','on');
    set(handles.HiLim_Ax3_edit,'Visible','on');
elseif button_state==get(hObject,'Min') && handles.data_workspace_flag==1
    set(handles.Step_Ax3_edit,'Visible','on');
    set(handles.LoLim_Ax3_edit,'Visible','on');
    set(handles.HiLim_Ax3_edit,'Visible','on');
else
    set(handles.Step_Ax3_edit,'Visible','on');
    set(handles.LoLim_Ax3_edit,'Visible','on');
    set(handles.HiLim_Ax3_edit,'Visible','on');
end

guidata(gcbo, handles);

% --- Executes on button press in ax_label4_radio.
function ax_label4_radio_Callback(hObject, eventdata, handles)
% hObject    handle to ax_label4_radio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ax_label4_radio

button_state=get(hObject,'Value');
if button_state==get(hObject,'Max') && handles.data_workspace_flag==1
    %button is pressed and object is from workspace
    set(handles.Step_Ax4_edit,'Visible','off');
    set(handles.LoLim_Ax4_edit,'Visible','on');
    set(handles.HiLim_Ax4_edit,'Visible','on');
elseif button_state==get(hObject,'Max') && handles.data_file_flag==1
    set(handles.Step_Ax4_edit,'Visible','off');
    set(handles.LoLim_Ax4_edit,'Visible','on');
    set(handles.HiLim_Ax4_edit,'Visible','on');
elseif button_state==get(hObject,'Min') && handles.data_workspace_flag==1
    set(handles.Step_Ax4_edit,'Visible','on');
    set(handles.LoLim_Ax4_edit,'Visible','on');
    set(handles.HiLim_Ax4_edit,'Visible','on');
else
    set(handles.Step_Ax4_edit,'Visible','on');
    set(handles.LoLim_Ax4_edit,'Visible','on');
    set(handles.HiLim_Ax4_edit,'Visible','on');
end

guidata(gcbo, handles);

% --- Executes on button press in u1_rlu_radio.
function u1_rlu_radio_Callback(hObject, eventdata, handles)
% hObject    handle to u1_rlu_radio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of u1_rlu_radio
button_state=get(hObject,'Value');
if button_state==get(hObject,'Max');%button is pressed
    set(handles.u1_ang_radio,'Value',0);
end
guidata(gcbo, handles);


% --- Executes on button press in u2_rlu_radio.
function u2_rlu_radio_Callback(hObject, eventdata, handles)
% hObject    handle to u2_rlu_radio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of u2_rlu_radio

button_state=get(hObject,'Value');
if button_state==get(hObject,'Max');%button is pressed
    set(handles.u2_ang_radio,'Value',0);
end
guidata(gcbo, handles);

% --- Executes on button press in u3_rlu_radio.
function u3_rlu_radio_Callback(hObject, eventdata, handles)
% hObject    handle to u3_rlu_radio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of u3_rlu_radio

button_state=get(hObject,'Value');
if button_state==get(hObject,'Max');%button is pressed
    set(handles.u3_ang_radio,'Value',0);
end
guidata(gcbo, handles);

% --- Executes on button press in u1_ang_radio.
function u1_ang_radio_Callback(hObject, eventdata, handles)
% hObject    handle to u1_ang_radio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of u1_ang_radio

button_state=get(hObject,'Value');
if button_state==get(hObject,'Max');%button is pressed
    set(handles.u1_rlu_radio,'Value',0);
end
guidata(gcbo, handles);

% --- Executes on button press in u2_ang_radio.
function u2_ang_radio_Callback(hObject, eventdata, handles)
% hObject    handle to u2_ang_radio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of u2_ang_radio

button_state=get(hObject,'Value');
if button_state==get(hObject,'Max');%button is pressed
    set(handles.u2_rlu_radio,'Value',0);
end
guidata(gcbo, handles);

% --- Executes on button press in u3_ang_radio.
function u3_ang_radio_Callback(hObject, eventdata, handles)
% hObject    handle to u3_ang_radio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of u3_ang_radio

button_state=get(hObject,'Value');
if button_state==get(hObject,'Max');%button is pressed
    set(handles.u3_rlu_radio,'Value',0);
end
guidata(gcbo, handles);



% --- Executes on selection change in SaveAsType_menu.
function SaveAsType_menu_Callback(hObject, eventdata, handles)
% hObject    handle to SaveAsType_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns SaveAsType_menu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from SaveAsType_menu

str = get(hObject, 'String');
val = get(hObject,'Value');
% Set current data to the selected data set.
switch str{val};
case 'Workspace object' % User selects to save object to workspace
   handles.save_type = 1;
   set(handles.SaveAs_FilePath_text,'Visible','off');
   set(handles.SaveAsFilePath_edit,'Visible','off');
   set(handles.SaveAsFileName_text,'Visible','off');
   set(handles.SaveAsFileName_edit,'Visible','off');
   set(handles.SaveAsObject_text,'Visible','on');
   set(handles.SaveAsObject_edit,'Visible','on');
   set(handles.SaveAsFilePath_browse,'Visible','off');
case 'File' % User selects to save object to file.
   handles.save_type = 2;
   set(handles.SaveAs_FilePath_text,'Visible','on');
   set(handles.SaveAsFilePath_edit,'Visible','on');
   set(handles.SaveAsFileName_text,'Visible','on');
   set(handles.SaveAsFileName_edit,'Visible','on');
   set(handles.SaveAsObject_text,'Visible','off');
   set(handles.SaveAsObject_edit,'Visible','off');
   set(handles.SaveAsFilePath_browse,'Visible','on');
case 'Both'
   handles.save_type = 3; %User selects to save object in workspace and in file 
   set(handles.SaveAs_FilePath_text,'Visible','on');
   set(handles.SaveAsFilePath_edit,'Visible','on');
   set(handles.SaveAsFileName_text,'Visible','on');
   set(handles.SaveAsFileName_edit,'Visible','on');
   set(handles.SaveAsObject_text,'Visible','on');
   set(handles.SaveAsObject_edit,'Visible','on');
   set(handles.SaveAsFilePath_browse,'Visible','on');
end

% Save the handles structure.
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function SaveAsType_menu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SaveAsType_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function SaveAsFilePath_edit_Callback(hObject, eventdata, handles)
% hObject    handle to SaveAsFilePath_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SaveAsFilePath_edit as text
%        str2double(get(hObject,'String')) returns contents of SaveAsFilePath_edit as a double


% --- Executes during object creation, after setting all properties.
function SaveAsFilePath_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SaveAsFilePath_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function SaveAsFileName_edit_Callback(hObject, eventdata, handles)
% hObject    handle to SaveAsFileName_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SaveAsFileName_edit as text
%        str2double(get(hObject,'String')) returns contents of SaveAsFileName_edit as a double


% --- Executes during object creation, after setting all properties.
function SaveAsFileName_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SaveAsFileName_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function SaveAsObject_edit_Callback(hObject, eventdata, handles)
% hObject    handle to SaveAsObject_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SaveAsObject_edit as text
%        str2double(get(hObject,'String')) returns contents of SaveAsObject_edit as a double


% --- Executes during object creation, after setting all properties.
function SaveAsObject_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SaveAsObject_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in BrowseSQW_pushbutton.
function BrowseSQW_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to BrowseSQW_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if handles.data_file_flag==1
    [sqw_filename,sqw_pathname,FilterIndex] = uigetfile({'*.sqw'},'Select SQW file');
elseif handles.data_nd_file_flag==1
    [sqw_filename,sqw_pathname,FilterIndex] = uigetfile(...
        {'*.d0d';'*.d1d';'*.d2d';'*.d3d';'*.d4d';'*.sqw'},...
        'Select data file');
end

if ischar(sqw_pathname) && ischar(sqw_filename)
    %i.e. the cancel button was not pressed
    set(handles.SQW_filename_edit,'string',[sqw_pathname,sqw_filename]);
    guidata(gcbo,handles);
end


% --- Executes on button press in GenSQW_pushbutton.
function GenSQW_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to GenSQW_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

horace_gen_sqw;%opens the horace_gen_sqw GUI.

% --- Executes on button press in GetDataFile_pushbutton.
function GetDataFile_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to GetDataFile_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles=hor_sqwbutton_visibilities(handles);
guidata(gcbo, handles);

% --- Executes on button press in GetDataWorkspace_pushbutton.
function GetDataWorkspace_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to GetDataWorkspace_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles=hor_workspacebutton_visibilities(handles);


%update the dropdown menu:
drawnow;
vars = evalin('base','whos');%gives a structure array with all of the workspace variables in it
counter=1;
for i=1:numel(vars)
    test_el=vars(i);
    if strcmp(test_el.class,'d1d') || strcmp(test_el.class,'d2d') ||...
            strcmp(test_el.class,'d3d') || strcmp(test_el.class,'d4d') ||...
            strcmp(test_el.class,'sqw');
        cellofvars{counter}=test_el.name;
        counter=counter+1;
    end
end
if ~exist('cellofvars','var')
    disp('No dnd or sqw objects in current workspace');
    disp('---------------------------------------------');
    disp('Load objects into Matlab workspace to proceed')
    return%if no objects that can be plotted or cut are in the workspace
    %we must exit this function
end

drawnow;
set(handles.select_obj_menu,'String',cellofvars);
guidata(gcbo, handles);

%If previously we had selected "Get SQW data from file" the integration
%panel visibilities would be modified, which can lead to inconsistencies.
%So do the same as would occur when a new variable is selected:

str = get(handles.select_obj_menu, 'String');
val = get(handles.select_obj_menu,'Value');
%
drawnow;
reqstring=str{val};
request=['whos(''',reqstring,''')'];
%determine what kind of object we are dealing with:
workobj=evalin('base',request);%returns a structure array with info about the object
%
object_name=workobj.name;
handles.object_name=object_name;
w_in=evalin('base',object_name);%get the data from the base workspace.
handles.w_in=w_in;%store the object in the handles structure
set(handles.RetainPixel_text,'Visible','off');
set(handles.RetainPixel_radio,'Visible','off');
set(handles.Smooth_panel,'Visible','on');
set(handles.proj_panel,'Visible','off');
if strcmp(workobj.class,'d0d');
    ndims=0;
    handles=hor_switchdims2(handles,ndims);%this is a subroutine to update the GUI display
elseif strcmp(workobj.class,'d1d')
    ndims=1;
    handles=hor_switchdims2(handles,ndims);
elseif strcmp(workobj.class,'d2d')
    ndims=2;
    handles=hor_switchdims2(handles,ndims);
elseif strcmp(workobj.class,'d3d')
    ndims=3;
    handles=hor_switchdims2(handles,ndims);
elseif strcmp(workobj.class,'d4d')
    ndims=4;
    handles=hor_switchdims2(handles,ndims);
elseif strcmp(workobj.class,'sqw')
    %extra subroutine needed to determine dimensionality:
    [handles,ndims]=hor_sqwdims(handles);
    handles=hor_switchdims2(handles,ndims);
    set(handles.RetainPixel_text,'Visible','on');
    set(handles.RetainPixel_radio,'Visible','on');
    set(handles.Smooth_panel,'Visible','off');
    set(handles.proj_panel,'Visible','on');
else
    disp('ERROR: selected dataset not a Horace data class');
    return
    %NB we will get this error message if we try to read an sqw object.
    %This should be fixed later.
end

% Save the handles structure.
guidata(hObject,handles);



% --- Executes on selection change in PlotAxis1_edit.
function PlotAxis1_edit_Callback(hObject, eventdata, handles)
% hObject    handle to PlotAxis1_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns PlotAxis1_edit contents as cell array
%        contents{get(hObject,'Value')} returns selected item from PlotAxis1_edit


% --- Executes during object creation, after setting all properties.
function PlotAxis1_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PlotAxis1_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in PlotAxis2_edit.
function PlotAxis2_edit_Callback(hObject, eventdata, handles)
% hObject    handle to PlotAxis2_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns PlotAxis2_edit contents as cell array
%        contents{get(hObject,'Value')} returns selected item from PlotAxis2_edit


% --- Executes during object creation, after setting all properties.
function PlotAxis2_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PlotAxis2_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in PlotAxis3_edit.
function PlotAxis3_edit_Callback(hObject, eventdata, handles)
% hObject    handle to PlotAxis3_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns PlotAxis3_edit contents as cell array
%        contents{get(hObject,'Value')} returns selected item from PlotAxis3_edit


% --- Executes during object creation, after setting all properties.
function PlotAxis3_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PlotAxis3_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function PlotAx1_lo_edit_Callback(hObject, eventdata, handles)
% hObject    handle to PlotAx1_lo_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of PlotAx1_lo_edit as text
%        str2double(get(hObject,'String')) returns contents of PlotAx1_lo_edit as a double


% --- Executes during object creation, after setting all properties.
function PlotAx1_lo_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PlotAx1_lo_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function PlotAx2_lo_edit_Callback(hObject, eventdata, handles)
% hObject    handle to PlotAx2_lo_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of PlotAx2_lo_edit as text
%        str2double(get(hObject,'String')) returns contents of PlotAx2_lo_edit as a double


% --- Executes during object creation, after setting all properties.
function PlotAx2_lo_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PlotAx2_lo_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function PlotAx3_lo_edit_Callback(hObject, eventdata, handles)
% hObject    handle to PlotAx3_lo_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of PlotAx3_lo_edit as text
%        str2double(get(hObject,'String')) returns contents of PlotAx3_lo_edit as a double


% --- Executes during object creation, after setting all properties.
function PlotAx3_lo_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PlotAx3_lo_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





function PlotAx1_hi_edit_Callback(hObject, eventdata, handles)
% hObject    handle to PlotAx1_hi_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of PlotAx1_hi_edit as text
%        str2double(get(hObject,'String')) returns contents of PlotAx1_hi_edit as a double


% --- Executes during object creation, after setting all properties.
function PlotAx1_hi_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PlotAx1_hi_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function PlotAx2_hi_edit_Callback(hObject, eventdata, handles)
% hObject    handle to PlotAx2_hi_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of PlotAx2_hi_edit as text
%        str2double(get(hObject,'String')) returns contents of PlotAx2_hi_edit as a double


% --- Executes during object creation, after setting all properties.
function PlotAx2_hi_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PlotAx2_hi_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function PlotAx3_hi_edit_Callback(hObject, eventdata, handles)
% hObject    handle to PlotAx3_hi_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of PlotAx3_hi_edit as text
%        str2double(get(hObject,'String')) returns contents of PlotAx3_hi_edit as a double


% --- Executes during object creation, after setting all properties.
function PlotAx3_hi_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PlotAx3_hi_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on button press in Plot_pushbutton.
function Plot_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to Plot_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%==
%Update the status flag:
set(handles.Working_text,'BackgroundColor','y');
set(handles.Working_text,'String',{'Status :';'Working'});
guidata(gcbo,handles);
%
handles=hor_plotswitch(handles);%go into this subroutine to work out which 
%plot options have been selected (axes limits, smoothing, etc).
guidata(gcbo,handles);
%
%Get the properties of the figure that has just been plotted (in case we
%wish to overplot):
figure_props=get(gcf);
handles.figure_props=figure_props;
%
%Reset the status flag:
set(handles.Working_text,'BackgroundColor','g');
set(handles.Working_text,'String',{'Status :';'Idle'});
guidata(gcbo,handles);



% --- Executes on button press in Cut_pushbutton.
function Cut_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to Cut_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%this is one of the most important functions in the GUI!

%==
%Update the status flag:
drawnow;
set(handles.Working_text,'BackgroundColor','y');
set(handles.Working_text,'String',{'Status :';'Working'});
drawnow;
guidata(gcbo,handles);
%==
%
%Get all of the information about the cut and work out what sort of cut to
%perform:
handles=hor_cutprep(handles);
%
drawnow;
set(handles.Working_text,'BackgroundColor','g');
set(handles.Working_text,'String',{'Status :';'Done'});
drawnow;
guidata(gcbo,handles);


% --- Executes on button press in PlotOver_pushbutton.
function PlotOver_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to PlotOver_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Update the status flag:
set(handles.Working_text,'BackgroundColor','y');
set(handles.Working_text,'String',{'Status :';'Working'});
guidata(gcbo,handles);
%
try
    handles=hor_plotover_1d(handles);
catch
    %we got an error because a figure window is not open:
    disp('ERROR: no figure window open to plot over');
    set(handles.Working_text,'BackgroundColor','r');
    set(handles.Working_text,'String',{'Status :';'Error'});
    guidata(gcbo,handles);
end
 
%Get the properties of the figure that has just been plotted. For an overplot
%it should not have changed from the previous plot:
figure_props=get(gcf);
handles.figure_props=figure_props;
guidata(gcbo,handles);
%
%Reset the status flag:
set(handles.Working_text,'BackgroundColor','g');
set(handles.Working_text,'String',{'Status :';'Idle'});
guidata(gcbo,handles);


% --- Executes on selection change in linlogScale_menu1.
function linlogScale_menu1_Callback(hObject, eventdata, handles)
% hObject    handle to linlogScale_menu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns linlogScale_menu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from linlogScale_menu1

str = get(hObject, 'String');
val = get(hObject,'Value');
%
drawnow;
linlogstring=str{val};
handles.linlog1=linlogstring;
drawnow;
guidata(gcbo,handles);


% --- Executes during object creation, after setting all properties.
function linlogScale_menu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to linlogScale_menu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in linlogScale_menu2.
function linlogScale_menu2_Callback(hObject, eventdata, handles)
% hObject    handle to linlogScale_menu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns linlogScale_menu2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from linlogScale_menu2

str = get(hObject, 'String');
val = get(hObject,'Value');
%
drawnow;
linlogstring=str{val};
handles.linlog2=linlogstring;
guidata(gcbo,handles);


% --- Executes during object creation, after setting all properties.
function linlogScale_menu2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to linlogScale_menu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in linlogScale_menu3.
function linlogScale_menu3_Callback(hObject, eventdata, handles)
% hObject    handle to linlogScale_menu3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns linlogScale_menu3 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from linlogScale_menu3

str = get(hObject, 'String');
val = get(hObject,'Value');
%
drawnow;
linlogstring=str{val};
handles.linlog3=linlogstring;
guidata(gcbo,handles);


% --- Executes during object creation, after setting all properties.
function linlogScale_menu3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to linlogScale_menu3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes on button press in SmoothAx1_button.
function SmoothAx1_button_Callback(hObject, eventdata, handles)
% hObject    handle to SmoothAx1_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of SmoothAx1_button


% --- Executes on button press in SmoothAx2_button.
function SmoothAx2_button_Callback(hObject, eventdata, handles)
% hObject    handle to SmoothAx2_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of SmoothAx2_button


% --- Executes on button press in SmoothAx3_button.
function SmoothAx3_button_Callback(hObject, eventdata, handles)
% hObject    handle to SmoothAx3_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of SmoothAx3_button


% --- Executes on selection change in SmoothAx1_menu.
function SmoothAx1_menu_Callback(hObject, eventdata, handles)
% hObject    handle to SmoothAx1_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns SmoothAx1_menu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from SmoothAx1_menu

str = get(hObject, 'String');
val = get(hObject,'Value');
%
drawnow;
smoothfunc=str{val};
handles.smoothfunc1=smoothfunc;
drawnow;
guidata(gcbo,handles);


% --- Executes during object creation, after setting all properties.
function SmoothAx1_menu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SmoothAx1_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function SmoothWid1_edit_Callback(hObject, eventdata, handles)
% hObject    handle to SmoothWid1_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SmoothWid1_edit as text
%        str2double(get(hObject,'String')) returns contents of SmoothWid1_edit as a double


% --- Executes during object creation, after setting all properties.
function SmoothWid1_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SmoothWid1_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function SmoothWid2_edit_Callback(hObject, eventdata, handles)
% hObject    handle to SmoothWid2_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SmoothWid2_edit as text
%        str2double(get(hObject,'String')) returns contents of SmoothWid2_edit as a double


% --- Executes during object creation, after setting all properties.
function SmoothWid2_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SmoothWid2_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function SmoothWid3_edit_Callback(hObject, eventdata, handles)
% hObject    handle to SmoothWid3_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SmoothWid3_edit as text
%        str2double(get(hObject,'String')) returns contents of SmoothWid3_edit as a double


% --- Executes during object creation, after setting all properties.
function SmoothWid3_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SmoothWid3_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in Marker_menu.
function Marker_menu_Callback(hObject, eventdata, handles)
% hObject    handle to Marker_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns Marker_menu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Marker_menu

str = get(hObject, 'String');
val = get(hObject,'Value');
%
drawnow;
marker=str{val};
handles.marker=marker;
drawnow;
guidata(gcbo,handles);


% --- Executes during object creation, after setting all properties.
function Marker_menu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Marker_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in MarkerColour_menu.
function MarkerColour_menu_Callback(hObject, eventdata, handles)
% hObject    handle to MarkerColour_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns MarkerColour_menu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from MarkerColour_menu

str = get(hObject, 'String');
val = get(hObject,'Value');
%
drawnow;
colour=str{val};
handles.marker_colour=colour;
drawnow;
guidata(gcbo,handles);

% --- Executes during object creation, after setting all properties.
function MarkerColour_menu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MarkerColour_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in LineStyle_menu.
function LineStyle_menu_Callback(hObject, eventdata, handles)
% hObject    handle to LineStyle_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns LineStyle_menu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from LineStyle_menu

str = get(hObject, 'String');
val = get(hObject,'Value');
%
drawnow;
line=str{val};
handles.line=line;
drawnow;
guidata(gcbo,handles);

% --- Executes during object creation, after setting all properties.
function LineStyle_menu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to LineStyle_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on selection change in Errorbar_menu.
function Errorbar_menu_Callback(hObject, eventdata, handles)
% hObject    handle to Errorbar_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns Errorbar_menu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Errorbar_menu

str = get(hObject, 'String');
val = get(hObject,'Value');
%
drawnow;
errorbar_choice=str{val};
handles.errorbar_choice=errorbar_choice;
drawnow;
guidata(gcbo,handles);

% --- Executes during object creation, after setting all properties.
function Errorbar_menu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Errorbar_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes on button press in SaveAsFilePath_browse.
function SaveAsFilePath_browse_Callback(hObject, eventdata, handles)
% hObject    handle to SaveAsFilePath_browse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

saveas_filepath=uigetdir('C:\');

set(handles.SaveAsFilePath_edit,'string',saveas_filepath);
guidata(gcbo,handles);



% --- Executes on button press in GetndDataFile_pushbutton.
function GetndDataFile_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to GetndDataFile_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles=hor_nddatabutton_visibilities(handles);
guidata(gcbo, handles);


% --- Executes on button press in LoadNdData_pushbutton.
function LoadNdData_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to LoadNdData_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Update the status flag:
set(handles.Working_text,'BackgroundColor','y');
set(handles.Working_text,'String',{'Status :';'Working'});
guidata(gcbo,handles);
%
%
filename=get(handles.SQW_filename_edit,'String');
if ~isempty(filename)
    %need to give a name for the output. Use the name of the object
    hashplace=strfind(filename,'\');%finds location of delimiters
    dotplace=strfind(filename,'.');%find the location of file extension (assumes only one ".")
    savename=filename((hashplace(end)+1):(dotplace-1));
    try
        evalin('base',[savename,'=read_dnd(''',filename,''');']);%try reading dnd file
    catch
        try
            %if file was .sqw then read_dnd would fail. So try read_sqw
            evalin('base',[savename,'=read_sqw(''',filename,''');']);
        catch
            err=lasterror;%for debug;
            disp('ERROR: unable to read specified file.');
            disp('Check it has extension .d0d, .d1d, .d2d, .d3d, .d4d, or .sqw');
            set(handles.Working_text,'BackgroundColor','r');
            set(handles.Working_text,'String',{'Status :';'Error'});
            guidata(gcbo,handles);
        end
    end
else isempty(filename)
    disp('ERROR: you must specify a filename for the data');
    set(handles.Working_text,'BackgroundColor','r');
    set(handles.Working_text,'String',{'Status :';'Error'});
    guidata(gcbo,handles);
    return;
end

set(handles.Working_text,'BackgroundColor','g');
set(handles.Working_text,'String',{'Status :';'Done'});
guidata(gcbo,handles);
guidata(gcbo,handles);    



function SavePars_edit_Callback(hObject, eventdata, handles)
% hObject    handle to SavePars_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SavePars_edit as text
%        str2double(get(hObject,'String')) returns contents of SavePars_edit as a double


% --- Executes during object creation, after setting all properties.
function SavePars_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SavePars_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in SavePars_browse.
function SavePars_browse_Callback(hObject, eventdata, handles)
% hObject    handle to SavePars_browse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[pars_filename,pars_pathname,FilterIndex] = uiputfile({'*.hor'},'Select HOR (Horace parameters) file');

if ischar(pars_filename) && ischar(pars_pathname)
    %i.e. the cancel button was not pressed
    set(handles.SavePars_edit,'string',[pars_pathname,pars_filename]);
    guidata(gcbo,handles);
end


function LoadPars_edit_Callback(hObject, eventdata, handles)
% hObject    handle to LoadPars_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of LoadPars_edit as text
%        str2double(get(hObject,'String')) returns contents of LoadPars_edit as a double


% --- Executes during object creation, after setting all properties.
function LoadPars_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to LoadPars_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in LoadPars_browse.
function LoadPars_browse_Callback(hObject, eventdata, handles)
% hObject    handle to LoadPars_browse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[hor_filename,hor_pathname,FilterIndex] = uigetfile({'*.hor'},'Select HOR parameter file');

if ischar(hor_filename) && ischar(hor_pathname)
    %i.e. the canecl button was not pressed
    set(handles.LoadPars_edit,'string',[hor_pathname,hor_filename]);
    %
    guidata(gcbo,handles);
end


% --- Executes on button press in LoadPars_load.
function LoadPars_load_Callback(hObject, eventdata, handles)
% hObject    handle to LoadPars_load (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles=hor_readparams(handles);
guidata(gcbo,handles);


% --- Executes on button press in SavePars_save.
function SavePars_save_Callback(hObject, eventdata, handles)
% hObject    handle to SavePars_save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles=hor_saveparams(handles);
guidata(gcbo,handles);


% --- Executes on button press in RetainPixel_radio.
function RetainPixel_radio_Callback(hObject, eventdata, handles)
% hObject    handle to RetainPixel_radio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of RetainPixel_radio


