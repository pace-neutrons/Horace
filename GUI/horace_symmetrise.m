function varargout = horace_symmetrise(varargin)
% HORACE_SYMMETRISE M-file for horace_symmetrise.fig
%      HORACE_SYMMETRISE, by itself, creates a new HORACE_SYMMETRISE or raises the existing
%      singleton*.
%
%      H = HORACE_SYMMETRISE returns the handle to a new HORACE_SYMMETRISE or the handle to
%      the existing singleton*.
%
%      HORACE_SYMMETRISE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in HORACE_SYMMETRISE.M with the given input arguments.
%
%      HORACE_SYMMETRISE('Property','Value',...) creates a new HORACE_SYMMETRISE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before horace_symmetrise_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to horace_symmetrise_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help horace_symmetrise

% Last Modified by GUIDE v2.5 22-Jan-2010 16:50:13

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @horace_symmetrise_OpeningFcn, ...
                   'gui_OutputFcn',  @horace_symmetrise_OutputFcn, ...
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


% --- Executes just before horace_symmetrise is made visible.
function horace_symmetrise_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to horace_symmetrise (see VARARGIN)

% Choose default command line output for horace_symmetrise
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes horace_symmetrise wait for user response (see UIRESUME)
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
        set(handles.obj_popupmenu,'String','No objects to select');
        guidata(gcbo, handles);
        return%if no objects that can be plotted or cut are in the workspace
        %we must exit this function
    end
    
    %It is at this point we circshift the cell array of variables so that
    %the object we want is on top:
%     cellofvars=circshift(cellofvars',(1-nsteps));
%     cellofvars=cellofvars';
    sz=size(cellofvars);
    newcell=cell(sz(1),sz(2)+1);
    newcell(2:end)=cellofvars;
    newcell{1}=cellofvars{nsteps};
    
    drawnow;
    set(handles.obj_popupmenu,'String',newcell);
    guidata(gcbo, handles);

    str = get(handles.obj_popupmenu, 'String');
    %val = get(handles.select_obj_popupmenu,'Value');
    val=nsteps;
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
else
    %Clear error message
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
        mess1=' No dnd or sqw objects in current workspace  ';
        mess2='---------------------------------------------';
        mess3='Load objects into Matlab workspace to proceed';
        set(handles.message_info_text,'String',[mess1; mess2; mess3]);
        guidata(hObject,handles);
        set(handles.obj_popupmenu,'String','No objects to select');
        guidata(gcbo, handles);
        return%if no objects that can be plotted or cut are in the workspace
        %we must exit this function
    end
    
    drawnow;
    set(handles.obj_popupmenu,'String',cellofvars);
    guidata(hObject, handles);

    str = get(handles.obj_popupmenu, 'String');
    val = get(handles.obj_popupmenu,'Value');
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
end




% --- Outputs from this function are returned to the command line.
function varargout = horace_symmetrise_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in obj_popupmenu.
function obj_popupmenu_Callback(hObject, eventdata, handles)
% hObject    handle to obj_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns obj_popupmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from obj_popupmenu

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
    set(handles.obj_popupmenu,'String','No objects to select');
    guidata(gcbo, handles);
    return%if no objects that can be plotted or cut are in the workspace
    %we must exit this function
end

drawnow;
set(handles.obj_popupmenu,'String',cellofvars);
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
function obj_popupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to obj_popupmenu (see GCBO)
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


% --- Executes on button press in symmetrise_pushbutton.
function symmetrise_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to symmetrise_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Clear error message
set(handles.message_info_text,'String','');
guidata(gcbo,handles);
drawnow;

outobjname=get(handles.outobj_edit,'String');
outfilename=get(handles.outfile_edit,'String');
out_to_file=get(handles.outfile_radiobutton,'Value');
obj_to_cut='win';

if isfield(handles,'w_in')
    win=handles.w_in;
    if numel(win)~=1
        mess='Object selected is an array of objects. Symmetrisation not yet implemented for arrays -- symmetrisation not performed';
        set(handles.message_info_text,'String',mess);
        guidata(gcbo,handles);
        return;
    end
    ndims=dimensions(win);
else
    mess='No valid object selected -- symmetrisation not performed';
    set(handles.message_info_text,'String',mess);
    guidata(gcbo,handles);
    return;
end

%===
midspec=get(handles.midpoint_radiobutton,'Value');
midmax=get(handles.midpoint_radiobutton,'Max');
planespec=get(handles.plane_radiobutton,'Value');
planemax=get(handles.plane_radiobutton,'Max');

ismid=false;
if midspec==midmax
    midpoint=get(handles.midpoint_edit,'String');
    %tol=str2mat(tol);
    %must strip out square brackets, if user has inserted them:
    s1=strfind(midpoint,'['); s2=strfind(midpoint,']');
    if isempty(s1) && isempty(s2)
        midpointnew=strread(midpoint,'%f','delimiter',',');
    elseif ~isempty(s1) && ~isempty(s2)
        midpoint=midpoint(s1+1:s2-1);
        midpointnew=strread(midpoint,'%f','delimiter',',');
    else
        mess1='Ensure midpoint is of form [val] for 1d, or [val_x,val_y] for 2d';
        set(handles.message_info_text,'String',mess1);
        guidata(gcbo,handles);
        return;
    end
    %
    if ~all(isnan(midpointnew)) && numel(midpointnew)==ndims
        ismid=true;
        midpointnew=reshape(midpointnew,1,numel(midpointnew));
    elseif numel(midpointnew)~=ndims
        mess1='Ensure midpoint is of form [val] for 1d, or [val_x,val_y] for 2d';
        set(handles.message_info_text,'String',mess1);
        guidata(gcbo,handles);
        return;
    end
else
    %we have a reflection plane specified.
    %==
    v1=get(handles.v1_edit,'String');
    %tol=str2mat(tol);
    %must strip out square brackets, if user has inserted them:
    s1=strfind(v1,'['); s2=strfind(v1,']');
    if isempty(s1) && isempty(s2)
        v1new=strread(v1,'%f','delimiter',',');
    elseif ~isempty(s1) && ~isempty(s2)
        v1=v1(s1+1:s2-1);
        v1new=strread(v1,'%f','delimiter',',');
    else
        mess1='Ensure v1 is of form [a,b,c]';
        set(handles.message_info_text,'String',mess1);
        guidata(gcbo,handles);
        return;
    end
    if numel(v1new)~=3
        mess1='Ensure v1 is of form [a,b,c]';
        set(handles.message_info_text,'String',mess1);
        guidata(gcbo,handles);
        return;
    end
    %==
    v2=get(handles.v2_edit,'String');
    %tol=str2mat(tol);
    %must strip out square brackets, if user has inserted them:
    s1=strfind(v2,'['); s2=strfind(v2,']');
    if isempty(s1) && isempty(s2)
        v2new=strread(v2,'%f','delimiter',',');
    elseif ~isempty(s1) && ~isempty(s2)
        v2=v2(s1+1:s2-1);
        v2new=strread(v2,'%f','delimiter',',');
    else
        mess1='Ensure v2 is of form [a,b,c]';
        set(handles.message_info_text,'String',mess1);
        guidata(gcbo,handles);
        return;
    end
    if numel(v2new)~=3
        mess1='Ensure v2 is of form [a,b,c]';
        set(handles.message_info_text,'String',mess1);
        guidata(gcbo,handles);
        return;
    end
    %==
    %Case for v3 is slightly different
    v3=get(handles.v3_edit,'String');
    
    if ~isempty(v3)
        %must strip out square brackets, if user has inserted them:
        s1=strfind(v3,'['); s2=strfind(v3,']');
        if isempty(s1) && isempty(s2)
            v1new=strread(v3,'%f','delimiter',',');
        elseif ~isempty(s1) && ~isempty(s2)
            v3=v3(s1+1:s2-1);
            v3new=strread(v3,'%f','delimiter',',');
        else
            mess1='Ensure v3 is of form [a,b,c]';
            set(handles.message_info_text,'String',mess1);
            guidata(gcbo,handles);
            return;
        end
        if numel(v3new)~=3
            mess1='Ensure v3 is of form [a,b,c]';
            set(handles.message_info_text,'String',mess1);
            guidata(gcbo,handles);
            return;
        end
    else
        v3new=[0,0,0];%default is that the plane goes through the origin.
    end
    v1new=reshape(v1new,1,3);
    v2new=reshape(v2new,1,3);
    v3new=reshape(v3new,1,3);
    %==
end
%====

%Work out which of the symmetrise functions is required:
if is_sqw_type(sqw(win))
    funcstr='symmetrise_sqw';
elseif ndims==1
    funcstr='symmetrise_horace_1d';
elseif ndims==2
    funcstr='symmetrise_horace_2d';
else
    mess='Selected object must either be sqw-type, or be dnd of dimensionality less than 3';
    set(handles.message_info_text,'String',mess);
    guidata(gcbo,handles);
    return;
end

%====
%Recall we cannot use the midpoint arg in for sqw-type data:
if is_sqw_type(sqw(win)) && ismid
    mess='For sqw objects you can only use a specified plane to symmetrise, not a midpoint';
    set(handles.message_info_text,'String',mess);
    guidata(gcbo,handles);
    return;
end

%======
%====
if isempty(outobjname)
    mess='Provide a name for the output object that will be created by symmetrise operation';
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
%====

%==========================
%Now we do the varoius different kinds of function evaluation:
try
    if ~saveafile
        if ~ismid
            out=eval([funcstr,'(',obj_to_cut,',[',num2str(v1new),'],[',num2str(v2new),'],[',...
                num2str(v3new),']);']);
        else
            out=eval([funcstr,'(',obj_to_cut,',[',num2str(midpointnew),']);']);
        end
    elseif saveafile && strcmp(outfilename,'-save')
        if ~ismid
            out=eval([funcstr,'(',obj_to_cut,',[',num2str(v1new),'],[',num2str(v2new),'],[',...
                num2str(v3new),']);']);
        else
            out=eval([funcstr,'(',obj_to_cut,',[',num2str(midpointnew),']);']);
        end
        save(out);
    else
        if ~ismid
            out=eval([funcstr,'(',obj_to_cut,',[',num2str(v1new),'],[',num2str(v2new),'],[',...
                num2str(v3new),']);']);
        else
            out=eval([funcstr,'(',obj_to_cut,',[',num2str(midpointnew),']);']);
        end
        save(out,outfilename);
    end
    
catch
    the_err=lasterror;
    emess=the_err.message;
    nchar=strfind(emess,['at ',num2str(the_err.stack(1).line)]);
    mess1='No symmetrise performed';
    mess2=emess(nchar+9:end);
    set(handles.message_info_text,'String',{mess1,mess2});
    guidata(gcbo,handles);
    return;
end
    
    
assignin('base',outobjname,out);
set(handles.message_info_text,'String','Success!');
guidata(gcbo,handles);





function v1_edit_Callback(hObject, eventdata, handles)
% hObject    handle to v1_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of v1_edit as text
%        str2double(get(hObject,'String')) returns contents of v1_edit as a double


% --- Executes during object creation, after setting all properties.
function v1_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to v1_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in plane_radiobutton.
function plane_radiobutton_Callback(hObject, eventdata, handles)
% hObject    handle to plane_radiobutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of plane_radiobutton

button_state=get(hObject,'Value');
if button_state==get(hObject,'Max');%button is pressed
    set(handles.midpoint_radiobutton,'Value',0);
end
guidata(gcbo, handles);


function midpoint_edit_Callback(hObject, eventdata, handles)
% hObject    handle to midpoint_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of midpoint_edit as text
%        str2double(get(hObject,'String')) returns contents of midpoint_edit as a double


% --- Executes during object creation, after setting all properties.
function midpoint_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to midpoint_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in midpoint_radiobutton.
function midpoint_radiobutton_Callback(hObject, eventdata, handles)
% hObject    handle to midpoint_radiobutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of midpoint_radiobutton

button_state=get(hObject,'Value');
if button_state==get(hObject,'Max');%button is pressed
    set(handles.plane_radiobutton,'Value',0);
end
guidata(gcbo, handles);



function v2_edit_Callback(hObject, eventdata, handles)
% hObject    handle to v2_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of v2_edit as text
%        str2double(get(hObject,'String')) returns contents of v2_edit as a double


% --- Executes during object creation, after setting all properties.
function v2_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to v2_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function v3_edit_Callback(hObject, eventdata, handles)
% hObject    handle to v3_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of v3_edit as text
%        str2double(get(hObject,'String')) returns contents of v3_edit as a double


% --- Executes during object creation, after setting all properties.
function v3_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to v3_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


