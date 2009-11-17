function varargout = horace_gen_sqw(varargin)
% HORACE_GEN_SQW M-file for horace_gen_sqw.fig
%      HORACE_GEN_SQW, by itself, creates a new HORACE_GEN_SQW or raises the existing
%      singleton*.
%
%      H = HORACE_GEN_SQW returns the handle to a new HORACE_GEN_SQW or the handle to
%      the existing singleton*.
%
%      HORACE_GEN_SQW('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in HORACE_GEN_SQW.M with the given input arguments.
%
%      HORACE_GEN_SQW('Property','Value',...) creates a new HORACE_GEN_SQW or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before horace_gen_sqw_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to horace_gen_sqw_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help horace_gen_sqw

% Last Modified by GUIDE v2.5 01-Dec-2008 10:32:33

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @horace_gen_sqw_OpeningFcn, ...
                   'gui_OutputFcn',  @horace_gen_sqw_OutputFcn, ...
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


% --- Executes just before horace_gen_sqw is made visible.
function horace_gen_sqw_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to horace_gen_sqw (see VARARGIN)

% Choose default command line output for horace_gen_sqw
handles.output = hObject;
handles.geometry=1;%setup the default assuption that the geometry is direct

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes horace_gen_sqw wait for user response (see UIRESUME)
% uiwait(handles.horace_gen_sqw);


% --- Outputs from this function are returned to the command line.
function varargout = horace_gen_sqw_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in Run_pushbutton.
function Run_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to Run_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% This is the function that does most of the work!
set(handles.Run_pushbutton,'UserData',1);
%the above it to cancel any previously issued STOP command
drawnow;
%Set the Status pane to show working message
mess=cell(3,1);
mess{1}=' ';
mess{2}='Status :';
mess{3}='Working';
set(handles.Status_text,'string',mess);
set(handles.Status_text,'BackgroundColor','y');
drawnow;
%
%=================
%Get the necessary information for the gen_sqw command:
%=================

%Get par file, sqw file etc:
par_file=get(handles.ParFile_edit,'String');
sqw_file=get(handles.SQW_filename_edit,'String');
spe_dir=get(handles.SpePath_edit,'String');
%
% Catch problem if fields are empty:
try
    if isempty(par_file) || isempty(sqw_file) || isempty(spe_dir)
        disp('ERROR: One or more input fields are empty');
        error('Error');
    end
catch
    err=lasterror;%for debug purposes.
    mess=cell(3,1); mess{1}=' ';mess{2}='Status :'; mess{3}='Error';
    set(handles.Status_text,'String',mess);
    set(handles.Status_text,'BackgroundColor','r');
    drawnow;
    return
end

%==========
%get psi and Ei:
%use the routine nicked from homer gui to parse strings.
psistr=get(handles.Psi_edit,'String');
Eistr=get(handles.Ei_edit,'String');

try
    if isempty(psistr) || isempty(Eistr)
        disp('ERROR: Psi or Ei fields are empty');
        error('Error');
    end
catch
    err=lasterror;%for debug purposes.
    mess=cell(3,1); mess{1}=' ';mess{2}='Status :'; mess{3}='Error';
    set(handles.Status_text,'String',mess);
    set(handles.Status_text,'BackgroundColor','r');
    drawnow;
    return
end

psichar=hor_parse(psistr);
Eichar=hor_parse(Eistr);
%convert the psi character array to a vector;
psi=str2num(psichar);
Ei=str2num(Eichar);

%============
%get geometry:
emode=handles.geometry;
if emode~=1
    disp('ERROR: only direct geometry is supported by Horace');
    mess=cell(3,1); mess{1}=' ';mess{2}='Status :'; mess{3}='Error';
    set(handles.Status_text,'String',mess);
    set(handles.Status_text,'BackgroundColor','r');
    drawnow;
    return
end

%========
%get spe files:
spe_files=get(handles.SelectSPE_edit,'String');

try
    if isempty(spe_files)
        disp('ERROR: No SPE files selected');
        error('Error');
    end
catch
    err=lasterror;%for debug purposes.
    mess=cell(3,1); mess{1}=' ';mess{2}='Status :'; mess{3}='Error';
    set(handles.Status_text,'String',mess);
    set(handles.Status_text,'BackgroundColor','r');
    drawnow;
    return
end

if iscell(spe_files)
    %multiple spe files (option usually used)
    for i=1:numel(spe_files)
        spe_files{i}=[spe_dir,'\',spe_files{i}];
    end
else
    %only one spe file given:
    spe_files=[spe_dir,'\',spe_files];
end
    
%check that the number of elements of psi/Ei are consistent with the number
%of SPE files:
try
    if numel(spe_files)>1
        if numel(psi)>1 & numel(Ei)>1
            disp('ERROR: you can vary Ei or psi, but not both');
            error('');
        end
        if numel(psi)==1 & numel(Ei)==1
            disp('ERROR: Multiple SPE files selected, but only one value provided for Psi and Ei');
            error('');
        end
    else
        if numel(psi)>1 || numel(Ei)>1
            disp('ERROR: only one SPE file selected, but more than one Ei or Psi given');
            error('');
        end
    end
catch
    err=lasterror;%for debug purposes.
    mess=cell(3,1); mess{1}=' ';mess{2}='Status :'; mess{3}='Error';
    set(handles.Status_text,'String',mess);
    set(handles.Status_text,'BackgroundColor','r');
    drawnow;
    return
end

try
    if numel(spe_files)>1 && numel(psi)>1
        if numel(spe_files)~=numel(psi)
            disp('ERROR: number of SPE files is not the same as number of Psi')
            error('');
        end
    elseif numel(spe_files)>1 && numel(Ei)>1
        if numel(spe_files)~=numel(Ei)
            disp('ERROR: number of SPE files is not the same as number of Ei')
            error('');
        end
    else
        if numel(spe_files)~=1 && numel(Ei)~=1 && numel(psi)~=1
            disp('ERROR: one SPE file provided, but more than one Psi / Ei given');
        end
    end
catch
    err=lasterror;%for debug purposes.
    mess=cell(3,1); mess{1}=' ';mess{2}='Status :'; mess{3}='Error';
    set(handles.Status_text,'String',mess);
    set(handles.Status_text,'BackgroundColor','r');
    drawnow;
    return
end

%===========
%get all the other info required:
a=get(handles.alatt_edit,'String');
b=get(handles.blatt_edit,'String');
c=get(handles.clatt_edit,'String');
alpha=get(handles.alphalatt_edit,'String');
beta=get(handles.betalatt_edit,'String');
gamma=get(handles.gammalatt_edit,'String');
ux=get(handles.ux_edit,'String');
uy=get(handles.uy_edit,'String');
uz=get(handles.uz_edit,'String');
vx=get(handles.vx_edit,'String');
vy=get(handles.vy_edit,'String');
vz=get(handles.vz_edit,'String');
omega=get(handles.OmegaOffset_edit,'String');
gl=get(handles.glOffset_edit,'String');
gu=get(handles.guOffset_edit,'String');
dpsi=get(handles.dpsi_edit,'String');
%
%do a big check to make sure all of these are valid:
try
    if isempty(a) || isempty(b) || isempty(c) || isempty(alpha) || isempty(beta) ||...
            isempty(gamma) || isempty(ux) || isempty(uy) || isempty(uz) || ...
            isempty(vx) || isempty(vy) || isempty(vz) || isempty(omega) || ...
            isempty(gl) || isempty(gu) || isempty(dpsi)
        disp('ERROR: one or more of the lattice / crystal orientation info fields is empty');
        error('');
    end
catch
    err=lasterror;%for debug purposes.
    mess=cell(3,1); mess{1}=' ';mess{2}='Status :'; mess{3}='Error';
    set(handles.Status_text,'String',mess);
    set(handles.Status_text,'BackgroundColor','r');
    drawnow;
    return
end
alatt=[str2double(a),str2double(b),str2double(c)];
angdeg=[str2double(alpha),str2double(beta),str2double(gamma)];
u=[str2double(ux),str2double(uy),str2double(uz)];
v=[str2double(vx),str2double(vy),str2double(vz)];
omega=str2double(omega);
gl=str2double(gl); gu=str2double(gu);
dpsi=str2double(dpsi);
if iscell(spe_files)
    nfiles=numel(spe_files);
else
    nfiles=1;
end

%final bit of packaging is to make psi and ei vectors of the same length.
%Obviously the elements of one of them will all be the same. We do this so
%that we don't need to faff around with more if statements below:
if numel(psi)>1
    Ei_new=zeros(size(psi));
    for i=1:length(psi)
        Ei_new(i)=Ei;
    end
    Ei=Ei_new;
elseif numel(Ei)>1
    psi_new=zeros(size(Ei));
    for i=1:length(Ei)
        psi_new(i)=psi;
    end
    psi=psi_new;
end

%==========================================================================
%==========================================================================

%We now run the special gen_sqw command that goes with the GUI:

try
    [tmp_file,grid_size,urange] = gen_sqw_gui (sqw, spe_files, par_file, sqw_file,Ei, emode, ...
        alatt, angdeg,u, v, psi, omega, dpsi, gl, gu, hObject,handles, [50,50,50,50]);
    %
catch
    err=lasterror;%for debug
    disp('==================');
    if get(handles.Run_pushbutton,'UserData')==0
        %do nothing else
    else
        stack=err.stack;
        disp(err.message);
        disp('==================');
        disp('Error is in the following file, function, line number:');
        disp(stack(1,1).file);
        disp(stack(1,1).name);
        disp(num2str(stack(1,1).line));
    end
    %disp error message in gui:
    set(handles.Status_text,'string',{' ';'Status :'; 'Error'});
    set(handles.Status_text,'BackgroundColor','r');
    drawnow;
    return
end

status=get(handles.Run_pushbutton,'UserData');
if status==1
    mess=cell(3,1);
    mess{1}=' ';
    mess{2}='Status :';
    mess{3}='Done';
    set(handles.Status_text,'string',mess);
    set(handles.Status_text,'BackgroundColor','g');
else
    mess=cell(3,1);
    mess{1}=' ';
    mess{2}='Status :';
    mess{3}='Stopped';
    set(handles.Status_text,'string',mess);
    set(handles.Status_text,'BackgroundColor','b');
end
drawnow;
guidata(gcbo,handles);


% --- Executes on button press in Stop_pushbutton.
function Stop_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to Stop_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.Run_pushbutton,'UserData',0);
guidata(gcbo, handles);


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


% --- Executes on button press in SQW_filename_browse.
function SQW_filename_browse_Callback(hObject, eventdata, handles)
% hObject    handle to SQW_filename_browse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[sqw_filename,sqw_pathname,FilterIndex] = uiputfile({'*.sqw'},'Select SQW filename');

if iscell(sqw_filename)
    SQW_files=cell(size(sqw_filename));
    for i=1:numel(SQW_files)
        SQW_files{i}=[sqw_pathname,sqw_filename{i}];
    end
    set(handles.SQW_filename_edit,'Style','listbox');
    set(handles.SQW_filename_edit,'String',SQW_files);
else
    set(handles.SQW_filename_edit,'Style','edit');
    set(handles.SQW_filename_edit,'String',[sqw_pathname,sqw_filename]);
end

guidata(gcbo,handles);



function SpePath_edit_Callback(hObject, eventdata, handles)
% hObject    handle to SpePath_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SpePath_edit as text
%        str2double(get(hObject,'String')) returns contents of SpePath_edit as a double


% --- Executes during object creation, after setting all properties.
function SpePath_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SpePath_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in SpePath_browse.
function SpePath_browse_Callback(hObject, eventdata, handles)
% hObject    handle to SpePath_browse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

spepath_dir=uigetdir('C:\');

set(handles.SpePath_edit,'string',spepath_dir);
guidata(gcbo,handles);



function ParFile_edit_Callback(hObject, eventdata, handles)
% hObject    handle to ParFile_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ParFile_edit as text
%        str2double(get(hObject,'String')) returns contents of ParFile_edit as a double


% --- Executes during object creation, after setting all properties.
function ParFile_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ParFile_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in ParFile_browse.
function ParFile_browse_Callback(hObject, eventdata, handles)
% hObject    handle to ParFile_browse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[par_filename,par_pathname,FilterIndex] = uigetfile({'*.par'},'Select PAR filename',...
    'MultiSelect','off');

set(handles.ParFile_edit,'String',[par_pathname,par_filename]);

guidata(gcbo,handles);


function alatt_edit_Callback(hObject, eventdata, handles)
% hObject    handle to alatt_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of alatt_edit as text
%        str2double(get(hObject,'String')) returns contents of alatt_edit as a double


% --- Executes during object creation, after setting all properties.
function alatt_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to alatt_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function blatt_edit_Callback(hObject, eventdata, handles)
% hObject    handle to blatt_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of blatt_edit as text
%        str2double(get(hObject,'String')) returns contents of blatt_edit as a double


% --- Executes during object creation, after setting all properties.
function blatt_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to blatt_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function clatt_edit_Callback(hObject, eventdata, handles)
% hObject    handle to clatt_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of clatt_edit as text
%        str2double(get(hObject,'String')) returns contents of clatt_edit as a double


% --- Executes during object creation, after setting all properties.
function clatt_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to clatt_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function alphalatt_edit_Callback(hObject, eventdata, handles)
% hObject    handle to alphalatt_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of alphalatt_edit as text
%        str2double(get(hObject,'String')) returns contents of alphalatt_edit as a double


% --- Executes during object creation, after setting all properties.
function alphalatt_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to alphalatt_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function betalatt_edit_Callback(hObject, eventdata, handles)
% hObject    handle to betalatt_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of betalatt_edit as text
%        str2double(get(hObject,'String')) returns contents of betalatt_edit as a double


% --- Executes during object creation, after setting all properties.
function betalatt_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to betalatt_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function gammalatt_edit_Callback(hObject, eventdata, handles)
% hObject    handle to gammalatt_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of gammalatt_edit as text
%        str2double(get(hObject,'String')) returns contents of gammalatt_edit as a double


% --- Executes during object creation, after setting all properties.
function gammalatt_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to gammalatt_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ux_edit_Callback(hObject, eventdata, handles)
% hObject    handle to ux_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ux_edit as text
%        str2double(get(hObject,'String')) returns contents of ux_edit as a double


% --- Executes during object creation, after setting all properties.
function ux_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ux_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function uy_edit_Callback(hObject, eventdata, handles)
% hObject    handle to uy_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of uy_edit as text
%        str2double(get(hObject,'String')) returns contents of uy_edit as a double


% --- Executes during object creation, after setting all properties.
function uy_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to uy_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function uz_edit_Callback(hObject, eventdata, handles)
% hObject    handle to uz_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of uz_edit as text
%        str2double(get(hObject,'String')) returns contents of uz_edit as a double


% --- Executes during object creation, after setting all properties.
function uz_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to uz_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function vx_edit_Callback(hObject, eventdata, handles)
% hObject    handle to vx_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of vx_edit as text
%        str2double(get(hObject,'String')) returns contents of vx_edit as a double


% --- Executes during object creation, after setting all properties.
function vx_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to vx_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function vy_edit_Callback(hObject, eventdata, handles)
% hObject    handle to vy_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of vy_edit as text
%        str2double(get(hObject,'String')) returns contents of vy_edit as a double


% --- Executes during object creation, after setting all properties.
function vy_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to vy_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function vz_edit_Callback(hObject, eventdata, handles)
% hObject    handle to vz_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of vz_edit as text
%        str2double(get(hObject,'String')) returns contents of vz_edit as a double


% --- Executes during object creation, after setting all properties.
function vz_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to vz_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when Lattice_panel is resized.
function Lattice_panel_ResizeFcn(hObject, eventdata, handles)
% hObject    handle to Lattice_panel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function OmegaOffset_edit_Callback(hObject, eventdata, handles)
% hObject    handle to OmegaOffset_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of OmegaOffset_edit as text
%        str2double(get(hObject,'String')) returns contents of OmegaOffset_edit as a double


% --- Executes during object creation, after setting all properties.
function OmegaOffset_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to OmegaOffset_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function glOffset_edit_Callback(hObject, eventdata, handles)
% hObject    handle to glOffset_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of glOffset_edit as text
%        str2double(get(hObject,'String')) returns contents of glOffset_edit as a double


% --- Executes during object creation, after setting all properties.
function glOffset_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to glOffset_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function guOffset_edit_Callback(hObject, eventdata, handles)
% hObject    handle to guOffset_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of guOffset_edit as text
%        str2double(get(hObject,'String')) returns contents of guOffset_edit as a double


% --- Executes during object creation, after setting all properties.
function guOffset_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to guOffset_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Psi_edit_Callback(hObject, eventdata, handles)
% hObject    handle to Psi_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Psi_edit as text
%        str2double(get(hObject,'String')) returns contents of Psi_edit as a double


% --- Executes during object creation, after setting all properties.
function Psi_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Psi_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




function Ei_edit_Callback(hObject, eventdata, handles)
% hObject    handle to Ei_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Ei_edit as text
%        str2double(get(hObject,'String')) returns contents of Ei_edit as a double


% --- Executes during object creation, after setting all properties.
function Ei_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Ei_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Geometry_menu_Callback(hObject, eventdata, handles)
% hObject    handle to Geometry_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Geometry_menu as text
%        str2double(get(hObject,'String')) returns contents of Geometry_menu as a double

str = get(hObject, 'String');
val = get(hObject,'Value');
% Set current data to the selected data set.
switch str{val};
case 'Direct' 
   handles.geometry = 1;
case 'Indirect'
   handles.geometry = 2;
   disp('ERROR: Indirect geometry instruments are currently not supported in Horace');
   return;
end

% Save the handles structure.
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function Geometry_menu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Geometry_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function SelectSPE_edit_Callback(hObject, eventdata, handles)
% hObject    handle to SelectSPE_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SelectSPE_edit as text
%        str2double(get(hObject,'String')) returns contents of SelectSPE_edit as a double


% --- Executes during object creation, after setting all properties.
function SelectSPE_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SelectSPE_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in SelectSPE_browse.
function SelectSPE_browse_Callback(hObject, eventdata, handles)
% hObject    handle to SelectSPE_browse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[spe_filename,spe_pathname,FilterIndex] = uigetfile({'*.spe'},'Select SPE file(s)',...
    'MultiSelect','on');

if iscell(spe_filename)
    %more than one spe files selected
    set(handles.SelectSPE_edit,'Style','listbox');
    set(handles.SelectSPE_edit,'String',spe_filename);
else
    %only one spe file selected
    set(handles.SelectSPE_edit,'Style','edit');
    set(handles.SelectSPE_edit,'String',spe_filename);
end

guidata(gcbo,handles);




function dpsi_edit_Callback(hObject, eventdata, handles)
% hObject    handle to dpsi_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of dpsi_edit as text
%        str2double(get(hObject,'String')) returns contents of dpsi_edit as a double


% --- Executes during object creation, after setting all properties.
function dpsi_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dpsi_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


