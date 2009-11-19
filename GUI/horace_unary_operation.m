function varargout = horace_unary_operation(varargin)
% HORACE_UNARY_OPERATION M-file for horace_unary_operation.fig
%      HORACE_UNARY_OPERATION, by itself, creates a new HORACE_UNARY_OPERATION or raises the existing
%      singleton*.
%
%      H = HORACE_UNARY_OPERATION returns the handle to a new HORACE_UNARY_OPERATION or the handle to
%      the existing singleton*.
%
%      HORACE_UNARY_OPERATION('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in HORACE_UNARY_OPERATION.M with the given input arguments.
%
%      HORACE_UNARY_OPERATION('Property','Value',...) creates a new HORACE_UNARY_OPERATION or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before horace_unary_operation_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to horace_unary_operation_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help horace_unary_operation

% Last Modified by GUIDE v2.5 13-Nov-2009 13:13:33

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @horace_unary_operation_OpeningFcn, ...
                   'gui_OutputFcn',  @horace_unary_operation_OutputFcn, ...
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


% --- Executes just before horace_unary_operation is made visible.
function horace_unary_operation_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to horace_unary_operation (see VARARGIN)

% Choose default command line output for horace_unary_operation
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes horace_unary_operation wait for user response (see UIRESUME)
% uiwait(handles.figure1);

noobj=false;
try
    nsteps=evalin('base','horace_gui_nstep_switch');
catch
    noobj=true;
end

if ~noobj
    nsteps=str2double(nsteps); %convert from string to number
    %We must populate the list box now.
    %==================================
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
        set(handles.select_obj_popupmenu,'String','No objects to select');
        guidata(gcbo, handles);
        return%if no objects that can be plotted or cut are in the workspace
        %we must exit this function
    end
    
    %It is at this point we circshift the cell array of variables so that
    %the object we want is on top:
    cellofvars=circshift(cellofvars',(1-nsteps));
    cellofvars=cellofvars';
    
    drawnow;
    set(handles.select_obj_popupmenu,'String',cellofvars);
    guidata(gcbo, handles);

    str = get(handles.select_obj_popupmenu, 'String');
    val = get(handles.select_obj_popupmenu,'Value');
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
    
    %Also ensure the default function (1st in list) acos is selected:
    handles.funcstr='acos';
    
    guidata(hObject,handles);
    %
    
    evalin('base','clear horace_gui_nstep_switch');%gets rid of the evidence!
end



% --- Outputs from this function are returned to the command line.
function varargout = horace_unary_operation_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in select_obj_popupmenu.
function select_obj_popupmenu_Callback(hObject, eventdata, handles)
% hObject    handle to select_obj_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns select_obj_popupmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from select_obj_popupmenu

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
    set(handles.select_obj_popupmenu,'String','No objects to select');
    guidata(gcbo, handles);
    return%if no objects that can be plotted or cut are in the workspace
    %we must exit this function
end

drawnow;
set(handles.select_obj_popupmenu,'String',cellofvars);
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
function select_obj_popupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to select_obj_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in func_popupmenu.
function func_popupmenu_Callback(hObject, eventdata, handles)
% hObject    handle to func_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns func_popupmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from func_popupmenu

str = get(hObject, 'String');
val = get(hObject,'Value');
funcstr=str{val};

handles.funcstr=funcstr;

guidata(gcbo,handles);

% --- Executes during object creation, after setting all properties.
function func_popupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to func_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function outobj_edit_Callback(hObject, eventdata, handles)
% hObject    handle to outobj_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of outobj_edit as text
%        str2double(get(hObject,'String')) returns contents of outobj_edit as a double


% --- Executes during object creation, after setting all properties.
function outobj_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to outobj_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in outfile_radiobutton.
function outfile_radiobutton_Callback(hObject, eventdata, handles)
% hObject    handle to outfile_radiobutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of outfile_radiobutton



function outfile_edit_Callback(hObject, eventdata, handles)
% hObject    handle to outfile_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of outfile_edit as text
%        str2double(get(hObject,'String')) returns contents of outfile_edit as a double


% --- Executes during object creation, after setting all properties.
function outfile_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to outfile_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in outfile_browse_pushbutton.
function outfile_browse_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to outfile_browse_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[save_filename,save_pathname,FilterIndex] = uiputfile({'*.sqw';'*.d0d';'*.d1d';'*.d2d';...
    '*.d3d';'*.d4d';'*.*'},'Save As');

if ischar(save_pathname) && ischar(save_filename)
    %i.e. the cancel button was not pressed
    set(handles.outfile_edit,'String',[save_pathname,save_filename]);
    guidata(gcbo,handles);
end


% --- Executes on button press in operate_pushbutton.
function operate_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to operate_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Clear error message
set(handles.message_info_text,'String','');
guidata(gcbo,handles);
drawnow;

if isfield(handles,'w_in')
    win=handles.w_in;
    ndims=dimensions(win);
else
    mess='No valid object selected -- no cut taken';
    set(handles.message_info_text,'String',mess);
    guidata(gcbo,handles);
    return;
end

if ~isfield(handles,'funcstr')
    mess='No function selected -- operation not performed';
    set(handles.message_info_text,'String',mess);
    guidata(gcbo,handles);
    return;
end
funcstr=handles.funcstr;

outobjname=get(handles.outobj_edit,'String');
outfilename=get(handles.outfile_edit,'String');
out_to_file=get(handles.outfile_radiobutton,'Value');
obj_to_cut='win';

%====
if isempty(outobjname)
    mess='Provide a name for the output object that will be created by unary operation';
    set(handles.message_info_text,'String',mess);
    guidata(gcbo,handles);
    return;
end
%====
if out_to_file==get(handles.outfile_radiobutton,'Max')
    saveafile=true;
else
    saveafile=false;
end
%===
if saveafile && isempty(outfilename)
    outfilename='-save';
end
%NB - there is not actually a save option as part of unary operation, but
%we can do it anyway using the save command


%Now do the operation:
try
    if ~saveafile
        out=eval([funcstr,'(',obj_to_cut,');']);
    elseif saveafile && strcmp(outfilename,'-save')
        out=eval([funcstr,'(',obj_to_cut,');']);
        save(out);
    else
        out=eval([funcstr,'(',obj_to_cut,');']);
        save(out,outfilename);
    end
catch
    the_err=lasterror;
    emess=the_err.message;
    nchar=strfind(emess,['at ',num2str(the_err.stack(1).line)]);
    mess1='No operation performed';
    mess2=emess(nchar+9:end);
    set(handles.message_info_text,'String',{mess1,mess2});
    guidata(gcbo,handles);
    return;
end
    
assignin('base',outobjname,out);
set(handles.message_info_text,'String','Success!');
guidata(gcbo,handles);