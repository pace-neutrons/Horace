function varargout = horace_cut_from_file(varargin)
% HORACE_CUT_FROM_FILE M-file for horace_cut_from_file.fig
%      HORACE_CUT_FROM_FILE, by itself, creates a new HORACE_CUT_FROM_FILE or raises the existing
%      singleton*.
%
%      H = HORACE_CUT_FROM_FILE returns the handle to a new HORACE_CUT_FROM_FILE or the handle to
%      the existing singleton*.
%
%      HORACE_CUT_FROM_FILE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in HORACE_CUT_FROM_FILE.M with the given input arguments.
%
%      HORACE_CUT_FROM_FILE('Property','Value',...) creates a new HORACE_CUT_FROM_FILE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before horace_cut_from_file_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to horace_cut_from_file_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help horace_cut_from_file

% Last Modified by GUIDE v2.5 11-Nov-2009 11:23:08

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @horace_cut_from_file_OpeningFcn, ...
                   'gui_OutputFcn',  @horace_cut_from_file_OutputFcn, ...
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

% --- Executes just before horace_cut_from_file is made visible.
function horace_cut_from_file_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to horace_cut_from_file (see VARARGIN)

% Choose default command line output for horace_cut_from_file
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes horace_cut_from_file wait for user response (see UIRESUME)
% uiwait(handles.figure1);


nofile=false;
try
    flname=evalin('base','sqw_filename_internal');
catch
    nofile=true;
end

if ~nofile
    set(handles.sqw_filename_edit,'String',flname);
    guidata(hObject,handles);
    evalin('base','clear sqw_filename_internal');%gets rid of the evidence!
end



% --- Outputs from this function are returned to the command line.
function varargout = horace_cut_from_file_OutputFcn(hObject, eventdata, handles) 
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


% --- Executes on button press in sqw_in_browse_pushbutton.
function sqw_in_browse_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to sqw_in_browse_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[sqw_filename,sqw_pathname,FilterIndex] = uigetfile({'*.sqw'},'Select SQW file');

if ischar(sqw_pathname) && ischar(sqw_filename)
    %i.e. the cancel button was not pressed
    set(handles.sqw_filename_edit,'string',[sqw_pathname,sqw_filename]);
    guidata(gcbo,handles);
end



% --- Executes on button press in rlu_1_radiobutton.
function rlu_1_radiobutton_Callback(hObject, eventdata, handles)
% hObject    handle to rlu_1_radiobutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of rlu_1_radiobutton

button_state=get(hObject,'Value');
if button_state==get(hObject,'Max');%button is pressed
    set(handles.ang_1_radiobutton,'Value',0);
end
guidata(gcbo, handles);


% --- Executes on button press in ang_1_radiobutton.
function ang_1_radiobutton_Callback(hObject, eventdata, handles)
% hObject    handle to ang_1_radiobutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ang_1_radiobutton

button_state=get(hObject,'Value');
if button_state==get(hObject,'Max');%button is pressed
    set(handles.rlu_1_radiobutton,'Value',0);
end
guidata(gcbo, handles);

% --- Executes on button press in rlu_2_radiobutton.
function rlu_2_radiobutton_Callback(hObject, eventdata, handles)
% hObject    handle to rlu_2_radiobutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of rlu_2_radiobutton

button_state=get(hObject,'Value');
if button_state==get(hObject,'Max');%button is pressed
    set(handles.ang_2_radiobutton,'Value',0);
end
guidata(gcbo, handles);

% --- Executes on button press in ang_2_radiobutton.
function ang_2_radiobutton_Callback(hObject, eventdata, handles)
% hObject    handle to ang_2_radiobutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ang_2_radiobutton

button_state=get(hObject,'Value');
if button_state==get(hObject,'Max');%button is pressed
    set(handles.rlu_2_radiobutton,'Value',0);
end
guidata(gcbo, handles);

% --- Executes on button press in rlu_3_radiobutton.
function rlu_3_radiobutton_Callback(hObject, eventdata, handles)
% hObject    handle to rlu_3_radiobutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of rlu_3_radiobutton

button_state=get(hObject,'Value');
if button_state==get(hObject,'Max');%button is pressed
    set(handles.ang_3_radiobutton,'Value',0);
end
guidata(gcbo, handles);

% --- Executes on button press in ang_3_radiobutton.
function ang_3_radiobutton_Callback(hObject, eventdata, handles)
% hObject    handle to ang_3_radiobutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ang_3_radiobutton

button_state=get(hObject,'Value');
if button_state==get(hObject,'Max');%button is pressed
    set(handles.rlu_3_radiobutton,'Value',0);
end
guidata(gcbo, handles);


function u_edit_Callback(hObject, eventdata, handles)
% hObject    handle to u_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of u_edit as text
%        str2double(get(hObject,'String')) returns contents of u_edit as a double


% --- Executes during object creation, after setting all properties.
function u_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to u_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function v_edit_Callback(hObject, eventdata, handles)
% hObject    handle to v_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of v_edit as text
%        str2double(get(hObject,'String')) returns contents of v_edit as a double


% --- Executes during object creation, after setting all properties.
function v_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to v_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function w_edit_Callback(hObject, eventdata, handles)
% hObject    handle to w_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of w_edit as text
%        str2double(get(hObject,'String')) returns contents of w_edit as a double


% --- Executes during object creation, after setting all properties.
function w_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to w_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ax1_range_edit_Callback(hObject, eventdata, handles)
% hObject    handle to ax1_range_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ax1_range_edit as text
%        str2double(get(hObject,'String')) returns contents of ax1_range_edit as a double


% --- Executes during object creation, after setting all properties.
function ax1_range_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ax1_range_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ax2_range_edit_Callback(hObject, eventdata, handles)
% hObject    handle to ax2_range_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ax2_range_edit as text
%        str2double(get(hObject,'String')) returns contents of ax2_range_edit as a double


% --- Executes during object creation, after setting all properties.
function ax2_range_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ax2_range_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ax3_range_edit_Callback(hObject, eventdata, handles)
% hObject    handle to ax3_range_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ax3_range_edit as text
%        str2double(get(hObject,'String')) returns contents of ax3_range_edit as a double


% --- Executes during object creation, after setting all properties.
function ax3_range_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ax3_range_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ax4_range_edit_Callback(hObject, eventdata, handles)
% hObject    handle to ax4_range_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ax4_range_edit as text
%        str2double(get(hObject,'String')) returns contents of ax4_range_edit as a double


% --- Executes during object creation, after setting all properties.
function ax4_range_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ax4_range_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function out_obj_edit_Callback(hObject, eventdata, handles)
% hObject    handle to out_obj_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of out_obj_edit as text
%        str2double(get(hObject,'String')) returns contents of out_obj_edit as a double


% --- Executes during object creation, after setting all properties.
function out_obj_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to out_obj_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in out_file_radio.
function out_file_radio_Callback(hObject, eventdata, handles)
% hObject    handle to out_file_radio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of out_file_radio



function out_file_edit_Callback(hObject, eventdata, handles)
% hObject    handle to out_file_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of out_file_edit as text
%        str2double(get(hObject,'String')) returns contents of out_file_edit as a double


% --- Executes during object creation, after setting all properties.
function out_file_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to out_file_edit (see GCBO)
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

%Clear any old variable from a previous call:
clear proj
%
%This is the most complicated bit of this GUI.
%First get that all the necessary arguments and check they have values:
filestring=get(handles.sqw_filename_edit,'String');
u=get(handles.u_edit,'String');
v=get(handles.v_edit,'String');
w=get(handles.w_edit,'String');
u_rlu=get(handles.rlu_1_radiobutton,'Value');
v_rlu=get(handles.rlu_2_radiobutton,'Value');
w_rlu=get(handles.rlu_3_radiobutton,'Value');
a1=get(handles.ax1_range_edit,'String');
a2=get(handles.ax2_range_edit,'String');
a3=get(handles.ax3_range_edit,'String');
a4=get(handles.ax4_range_edit,'String');
outobjname=get(handles.out_obj_edit,'String');
outfilename=get(handles.out_file_edit,'String');
keep_pixels=get(handles.keep_pix_radiobutton,'Value');
out_to_file=get(handles.out_file_radio,'Value');

if isempty(filestring)
    mess='Specify an sqw file from which to make a cut';
    set(handles.message_info_text,'String',mess);
    guidata(gcbo,handles);
    return;
end
%==
if isempty(u) || isempty(v)
    mess='Projection axes u and v must be specified for cut';
    set(handles.message_info_text,'String',mess);
    guidata(gcbo,handles);
    return;
else
    u=strread(u,'%f','delimiter',',');
    v=strread(v,'%f','delimiter',',');
    if numel(u)~=3 || numel(v)~=3
        mess='u and v must comprise 3 numbers specifying h, k, and l of projection axes';
        set(handles.message_info_text,'String',mess);
        guidata(gcbo,handles);
        return;
    end
    if ~isempty(w)
        w=strread(w,'%f','delimiter',',');
    end
end
%==
angstring='';
if u_rlu==get(handles.rlu_1_radiobutton,'Max')
    angstring=[angstring,'r'];
else
    angstring=[angstring,'a'];
end
if v_rlu==get(handles.rlu_2_radiobutton,'Max')
    angstring=[angstring,'r'];
else
    angstring=[angstring,'a'];
end
if w_rlu==get(handles.rlu_3_radiobutton,'Max')
    angstring=[angstring,'r'];
else
    angstring=[angstring,'a'];
end
%
proj.u=u'; proj.v=v';
if ~isempty(w)
    proj.w=w';
end
proj.type=angstring;
%===
if isempty(a1) || isempty(a2) || isempty(a3) || isempty(a4)
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
if out_to_file==get(handles.out_file_radio,'Max')
    saveafile=true;
else
    saveafile=false;
end
%===
if saveafile && isempty(outfilename)
    outfilename='-save';
end

%Now make the cut:
try
    if ~keeppix && ~saveafile
        out=eval(['cut_sqw(''',filestring,''',proj',',[',a1,'],[',...
            a2,'],[',a3,'],[',a4,'],''-nopix'');']);
    elseif keeppix && ~saveafile
        out=eval(['cut_sqw(''',filestring,''',proj',',[',a1,'],[',...
            a2,'],[',a3,'],[',a4,']);']);
    elseif ~keeppix && saveafile
        out=eval(['cut_sqw(''',filestring,''',proj',',[',a1,'],[',...
            a2,'],[',a3,'],[',a4,'],''-nopix'',''',outfilename,''');']);
    elseif keeppix && saveafile
        out=eval(['cut_sqw(''',filestring,''',proj',',[',a1,'],[',...
            a2,'],[',a3,'],[',a4,'],''',outfilename,''');']);
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


% --- Executes on button press in outfile_browse_pushbutton.
function outfile_browse_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to outfile_browse_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[save_filename,save_pathname,FilterIndex] = uiputfile({'*.sqw';'*.d0d';'*.d1d';'*.d2d';...
    '*.d3d';'*.d4d';'*.*'},'Save As');

if ischar(save_pathname) && ischar(save_filename)
    %i.e. the cancel button was not pressed
    set(handles.out_file_edit,'String',[save_pathname,save_filename]);
    guidata(gcbo,handles);
end

% --- Executes on button press in keep_pix_radiobutton.
function keep_pix_radiobutton_Callback(hObject, eventdata, handles)
% hObject    handle to keep_pix_radiobutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of keep_pix_radiobutton


