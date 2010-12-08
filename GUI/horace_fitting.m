function varargout = horace_fitting(varargin)
% HORACE_FITTING M-file for horace_fitting.fig
%      HORACE_FITTING, by itself, creates a new HORACE_FITTING or raises the existing
%      singleton*.
%
%      H = HORACE_FITTING returns the handle to a new HORACE_FITTING or the handle to
%      the existing singleton*.
%
%      HORACE_FITTING('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in HORACE_FITTING.M with the given input arguments.
%
%      HORACE_FITTING('Property','Value',...) creates a new HORACE_FITTING or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before horace_fitting_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to horace_fitting_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help horace_fitting

% Last Modified by GUIDE v2.5 07-Dec-2010 14:03:47

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @horace_fitting_OpeningFcn, ...
                   'gui_OutputFcn',  @horace_fitting_OutputFcn, ...
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


% --- Executes just before horace_fitting is made visible.
function horace_fitting_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to horace_fitting (see VARARGIN)

% Choose default command line output for horace_fitting
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes horace_fitting wait for user response (see UIRESUME)
% uiwait(handles.figure1);


set(handles.message_info_text,'String','');
guidata(hObject,handles);
drawnow;
%
vars = evalin('base','whos');%gives a structure array with all of the workspace variables in it
counter=1;
for i=1:numel(vars)
    test_el=vars(i);
    if strcmp(test_el.class,'d1d')
        cellofnames{counter}=test_el.name;
        cellofvars{counter}=[test_el.name,'.........',test_el.class];
        counter=counter+1;
    elseif strcmp(test_el.class,'sqw')
        myvar=evalin('base',test_el.name);
        if dimensions(myvar)==1
            cellofnames{counter}=test_el.name;
            cellofvars{counter}=[test_el.name,'.........',test_el.class];
            counter=counter+1;
        end
    end
end
if exist('cellofvars','var')
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
end

guidata(hObject,handles);



% --- Outputs from this function are returned to the command line.
function varargout = horace_fitting_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


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
    if strcmp(test_el.class,'d1d')
        cellofnames{counter}=test_el.name;
        cellofvars{counter}=[test_el.name,'.........',test_el.class];
        counter=counter+1;
    elseif strcmp(test_el.class,'sqw')
        myvar=evalin('base',test_el.name);
        if dimensions(myvar)==1
            cellofnames{counter}=test_el.name;
            cellofvars{counter}=[test_el.name,'.........',test_el.class];
            counter=counter+1;
        end
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

%drawnow;
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


% --- Executes on button press in refresh_list_pushbutton.
function refresh_list_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to refresh_list_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

vars = evalin('base','whos');%gives a structure array with all of the workspace variables in it
counter=1;
for i=1:numel(vars)
    test_el=vars(i);
    if strcmp(test_el.class,'d1d')
        cellofnames{counter}=test_el.name;
        cellofvars{counter}=[test_el.name,'.........',test_el.class];
        counter=counter+1;
    elseif strcmp(test_el.class,'sqw')
        myvar=evalin('base',test_el.name);
        if dimensions(myvar)==1
            cellofnames{counter}=test_el.name;
            cellofvars{counter}=[test_el.name,'.........',test_el.class];
            counter=counter+1;
        end
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

%drawnow;
set(handles.obj_list_popupmenu,'String',cellofvars);

%We must also update handles so that the object displayed in the list is
%the current work object:
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

guidata(gcbo, handles);





% --- Executes on selection change in peakfuncs_popupmenu.
function peakfuncs_popupmenu_Callback(hObject, eventdata, handles)
% hObject    handle to peakfuncs_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns peakfuncs_popupmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from peakfuncs_popupmenu

%str = get(hObject, 'String');
val = get(hObject,'Value');
%
drawnow;
handles.peakfunc=val-1;
guidata(gcbo,handles);




% --- Executes during object creation, after setting all properties.
function peakfuncs_popupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to peakfuncs_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in bgfuncs_popupmenu.
function bgfuncs_popupmenu_Callback(hObject, eventdata, handles)
% hObject    handle to bgfuncs_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns bgfuncs_popupmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from bgfuncs_popupmenu

val = get(hObject,'Value');
%
drawnow;
handles.bgfunc=val-1;
guidata(gcbo,handles);

%Must now grey out the appropriate coeffs, (e.g. grey out slope and x^2
%coeff if just using constant background, etc).
if val==2
    %zero bg
    set(handles.background_edit,'Enable','off');
    set(handles.bgfix_radiobutton,'Enable','off');
    set(handles.bgslope_edit,'Enable','off');
    set(handles.fixslope_radiobutton,'Enable','off');
    set(handles.bgx2_edit,'Enable','off');
    set(handles.fixx2_radiobutton,'Enable','off');
elseif val==3
    %non-zero bg
    set(handles.background_edit,'Enable','on');
    set(handles.bgfix_radiobutton,'Enable','on');
    set(handles.bgslope_edit,'Enable','off');
    set(handles.fixslope_radiobutton,'Enable','off');
    set(handles.bgx2_edit,'Enable','off');
    set(handles.fixx2_radiobutton,'Enable','off');
elseif val==4
    %linear sloping background
    set(handles.background_edit,'Enable','on');
    set(handles.bgfix_radiobutton,'Enable','on');
    set(handles.bgslope_edit,'Enable','on');
    set(handles.fixslope_radiobutton,'Enable','on');
    set(handles.bgx2_edit,'Enable','off');
    set(handles.fixx2_radiobutton,'Enable','off');
elseif val==5
    %quadratic background
    set(handles.background_edit,'Enable','on');
    set(handles.bgfix_radiobutton,'Enable','on');
    set(handles.bgslope_edit,'Enable','on');
    set(handles.fixslope_radiobutton,'Enable','on');
    set(handles.bgx2_edit,'Enable','on');
    set(handles.fixx2_radiobutton,'Enable','on');
end
    



% --- Executes during object creation, after setting all properties.
function bgfuncs_popupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to bgfuncs_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in plot_pushbutton.
function plot_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to plot_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Clear error message
set(handles.message_info_text,'String','');
guidata(gcbo,handles);

datetime=fix(clock);
timenow=datetime(4:end);
timestring=[num2str(timenow(1)),':',num2str(timenow(2)),':',num2str(timenow(3))];
mess_initialise=['Plotting started at ',timestring,'...'];
drawnow

objname=handles.object_name;
%Find out if the object we wish to plot is a fit or simulation:
is_sim=strfind(objname,'_SIM_');
is_fit=strfind(objname,'_FIT_');

if ~isempty(is_sim)
    dataname=objname(1:is_sim-1);%in case of sim
    flag=1;
elseif ~isempty(is_fit)
    dataname=objname(1:is_fit-1);%in case of fit
    flag=1;
else
    dataname=objname;%in case of data
    flag=0;
end

if isfield(handles,'w_in');
    if flag==0
        win=handles.w_in;
        if numel(win)~=1
            mess='No plot performed - object selected is an array of Horace objects';
            set(handles.message_info_text,'String',char({mess_initialise,mess}));
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
            set(handles.message_info_text,'String',char({mess_initialise,'Success!'}));
            drawnow;
            guidata(gcbo,handles);
        else
            mess='Selected object is not 1-dimensional, to plot it use the main Horace GUI';
            set(handles.message_info_text,'String',char({mess_initialise,mess}));
            guidata(gcbo,handles);
            return;
        end
    elseif flag==1
        %We now need to be cleverer, and plot the original object, and then
        %overplot the fit / simulation as a line.
        w_data=evalin('base',dataname);
        w_fitsim=handles.w_in;
        if numel(w_fitsim)~=1
            mess='No plot performed - object selected is an array of Horace objects';
            set(handles.message_info_text,'String',char({mess_initialise,mess}));
            drawnow;
            guidata(gcbo,handles);
            return;
        end
        ndims=dimensions(w_fitsim);
        if ndims==1
            if isfield(handles,'plotmarker') && ~isempty(handles.plotmarker)
                amark(handles.plotmarker);
            end
            if isfield(handles,'plotcolour') && ~isempty(handles.plotcolour)
                acolor(handles.plotcolour);
            end
            %plot the data object:
            [fig_handle,axis_handle,plot_handle]=dp(w_data);
            %overplot the fit/sim:
            [fig_handle,axis_handle,plot_handle]=pl(w_fitsim);
            drawnow;
            handles.horacefig=fig_handle;
            set(handles.message_info_text,'String',char({mess_initialise,'Success!'}));
            drawnow;
            guidata(gcbo,handles);
        else
            mess='Selected object is not 1-dimensional, to plot it use the main Horace GUI';
            set(handles.message_info_text,'String',char({mess_initialise,mess}));
            guidata(gcbo,handles);
            return;
        end
        
        
    else
        mess='Horace GUI logic flaw - contact horacehelp@stfc.ac.uk so that we can fix this';
        set(handles.message_info_text,'String',char({mess_initialise,mess}));
        guidata(gcbo,handles);
        return;
    end    
end

guidata(gcbo,handles);





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
if val~=1
    reqstring=str{val};
else
    reqstring='o';
end
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
if val~=1
    reqstring=str{val};
    reqstring(1:3)=[]; reqstring(end)=[];
else
    reqstring='red';%default choice
end
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





% --- Executes on button press in fit_pushbutton.
function fit_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to fit_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


%Clear error message
set(handles.message_info_text,'String','');
guidata(gcbo,handles);
drawnow;

datetime=fix(clock);
timenow=datetime(4:end);
timestring=[num2str(timenow(1)),':',num2str(timenow(2)),':',num2str(timenow(3))];
mess_initialise=['Fitting started at ',timestring,'...'];

if isfield(handles,'w_in')
    win=handles.w_in;
    if numel(win)~=1
        for i=1:numel(win)
            ndims(i)=dimensions(win(i));%we have this for debug purposes only
        end
    else
        ndims=dimensions(win);
    end
else
    mess='No valid object selected -- no fitting performed';
    set(handles.message_info_text,'String',char({mess_initialise,mess}));
    guidata(gcbo,handles);
    return;
end

if ~isfield(handles,'peakfunc')
    mess='No peak function selected -- no fitting performed';
    set(handles.message_info_text,'String',char({mess_initialise,mess}));
    guidata(gcbo,handles);
    return;
end

if ~isfield(handles,'bgfunc')
    mess='No background function selected -- no fitting performed';
    set(handles.message_info_text,'String',char({mess_initialise,mess}));
    guidata(gcbo,handles);
    return;
end

%obj_to_cut='win';

%We need the precise name of the object that is going to be simulated:
objname=handles.object_name;

if handles.bgfunc==1
    bgfuncstr='zero_bg';
elseif handles.bgfunc==2
    bgfuncstr='const_bg';
elseif handles.bgfunc==3
    bgfuncstr='linear_bg';
elseif handles.bgfunc==4
    bgfuncstr='quad_bg';
else
    
end

if handles.peakfunc==1
    funcstr='mgauss';
elseif handles.peakfunc==2
    funcstr='mlorz';
elseif handles.peakfunc==3
    funcstr='mgauss2';
elseif handles.peakfunc==4
    funcstr='mlorz2';
elseif handles.peakfunc==5
    funcstr='mtriangle';
elseif handles.peakfunc==6
    funcstr='mheaviside';
elseif handles.peakfunc==7
    funcstr='mgreen';
end

outname=[objname,'_FIT_',funcstr(2:end),'_',bgfuncstr];

%=============
%Now must collect up all the input parameters, and ensure they are of the
%correct format:
amplist=get(handles.amp_edit,'String');
cenlist=get(handles.centre_edit,'String');
widlist=get(handles.width_edit,'String');
amparray=str2num(amplist);
cenarray=str2num(cenlist);
widarray=str2num(widlist);

if isempty(amparray) || any(isnan(amparray))
    mess='Amplitude list must comprise comma separated numbers -- no fitting performed';
    set(handles.message_info_text,'String',char({mess_initialise,mess}));
    guidata(gcbo,handles);
    return;
elseif isempty(cenarray) || any(isnan(cenarray))
    mess='Centre list must comprise comma separated numbers -- no fitting performed';
    set(handles.message_info_text,'String',char({mess_initialise,mess}));
    guidata(gcbo,handles);
    return;
elseif isempty(widarray) || any(isnan(widarray))
    mess='Width list must comprise comma separated numbers -- no fitting performed';
    set(handles.message_info_text,'String',char({mess_initialise,mess}));
    guidata(gcbo,handles);
    return;
end

if ~isequal(size(amparray),size(cenarray)) || ~isequal(size(widarray),size(cenarray))
    mess='Lists of amplitude, centre and width must contain the same number of entries -- no fitting performed';
    set(handles.message_info_text,'String',char({mess_initialise,mess}));
    guidata(gcbo,handles);
    return;
end

pin=[];
for i=1:length(amparray)
    pin=[pin amparray(i) cenarray(i) widarray(i)];
end

%==

constlist=get(handles.background_edit,'String');
slopelist=get(handles.bgslope_edit,'String');
x2list=get(handles.bgx2_edit,'String');
constarray=str2num(constlist);
slopearray=str2num(slopelist);
x2array=str2num(x2list);

bgon=strcmp(get(handles.background_edit,'Enable'),'on');
slopeon=strcmp(get(handles.bgslope_edit,'Enable'),'on');;
x2on=strcmp(get(handles.bgx2_edit,'Enable'),'on');

if (isempty(constarray) & bgon) || (any(isnan(constarray)) & bgon) 
    mess='Background must be a single number -- no fitting performed';
    set(handles.message_info_text,'String',char({mess_initialise,mess}));
    guidata(gcbo,handles);
    return;
elseif (isempty(slopearray) & slopeon) || (any(isnan(slopearray)) & slopeon) 
    mess='Slope must be a single number -- no fitting performed';
    set(handles.message_info_text,'String',char({mess_initialise,mess}));
    guidata(gcbo,handles);
    return;
elseif (isempty(x2array) & x2on) || (any(isnan(x2array)) & x2on) 
    mess='x^2 coefficient must be a single number -- no fitting performed';
    set(handles.message_info_text,'String',char({mess_initialise,mess}));
    guidata(gcbo,handles);
    return;
end

bpin=[];
if bgon
    bpin=[bpin constarray];
end
if slopeon
    bpin=[bpin slopearray];
end
if x2on
    bpin=[bpin x2array];
end

%==========================================================================
%Fitting is more complex than simulating, because we have to deal with
%fixed parameters as well. Note that we either have all of the amplitudes
%fixed, are all of them free. This tool is not sufficiently sophisticated
%to deal with some free / some fixed / bindings.

%Peak fit parameters first:
ampfix=get(handles.ampfix_radiobutton,'Value');
cenfix=get(handles.centrefix_radiobutton,'Value');
widfix=get(handles.widthfix_radiobutton,'Value');

pfree=[];
for i=1:length(amparray)
    pfree=[pfree 1-ampfix 1-cenfix 1-widfix];
end

%Now background paramters (more complex, due to some not being used):
bgfix=get(handles.bgfix_radiobutton,'Value');
slopefix=get(handles.fixslope_radiobutton,'Value');
x2fix=get(handles.fixx2_radiobutton,'Value');

bpfree=[];
if bgon
    bpfree=[bpfree 1-bgfix];
end
if slopeon
    bpfree=[bpfree 1-slopefix];
end
if x2on
    bpfree=[bpfree 1-x2fix];
end


%===============
%Now do the operation:
try
    [out,fitdata]=fit_func(win,str2func(funcstr),pin,pfree,str2func(bgfuncstr),bpin,bpfree,'list',2);
catch
    the_err=lasterror;
    emess=the_err.message;
    nchar=strfind(emess,['at ',num2str(the_err.stack(1).line)]);
    mess1='No fit performed';
    mess2=emess(nchar+9:end);
    set(handles.message_info_text,'String',char({mess_initialise,mess1,mess2}));
    guidata(gcbo,handles);
    return;
end
    
assignin('base',outname,out);

%We now wish to print the fitdata in the message window:
chisq_str=['Chi^2 = ',num2str(fitdata.chisq)];
mess_to_print={mess_initialise,...
    'Success! See Matlab command window for full details of fit',...
    '(fit parameters, errors, covariance matrix, etc)',...
    '-------------------------------------',chisq_str};

npeaks=numel(fitdata.p) /3;
for i=1:npeaks
    mess_to_print{6+3*(i-1)}=['Amplitude ',num2str(i),' = ',num2str(fitdata.p(1+3*(i-1))),...
        ' +/- ',num2str(fitdata.sig(1+3*(i-1)))];
    mess_to_print{7+3*(i-1)}=['Centre ',num2str(i),' = ',num2str(fitdata.p(2+3*(i-1))),...
        ' +/- ',num2str(fitdata.sig(2+3*(i-1)))];
    mess_to_print{8+3*(i-1)}=['Width ',num2str(i),' = ',num2str(fitdata.p(3+3*(i-1))),...
        ' +/- ',num2str(fitdata.sig(3+3*(i-1)))];    
end

%also must include background info (a little trickier):
counter=1;
if bgon
    myout=['Background  = ',num2str(fitdata.bp{1}(counter)),...
        ' +/- ',num2str(fitdata.bsig{1}(counter))];
    mess_to_print=[mess_to_print,myout];
    counter=counter+1;
end
if slopeon
    myout=['Slope  = ',num2str(fitdata.bp{1}(counter)),...
        ' +/- ',num2str(fitdata.bsig{1}(counter))];
    mess_to_print=[mess_to_print,myout];
    counter=counter+1;
end
if x2on
    myout=['x^2 coeffeicient  = ',num2str(fitdata.bp{1}(counter)),...
        ' +/- ',num2str(fitdata.bsig{1}(counter))];
    mess_to_print=[mess_to_print,myout];
end


set(handles.message_info_text,'String',char(mess_to_print));
guidata(gcbo,handles);








function amp_edit_Callback(hObject, eventdata, handles)
% hObject    handle to amp_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of amp_edit as text
%        str2double(get(hObject,'String')) returns contents of amp_edit as a double


% --- Executes during object creation, after setting all properties.
function amp_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to amp_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function centre_edit_Callback(hObject, eventdata, handles)
% hObject    handle to centre_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of centre_edit as text
%        str2double(get(hObject,'String')) returns contents of centre_edit as a double


% --- Executes during object creation, after setting all properties.
function centre_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to centre_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function width_edit_Callback(hObject, eventdata, handles)
% hObject    handle to width_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of width_edit as text
%        str2double(get(hObject,'String')) returns contents of width_edit as a double


% --- Executes during object creation, after setting all properties.
function width_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to width_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in ampfix_radiobutton.
function ampfix_radiobutton_Callback(hObject, eventdata, handles)
% hObject    handle to ampfix_radiobutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ampfix_radiobutton


% --- Executes on button press in centrefix_radiobutton.
function centrefix_radiobutton_Callback(hObject, eventdata, handles)
% hObject    handle to centrefix_radiobutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in widthfix_radiobutton.
function widthfix_radiobutton_Callback(hObject, eventdata, handles)
% hObject    handle to widthfix_radiobutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of widthfix_radiobutton



function background_edit_Callback(hObject, eventdata, handles)
% hObject    handle to background_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of background_edit as text
%        str2double(get(hObject,'String')) returns contents of background_edit as a double


% --- Executes during object creation, after setting all properties.
function background_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to background_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function bgslope_edit_Callback(hObject, eventdata, handles)
% hObject    handle to bgslope_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of bgslope_edit as text
%        str2double(get(hObject,'String')) returns contents of bgslope_edit as a double


% --- Executes during object creation, after setting all properties.
function bgslope_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to bgslope_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in bgfix_radiobutton.
function bgfix_radiobutton_Callback(hObject, eventdata, handles)
% hObject    handle to bgfix_radiobutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of bgfix_radiobutton


% --- Executes on button press in fixslope_radiobutton.
function fixslope_radiobutton_Callback(hObject, eventdata, handles)
% hObject    handle to fixslope_radiobutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of fixslope_radiobutton





function bgx2_edit_Callback(hObject, eventdata, handles)
% hObject    handle to bgx2_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of bgx2_edit as text
%        str2double(get(hObject,'String')) returns contents of bgx2_edit as a double


% --- Executes during object creation, after setting all properties.
function bgx2_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to bgx2_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in fixx2_radiobutton.
function fixx2_radiobutton_Callback(hObject, eventdata, handles)
% hObject    handle to fixx2_radiobutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of fixx2_radiobutton




% --- Executes on button press in simulate_pushbutton.
function simulate_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to simulate_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Clear error message
set(handles.message_info_text,'String','');
guidata(gcbo,handles);
drawnow;

datetime=fix(clock);
timenow=datetime(4:end);
timestring=[num2str(timenow(1)),':',num2str(timenow(2)),':',num2str(timenow(3))];
mess_initialise=['Simulation started at ',timestring,'...'];

if isfield(handles,'w_in')
    win=handles.w_in;
    if numel(win)~=1
        for i=1:numel(win)
            ndims(i)=dimensions(win(i));%we have this for debug purposes only
        end
    else
        ndims=dimensions(win);
    end
else
    mess='No valid object selected -- no simulation performed';
    set(handles.message_info_text,'String',char({mess_initialise,mess}));
    guidata(gcbo,handles);
    return;
end

if ~isfield(handles,'peakfunc')
    mess='No peak function selected -- no simulation performed';
    set(handles.message_info_text,'String',char({mess_initialise,mess}));
    guidata(gcbo,handles);
    return;
end

if ~isfield(handles,'bgfunc')
    mess='No background function selected -- no simulation performed';
    set(handles.message_info_text,'String',char({mess_initialise,mess}));
    guidata(gcbo,handles);
    return;
end

%obj_to_cut='win';

%We need the precise name of the object that is going to be simulated:
objname=handles.object_name;

if handles.bgfunc==1
    bgfuncstr='zero_bg';
elseif handles.bgfunc==2
    bgfuncstr='const_bg';
elseif handles.bgfunc==3
    bgfuncstr='linear_bg';
elseif handles.bgfunc==4
    bgfuncstr='quad_bg';
else
    
end

if handles.peakfunc==1
    funcstr='mgauss';
elseif handles.peakfunc==2
    funcstr='mlorz';
elseif handles.peakfunc==3
    funcstr='mgauss2';
elseif handles.peakfunc==4
    funcstr='mlorz2';
elseif handles.peakfunc==5
    funcstr='mtriangle';
elseif handles.peakfunc==6
    funcstr='mheaviside';
elseif handles.peakfunc==7
    funcstr='mgreen';
end

outname=[objname,'_SIM_',funcstr(2:end),'_',bgfuncstr];

%=============
%Now must collect up all the input parameters, and ensure they are of the
%correct format:
amplist=get(handles.amp_edit,'String');
cenlist=get(handles.centre_edit,'String');
widlist=get(handles.width_edit,'String');
amparray=str2num(amplist);
cenarray=str2num(cenlist);
widarray=str2num(widlist);

if isempty(amparray) || any(isnan(amparray))
    mess='Amplitude list must comprise comma separated numbers -- no simulation performed';
    set(handles.message_info_text,'String',char({mess_initialise,mess}));
    guidata(gcbo,handles);
    return;
elseif isempty(cenarray) || any(isnan(cenarray))
    mess='Centre list must comprise comma separated numbers -- no simulation performed';
    set(handles.message_info_text,'String',char({mess_initialise,mess}));
    guidata(gcbo,handles);
    return;
elseif isempty(widarray) || any(isnan(widarray))
    mess='Width list must comprise comma separated numbers -- no simulation performed';
    set(handles.message_info_text,'String',char({mess_initialise,mess}));
    guidata(gcbo,handles);
    return;
end

if ~isequal(size(amparray),size(cenarray)) || ~isequal(size(widarray),size(cenarray))
    mess='Lists of amplitude, centre and width must contain the same number of entries -- no simulation performed';
    set(handles.message_info_text,'String',char({mess_initialise,mess}));
    guidata(gcbo,handles);
    return;
end

pin=[];
for i=1:length(amparray)
    pin=[pin amparray(i) cenarray(i) widarray(i)];
end

%==

constlist=get(handles.background_edit,'String');
slopelist=get(handles.bgslope_edit,'String');
x2list=get(handles.bgx2_edit,'String');
constarray=str2num(constlist);
slopearray=str2num(slopelist);
x2array=str2num(x2list);

bgon=strcmp(get(handles.background_edit,'Enable'),'on');
slopeon=strcmp(get(handles.bgslope_edit,'Enable'),'on');;
x2on=strcmp(get(handles.bgx2_edit,'Enable'),'on');

if (isempty(constarray) & bgon) || (any(isnan(constarray)) & bgon) 
    mess='Background must be a single number -- no simulation performed';
    set(handles.message_info_text,'String',char({mess_initialise,mess}));
    guidata(gcbo,handles);
    return;
elseif (isempty(slopearray) & slopeon) || (any(isnan(slopearray)) & slopeon) 
    mess='Slope must be a single number -- no simulation performed';
    set(handles.message_info_text,'String',char({mess_initialise,mess}));
    guidata(gcbo,handles);
    return;
elseif (isempty(x2array) & x2on) || (any(isnan(x2array)) & x2on) 
    mess='x^2 coefficient must be a single number -- no simulation performed';
    set(handles.message_info_text,'String',char({mess_initialise,mess}));
    guidata(gcbo,handles);
    return;
end

bpin=[];
if bgon
    bpin=[bpin constarray];
end
if slopeon
    bpin=[bpin slopearray];
end
if x2on
    bpin=[bpin x2array];
end

%===============
%Now do the operation:
try
    out=func_eval(win,str2func(funcstr),pin);
    bgout=func_eval(win,str2func(bgfuncstr),bpin);
    out=plus(out,bgout);
catch
    the_err=lasterror;
    emess=the_err.message;
    nchar=strfind(emess,['at ',num2str(the_err.stack(1).line)]);
    mess1='No simulation performed';
    mess2=emess(nchar+9:end);
    set(handles.message_info_text,'String',char({mess_initialise,mess1,mess2}));
    guidata(gcbo,handles);
    return;
end
    
assignin('base',outname,out);
set(handles.message_info_text,'String',char({mess_initialise,'Success!'}));
guidata(gcbo,handles);








