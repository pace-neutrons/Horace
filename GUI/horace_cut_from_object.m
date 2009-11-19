function varargout = horace_cut_from_object(varargin)
% HORACE_CUT_FROM_OBJECT M-file for horace_cut_from_object.fig
%      HORACE_CUT_FROM_OBJECT, by itself, creates a new HORACE_CUT_FROM_OBJECT or raises the existing
%      singleton*.
%
%      H = HORACE_CUT_FROM_OBJECT returns the handle to a new HORACE_CUT_FROM_OBJECT or the handle to
%      the existing singleton*.
%
%      HORACE_CUT_FROM_OBJECT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in HORACE_CUT_FROM_OBJECT.M with the given input arguments.
%
%      HORACE_CUT_FROM_OBJECT('Property','Value',...) creates a new HORACE_CUT_FROM_OBJECT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before horace_cut_from_object_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to horace_cut_from_object_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help horace_cut_from_object

% Last Modified by GUIDE v2.5 12-Nov-2009 16:18:57

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @horace_cut_from_object_OpeningFcn, ...
                   'gui_OutputFcn',  @horace_cut_from_object_OutputFcn, ...
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


% --- Executes just before horace_cut_from_object is made visible.
function horace_cut_from_object_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to horace_cut_from_object (see VARARGIN)

% Choose default command line output for horace_cut_from_object
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes horace_cut_from_object wait for user response (see UIRESUME)
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
        set(handles.select_object_popupmenu,'String','No objects to select');
        guidata(gcbo, handles);
        return%if no objects that can be plotted or cut are in the workspace
        %we must exit this function
    end
    
    %It is at this point we circshift the cell array of variables so that
    %the object we want is on top:
    cellofvars=circshift(cellofvars',(1-nsteps));
    cellofvars=cellofvars';
    
    drawnow;
    set(handles.select_object_popupmenu,'String',cellofvars);
    guidata(gcbo, handles);

    str = get(handles.select_object_popupmenu, 'String');
    val = get(handles.select_object_popupmenu,'Value');
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
    %
    
    evalin('base','clear horace_gui_nstep_switch');%gets rid of the evidence!
end



% --- Outputs from this function are returned to the command line.
function varargout = horace_cut_from_object_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function objectname_edit_Callback(hObject, eventdata, handles)
% hObject    handle to objectname_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of objectname_edit as text
%        str2double(get(hObject,'String')) returns contents of objectname_edit as a double


% --- Executes during object creation, after setting all properties.
function objectname_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to objectname_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ax1_edit_Callback(hObject, eventdata, handles)
% hObject    handle to ax1_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ax1_edit as text
%        str2double(get(hObject,'String')) returns contents of ax1_edit as a double


% --- Executes during object creation, after setting all properties.
function ax1_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ax1_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ax2_edit_Callback(hObject, eventdata, handles)
% hObject    handle to ax2_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ax2_edit as text
%        str2double(get(hObject,'String')) returns contents of ax2_edit as a double


% --- Executes during object creation, after setting all properties.
function ax2_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ax2_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ax3_edit_Callback(hObject, eventdata, handles)
% hObject    handle to ax3_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ax3_edit as text
%        str2double(get(hObject,'String')) returns contents of ax3_edit as a double


% --- Executes during object creation, after setting all properties.
function ax3_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ax3_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ax4_edit_Callback(hObject, eventdata, handles)
% hObject    handle to ax4_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ax4_edit as text
%        str2double(get(hObject,'String')) returns contents of ax4_edit as a double


% --- Executes during object creation, after setting all properties.
function ax4_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ax4_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
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


% --- Executes on button press in do_cut_pushbutton.
function do_cut_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to do_cut_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Clear error message
set(handles.message_info_text,'String','');
guidata(gcbo,handles);
drawnow;

%This is the main business of this mini GUI. Note that we have a lot more
%cases to deal with than when cutting from file, because the cut command
%has to be called with the appropriate number of inputs for the
%dimensionality of object.
if isfield(handles,'w_in')
    win=handles.w_in;
    ndims=dimensions(win);
else
    mess='No valid object selected -- no cut taken';
    set(handles.message_info_text,'String',mess);
    guidata(gcbo,handles);
    return;
end

extra_flag=false;

%First get the info contained in the GUI's fields.
a1=get(handles.ax1_edit,'String');
a2=get(handles.ax2_edit,'String');
a3=get(handles.ax3_edit,'String');
a4=get(handles.ax4_edit,'String');
outobjname=get(handles.outobj_edit,'String');
outfilename=get(handles.outfile_edit,'String');
keep_pixels=get(handles.keep_pix_radiobutton,'Value');
out_to_file=get(handles.outfile_radiobutton,'Value');
obj_to_cut='win';

%Check all is in correct format:
if isempty(a1)
    mess1='   Ensure binning values are entered if the form of lo,step,hi / step / lo,hi    ';
    mess2='NB: enter 0 if you wish to use intrinsic binning and entire data range along axis';
    set(handles.message_info_text,'String',[mess1; mess2]);
    guidata(gcbo,handles);
    return;
elseif isempty(a2) && ndims>=1.9
    mess1='   Ensure binning values are entered if the form of lo,step,hi / step / lo,hi    ';
    mess2='NB: enter 0 if you wish to use intrinsic binning and entire data range along axis';
    set(handles.message_info_text,'String',[mess1; mess2]);
    guidata(gcbo,handles);
    return;
elseif isempty(a3) && ndims>=2.9
    mess1='   Ensure binning values are entered if the form of lo,step,hi / step / lo,hi    ';
    mess2='NB: enter 0 if you wish to use intrinsic binning and entire data range along axis';
    set(handles.message_info_text,'String',[mess1; mess2]);
    guidata(gcbo,handles);
    return;  
elseif isempty(a4) && ndims>=3.9
    mess1='   Ensure binning values are entered if the form of lo,step,hi / step / lo,hi    ';
    mess2='NB: enter 0 if you wish to use intrinsic binning and entire data range along axis';
    set(handles.message_info_text,'String',[mess1; mess2]);
    guidata(gcbo,handles);
    return;  
else
    %must strip out square brackets, if user has inserted them:
    s1=strfind(a1,'['); s2=strfind(a1,']');
    if isempty(s1) && isempty(s2)
        a1new=strread(a1,'%f','delimiter',',');
    elseif ~isempty(s1) && ~isempty(s2)
        a1=a1(s1+1:s2-1);
        a1new=strread(a1,'%f','delimiter',',');
    else
        mess1='   Ensure binning values are entered if the form of lo,step,hi / step / lo,hi    ';
        mess2='NB: enter 0 if you wish to use intrinsic binning and entire data range along axis';
        set(handles.message_info_text,'String',[mess1; mess2]);
        guidata(gcbo,handles);
        return;
    end
    s1=strfind(a2,'['); s2=strfind(a2,']');
    if isempty(s1) && isempty(s2)
        a2new=strread(a2,'%f','delimiter',',');
    elseif ~isempty(s1) && ~isempty(s2)
        a2=a2(s1+1:s2-1);
        a2new=strread(a2,'%f','delimiter',',');
    else
        mess1='   Ensure binning values are entered if the form of lo,step,hi / step / lo,hi    ';
        mess2='NB: enter 0 if you wish to use intrinsic binning and entire data range along axis';
        set(handles.message_info_text,'String',[mess1; mess2]);
        guidata(gcbo,handles);
        return;
    end
    s1=strfind(a3,'['); s2=strfind(a3,']');
    if isempty(s1) && isempty(s2)
        a3new=strread(a3,'%f','delimiter',',');
    elseif ~isempty(s1) && ~isempty(s2)
        a3=a3(s1+1:s2-1);
        a3new=strread(a3,'%f','delimiter',',');
    else
        mess1='   Ensure binning values are entered if the form of lo,step,hi / step / lo,hi    ';
        mess2='NB: enter 0 if you wish to use intrinsic binning and entire data range along axis';
        set(handles.message_info_text,'String',[mess1; mess2]);
        guidata(gcbo,handles);
        return;
    end
    s1=strfind(a4,'['); s2=strfind(a4,']');
    if isempty(s1) && isempty(s2)
        a4new=strread(a4,'%f','delimiter',',');
    elseif ~isempty(s1) && ~isempty(s2)
        a4=a4(s1+1:s2-1);
        a4new=strread(a4,'%f','delimiter',',');
    else
        mess1='   Ensure binning values are entered if the form of lo,step,hi / step / lo,hi    ';
        mess2='NB: enter 0 if you wish to use intrinsic binning and entire data range along axis';
        set(handles.message_info_text,'String',[mess1; mess2]);
        guidata(gcbo,handles);
        return;
    end
end
%
if a1new==0; a1new=[]; a1=''; end; %intrinsic binning case
if a2new==0; a2new=[]; a2=''; end;
if a3new==0; a3new=[]; a3=''; end;
if a4new==0; a4new=[]; a4=''; end;
a1new=a1new'; a2new=a2new'; a3new=a3new'; a4new=a4new';
if numel(a1new)>3 || numel(a2new)>3 || numel(a3new)>3 || numel(a4new)>3
    mess1='   Ensure binning values are entered if the form of lo,step,hi / step / lo,hi    ';
    mess2='NB: enter 0 if you wish to use intrinsic binning and entire data range along axis';
    set(handles.message_info_text,'String',[mess1; mess2]);
    guidata(gcbo,handles);
    return;
end

%Also need to deal with the case where we specify a scalar as one of the
%binning arguments (i.e. just a step size) but the object is dnd, since
%otherwise we get an error message from the cut routine.
if ~is_sqw_type(sqw(win))
    if (numel(a1new)==1 && a1new~=0) || (numel(a2new)==1 && a2new~=0) || ...
            (numel(a3new)==1 && a3new~=0) || (numel(a4new)==1 && a4new~=0)
        mess1='Object is dnd -- cannot use scalar input to rebin along an axis.';
        mess2=' Must specify binning as [lo,hi] (integration), [lo,0,hi], or 0 ';
        set(handles.message_info_text,'String',[mess1; mess2]);
        guidata(gcbo,handles);
        return;
    elseif (numel(a1new)==3 && a1new(2)~=0) || (numel(a2new)==3 && a2new(2)~=0) || ...
            (numel(a3new)==3 && a3new(2)~=0) || (numel(a4new)==3 && a4new(2)~=0)
        mess1='Object is dnd -- cannot use non-zero step size to rebin along an axis.';
        mess2='    Must specify binning as [lo,hi] (integration), [lo,0,hi], or 0    ';
        set(handles.message_info_text,'String',[mess1; mess2]);
        guidata(gcbo,handles);
        return;
    end
end



%====
if keep_pixels==get(handles.keep_pix_radiobutton,'Max')
    keeppix=true;
else
    keeppix=false;
end
%====
if isempty(outobjname)
    mess='Provide a name for the output object that will be created by cut';
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

%=============
%We now have to deal explicitly with the cases for the 4 possible
%dimensionalities of cut, plus whether keeping pixels is valid or not. The
%latter is not so difficult to deal with.
if keeppix && ~is_sqw_type(sqw(win))
    mess='Selected object has no pixel info -- proceeding with cut, but no pixel info retained';
    set(handles.message_info_text,'String',mess);
    guidata(gcbo,handles);
    keeppix=true;%bizarrely, this is what we need to do (so there is no '-nopix' argument)
    extra_flag=true;
elseif ~is_sqw_type(sqw(win))
    keeppix=true;
end

%=============

%Now make the cut:
try
    switch ndims
        case 4
            if ~keeppix && ~saveafile
                out=eval(['cut(',obj_to_cut,',[',a1,'],[',...
                    a2,'],[',a3,'],[',a4,'],''-nopix'');']);
            elseif keeppix && ~saveafile
                out=eval(['cut(',obj_to_cut,',[',a1,'],[',...
                    a2,'],[',a3,'],[',a4,']);']);
            elseif ~keeppix && saveafile
                out=eval(['cut(',obj_to_cut,',[',a1,'],[',...
                    a2,'],[',a3,'],[',a4,'],''-nopix'',''',outfilename,''');']);
            elseif keeppix && saveafile
                out=eval(['cut(',obj_to_cut,',[',a1,'],[',...
                    a2,'],[',a3,'],[',a4,'],''',outfilename,''');']);
            end
        case 3
            if ~keeppix && ~saveafile
                out=eval(['cut(',obj_to_cut,',[',a1,'],[',...
                    a2,'],[',a3,'],''-nopix'');']);
            elseif keeppix && ~saveafile
                out=eval(['cut(',obj_to_cut,',[',a1,'],[',...
                    a2,'],[',a3,']);']);
            elseif ~keeppix && saveafile
                out=eval(['cut(',obj_to_cut,',[',a1,'],[',...
                    a2,'],[',a3,'],''-nopix'',''',outfilename,''');']);
            elseif keeppix && saveafile
                out=eval(['cut(',obj_to_cut,',[',a1,'],[',...
                    a2,'],[',a3,'],''',outfilename,''');']);
            end
        case 2
            if ~keeppix && ~saveafile
                out=eval(['cut(',obj_to_cut,',[',a1,'],[',...
                    a2,'],''-nopix'');']);
            elseif keeppix && ~saveafile
                out=eval(['cut(',obj_to_cut,',[',a1,'],[',...
                    a2,']);']);
            elseif ~keeppix && saveafile
                out=eval(['cut(',obj_to_cut,',[',a1,'],[',...
                    a2,'],''-nopix'',''',outfilename,''');']);
            elseif keeppix && saveafile
                out=eval(['cut(',obj_to_cut,',[',a1,'],[',...
                    a2,'],''',outfilename,''');']);
            end
        case 1
            if ~keeppix && ~saveafile
                out=eval(['cut(',obj_to_cut,',[',a1,'],''-nopix'');']);
            elseif keeppix && ~saveafile
                out=eval(['cut(',obj_to_cut,',[',a1,']);']);
            elseif ~keeppix && saveafile
                out=eval(['cut(',obj_to_cut,',[',a1,'],''-nopix'',''',outfilename,''');']);
            elseif keeppix && saveafile
                out=eval(['cut(',obj_to_cut,',[',a1,'],''',outfilename,''');']);
            end
        case 0
            mess='Selected object is zero dimensional -- cut not possible';
            set(handles.message_info_text,'String',mess);
            guidata(gcbo,handles);
            return;
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
if extra_flag==false
    set(handles.message_info_text,'String','Success!');
    guidata(gcbo,handles);
else
    mess='Selected object has no pixel info -- proceeding with cut, but no pixel info retained';
    set(handles.message_info_text,'String',mess);
    guidata(gcbo,handles);
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


% --- Executes on button press in keep_pix_radiobutton.
function keep_pix_radiobutton_Callback(hObject, eventdata, handles)
% hObject    handle to keep_pix_radiobutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of keep_pix_radiobutton


% --- Executes on selection change in select_object_popupmenu.
function select_object_popupmenu_Callback(hObject, eventdata, handles)
% hObject    handle to select_object_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns select_object_popupmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from select_object_popupmenu

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
    set(handles.select_object_popupmenu,'String','No objects to select');
    guidata(gcbo, handles);
    return%if no objects that can be plotted or cut are in the workspace
    %we must exit this function
end

drawnow;
set(handles.select_object_popupmenu,'String',cellofvars);
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
function select_object_popupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to select_object_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


