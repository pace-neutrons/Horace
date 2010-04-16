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

% Last Modified by GUIDE v2.5 22-Jan-2010 17:08:30

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

splash('splashscreen','jpg',4000);

% Choose default command line output for horace
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes horace wait for user response (see UIRESUME)
% uiwait(handles.figure1);

set(handles.message_info_text,'String','');
guidata(hObject,handles);
drawnow;
%
vars = evalin('base','whos');%gives a structure array with all of the workspace variables in it
counter=1;
for i=1:numel(vars)
    test_el=vars(i);
    if strcmp(test_el.class,'d1d') || strcmp(test_el.class,'d2d') ||...
            strcmp(test_el.class,'d3d') || strcmp(test_el.class,'d4d') ||...
            strcmp(test_el.class,'sqw');
        cellofnames{counter}=test_el.name;
        cellofvars{counter}=[test_el.name,'.........',test_el.class];
        counter=counter+1;
    end
end
if ~exist('cellofvars','var')
    return%if no objects that can be plotted or cut are in the workspace
    %we must exit this function
end
guidata(hObject, handles);
drawnow;
set(handles.obj_list_popupmenu,'String',cellofvars);
guidata(hObject, handles);

str = get(handles.obj_list_popupmenu, 'String');
val = get(handles.obj_list_popupmenu,'Value');
%
drawnow;
reqstring=str{val};
reqstring(end-11:end)=[];
request=['whos(''',reqstring,''')'];
%determine what kind of object we are dealing with:
workobj=evalin('base',request);%returns a structure array with info about the object
%
object_name=workobj.name;
handles.object_name=object_name;
w_in=evalin('base',object_name);%get the data from the base workspace.
handles.w_in=w_in;%store the object in the handles structure

guidata(hObject,handles);



% --- Outputs from this function are returned to the command line.
function varargout = horace_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function sqw_filename_edit_Callback(hObject, eventdata, handles)
% hObject    handle to sqw_filename_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of sqw_filename_edit as text
%        str2double(get(hObject,'String')) returns contents of sqw_filename_edit as a double


% --- Executes during object creation, after setting all properties.
function sqw_filename_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sqw_filename_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in sqw_browse_pushbutton.
function sqw_browse_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to sqw_browse_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[sqw_filename,sqw_pathname,FilterIndex] = uigetfile({'*.sqw'},'Select SQW file');

if ischar(sqw_pathname) && ischar(sqw_filename)
    %i.e. the cancel button was not pressed
    set(handles.sqw_filename_edit,'string',[sqw_pathname,sqw_filename]);
    guidata(gcbo,handles);
end


% --- Executes on selection change in obj_list_popupmenu.
function obj_list_popupmenu_Callback(hObject, eventdata, handles)
% hObject    handle to obj_list_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns obj_list_popupmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from obj_list_popupmenu


%
%Clear error message
set(handles.message_info_text,'String','');
guidata(gcbo,handles);
drawnow;
%
vars = evalin('base','whos');%gives a structure array with all of the workspace variables in it
counter=1;
for i=1:numel(vars)
    test_el=vars(i);
    if strcmp(test_el.class,'d1d') || strcmp(test_el.class,'d2d') ||...
            strcmp(test_el.class,'d3d') || strcmp(test_el.class,'d4d') ||...
            strcmp(test_el.class,'sqw');
        cellofnames{counter}=test_el.name;
        cellofvars{counter}=[test_el.name,'.........',test_el.class];
        counter=counter+1;
    end
end
if ~exist('cellofvars','var')
    mess1=' No dnd or sqw objects in current workspace  ';
    mess2='---------------------------------------------';
    mess3='Load objects into Matlab workspace to proceed';
    set(handles.message_info_text,'String',[mess1; mess2; mess3]);
    guidata(gcbo,handles);
    set(handles.obj_list_popupmenu,'String','No objects to select');
    guidata(gcbo, handles);
    return%if no objects that can be plotted or cut are in the workspace
    %we must exit this function
end

drawnow;
set(handles.obj_list_popupmenu,'String',cellofvars);
guidata(gcbo, handles);

str = get(hObject, 'String');
val = get(hObject,'Value');
%
drawnow;
reqstring=str{val};
reqstring(end-11:end)=[];
request=['whos(''',reqstring,''')'];
%determine what kind of object we are dealing with:
workobj=evalin('base',request);%returns a structure array with info about the object
%
object_name=workobj.name;
handles.object_name=object_name;
w_in=evalin('base',object_name);%get the data from the base workspace.
handles.w_in=w_in;%store the object in the handles structure

guidata(gcbo,handles);


% --- Executes during object creation, after setting all properties.
function obj_list_popupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to obj_list_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





% --- Executes on button press in cut_from_object_pushbutton.
function cut_from_object_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to cut_from_object_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Clear error message
set(handles.message_info_text,'String','');
guidata(gcbo,handles);
drawnow;

if isfield(handles,'w_in');
    test=get(handles.obj_list_popupmenu,'String');
    nstep=strmatch(handles.object_name,test);
    assignin('base','horace_gui_nstep_switch',num2str(nstep));
    horace_cut_from_object;
else
    mess='No cut initialised -- select an object to cut';
    set(handles.message_info_text,'String',mess);
    drawnow;
    guidata(gcbo,handles);
end

guidata(gcbo,handles);


% --- Executes on button press in plot_pushbutton.
function plot_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to plot_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Clear error message
set(handles.message_info_text,'String','');
guidata(gcbo,handles);
drawnow;
if isfield(handles,'w_in');
    win=handles.w_in;
    if numel(win)~=1
        mess='No plot performed - object selected is an array of Horace objects';
        set(handles.message_info_text,'String',mess);
        drawnow;
        guidata(gcbo,handles);
        return;
    end
    ndims=dimensions(win);
    if ndims==1
        if isfield(handles,'plotmarker') && ~isempty(handles.plotmarker)
            amark(handles.plotmarker);
        end
        if isfield(handles,'plotcolour') && ~isempty(handles.plotcolour)
            acolor(handles.plotcolour);
        end
        [fig_handle,axis_handle,plot_handle]=dp(win);
        drawnow;
        handles.horacefig=fig_handle;
    elseif ndims==2
        [fig_handle,axis_handle,plot_handle]=plot(win);
        drawnow;
        handles.horacefig=fig_handle;
        set(handles.message_info_text,'String','Success!');
        drawnow;
        guidata(gcbo,handles);
    elseif ndims==3
        [fig_handle,axis_handle,plot_handle]=plot(win);
        drawnow;
        handles.horacefig=fig_handle;
        set(handles.message_info_text,'String','Success!');
        drawnow;
        guidata(gcbo,handles);
    elseif ndims==4
        mess='Selected object is 4-dimensional, so cannot plot';
        set(handles.message_info_text,'String',mess);
        guidata(gcbo,handles);
        return;
    end        
end

guidata(gcbo,handles);

% --- Executes on button press in save_to_file_pushbutton.
function save_to_file_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to save_to_file_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in unary_ops_pushbutton.
function unary_ops_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to unary_ops_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Clear error message
set(handles.message_info_text,'String','');
guidata(gcbo,handles);
drawnow;

if isfield(handles,'w_in');
    test=get(handles.obj_list_popupmenu,'String');
    nstep=strmatch(handles.object_name,test);
    assignin('base','horace_gui_nstep_switch',num2str(nstep));
    horace_unary_operation;
else
    mess='No unary operation initialised -- select an object on which to operate';
    set(handles.message_info_text,'String',mess);
    drawnow;
    guidata(gcbo,handles);
end

guidata(gcbo,handles);


% --- Executes on button press in binary_ops_pushbutton.
function binary_ops_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to binary_ops_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Clear error message
set(handles.message_info_text,'String','');
guidata(gcbo,handles);
drawnow;

if isfield(handles,'w_in');
    test=get(handles.obj_list_popupmenu,'String');
    nstep=strmatch(handles.object_name,test);
    assignin('base','horace_gui_nstep_switch',num2str(nstep));
    horace_binary_operation;
else
    mess='No binary operation initialised -- select an object on which to operate';
    set(handles.message_info_text,'String',mess);
    drawnow;
    guidata(gcbo,handles);
end

guidata(gcbo,handles);

% --- Executes on button press in cut_from_file_pushbutton.
function cut_from_file_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to cut_from_file_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Clear error message
set(handles.message_info_text,'String','');
guidata(gcbo,handles);
drawnow;

sqw_flname=get(handles.sqw_filename_edit,'String');
if ~isempty(sqw_flname)
    assignin('base','sqw_filename_internal',sqw_flname);
    horace_cut_from_file;
else
    mess='No cut initialised -- select a file to cut';
    set(handles.message_info_text,'String',mess);
    drawnow;
    guidata(gcbo,handles);
end

guidata(gcbo,handles);

% --- Executes on button press in overplot_pushbutton.
function overplot_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to overplot_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Clear error message
set(handles.message_info_text,'String','');
guidata(gcbo,handles);
drawnow;

if isfield(handles,'w_in');
    win=handles.w_in;
    if numel(win)~=1
        mess='No plot-over performed - object selected is an array of Horace objects';
        set(handles.message_info_text,'String',mess);
        drawnow;
        guidata(gcbo,handles);
        return;
    end
    ndims=dimensions(win);
    if ndims==1
        if isfield(handles,'plotovermarker') && ~isempty(handles.plotovermarker)
            amark(handles.plotovermarker);
        end
        if isfield(handles,'plotovercolour') && ~isempty(handles.plotovercolour)
            acolor(handles.plotovercolour);
        end
        if isfield(handles,'horacefig')
            try
                set(0,'CurrentFigure',handles.horacefig);
                pp(win);
                drawnow;
                set(handles.message_info_text,'String','Success!');
                drawnow;
                guidata(gcbo,handles);
            catch
                pp(win);
                drawnow;
                set(handles.message_info_text,'String','Success!');
                drawnow;
                guidata(gcbo,handles);
            end
        else
            dp(win);
            drawnow;
            set(handles.message_info_text,'String','Success!');
            drawnow;
            guidata(gcbo,handles);
        end
    else
        mess='Cannot overplot anything other than 1d cuts';
        set(handles.message_info_text,'String',mess);
        drawnow;
        guidata(gcbo,handles);
    end        
end


function savefile_edit_Callback(hObject, eventdata, handles)
% hObject    handle to savefile_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of savefile_edit as text
%        str2double(get(hObject,'String')) returns contents of savefile_edit as a double


% --- Executes during object creation, after setting all properties.
function savefile_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to savefile_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





% --- Executes on selection change in plot_marker_popupmenu.
function plot_marker_popupmenu_Callback(hObject, eventdata, handles)
% hObject    handle to plot_marker_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns plot_marker_popupmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from plot_marker_popupmenu

str = get(hObject, 'String');
val = get(hObject,'Value');
%
drawnow;
reqstring=str{val};
handles.plotmarker=reqstring(1);
guidata(gcbo,handles);


% --- Executes during object creation, after setting all properties.
function plot_marker_popupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to plot_marker_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes on selection change in plot_colour_popupmenu.
function plot_colour_popupmenu_Callback(hObject, eventdata, handles)
% hObject    handle to plot_colour_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns plot_colour_popupmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from plot_colour_popupmenu

str = get(hObject, 'String');
val = get(hObject,'Value');
%
drawnow;
reqstring=str{val};
reqstring(1:3)=[]; reqstring(end)=[];
handles.plotcolour=reqstring;
guidata(gcbo,handles);

% --- Executes during object creation, after setting all properties.
function plot_colour_popupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to plot_colour_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in plot_over_marker_popupmenu.
function plot_over_marker_popupmenu_Callback(hObject, eventdata, handles)
% hObject    handle to plot_over_marker_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns plot_over_marker_popupmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from plot_over_marker_popupmenu

str = get(hObject, 'String');
val = get(hObject,'Value');
%
drawnow;
reqstring=str{val};
handles.plotovermarker=reqstring(1);
guidata(gcbo,handles);



% --- Executes during object creation, after setting all properties.
function plot_over_marker_popupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to plot_over_marker_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in plot_over_colour_popupmenu.
function plot_over_colour_popupmenu_Callback(hObject, eventdata, handles)
% hObject    handle to plot_over_colour_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns plot_over_colour_popupmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from plot_over_colour_popupmenu

str = get(hObject, 'String');
val = get(hObject,'Value');
%
drawnow;
reqstring=str{val};
reqstring(1:3)=[]; reqstring(end)=[];
handles.plotovercolour=reqstring;
guidata(gcbo,handles);


% --- Executes during object creation, after setting all properties.
function plot_over_colour_popupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to plot_over_colour_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes on button press in savefile_browse_pushbutton.
function savefile_browse_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to savefile_browse_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[save_filename,save_pathname,FilterIndex] = uiputfile({'*.sqw';'*.d0d';'*.d1d';'*.d2d';...
    '*.d3d';'*.d4d';'*.*'},'Save As');

if ischar(save_pathname) && ischar(save_filename)
    %i.e. the cancel button was not pressed
    set(handles.savefile_edit,'String',[save_pathname,save_filename]);
    guidata(gcbo,handles);
end


% --- Executes on button press in savefile_to_file_pushbutton.
function savefile_to_file_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to savefile_to_file_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Clear error message
set(handles.message_info_text,'String','');
guidata(gcbo,handles);
drawnow;

if isfield(handles,'w_in')
    win=handles.w_in;
    if numel(win)~=1
        mess='No save performed - object selected is an array of Horace objects';
        set(handles.message_info_text,'String',mess);
        drawnow;
        guidata(gcbo,handles);
        return;
    end
    str=get(handles.savefile_edit,'String');
    if ~isempty(str)
        save(win,str);
    else
        mess='No file written -- select a filename';
        set(handles.message_info_text,'String',mess);
        drawnow;
        guidata(gcbo,handles);
    end
else
    mess='No file written -- select an object to save';
    set(handles.message_info_text,'String',mess);
    drawnow;
    guidata(gcbo,handles);
end

    


% --- Executes on button press in bose_pushbutton.
function bose_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to bose_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Clear error message
set(handles.message_info_text,'String','');
guidata(gcbo,handles);
drawnow;

if isfield(handles,'w_in');
    test=get(handles.obj_list_popupmenu,'String');
    nstep=strmatch(handles.object_name,test);
    assignin('base','horace_gui_nstep_switch',num2str(nstep));
    horace_bosegui;
else
    mess='No bose correction initialised -- select an object on which to operate';
    set(handles.message_info_text,'String',mess);
    drawnow;
    guidata(gcbo,handles);
end

guidata(gcbo,handles);


% --- Executes on button press in replicate_pushbutton.
function replicate_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to replicate_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Clear error message
set(handles.message_info_text,'String','');
guidata(gcbo,handles);
drawnow;

if isfield(handles,'w_in');
%     if is_sqw_type(sqw(handles.w_in))
%         mess='No replication initialised -- object selected is sqw type, which cannot be replicated';
%         set(handles.message_info_text,'String',mess);
%         drawnow;
%         guidata(gcbo,handles);
%         return;
%     end
    test=get(handles.obj_list_popupmenu,'String');
    nstep=strmatch(handles.object_name,test);
    assignin('base','horace_gui_nstep_switch',num2str(nstep));
    horace_replicate;
else
    mess='No replication initialised -- select an object on which to operate';
    set(handles.message_info_text,'String',mess);
    drawnow;
    guidata(gcbo,handles);
end

guidata(gcbo,handles);


% --- Executes on button press in combine_pushbutton.
function combine_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to combine_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Clear error message
set(handles.message_info_text,'String','');
guidata(gcbo,handles);
drawnow;

if isfield(handles,'w_in');
%     if is_sqw_type(sqw(handles.w_in))
%         mess='No replication initialised -- object selected is sqw type, which cannot be replicated';
%         set(handles.message_info_text,'String',mess);
%         drawnow;
%         guidata(gcbo,handles);
%         return;
%     end
    test=get(handles.obj_list_popupmenu,'String');
    nstep=strmatch(handles.object_name,test);
    assignin('base','horace_gui_nstep_switch',num2str(nstep));
    horace_combine;
else
    mess='No combine initialised -- select an object on which to operate';
    set(handles.message_info_text,'String',mess);
    drawnow;
    guidata(gcbo,handles);
end

guidata(gcbo,handles);


% --- Executes on button press in symmetrise_pushbutton.
function symmetrise_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to symmetrise_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Clear error message
set(handles.message_info_text,'String','');
guidata(gcbo,handles);
drawnow;

if isfield(handles,'w_in');
%     if is_sqw_type(sqw(handles.w_in))
%         mess='No replication initialised -- object selected is sqw type, which cannot be replicated';
%         set(handles.message_info_text,'String',mess);
%         drawnow;
%         guidata(gcbo,handles);
%         return;
%     end
    test=get(handles.obj_list_popupmenu,'String');
    nstep=strmatch(handles.object_name,test);
    assignin('base','horace_gui_nstep_switch',num2str(nstep));
    horace_symmetrise;
else
    mess='No symmetrise initialised -- select an object on which to operate';
    set(handles.message_info_text,'String',mess);
    drawnow;
    guidata(gcbo,handles);
end

guidata(gcbo,handles);


% --- Executes on button press in rebin_pushbutton.
function rebin_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to rebin_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Clear error message
set(handles.message_info_text,'String','');
guidata(gcbo,handles);
drawnow;

if isfield(handles,'w_in');
%     if is_sqw_type(sqw(handles.w_in))
%         mess='No replication initialised -- object selected is sqw type, which cannot be replicated';
%         set(handles.message_info_text,'String',mess);
%         drawnow;
%         guidata(gcbo,handles);
%         return;
%     end
    test=get(handles.obj_list_popupmenu,'String');
    nstep=strmatch(handles.object_name,test);
    assignin('base','horace_gui_nstep_switch',num2str(nstep));
    horace_rebin;
else
    mess='No rebin initialised -- select an object on which to operate';
    set(handles.message_info_text,'String',mess);
    drawnow;
    guidata(gcbo,handles);
end

guidata(gcbo,handles);

