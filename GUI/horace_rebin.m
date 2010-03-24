function varargout = horace_rebin(varargin)
% HORACE_REBIN M-file for horace_rebin.fig
%      HORACE_REBIN, by itself, creates a new HORACE_REBIN or raises the existing
%      singleton*.
%
%      H = HORACE_REBIN returns the handle to a new HORACE_REBIN or the handle to
%      the existing singleton*.
%
%      HORACE_REBIN('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in HORACE_REBIN.M with the given input arguments.
%
%      HORACE_REBIN('Property','Value',...) creates a new HORACE_REBIN or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before horace_rebin_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to horace_rebin_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help horace_rebin

% Last Modified by GUIDE v2.5 25-Jan-2010 12:04:01

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @horace_rebin_OpeningFcn, ...
                   'gui_OutputFcn',  @horace_rebin_OutputFcn, ...
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


% --- Executes just before horace_rebin is made visible.
function horace_rebin_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to horace_rebin (see VARARGIN)

% Choose default command line output for horace_rebin
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes horace_rebin wait for user response (see UIRESUME)
% uiwait(handles.figure1);

%The following code is copied from horace_binary_ops
noobj=false;
try
    nsteps=evalin('base','horace_gui_nstep_switch');
catch
    noobj=true;
end

if ~noobj
    nsteps=str2double(nsteps); %convert from string to number
    %We must populate the list boxes now.
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
        set(handles.obj1_popupmenu,'String','No objects to select');
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
    %set(handles.obj1_popupmenu,'String',cellofvars);
    set(handles.obj1_popupmenu,'String',newcell);
    guidata(gcbo, handles);

    str = get(handles.obj1_popupmenu, 'String');
    %val = get(handles.obj1_popupmenu,'Value');
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
    handles.object_name1=object_name;
    w_in1=evalin('base',object_name);%get the data from the base workspace.
    handles.w_in1=w_in1;%store the object in the handles structure
    %
    % Set the default 2nd object to be the first in the list:
    drawnow;
    set(handles.template_popupmenu,'String',cellofvars);
    guidata(gcbo, handles);
    str = get(handles.template_popupmenu, 'String');
    val = get(handles.template_popupmenu,'Value');
    %
    drawnow;
    reqstring=str{val};
    reqstring(end-11:end)=[];
    request=['whos(''',reqstring,''')'];
    %determine what kind of object we are dealing with:
    workobj=evalin('base',request);%returns a structure array with info about the object
    %
    object_name=workobj.name;
    handles.object_name2=object_name;
    w_in2=evalin('base',object_name);%get the data from the base workspace.
    handles.w_in2=w_in2;
    
   
    %Also ensure the default function (1st in list) minus is selected:
    handles.funcstr='minus';
    
    guidata(hObject,handles);
    %
    
    evalin('base','clear horace_gui_nstep_switch');%gets rid of the evidence!
else
    %
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
        set(handles.obj1_popupmenu,'String','No objects to select');
        guidata(hObject, handles);
        return%if no objects that can be plotted or cut are in the workspace
        %we must exit this function
    end
    
    drawnow;
    set(handles.obj1_popupmenu,'String',cellofvars);
    guidata(hObject, handles);

    str = get(handles.obj1_popupmenu, 'String');
    val = get(handles.obj1_popupmenu,'Value');
    %
    drawnow;
    reqstring=str{val};
    reqstring(end-11:end)=[];
    request=['whos(''',reqstring,''')'];
    %determine what kind of object we are dealing with:
    workobj=evalin('base',request);%returns a structure array with info about the object
    %
    object_name=workobj.name;
    handles.object_name1=object_name;
    w_in1=evalin('base',object_name);%get the data from the base workspace.
    handles.w_in1=w_in1;%store the object in the handles structure
    %
    % Set the default 2nd object to be the first in the list:
    drawnow;
    set(handles.template_popupmenu,'String',cellofvars);
    guidata(hObject, handles);
    str = get(handles.template_popupmenu, 'String');
    val = get(handles.template_popupmenu,'Value');
    %
    drawnow;
    reqstring=str{val};
    reqstring(end-11:end)=[];
    request=['whos(''',reqstring,''')'];
    %determine what kind of object we are dealing with:
    workobj=evalin('base',request);%returns a structure array with info about the object
    %
    object_name=workobj.name;
    handles.object_name2=object_name;
    w_in2=evalin('base',object_name);%get the data from the base workspace.
    handles.w_in2=w_in2;
    
    guidata(hObject,handles);
    %
    
end




% --- Outputs from this function are returned to the command line.
function varargout = horace_rebin_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in obj1_popupmenu.
function obj1_popupmenu_Callback(hObject, eventdata, handles)
% hObject    handle to obj1_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns obj1_popupmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from obj1_popupmenu

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
    set(handles.obj1_popupmenu,'String','No objects to select');
    guidata(gcbo, handles);
    return%if no objects that can be plotted or cut are in the workspace
    %we must exit this function
end

drawnow;
set(handles.obj1_popupmenu,'String',cellofvars);
guidata(gcbo, handles);

str = get(hObject, 'String');
val = get(hObject,'Value');
%
drawnow;
reqstring=str{val};
reqstring(end-11:end)=[];
request=['whos(''',reqstring,''')'];
%determine what kind of object we are dealing with:
workobj1=evalin('base',request);%returns a structure array with info about the object
%
object_name1=workobj1.name;
handles.object_name1=object_name1;
w_in1=evalin('base',object_name1);%get the data from the base workspace.
handles.w_in1=w_in1;%store the object in the handles structure

guidata(gcbo,handles);



% --- Executes during object creation, after setting all properties.
function obj1_popupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to obj1_popupmenu (see GCBO)
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


% --- Executes on button press in rebin_pushbutton.
function rebin_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to rebin_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%This is the main function:
%Clear error message
set(handles.message_info_text,'String','');
guidata(gcbo,handles);
drawnow;

outobjname=get(handles.outobj_edit,'String');
outfilename=get(handles.outfile_edit,'String');
out_to_file=get(handles.outfile_radiobutton,'Value');
obj_to_cut='win1';

if isfield(handles,'w_in1')
    win1=handles.w_in1;
    if numel(win1)~=1
        mess='Object#1 is an array of objects. Rebin not yet implemented for arrays -- operation not performed';
        set(handles.message_info_text,'String',mess);
        guidata(gcbo,handles);
        return;
    end    
    ndims1=dimensions(win1);
else
    mess='No valid object#1 selected -- operation not performed';
    set(handles.message_info_text,'String',mess);
    guidata(gcbo,handles);
    return;
end

if isfield(handles,'w_in2')
    win2=handles.w_in2;
    if numel(win2)~=1
        mess='Object#2 is an array of objects. Rebin not yet implemented for arrays -- operation not performed';
        set(handles.message_info_text,'String',mess);
        guidata(gcbo,handles);
        return;
    end    
    ndims2=dimensions(win2);
    obj_to_cut2='win2';
else
    mess='No valid object#2 selected -- no operation performed';
    set(handles.message_info_text,'String',mess);
    guidata(gcbo,handles);
    return;
end

manspec=get(handles.lostephi_radiobutton,'Value');
nummax=get(handles.lostephi_radiobutton,'Max');

%The following unfinished code is to get the manually specified rebin. It
%will have to be a lot cleverer than that used in e.g. horace_combine,
%because we have to be able to sense multiple rebins, such as
%[lo1,step1,hi1],[],[lo3,step3,hi3] etc.
ismanual=false;
if manspec==nummax
    lostephi=get(handles.lostephi_edit,'String');
    %must strip out square brackets, if user has inserted them:
    s1=strfind(lostephi,'['); s2=strfind(lostephi,']');
    if isempty(s1) && isempty(s2)
        lostephinew{1}=strread(lostephi,'%f','delimiter',',');
    elseif ~isempty(s1) && ~isempty(s2)
        if length(s1)~=length(s2)
            mess1='Ensure manual rebinning is of form [lo1,step1,hi1], [step], or []';
            mess2=' and that the number of inputs is the same as the object dimensionality';
            set(handles.message_info_text,'String',[mess1,mess2]);
            guidata(gcbo,handles);
            return;
        elseif length(s1)~=ndims1
            mess1='Number of binning arguments must match the dimensionality of object to be rebinned';
            set(handles.message_info_text,'String',mess1);
            guidata(gcbo,handles);
            return;
        end
        for i=1:numel(s1)
            lostephi_tmp=lostephi(s1(i)+1:s2(i)-1);
            lostephinew{i}=strread(lostephi_tmp,'%f','delimiter',',');
        end
    else
        mess1='Ensure manual rebinning is of form [lo1,step1,hi1], [step], or []';
        mess2=' and that the number of inputs is the same as the object dimensionality';
        set(handles.message_info_text,'String',[mess1,mess2]);
        guidata(gcbo,handles);
        return;
    end
    
    for i=1:numel(lostephinew)
        if ~all(isnan(lostephinew{i})) && ...
                (numel(lostephinew{i})==3 || numel(lostephinew{i})==1 || numel(lostephinew{i})==0)
            ismanual=true;
        else
            mess1='Ensure manual rebinning is of form [lo1,step1,hi1], [step], or []';
            mess2=' and that the number of inputs is the same as the object dimensionality';
            set(handles.message_info_text,'String',{mess1,mess2});
            guidata(gcbo,handles);
        end
    end
end
 
%====
if isempty(outobjname)
    mess='Provide a name for the output object that will be created by combine operation';
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

%Need to check that the two objects being combined have the same
%dimensionality!
if ~ismanual && isfield(handles,'w_in2') && (ndims1 ~= ndims2)
    mess='Objects selected have different dimensionality -- cannot do rebinning';
    set(handles.message_info_text,'String',mess);
    guidata(gcbo,handles);
    return;
end

%Work out which of the rebin functions is required:
if is_sqw_type(sqw(win1))
    funcstr='rebin_sqw';
elseif ndims1==1
    funcstr='rebin_horace_1d';
elseif ndims1==2
    funcstr='rebin_horace_2d';
else
    mess='Object to rebin must either be sqw-type, or be dnd of dimensionality less than 3';
    set(handles.message_info_text,'String',mess);
    guidata(gcbo,handles);
    return;
end

%Make a string in the correct form to do manual rebin:
if ismanual
    argstr='';
    for i=1:numel(lostephinew)
        argstr=[argstr,',[',num2str(lostephinew{i}'),']'];
    end
end


%Now we execute the rebin operation:
try
    if ~saveafile
        if ~ismanual
            out=eval([funcstr,'(',obj_to_cut,',',obj_to_cut2,');']);
        else
            out=eval([funcstr,'(',obj_to_cut,argstr,');']);
        end
    elseif saveafile && strcmp(outfilename,'-save')
        if ~ismanual
            out=eval([funcstr,'(',obj_to_cut,',',obj_to_cut2,');']);
        else
            out=eval([funcstr,'(',obj_to_cut,argstr,');']);
        end
        save(out);
    else
        if ~ismanual
            out=eval([funcstr,'(',obj_to_cut,',',obj_to_cut2,');']);
        else
            out=eval([funcstr,'(',obj_to_cut,argstr,');']);
        end
        save(out,outfilename);
    end
    
catch
    the_err=lasterror;
    emess=the_err.message;
    nchar=strfind(emess,['at ',num2str(the_err.stack(1).line)]);
    mess1='No rebin performed';
    mess2=emess(nchar+9:end);
    set(handles.message_info_text,'String',{mess1,mess2});
    guidata(gcbo,handles);
    return;
end
    
    
assignin('base',outobjname,out);
set(handles.message_info_text,'String','Success!');
guidata(gcbo,handles);






% --- Executes on selection change in template_popupmenu.
function template_popupmenu_Callback(hObject, eventdata, handles)
% hObject    handle to template_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns template_popupmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from template_popupmenu

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
    set(handles.template_popupmenu,'String','No objects to select');
    guidata(gcbo, handles);
    return%if no objects that can be plotted or cut are in the workspace
    %we must exit this function
end

drawnow;
set(handles.template_popupmenu,'String',cellofvars);
guidata(gcbo, handles);

str = get(hObject, 'String');
val = get(hObject,'Value');
%
drawnow;
reqstring=str{val};
reqstring(end-11:end)=[];
request=['whos(''',reqstring,''')'];
%determine what kind of object we are dealing with:
workobj2=evalin('base',request);%returns a structure array with info about the object
%
object_name2=workobj2.name;
handles.object_name2=object_name2;
w_in2=evalin('base',object_name2);%get the data from the base workspace.
handles.w_in2=w_in2;%store the object in the handles structure

guidata(gcbo,handles);



% --- Executes during object creation, after setting all properties.
function template_popupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to template_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function lostephi_edit_Callback(hObject, eventdata, handles)
% hObject    handle to lostephi_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of lostephi_edit as text
%        str2double(get(hObject,'String')) returns contents of lostephi_edit as a double


% --- Executes during object creation, after setting all properties.
function lostephi_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lostephi_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in lostephi_radiobutton.
function lostephi_radiobutton_Callback(hObject, eventdata, handles)
% hObject    handle to lostephi_radiobutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of lostephi_radiobutton

button_state=get(hObject,'Value');
if button_state==get(hObject,'Max');%button is pressed
    set(handles.template_radiobutton,'Value',0);
end
guidata(gcbo, handles);


% --- Executes on button press in template_radiobutton.
function template_radiobutton_Callback(hObject, eventdata, handles)
% hObject    handle to template_radiobutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of template_radiobutton

button_state=get(hObject,'Value');
if button_state==get(hObject,'Max');%button is pressed
    set(handles.lostephi_radiobutton,'Value',0);
end
guidata(gcbo, handles);

