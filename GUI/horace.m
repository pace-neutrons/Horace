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

% Last Modified by GUIDE v2.5 19-Nov-2015 11:00:22

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

try
    %chicken; %for debug - automatically causes the below to fail if
    %problem with Matlab version / java
    splash('splashscreen','jpg',4000);
catch
    %do nothing - this is to prevent everything failing if the splash
    %function does not work
end



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

try
    backgroundImage = importdata('300px-Quintus_Horatius_Flaccus.jpg');
    %select the axes
    axes(handles.HoraceLogo_axes);
    %place image onto the axes
    imagesc(backgroundImage);
    colormap bone
    %remove the axis tick marks
    axis off
catch
    why;
    %again, do nothing if this fails for some reason
end

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

%We also now need to adjust the names of the axes in "cut", and grey out
%appropriate fields:
ndim=dimensions(w_in);

%Get the plot title info:
[title_main, title_pax, title_iax, display_pax, display_iax, energy_axis] = plot_titles (sqw(w_in));

%Get the info about the object:
if is_sqw_type(sqw(w_in))
    getit=get(w_in);
    gg=getit.data;
else
    gg=get(w_in);
end


%Alter the names of the labels:
for i=1:ndim
    plab=display_pax{i};
    axno=gg.pax(i);
    nn1=strfind(plab,'['); nn2=strfind(plab,']');
    if ~isempty(nn1) && ~isempty(nn2)
        textlab=plab(nn1+1:nn2-1);%label is a q axis
    else
        textlab='Energy';
    end
    eval(['set(handles.Cut_text',num2str(axno),',''String'',textlab)']);
    eval(['set(handles.Cut_ax',num2str(axno),'_edit,''String'','''');']);
    eval(['set(handles.Cut_ax',num2str(axno),'_edit,''Enable'',''on'');']);
end

for i=1:(4-ndim)
    plab=display_iax{i};
    axno=gg.iax(i);
    nn1=strfind(plab,'['); nn2=strfind(plab,']');
    if ~isempty(nn1) && ~isempty(nn2)
        textlab=plab(nn1+1:nn2-1);%label is a q axis
    else
        textlab='Energy';
    end
    eval(['set(handles.Cut_text',num2str(axno),',''String'',textlab);']);
    irange=gg.iint(:,i);
    eval(['set(handles.Cut_ax',num2str(axno),'_edit,''String'',''[',num2str(irange(1)),',',num2str(irange(2)),']'');']);
    eval(['set(handles.Cut_ax',num2str(axno),'_edit,''Enable'',''off'');']);
end



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
% set(handles.message_info_text,'String','');
% guidata(gcbo,handles);
% drawnow;

%Make cut panel visible, all others invisible:
set(handles.CutPanel, 'Visible', 'on');
set(handles.UnaryPanel, 'Visible', 'off');
set(handles.BinaryPanel, 'Visible', 'off');
set(handles.BosePanel, 'Visible', 'off');
set(handles.ReplicatePanel, 'Visible', 'off');
set(handles.CombinePanel, 'Visible', 'off');
set(handles.SymmetrisePanel, 'Visible', 'off');
set(handles.RebinPanel, 'Visible', 'off');
drawnow;
guidata(gcbo,handles);


% if isfield(handles,'w_in');
%     test=get(handles.obj_list_popupmenu,'String');
%     nstep=strmatch(handles.object_name,test);
%     assignin('base','horace_gui_nstep_switch',num2str(nstep));
%     horace_cut_from_object;
% else
%     mess='No cut initialised -- select an object to cut';
%     set(handles.message_info_text,'String',mess);
%     drawnow;
%     guidata(gcbo,handles);
% end
% 
% guidata(gcbo,handles);


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

if isfield(handles,'w_in');
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
    elseif ndims==2
        [fig_handle,axis_handle,plot_handle]=plot(win);
        drawnow;
        handles.horacefig=fig_handle;
        set(handles.message_info_text,'String',char({mess_initialise,'Success!'}));
        drawnow;
        guidata(gcbo,handles);
    elseif ndims==3
        [fig_handle,axis_handle,plot_handle]=plot(win);
        drawnow;
        handles.horacefig=fig_handle;
        set(handles.message_info_text,'String',char({mess_initialise,'Success!'}));
        drawnow;
        guidata(gcbo,handles);
    elseif ndims==4
        mess='Selected object is 4-dimensional, so cannot plot';
        set(handles.message_info_text,'String',char({mess_initialise,mess}));
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
% set(handles.message_info_text,'String','');
% guidata(gcbo,handles);
% drawnow;

%Set correct panel visibility:
set(handles.CutPanel, 'Visible', 'off');
set(handles.UnaryPanel, 'Visible', 'on');
set(handles.BinaryPanel, 'Visible', 'off');
set(handles.BosePanel, 'Visible', 'off');
set(handles.ReplicatePanel, 'Visible', 'off');
set(handles.CombinePanel, 'Visible', 'off');
set(handles.SymmetrisePanel, 'Visible', 'off');
set(handles.RebinPanel, 'Visible', 'off');
drawnow;
guidata(gcbo,handles);

% if isfield(handles,'w_in');
%     test=get(handles.obj_list_popupmenu,'String');
%     nstep=strmatch(handles.object_name,test);
%     assignin('base','horace_gui_nstep_switch',num2str(nstep));
%     horace_unary_operation;
% else
%     mess='No unary operation initialised -- select an object on which to operate';
%     set(handles.message_info_text,'String',mess);
%     drawnow;
%     guidata(gcbo,handles);
% end
% 
% guidata(gcbo,handles);


% --- Executes on button press in binary_ops_pushbutton.
function binary_ops_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to binary_ops_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Clear error message
% set(handles.message_info_text,'String','');
% guidata(gcbo,handles);
% drawnow;

%Set correct panel visibility:
set(handles.CutPanel, 'Visible', 'off');
set(handles.UnaryPanel, 'Visible', 'off');
set(handles.BinaryPanel, 'Visible', 'on');
set(handles.BosePanel, 'Visible', 'off');
set(handles.ReplicatePanel, 'Visible', 'off');
set(handles.CombinePanel, 'Visible', 'off');
set(handles.SymmetrisePanel, 'Visible', 'off');
set(handles.RebinPanel, 'Visible', 'off');
drawnow;
guidata(gcbo,handles);

% if isfield(handles,'w_in');
%     test=get(handles.obj_list_popupmenu,'String');
%     nstep=strmatch(handles.object_name,test);
%     assignin('base','horace_gui_nstep_switch',num2str(nstep));
%     horace_binary_operation;
% else
%     mess='No binary operation initialised -- select an object on which to operate';
%     set(handles.message_info_text,'String',mess);
%     drawnow;
%     guidata(gcbo,handles);
% end
% 
% guidata(gcbo,handles);

guidata(gcbo,handles);

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

drawnow;
set(handles.Bin_obj2_popupmenu,'String',cellofvars);
guidata(gcbo, handles);


% % --- Executes on button press in cut_from_file_pushbutton.
% function cut_from_file_pushbutton_Callback(hObject, eventdata, handles)
% % hObject    handle to cut_from_file_pushbutton (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
% 
% %Clear error message
% set(handles.message_info_text,'String','');
% guidata(gcbo,handles);
% drawnow;
% 
% sqw_flname=get(handles.sqw_filename_edit,'String');
% if ~isempty(sqw_flname)
%     assignin('base','sqw_filename_internal',sqw_flname);
%     horace_cut_from_file;
% else
%     mess='No cut initialised -- select a file to cut';
%     set(handles.message_info_text,'String',mess);
%     drawnow;
%     guidata(gcbo,handles);
% end
% 
% guidata(gcbo,handles);

% --- Executes on button press in overplot_pushbutton.
function overplot_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to overplot_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Clear error message
set(handles.message_info_text,'String','');
guidata(gcbo,handles);

datetime=fix(clock);
timenow=datetime(4:end);
timestring=[num2str(timenow(1)),':',num2str(timenow(2)),':',num2str(timenow(3))];
mess_initialise=['Overplotting started at ',timestring,'...'];
drawnow

if isfield(handles,'w_in');
    win=handles.w_in;
    if numel(win)~=1
        mess='No plot-over performed - object selected is an array of Horace objects';
        set(handles.message_info_text,'String',char({mess_initialise,mess}));
        drawnow;
        guidata(gcbo,handles);
        return;
    end
    ndims=dimensions(win);
    if ndims==1
        if isfield(handles,'plotovermarker') && ~isempty(handles.plotovermarker)
            amark(handles.plotovermarker);
            set(handles.message_info_text,'String',char({mess_initialise,'Success!'}));
            drawnow;
            guidata(gcbo,handles);
        end
        if isfield(handles,'plotovercolour') && ~isempty(handles.plotovercolour)
            acolor(handles.plotovercolour);
            set(handles.message_info_text,'String',char({mess_initialise,'Success!'}));
            drawnow;
            guidata(gcbo,handles);
        end
        if isfield(handles,'horacefig')
            try
                set(0,'CurrentFigure',handles.horacefig);
                pp(win);
                drawnow;
                set(handles.message_info_text,'String',char({mess_initialise,'Success!'}));
                drawnow;
                guidata(gcbo,handles);
            catch
                pp(win);
                drawnow;
                set(handles.message_info_text,'String',char({mess_initialise,'Success!'}));
                drawnow;
                guidata(gcbo,handles);
            end
        else
            dp(win);
            drawnow;
            set(handles.message_info_text,'String',char({mess_initialise,'Success!'}));
            drawnow;
            guidata(gcbo,handles);
        end
    else
        mess='Cannot overplot anything other than 1d cuts';
        set(handles.message_info_text,'String',char({mess_initialise,mess}));
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
if val~=1
    reqstring=str{val};
else
    reqstring='o';
end
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
if val~=1
    reqstring=str{val};
    reqstring(1:3)=[]; reqstring(end)=[];
else
    reqstring='r';%default choice
end
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

datetime=fix(clock);
timenow=datetime(4:end);
timestring=[num2str(timenow(1)),':',num2str(timenow(2)),':',num2str(timenow(3))];
mess_initialise=['Saving to file started at ',timestring,'...'];

if isfield(handles,'w_in')
    win=handles.w_in;
    if numel(win)~=1
        mess='No save performed - object selected is an array of Horace objects';
        set(handles.message_info_text,'String',char({mess_initialise,mess}));
        drawnow;
        guidata(gcbo,handles);
        return;
    end
    str=get(handles.savefile_edit,'String');
    if ~isempty(str)
        try
            save(win,str);
            mess=['File saved to ',str];
            set(handles.message_info_text,'String',char({mess_initialise,mess}));
        catch
            mess='Saving of file failed -- check object and/or filename';
            set(handles.message_info_text,'String',char({mess_initialise,mess}));
            return;
        end         
    else
        mess='No file written -- select a filename';
        set(handles.message_info_text,'String',char({mess_initialise,mess}));
        drawnow;
        guidata(gcbo,handles);
    end
else
    mess='No file written -- select an object to save';
    set(handles.message_info_text,'String',char({mess_initialise,mess}));
    drawnow;
    guidata(gcbo,handles);
end

    


% --- Executes on button press in bose_pushbutton.
function bose_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to bose_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Clear error message
% set(handles.message_info_text,'String','');
% guidata(gcbo,handles);
% drawnow;

%Set correct panel visibility:
set(handles.CutPanel, 'Visible', 'off');
set(handles.UnaryPanel, 'Visible', 'off');
set(handles.BinaryPanel, 'Visible', 'off');
set(handles.BosePanel, 'Visible', 'on');
set(handles.ReplicatePanel, 'Visible', 'off');
set(handles.CombinePanel, 'Visible', 'off');
set(handles.SymmetrisePanel, 'Visible', 'off');
set(handles.RebinPanel, 'Visible', 'off');
drawnow;
guidata(gcbo,handles);

% if isfield(handles,'w_in');
%     test=get(handles.obj_list_popupmenu,'String');
%     nstep=strmatch(handles.object_name,test);
%     assignin('base','horace_gui_nstep_switch',num2str(nstep));
%     horace_bosegui;
% else
%     mess='No bose correction initialised -- select an object on which to operate';
%     set(handles.message_info_text,'String',mess);
%     drawnow;
%     guidata(gcbo,handles);
% end
% 
% guidata(gcbo,handles);


% --- Executes on button press in replicate_pushbutton.
function replicate_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to replicate_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Clear error message
% set(handles.message_info_text,'String','');
% guidata(gcbo,handles);
% drawnow;

%Set correct panel visibility:
set(handles.CutPanel, 'Visible', 'off');
set(handles.UnaryPanel, 'Visible', 'off');
set(handles.BinaryPanel, 'Visible', 'off');
set(handles.BosePanel, 'Visible', 'off');
set(handles.ReplicatePanel, 'Visible', 'on');
set(handles.CombinePanel, 'Visible', 'off');
set(handles.SymmetrisePanel, 'Visible', 'off');
set(handles.RebinPanel, 'Visible', 'off');
drawnow;
guidata(gcbo,handles);

% if isfield(handles,'w_in');
% %     if is_sqw_type(sqw(handles.w_in))
% %         mess='No replication initialised -- object selected is sqw type, which cannot be replicated';
% %         set(handles.message_info_text,'String',mess);
% %         drawnow;
% %         guidata(gcbo,handles);
% %         return;
% %     end
%     test=get(handles.obj_list_popupmenu,'String');
%     nstep=strmatch(handles.object_name,test);
%     assignin('base','horace_gui_nstep_switch',num2str(nstep));
%     horace_replicate;
% else
%     mess='No replication initialised -- select an object on which to operate';
%     set(handles.message_info_text,'String',mess);
%     drawnow;
%     guidata(gcbo,handles);
% end

guidata(gcbo,handles);

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

drawnow;
set(handles.Rep_obj2_popupmenu,'String',cellofvars);
guidata(gcbo, handles);

guidata(gcbo,handles);


% --- Executes on button press in combine_pushbutton.
function combine_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to combine_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Clear error message
% set(handles.message_info_text,'String','');
% guidata(gcbo,handles);
% drawnow;

%Set correct panel visibility:
set(handles.CutPanel, 'Visible', 'off');
set(handles.UnaryPanel, 'Visible', 'off');
set(handles.BinaryPanel, 'Visible', 'off');
set(handles.BosePanel, 'Visible', 'off');
set(handles.ReplicatePanel, 'Visible', 'off');
set(handles.CombinePanel, 'Visible', 'on');
set(handles.SymmetrisePanel, 'Visible', 'off');
set(handles.RebinPanel, 'Visible', 'off');
drawnow;
guidata(gcbo,handles);

% if isfield(handles,'w_in');
% %     if is_sqw_type(sqw(handles.w_in))
% %         mess='No replication initialised -- object selected is sqw type, which cannot be replicated';
% %         set(handles.message_info_text,'String',mess);
% %         drawnow;
% %         guidata(gcbo,handles);
% %         return;
% %     end
%     test=get(handles.obj_list_popupmenu,'String');
%     nstep=strmatch(handles.object_name,test);
%     assignin('base','horace_gui_nstep_switch',num2str(nstep));
%     horace_combine;
% else
%     mess='No combine initialised -- select an object on which to operate';
%     set(handles.message_info_text,'String',mess);
%     drawnow;
%     guidata(gcbo,handles);
% end

guidata(gcbo,handles);

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

drawnow;
set(handles.Comb_obj2_popupmenu,'String',cellofvars);
guidata(gcbo, handles);

% --- Executes on button press in symmetrise_pushbutton.
function symmetrise_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to symmetrise_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Clear error message
% set(handles.message_info_text,'String','');
% guidata(gcbo,handles);
% drawnow;

%Set correct panel visibility:
set(handles.CutPanel, 'Visible', 'off');
set(handles.UnaryPanel, 'Visible', 'off');
set(handles.BinaryPanel, 'Visible', 'off');
set(handles.BosePanel, 'Visible', 'off');
set(handles.ReplicatePanel, 'Visible', 'off');
set(handles.CombinePanel, 'Visible', 'off');
set(handles.SymmetrisePanel, 'Visible', 'on');
set(handles.RebinPanel, 'Visible', 'off');
drawnow;
guidata(gcbo,handles);

% if isfield(handles,'w_in');
% %     if is_sqw_type(sqw(handles.w_in))
% %         mess='No replication initialised -- object selected is sqw type, which cannot be replicated';
% %         set(handles.message_info_text,'String',mess);
% %         drawnow;
% %         guidata(gcbo,handles);
% %         return;
% %     end
%     test=get(handles.obj_list_popupmenu,'String');
%     nstep=strmatch(handles.object_name,test);
%     assignin('base','horace_gui_nstep_switch',num2str(nstep));
%     horace_symmetrise;
% else
%     mess='No symmetrise initialised -- select an object on which to operate';
%     set(handles.message_info_text,'String',mess);
%     drawnow;
%     guidata(gcbo,handles);
% end
% 
% guidata(gcbo,handles);


% --- Executes on button press in rebin_pushbutton.
function rebin_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to rebin_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Clear error message
% set(handles.message_info_text,'String','');
% guidata(gcbo,handles);
% drawnow;

%Set correct panel visibility:
set(handles.CutPanel, 'Visible', 'off');
set(handles.UnaryPanel, 'Visible', 'off');
set(handles.BinaryPanel, 'Visible', 'off');
set(handles.BosePanel, 'Visible', 'off');
set(handles.ReplicatePanel, 'Visible', 'off');
set(handles.CombinePanel, 'Visible', 'off');
set(handles.SymmetrisePanel, 'Visible', 'off');
set(handles.RebinPanel, 'Visible', 'on');
drawnow;
guidata(gcbo,handles);

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

drawnow;
set(handles.Rebin_template_popupmenu,'String',cellofvars);
guidata(gcbo, handles);

% str = get(hObject, 'String');
% val = get(hObject,'Value');
% %
% drawnow;
% reqstring=str{val};
% reqstring(end-11:end)=[];
% request=['whos(''',reqstring,''')'];
% %determine what kind of object we are dealing with:
% template=evalin('base',request);%returns a structure array with info about the object
% %
% template_name=template.name;
% %handles.object_name=object_name;
% w_in2=evalin('base',template_name);%get the data from the base workspace.
% handles.w_in2=w_in2;%store the object in the handles structure
% 
% guidata(gcbo,handles);

% if isfield(handles,'w_in');
% %     if is_sqw_type(sqw(handles.w_in))
% %         mess='No replication initialised -- object selected is sqw type, which cannot be replicated';
% %         set(handles.message_info_text,'String',mess);
% %         drawnow;
% %         guidata(gcbo,handles);
% %         return;
% %     end
%     test=get(handles.obj_list_popupmenu,'String');
%     nstep=strmatch(handles.object_name,test);
%     assignin('base','horace_gui_nstep_switch',num2str(nstep));
%     horace_rebin;
% else
%     mess='No rebin initialised -- select an object on which to operate';
%     set(handles.message_info_text,'String',mess);
%     drawnow;
%     guidata(gcbo,handles);
% end
% 
% guidata(gcbo,handles);



% --- Executes on button press in SelectFile_pushbutton.
function SelectFile_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to SelectFile_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.DatafilePanel, 'Visible', 'on');
set(handles.WorkspacePanel, 'Visible', 'off');
set(handles.gen_sqw_panel, 'Visible', 'off');
drawnow;
guidata(gcbo,handles);


% --- Executes on button press in SelectWorkspace_pushbutton.
function SelectWorkspace_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to SelectWorkspace_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.DatafilePanel, 'Visible', 'off');
set(handles.WorkspacePanel, 'Visible', 'on');
set(handles.gen_sqw_panel, 'Visible', 'off');
drawnow;
guidata(gcbo,handles);





function Cut_ax1_edit_Callback(hObject, eventdata, handles)
% hObject    handle to Cut_ax1_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Cut_ax1_edit as text
%        str2double(get(hObject,'String')) returns contents of Cut_ax1_edit as a double


% --- Executes during object creation, after setting all properties.
function Cut_ax1_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Cut_ax1_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Cut_ax2_edit_Callback(hObject, eventdata, handles)
% hObject    handle to Cut_ax2_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Cut_ax2_edit as text
%        str2double(get(hObject,'String')) returns contents of Cut_ax2_edit as a double


% --- Executes during object creation, after setting all properties.
function Cut_ax2_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Cut_ax2_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Cut_ax3_edit_Callback(hObject, eventdata, handles)
% hObject    handle to Cut_ax3_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Cut_ax3_edit as text
%        str2double(get(hObject,'String')) returns contents of Cut_ax3_edit as a double


% --- Executes during object creation, after setting all properties.
function Cut_ax3_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Cut_ax3_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Cut_ax4_edit_Callback(hObject, eventdata, handles)
% hObject    handle to Cut_ax4_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Cut_ax4_edit as text
%        str2double(get(hObject,'String')) returns contents of Cut_ax4_edit as a double


% --- Executes during object creation, after setting all properties.
function Cut_ax4_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Cut_ax4_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Cut_Outobj_edit_Callback(hObject, eventdata, handles)
% hObject    handle to Cut_Outobj_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Cut_Outobj_edit as text
%        str2double(get(hObject,'String')) returns contents of Cut_Outobj_edit as a double


% --- Executes during object creation, after setting all properties.
function Cut_Outobj_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Cut_Outobj_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Cut_Outfile_radiobutton.
function Cut_Outfile_radiobutton_Callback(hObject, eventdata, handles)
% hObject    handle to Cut_Outfile_radiobutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Cut_Outfile_radiobutton



function Cut_outfile_edit_Callback(hObject, eventdata, handles)
% hObject    handle to Cut_outfile_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Cut_outfile_edit as text
%        str2double(get(hObject,'String')) returns contents of Cut_outfile_edit as a double


% --- Executes during object creation, after setting all properties.
function Cut_outfile_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Cut_outfile_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Cut_outfile_browse_pushbutton.
function Cut_outfile_browse_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to Cut_outfile_browse_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[save_filename,save_pathname,FilterIndex] = uiputfile({'*.sqw';'*.d0d';'*.d1d';'*.d2d';...
    '*.d3d';'*.d4d';'*.*'},'Save As');

if ischar(save_pathname) && ischar(save_filename)
    %i.e. the cancel button was not pressed
    set(handles.Cut_outfile_edit,'String',[save_pathname,save_filename]);
    guidata(gcbo,handles);
end


% --- Executes on button press in Cut_retain_radiobutton.
function Cut_retain_radiobutton_Callback(hObject, eventdata, handles)
% hObject    handle to Cut_retain_radiobutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Cut_retain_radiobutton


% --- Executes on button press in Cut_do_cut_pushbutton.
function Cut_do_cut_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to Cut_do_cut_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Clear error message
set(handles.message_info_text,'String','');
guidata(gcbo,handles);
drawnow;

datetime=fix(clock);
timenow=datetime(4:end);
timestring=[num2str(timenow(1)),':',num2str(timenow(2)),':',num2str(timenow(3))];
mess_initialise=['Cut started at ',timestring,'...'];

set(handles.message_info_text,'String',char({mess_initialise,'Working'}));
pause(0.1);
drawnow;
guidata(gcbo,handles);


%This is the main business of this part of the GUI. Note that we have a lot more
%cases to deal with than when cutting from file, because the cut command
%has to be called with the appropriate number of inputs for the
%dimensionality of object.
if isfield(handles,'w_in')
    win=handles.w_in;
    if numel(win)~=1
        mess='No cut performed - object selected is an array of Horace objects';
        set(handles.message_info_text,'String',char({mess_initialise,mess}));
        drawnow;
        guidata(gcbo,handles);
        return;
    end
    ndims=dimensions(win);
else
    mess='No valid object selected -- no cut taken';
    mess_cell={mess_initialise,mess};
    set(handles.message_info_text,'String',char(mess_cell));
    guidata(gcbo,handles);
    return;
end

extra_flag=false;

%First get the info contained in the GUI's fields.
a1=get(handles.Cut_ax1_edit,'String');
a2=get(handles.Cut_ax2_edit,'String');
a3=get(handles.Cut_ax3_edit,'String');
a4=get(handles.Cut_ax4_edit,'String');
outobjname=get(handles.Cut_Outobj_edit,'String');
outfilename=get(handles.Cut_outfile_edit,'String');
keep_pixels=get(handles.Cut_retain_radiobutton,'Value');
out_to_file=get(handles.Cut_Outfile_radiobutton,'Value');
obj_to_cut='win';

%Check all is in correct format:
if isempty(a1)
    mess1='   Ensure binning values are entered if the form of lo,step,hi / step / lo,hi    ';
    mess2='NB: enter 0 if you wish to use intrinsic binning and entire data range along axis';
    set(handles.message_info_text,'String',char({mess_initialise,mess1,mess2}));
    guidata(gcbo,handles);
    return;
elseif isempty(a2) && ndims>=1.9
    mess1='   Ensure binning values are entered if the form of lo,step,hi / step / lo,hi    ';
    mess2='NB: enter 0 if you wish to use intrinsic binning and entire data range along axis';
    set(handles.message_info_text,'String',char({mess_initialise,mess1,mess2}));
    guidata(gcbo,handles);
    return;
elseif isempty(a3) && ndims>=2.9
    mess1='   Ensure binning values are entered if the form of lo,step,hi / step / lo,hi    ';
    mess2='NB: enter 0 if you wish to use intrinsic binning and entire data range along axis';
    set(handles.message_info_text,'String',char({mess_initialise,mess1,mess2}));
    guidata(gcbo,handles);
    return;  
elseif isempty(a4) && ndims>=3.9
    mess1='   Ensure binning values are entered if the form of lo,step,hi / step / lo,hi    ';
    mess2='NB: enter 0 if you wish to use intrinsic binning and entire data range along axis';
    set(handles.message_info_text,'String',char({mess_initialise,mess1,mess2}));
    guidata(gcbo,handles);
    return;  
else
    try
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
            set(handles.message_info_text,'String',char({mess_initialise,mess1,mess2}));
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
            set(handles.message_info_text,'String',char({mess_initialise,mess1,mess2}));
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
            set(handles.message_info_text,'String',char({mess_initialise,mess1,mess2}));
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
            set(handles.message_info_text,'String',char({mess_initialise,mess1,mess2}));
            guidata(gcbo,handles);
            return;
        end
    catch
        mess1='Formatting error for binning arguments';
        mess2='Ensure they are of the form lo,step,hi / step / lo,hi, and are numeric';
        set(handles.message_info_text,'String',char({mess_initialise,mess1,mess2}));
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
    set(handles.message_info_text,'String',char({mess_initialise,mess1,mess2}));
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
        set(handles.message_info_text,'String',char({mess_initialise,mess1,mess2}));
        guidata(gcbo,handles);
        return;
    elseif (numel(a1new)==3 && a1new(2)~=0) || (numel(a2new)==3 && a2new(2)~=0) || ...
            (numel(a3new)==3 && a3new(2)~=0) || (numel(a4new)==3 && a4new(2)~=0)
        mess1='Object is dnd -- cannot use non-zero step size to rebin along an axis.';
        mess2='    Must specify binning as [lo,hi] (integration), [lo,0,hi], or 0    ';
        set(handles.message_info_text,'String',char({mess_initialise,mess1,mess2}));
        guidata(gcbo,handles);
        return;
    end
end



%====
if keep_pixels==get(handles.Cut_retain_radiobutton,'Max')
    keeppix=true;
else
    keeppix=false;
end
%====

if isempty(outobjname)
    mess='Provide a name for the output object that will be created by cut';
    set(handles.message_info_text,'String',char({mess_initialise,mess}));
    guidata(gcbo,handles);
    return;
end
%
testexp=regexpi(outobjname,'[A-Z]');
if testexp(1)~=1
    mess='The first character of the output name must be a letter, not a number or symbol';
    set(handles.message_info_text,'String',char({mess_initialise,mess}));
    guidata(gcbo,handles);
    return;
end

%====
if out_to_file==get(handles.Cut_Outfile_radiobutton,'Max')
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
    set(handles.message_info_text,'String',char({mess_initialise,mess}));
    guidata(gcbo,handles);
    keeppix=true;%bizarrely, this is what we need to do (so there is no '-nopix' argument)
    extra_flag=true;
elseif ~is_sqw_type(sqw(win))
    keeppix=true;
end

%=============

%After defining all of these axes, we now actually have to re-order them
%based on what is/isn't greyed out.
a1old=a1; a2old=a2; a3old=a3; a4old=a4;
getit=get(win);
if is_sqw_type(sqw(win))
    gg=getit.data;
else
    gg=getit;
end

ndim=dimensions(win);

for i=1:ndim
    axno=gg.pax(i);
    if axno==1
        eval(['a',num2str(i),'=a1old;']);
    elseif axno==2
        eval(['a',num2str(i),'=a2old;']);
    elseif axno==3
        eval(['a',num2str(i),'=a3old;']);
    elseif axno==4
        eval(['a',num2str(i),'=a4old;']);
    end
end



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
            set(handles.message_info_text,'String',char({mess_initialise,mess}));
            guidata(gcbo,handles);
            return;
    end
catch
    the_err=lasterror;
    emess=the_err.message;
    nchar=strfind(emess,['at ',num2str(the_err.stack(1).line)]);
    mess1='No operation performed';
    mess2=emess(nchar+9:end);
    set(handles.message_info_text,'String',char({mess_initialise,mess1,mess2}));
    guidata(gcbo,handles);
    return;
end
    
    
    
assignin('base',outobjname,out);
if extra_flag==false
    set(handles.message_info_text,'String',char({mess_initialise,'Success!'}));
    guidata(gcbo,handles);
else
    mess='Selected object has no pixel info -- proceeding with cut, but no pixel info retained...';
    set(handles.message_info_text,'String',char({mess_initialise,mess,'Success!'}));
    guidata(gcbo,handles);
end











% --- Executes on button press in Rebin_template_radiobutton.
function Rebin_template_radiobutton_Callback(hObject, eventdata, handles)
% hObject    handle to Rebin_template_radiobutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Rebin_template_radiobutton

button_state=get(hObject,'Value');
if button_state==get(hObject,'Max');%button is pressed
    set(handles.Rebin_lostephi_radiobutton,'Value',0);
end
guidata(gcbo, handles);


% --- Executes on selection change in Rebin_template_popupmenu.
function Rebin_template_popupmenu_Callback(hObject, eventdata, handles)
% hObject    handle to Rebin_template_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns Rebin_template_popupmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Rebin_template_popupmenu

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
    set(handles.Rebin_template_popupmenu,'String','No objects to select');
    guidata(gcbo, handles);
    return%if no objects that can be plotted or cut are in the workspace
    %we must exit this function
end

%drawnow;
set(handles.Rebin_template_popupmenu,'String',cellofvars);
guidata(gcbo, handles);

str = get(hObject, 'String');
val = get(hObject,'Value');
%
drawnow;
reqstring=str{val};
reqstring(end-11:end)=[];
request=['whos(''',reqstring,''')'];
%determine what kind of object we are dealing with:
template=evalin('base',request);%returns a structure array with info about the object
%
template_name=template.name;
%handles.object_name=object_name;
w_in2=evalin('base',template_name);%get the data from the base workspace.
handles.w_in2_rebin=w_in2;%store the object in the handles structure

guidata(gcbo,handles);




% --- Executes during object creation, after setting all properties.
function Rebin_template_popupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Rebin_template_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Rebin_lostephi_radiobutton.
function Rebin_lostephi_radiobutton_Callback(hObject, eventdata, handles)
% hObject    handle to Rebin_lostephi_radiobutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Rebin_lostephi_radiobutton

button_state=get(hObject,'Value');
if button_state==get(hObject,'Max');%button is pressed
    set(handles.Rebin_template_radiobutton,'Value',0);
end
guidata(gcbo, handles);


function Rebin_lostephi_edit_Callback(hObject, eventdata, handles)
% hObject    handle to Rebin_lostephi_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Rebin_lostephi_edit as text
%        str2double(get(hObject,'String')) returns contents of Rebin_lostephi_edit as a double


% --- Executes during object creation, after setting all properties.
function Rebin_lostephi_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Rebin_lostephi_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Rebin_outobj_edit_Callback(hObject, eventdata, handles)
% hObject    handle to Rebin_outobj_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Rebin_outobj_edit as text
%        str2double(get(hObject,'String')) returns contents of Rebin_outobj_edit as a double


% --- Executes during object creation, after setting all properties.
function Rebin_outobj_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Rebin_outobj_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Rebin_outfile_radiobutton.
function Rebin_outfile_radiobutton_Callback(hObject, eventdata, handles)
% hObject    handle to Rebin_outfile_radiobutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Rebin_outfile_radiobutton



function Rebin_outfile_edit_Callback(hObject, eventdata, handles)
% hObject    handle to Rebin_outfile_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Rebin_outfile_edit as text
%        str2double(get(hObject,'String')) returns contents of Rebin_outfile_edit as a double


% --- Executes during object creation, after setting all properties.
function Rebin_outfile_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Rebin_outfile_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Rebin_outfile_browse_pushbutton.
function Rebin_outfile_browse_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to Rebin_outfile_browse_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[save_filename,save_pathname,FilterIndex] = uiputfile({'*.sqw';'*.d0d';'*.d1d';'*.d2d';...
    '*.d3d';'*.d4d';'*.*'},'Save As');

if ischar(save_pathname) && ischar(save_filename)
    %i.e. the cancel button was not pressed
    set(handles.Rebin_outfile_edit,'String',[save_pathname,save_filename]);
    guidata(gcbo,handles);
end


% --- Executes on button press in Rebin_rebin_pushbutton.
function Rebin_rebin_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to Rebin_rebin_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Clear error message
set(handles.message_info_text,'String','');
guidata(gcbo,handles);
drawnow;

datetime=fix(clock);
timenow=datetime(4:end);
timestring=[num2str(timenow(1)),':',num2str(timenow(2)),':',num2str(timenow(3))];
mess_initialise=['Rebin started at ',timestring,'...'];

%-----
%Now execute the main function of this sub-panel:

outobjname=get(handles.Rebin_outobj_edit,'String');
outfilename=get(handles.Rebin_outfile_edit,'String');
out_to_file=get(handles.Rebin_outfile_radiobutton,'Value');
obj_to_cut='win1';

if isfield(handles,'w_in')
    win1=handles.w_in;
    if numel(win1)~=1
        mess='Data object is an array of objects. Rebin not yet implemented for arrays -- operation not performed';
        set(handles.message_info_text,'String',char({mess_initialise,mess}));
        guidata(gcbo,handles);
        return;
    end    
    ndims1=dimensions(win1);
else
    mess='No valid data object selected -- operation not performed';
    set(handles.message_info_text,'String',char({mess_initialise,mess}));
    guidata(gcbo,handles);
    return;
end

manspec=get(handles.Rebin_lostephi_radiobutton,'Value');
nummax=get(handles.Rebin_lostephi_radiobutton,'Max');

if isfield(handles,'w_in2_rebin') && ~(manspec==nummax)
    win2=handles.w_in2_rebin;
    if numel(win2)~=1
        mess='Template object is an array of objects. Rebin not yet implemented for arrays -- operation not performed';
        set(handles.message_info_text,'String',char({mess_initialise,mess}));
        guidata(gcbo,handles);
        return;
    end    
    ndims2=dimensions(win2);
    obj_to_cut2='win2';
elseif manspec==nummax
    %go to the next bit of code
else
    mess='No valid template object selected -- rebin not performed';
    set(handles.message_info_text,'String',char({mess_initialise,mess}));
    guidata(gcbo,handles);
    return;
end


%The following unfinished code is to get the manually specified rebin. It
%will have to be a lot cleverer than that used in e.g. horace_combine,
%because we have to be able to sense multiple rebins, such as
%[lo1,step1,hi1],[],[lo3,step3,hi3] etc.
ismanual=false;
if manspec==nummax
    try
        lostephi=get(handles.Rebin_lostephi_edit,'String');
        %must strip out square brackets, if user has inserted them:
        s1=strfind(lostephi,'['); s2=strfind(lostephi,']');
        if isempty(s1) && isempty(s2)
            lostephinew{1}=strread(lostephi,'%f','delimiter',',');
        elseif ~isempty(s1) && ~isempty(s2)
            if length(s1)~=length(s2)
                mess1='Ensure manual rebinning is of form [lo1,step1,hi1], [step], or []';
                mess2=' and that the number of inputs is the same as the object dimensionality';
                set(handles.message_info_text,'String',char({mess_initialise,mess1,mess2}));
                guidata(gcbo,handles);
                return;
            elseif length(s1)~=ndims1
                mess1='Number of binning arguments must match the dimensionality of object to be rebinned';
                set(handles.message_info_text,'String',char({mess_initialise,mess1}));
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
            set(handles.message_info_text,'String',char({mess_initialise,mess1,mess2}));
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
                set(handles.message_info_text,'String',char({mess_initialise,mess1,mess2}));
                guidata(gcbo,handles);
            end
        end
    catch
        mess1='Formatting error of manual rebinning entries';
        mess2='Ensure they are of the form [lo,step,hi], [step], or [], and are numeric';
        set(handles.message_info_text,'String',char({mess_initialise,mess1,mess2}));
        guidata(gcbo,handles);
        return;
    end    
end
 
%====
if isempty(outobjname)
    mess='Provide a name for the output object that will be created by combine operation';
    set(handles.message_info_text,'String',char({mess_initialise,mess}));
    guidata(gcbo,handles);
    return;
end
%
testexp=regexpi(outobjname,'[A-Z]');
if testexp(1)~=1
    mess='The first character of the output name must be a letter, not a number or symbol';
    set(handles.message_info_text,'String',char({mess_initialise,mess}));
    guidata(gcbo,handles);
    return;
end

%====
if out_to_file==get(handles.Rebin_outfile_radiobutton,'Max')
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
    set(handles.message_info_text,'String',char({mess_initialise,mess}));
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
    mess1='Object to be rebinned is d2d -- using "shoelace" rebinning algorithm';
    mess2='Be patient -- this can be quite slow!';
    set(handles.message_info_text,'String',char({mess_initialise,mess1,mess2}));
    guidata(gcbo,handles);
else
    mess1='Object to rebin must either be sqw-type, or be dnd of dimensionality less than 3';
    mess2='No rebin performed';
    set(handles.message_info_text,'String',char({mess_initialise,mess1,mess2}));
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
    set(handles.message_info_text,'String',char({mess_initialise,mess1,mess2}));
    guidata(gcbo,handles);
    return;
end
    
    
assignin('base',outobjname,out);
set(handles.message_info_text,'String',char({mess_initialise,'Success!'}));
guidata(gcbo,handles);


% --- Executes on button press in Sym_midpoint_radiobutton.
function Sym_midpoint_radiobutton_Callback(hObject, eventdata, handles)
% hObject    handle to Sym_midpoint_radiobutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Sym_midpoint_radiobutton

button_state=get(hObject,'Value');
if button_state==get(hObject,'Max');%button is pressed
    set(handles.Sym_plane_radiobutton,'Value',0);
end
guidata(gcbo, handles);



function Sym_midpoint_edit_Callback(hObject, eventdata, handles)
% hObject    handle to Sym_midpoint_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Sym_midpoint_edit as text
%        str2double(get(hObject,'String')) returns contents of Sym_midpoint_edit as a double


% --- Executes during object creation, after setting all properties.
function Sym_midpoint_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Sym_midpoint_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Sym_plane_radiobutton.
function Sym_plane_radiobutton_Callback(hObject, eventdata, handles)
% hObject    handle to Sym_plane_radiobutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Sym_plane_radiobutton

button_state=get(hObject,'Value');
if button_state==get(hObject,'Max');%button is pressed
    set(handles.Sym_midpoint_radiobutton,'Value',0);
end
guidata(gcbo, handles);


function Sym_v1_edit_Callback(hObject, eventdata, handles)
% hObject    handle to Sym_v1_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Sym_v1_edit as text
%        str2double(get(hObject,'String')) returns contents of Sym_v1_edit as a double


% --- Executes during object creation, after setting all properties.
function Sym_v1_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Sym_v1_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Sym_v2_edit_Callback(hObject, eventdata, handles)
% hObject    handle to Sym_v2_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Sym_v2_edit as text
%        str2double(get(hObject,'String')) returns contents of Sym_v2_edit as a double


% --- Executes during object creation, after setting all properties.
function Sym_v2_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Sym_v2_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Sym_v3_edit_Callback(hObject, eventdata, handles)
% hObject    handle to Sym_v3_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Sym_v3_edit as text
%        str2double(get(hObject,'String')) returns contents of Sym_v3_edit as a double


% --- Executes during object creation, after setting all properties.
function Sym_v3_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Sym_v3_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Sym_outobj_edit_Callback(hObject, eventdata, handles)
% hObject    handle to Sym_outobj_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Sym_outobj_edit as text
%        str2double(get(hObject,'String')) returns contents of Sym_outobj_edit as a double


% --- Executes during object creation, after setting all properties.
function Sym_outobj_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Sym_outobj_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Sym_outfile_radiobutton.
function Sym_outfile_radiobutton_Callback(hObject, eventdata, handles)
% hObject    handle to Sym_outfile_radiobutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Sym_outfile_radiobutton



function Sym_outfile_edit_Callback(hObject, eventdata, handles)
% hObject    handle to Sym_outfile_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Sym_outfile_edit as text
%        str2double(get(hObject,'String')) returns contents of Sym_outfile_edit as a double


% --- Executes during object creation, after setting all properties.
function Sym_outfile_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Sym_outfile_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Sym_outfile_browse_pushbutton.
function Sym_outfile_browse_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to Sym_outfile_browse_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[save_filename,save_pathname,FilterIndex] = uiputfile({'*.sqw';'*.d0d';'*.d1d';'*.d2d';...
    '*.d3d';'*.d4d';'*.*'},'Save As');

if ischar(save_pathname) && ischar(save_filename)
    %i.e. the cancel button was not pressed
    set(handles.Sym_outfile_edit,'String',[save_pathname,save_filename]);
    guidata(gcbo,handles);
end


% --- Executes on button press in Sym_symmetrise_pushbutton.
function Sym_symmetrise_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to Sym_symmetrise_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Clear error message
set(handles.message_info_text,'String','');
guidata(gcbo,handles);
drawnow;

datetime=fix(clock);
timenow=datetime(4:end);
timestring=[num2str(timenow(1)),':',num2str(timenow(2)),':',num2str(timenow(3))];
mess_initialise=['Symmetrise started at ',timestring,'...'];

outobjname=get(handles.Sym_outobj_edit,'String');
outfilename=get(handles.Sym_outfile_edit,'String');
out_to_file=get(handles.Sym_outfile_radiobutton,'Value');
obj_to_cut='win';

if isfield(handles,'w_in')
    win=handles.w_in;
    if numel(win)~=1
        mess='Object selected is an array of objects. Symmetrisation not yet implemented for arrays -- symmetrisation not performed';
        set(handles.message_info_text,'String',char({mess_initialise,mess}));
        guidata(gcbo,handles);
        return;
    end
    ndims=dimensions(win);
else
    mess='No valid object selected -- symmetrisation not performed';
    set(handles.message_info_text,'String',char({mess_initialise,mess}));
    guidata(gcbo,handles);
    return;
end

%===
midspec=get(handles.Sym_midpoint_radiobutton,'Value');
midmax=get(handles.Sym_midpoint_radiobutton,'Max');
planespec=get(handles.Sym_plane_radiobutton,'Value');
planemax=get(handles.Sym_plane_radiobutton,'Max');

ismid=false;
if midspec==midmax
    try
        midpoint=get(handles.Sym_midpoint_edit,'String');
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
            set(handles.message_info_text,'String',char({mess_initialise,mess1}));
            guidata(gcbo,handles);
            return;
        end
        %
        if ~all(isnan(midpointnew)) && numel(midpointnew)==ndims
            ismid=true;
            midpointnew=reshape(midpointnew,1,numel(midpointnew));
        elseif numel(midpointnew)~=ndims
            mess1='Ensure midpoint is of form [val] for 1d, or [val_x,val_y] for 2d';
            set(handles.message_info_text,'String',char({mess_initialise,mess1}));
            guidata(gcbo,handles);
            return;
        end
    catch
        mess1='Formatting error of symmetrisation midpoint entry';
        mess2='Ensure it is of the form [val] for 1d, or [val_x,val_y] for 2d, and is numeric';
        set(handles.message_info_text,'String',char({mess_initialise,mess1,mess2}));
        guidata(gcbo,handles);
        return;
    end            
else
    %we have a reflection plane specified.
    %==
    try
        v1=get(handles.Sym_v1_edit,'String');
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
            set(handles.message_info_text,'String',char({mess_initialise,mess1}));
            guidata(gcbo,handles);
            return;
        end
        if numel(v1new)~=3
            mess1='Ensure v1 is of form [a,b,c]';
            set(handles.message_info_text,'String',char({mess_initialise,mess1}));
            guidata(gcbo,handles);
            return;
        end
        %==
        v2=get(handles.Sym_v2_edit,'String');
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
            set(handles.message_info_text,'String',char({mess_initialise,mess1}));
            guidata(gcbo,handles);
            return;
        end
        if numel(v2new)~=3
            mess1='Ensure v2 is of form [a,b,c]';
            set(handles.message_info_text,'String',char({mess_initialise,mess1}));
            guidata(gcbo,handles);
            return;
        end
        %==
        %Case for v3 is slightly different
        v3=get(handles.Sym_v3_edit,'String');

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
                set(handles.message_info_text,'String',char({mess_initialise,mess1}));
                guidata(gcbo,handles);
                return;
            end
            if numel(v3new)~=3
                mess1='Ensure v3 is of form [a,b,c]';
                set(handles.message_info_text,'String',char({mess_initialise,mess1}));
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
    catch
        mess1='Formatting error of symmetrisation vectors';
        mess2='Ensure they are all of the form [qh,qk,ql], and are numeric';
        set(handles.message_info_text,'String',char({mess_initialise,mess1,mess2}));
        guidata(gcbo,handles);
        return;
    end           
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
    set(handles.message_info_text,'String',char({mess_initialise,mess}));
    guidata(gcbo,handles);
    return;
end

%====
%Recall we cannot use the midpoint arg in for sqw-type data:
if is_sqw_type(sqw(win)) && ismid
    mess='For sqw objects you can only use a specified plane to symmetrise, not a midpoint';
    set(handles.message_info_text,'String',char({mess_initialise,mess}));
    guidata(gcbo,handles);
    return;
end

%======
%====
if isempty(outobjname)
    mess='Provide a name for the output object that will be created by symmetrise operation';
    set(handles.message_info_text,'String',char({mess_initialise,mess}));
    guidata(gcbo,handles);
    return;
end
%
testexp=regexpi(outobjname,'[A-Z]');
if testexp(1)~=1
    mess='The first character of the output name must be a letter, not a number or symbol';
    set(handles.message_info_text,'String',char({mess_initialise,mess}));
    guidata(gcbo,handles);
    return;
end
%====
if out_to_file==get(handles.Sym_outfile_radiobutton,'Max')
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
    set(handles.message_info_text,'String',char({mess_initialise,mess1,mess2}));
    guidata(gcbo,handles);
    return;
end
    
    
assignin('base',outobjname,out);
set(handles.message_info_text,'String',char({mess_initialise,'Success!'}));
guidata(gcbo,handles);







% --- Executes on selection change in Comb_obj2_popupmenu.
function Comb_obj2_popupmenu_Callback(hObject, eventdata, handles)
% hObject    handle to Comb_obj2_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns Comb_obj2_popupmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Comb_obj2_popupmenu

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
    set(handles.Comb_obj2_popupmenu,'String','No objects to select');
    guidata(gcbo, handles);
    return%if no objects that can be plotted or cut are in the workspace
    %we must exit this function
end

%drawnow;
set(handles.Comb_obj2_popupmenu,'String',cellofvars);
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
handles.w_in2_comb=w_in2;%store the object in the handles structure

guidata(gcbo,handles);




% --- Executes during object creation, after setting all properties.
function Comb_obj2_popupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Comb_obj2_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Comb_tolerance_radiobutton.
function Comb_tolerance_radiobutton_Callback(hObject, eventdata, handles)
% hObject    handle to Comb_tolerance_radiobutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Comb_tolerance_radiobutton



function Comb_tolerance_edit_Callback(hObject, eventdata, handles)
% hObject    handle to Comb_tolerance_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Comb_tolerance_edit as text
%        str2double(get(hObject,'String')) returns contents of Comb_tolerance_edit as a double


% --- Executes during object creation, after setting all properties.
function Comb_tolerance_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Comb_tolerance_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Comb_outobj_edit_Callback(hObject, eventdata, handles)
% hObject    handle to Comb_outobj_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Comb_outobj_edit as text
%        str2double(get(hObject,'String')) returns contents of Comb_outobj_edit as a double


% --- Executes during object creation, after setting all properties.
function Comb_outobj_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Comb_outobj_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Comb_outfile_radiobutton.
function Comb_outfile_radiobutton_Callback(hObject, eventdata, handles)
% hObject    handle to Comb_outfile_radiobutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Comb_outfile_radiobutton



function Comb_outfile_edit_Callback(hObject, eventdata, handles)
% hObject    handle to Comb_outfile_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Comb_outfile_edit as text
%        str2double(get(hObject,'String')) returns contents of Comb_outfile_edit as a double


% --- Executes during object creation, after setting all properties.
function Comb_outfile_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Comb_outfile_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Comb_outfile_browse_pushbutton.
function Comb_outfile_browse_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to Comb_outfile_browse_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[save_filename,save_pathname,FilterIndex] = uiputfile({'*.sqw';'*.d0d';'*.d1d';'*.d2d';...
    '*.d3d';'*.d4d';'*.*'},'Save As');

if ischar(save_pathname) && ischar(save_filename)
    %i.e. the cancel button was not pressed
    set(handles.Comb_outfile_edit,'String',[save_pathname,save_filename]);
    guidata(gcbo,handles);
end


% --- Executes on button press in Comb_combine_pushbutton.
function Comb_combine_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to Comb_combine_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Clear error message
set(handles.message_info_text,'String','');
guidata(gcbo,handles);
drawnow;

datetime=fix(clock);
timenow=datetime(4:end);
timestring=[num2str(timenow(1)),':',num2str(timenow(2)),':',num2str(timenow(3))];
mess_initialise=['Combine started at ',timestring,'...'];


outobjname=get(handles.Comb_outobj_edit,'String');
outfilename=get(handles.Comb_outfile_edit,'String');
out_to_file=get(handles.Comb_outfile_radiobutton,'Value');
obj_to_cut='win1';

if isfield(handles,'w_in')
    win1=handles.w_in;
    if numel(win1)~=1
        mess='Object #1 is an array of objects. Combine not yet implemented for this -- operation not performed';
        set(handles.message_info_text,'String',char({mess_initialise,mess}));
        guidata(gcbo,handles);
        return;
    end    
    ndims1=dimensions(win1);
else
    mess='No valid object#1 selected -- operation not performed';
    set(handles.message_info_text,'String',char({mess_initialise,mess}));
    guidata(gcbo,handles);
    return;
end

if isfield(handles,'w_in2_comb')
    win2=handles.w_in2_comb;
    if numel(win2)~=1
        mess='Object #2 is an array of objects. Combine not yet implemented for this -- operation not performed';
        set(handles.message_info_text,'String',char({mess_initialise,mess}));
        guidata(gcbo,handles);
        return;
    end 
    ndims2=dimensions(win2);
    obj_to_cut2='win2';
else
    mess='No valid object#2 selected -- no operation performed';
    set(handles.message_info_text,'String',char({mess_initialise,mess}));
    guidata(gcbo,handles);
    return;
end

tolspec=get(handles.Comb_tolerance_radiobutton,'Value');
nummax=get(handles.Comb_tolerance_radiobutton,'Max');

istol=false;
if tolspec==nummax
    try
        tol=get(handles.Comb_tolerance_edit,'String');
        %tol=str2mat(tol);
        %must strip out square brackets, if user has inserted them:
        s1=strfind(tol,'['); s2=strfind(tol,']');
        if isempty(s1) && isempty(s2)
            tolnew=strread(tol,'%f','delimiter',',');
        elseif ~isempty(s1) && ~isempty(s2)
            tol=tol(s1+1:s2-1);
            tolnew=strread(tol,'%f','delimiter',',');
        else
            mess1='Ensure tolerance is of form [tol1,tol2,...], depending on the dimensionality';
            set(handles.message_info_text,'String',mess1);
            guidata(gcbo,handles);
            return;
        end

        if ~all(isnan(tolnew)) && numel(tolnew)==ndims1
            istol=true;
        elseif numel(tolnew)~=ndims1
            mess1='Ensure tolerance is of form [tol1,tol2,...], depending on the dimensionality';
            set(handles.message_info_text,'String',mess1);
            guidata(gcbo,handles);
        end
    catch
        mess1='Formatting error of tolerance entries';
        mess2='Ensure they are of the form [tolx], [tolx,toly], etc... , and are numeric';
        set(handles.message_info_text,'String',char({mess_initialise,mess1,mess2}));
        guidata(gcbo,handles);
        return;
    end
end
 
%====
if isempty(outobjname)
    mess='Provide a name for the output object that will be created by combine operation';
    set(handles.message_info_text,'String',char({mess_initialise,mess}));
    guidata(gcbo,handles);
    return;
end
%
testexp=regexpi(outobjname,'[A-Z]');
if testexp(1)~=1
    mess='The first character of the output name must be a letter, not a number or symbol';
    set(handles.message_info_text,'String',char({mess_initialise,mess}));
    guidata(gcbo,handles);
    return;
end
%====
if out_to_file==get(handles.Comb_outfile_radiobutton,'Max')
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
if (ndims1 ~= ndims2)
    mess='Objects selected have different dimensionality -- cannot do combine operation';
    set(handles.message_info_text,'String',char({mess_initialise,mess}));
    guidata(gcbo,handles);
    return;
end

%Work out which of the combine functions is required:
if is_sqw_type(sqw(win1)) && is_sqw_type(sqw(win2))
    funcstr='combine_sqw';
elseif is_sqw_type(sqw(win1)) && ~is_sqw_type(sqw(win2))
    mess='1st object is sqw type, but second is not -- cannot do combine operation';
    set(handles.message_info_text,'String',char({mess_initialise,mess}));
    guidata(gcbo,handles);
    return;
elseif ndims1==1
    funcstr='combine_horace_1d';
elseif ndims1==2
    funcstr='combine_horace_2d';
else
    mess='Both selected objects must either be sqw-type, or be dnd of dimensionality less than 3';
    set(handles.message_info_text,'String',char({mess_initialise,mess}));
    guidata(gcbo,handles);
    return;
end

%Now we execute the combine operation:
try
    if ~saveafile
        if ~istol
            out=eval([funcstr,'(',obj_to_cut,',',obj_to_cut2,');']);
        else
            out=eval([funcstr,'(',obj_to_cut,',',obj_to_cut2,',[',num2str(tol),']);']);
        end
    elseif saveafile && strcmp(outfilename,'-save')
        if ~istol
            out=eval([funcstr,'(',obj_to_cut,',',obj_to_cut2,');']);
        else
            out=eval([funcstr,'(',obj_to_cut,',',obj_to_cut2,',[',num2str(tol),']);']);
        end
        save(out);
    else
        if ~istol
            out=eval([funcstr,'(',obj_to_cut,',',obj_to_cut2,');']);
        else
            out=eval([funcstr,'(',obj_to_cut,',',obj_to_cut2,',[',num2str(tol),']);']);
        end
        save(out,outfilename);
    end
    
catch
    the_err=lasterror;
    emess=the_err.message;
    nchar=strfind(emess,['at ',num2str(the_err.stack(1).line)]);
    mess1='No combine performed';
    mess2=emess(nchar+9:end);
    set(handles.message_info_text,'String',char({mess_initialise,mess1,mess2}));
    guidata(gcbo,handles);
    return;
end
    
    
assignin('base',outobjname,out);
set(handles.message_info_text,'String',char({mess_initialise,'Success!'}));
guidata(gcbo,handles);







function Rep_outobj_edit_Callback(hObject, eventdata, handles)
% hObject    handle to Rep_outobj_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Rep_outobj_edit as text
%        str2double(get(hObject,'String')) returns contents of Rep_outobj_edit as a double


% --- Executes during object creation, after setting all properties.
function Rep_outobj_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Rep_outobj_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in Rep_obj2_popupmenu.
function Rep_obj2_popupmenu_Callback(hObject, eventdata, handles)
% hObject    handle to Rep_obj2_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns Rep_obj2_popupmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Rep_obj2_popupmenu


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
    set(handles.Rep_obj2_popupmenu,'String','No objects to select');
    guidata(gcbo, handles);
    return%if no objects that can be plotted or cut are in the workspace
    %we must exit this function
end

%drawnow;
set(handles.Rep_obj2_popupmenu,'String',cellofvars);
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
handles.w_in2_rep=w_in2;%store the object in the handles structure

guidata(gcbo,handles);




% --- Executes during object creation, after setting all properties.
function Rep_obj2_popupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Rep_obj2_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Rep_outfile_radiobutton.
function Rep_outfile_radiobutton_Callback(hObject, eventdata, handles)
% hObject    handle to Rep_outfile_radiobutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Rep_outfile_radiobutton



function Rep_outfile_edit_Callback(hObject, eventdata, handles)
% hObject    handle to Rep_outfile_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Rep_outfile_edit as text
%        str2double(get(hObject,'String')) returns contents of Rep_outfile_edit as a double


% --- Executes during object creation, after setting all properties.
function Rep_outfile_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Rep_outfile_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Rep_outfile_browse_pushbutton.
function Rep_outfile_browse_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to Rep_outfile_browse_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[save_filename,save_pathname,FilterIndex] = uiputfile({'*.sqw';'*.d0d';'*.d1d';'*.d2d';...
    '*.d3d';'*.d4d';'*.*'},'Save As');

if ischar(save_pathname) && ischar(save_filename)
    %i.e. the cancel button was not pressed
    set(handles.Rep_outfile_edit,'String',[save_pathname,save_filename]);
    guidata(gcbo,handles);
end


% --- Executes on button press in Rep_replicate_pushbutton.
function Rep_replicate_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to Rep_replicate_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Clear error message
set(handles.message_info_text,'String','');
guidata(gcbo,handles);
drawnow;

datetime=fix(clock);
timenow=datetime(4:end);
timestring=[num2str(timenow(1)),':',num2str(timenow(2)),':',num2str(timenow(3))];
mess_initialise=['Replicate started at ',timestring,'...'];


outobjname=get(handles.Rep_outobj_edit,'String');
outfilename=get(handles.Rep_outfile_edit,'String');
out_to_file=get(handles.Rep_outfile_radiobutton,'Value');
obj_to_cut='win1';

if isfield(handles,'w_in')
    win1=handles.w_in;
    if numel(win1)~=1
        mess='Object selected for replication is an array of objects. Replication not yet implemented for arrays -- no replication performed';
        set(handles.message_info_text,'String',char({mess_initialise,mess}));
        guidata(gcbo,handles);
        return;
    end
    ndims1=dimensions(win1);
else
    mess='No valid object#1 selected -- no replication performed';
    set(handles.message_info_text,'String',char({mess_initialise,mess}));
    guidata(gcbo,handles);
    return;
end

if ndims1>3.1
    mess='Object #1 is 4-dimensional -- cannot replicate';
    set(handles.message_info_text,'String',char({mess_initialise,mess}));
    guidata(gcbo,handles);
    return;
end

if isfield(handles,'w_in2_rep')
    win2=handles.w_in2_rep;
    if numel(win2)~=1
        mess='Object selected for template is an array of objects. Replication not yet implemented for arrays -- no replication performed';
        set(handles.message_info_text,'String',char({mess_initialise,mess}));
        guidata(gcbo,handles);
        return;
    end
    ndims2=dimensions(win2);
    obj_to_cut2='win2';
else
    mess='No valid object#2 selected -- no repliation performed';
    set(handles.message_info_text,'String',char({mess_initialise,mess}));
    guidata(gcbo,handles);
    return;
end

if ndims2<=ndims1
    mess='Object #2 must have higher dimensionality than object #1 -- no replication performed';
    set(handles.message_info_text,'String',char({mess_initialise,mess}));
    guidata(gcbo,handles);
    return;
end

%====
if isempty(outobjname)
    mess='Provide a name for the output object that will be created by replication';
    set(handles.message_info_text,'String',char({mess_initialise,mess}));
    guidata(gcbo,handles);
    return;
end
%
testexp=regexpi(outobjname,'[A-Z]');
if testexp(1)~=1
    mess='The first character of the output name must be a letter, not a number or symbol';
    set(handles.message_info_text,'String',char({mess_initialise,mess}));
    guidata(gcbo,handles);
    return;
end
%====
if out_to_file==get(handles.Rep_outfile_radiobutton,'Max')
    saveafile=true;
else
    saveafile=false;
end
%===
if saveafile && isempty(outfilename)
    outfilename='-save';
end
%===
sqw_flag=false;
if is_sqw_type(sqw(win1))
    sqw_flag=true;
    if ndims1==0
        obj_to_cut_dnd=d0d(win1);
    elseif ndims1==1
        obj_to_cut_dnd=d1d(win1);
    elseif ndims1==2
        obj_to_cut_dnd=d2d(win1);
    elseif ndims1==3
        obj_to_cut_dnd=d3d(win1);
    else
        mess='Object #1 is 4-dimensional -- cannot replicate';
        set(handles.message_info_text,'String',char({mess_initialise,mess}));
        guidata(gcbo,handles);
        return;
    end
end


%Now we execute the replication:
try
    if ~sqw_flag
        if ~saveafile
            out=eval(['replicate(',obj_to_cut,',',obj_to_cut2,');']);
        elseif saveafile && strcmp(outfilename,'-save')
            out=eval(['replicate(',obj_to_cut,',',obj_to_cut2,');']);
            save(out);
        else
            out=eval(['replicate(',obj_to_cut,',',obj_to_cut2,');']);
            save(out,outfilename);
        end
    else
        if ~saveafile
            out=eval(['replicate(',obj_to_cut_dnd,',',obj_to_cut2,');']);
        elseif saveafile && strcmp(outfilename,'-save')
            out=eval(['replicate(',obj_to_cut_dnd,',',obj_to_cut2,');']);
            save(out);
        else
            out=eval(['replicate(',obj_to_cut_dnd,',',obj_to_cut2,');']);
            save(out,outfilename);
        end
    end     
catch
    the_err=lasterror;
    emess=the_err.message;
    nchar=strfind(emess,['at ',num2str(the_err.stack(1).line)]);
    mess1='No replication performed';
    mess2=emess(nchar+9:end);
    set(handles.message_info_text,'String',char({mess_initialise,mess1,mess2}));
    guidata(gcbo,handles);
    return;
end
    
if ~sqw_flag    
    assignin('base',outobjname,out);
    set(handles.message_info_text,'String',char({mess_initialise,'Success!'}));
    guidata(gcbo,handles);
else
    assignin('base',outobjname,out);
    mess=['Replication successfully performed, however output is dnd-type, since '...
        'replication of sqw-type objects is not possible'];
    set(handles.message_info_text,'String',char({mess_initialise,mess}));
    guidata(gcbo,handles);
end







function Bose_temp_edit_Callback(hObject, eventdata, handles)
% hObject    handle to Bose_temp_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Bose_temp_edit as text
%        str2double(get(hObject,'String')) returns contents of Bose_temp_edit as a double


% --- Executes during object creation, after setting all properties.
function Bose_temp_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Bose_temp_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Bose_outobj_edit_Callback(hObject, eventdata, handles)
% hObject    handle to Bose_outobj_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Bose_outobj_edit as text
%        str2double(get(hObject,'String')) returns contents of Bose_outobj_edit as a double


% --- Executes during object creation, after setting all properties.
function Bose_outobj_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Bose_outobj_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Bose_outfile_radiobutton.
function Bose_outfile_radiobutton_Callback(hObject, eventdata, handles)
% hObject    handle to Bose_outfile_radiobutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Bose_outfile_radiobutton



function Bose_outfile_edit_Callback(hObject, eventdata, handles)
% hObject    handle to Bose_outfile_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Bose_outfile_edit as text
%        str2double(get(hObject,'String')) returns contents of Bose_outfile_edit as a double


% --- Executes during object creation, after setting all properties.
function Bose_outfile_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Bose_outfile_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Bose_outfile_browse_pushbutton.
function Bose_outfile_browse_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to Bose_outfile_browse_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[save_filename,save_pathname,FilterIndex] = uiputfile({'*.sqw';'*.d0d';'*.d1d';'*.d2d';...
    '*.d3d';'*.d4d';'*.*'},'Save As');

if ischar(save_pathname) && ischar(save_filename)
    %i.e. the cancel button was not pressed
    set(handles.Bose_outfile_edit,'String',[save_pathname,save_filename]);
    guidata(gcbo,handles);
end



% --- Executes on button press in Bose_bose_pushbutton.
function Bose_bose_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to Bose_bose_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Clear error message
set(handles.message_info_text,'String','');
guidata(gcbo,handles);
drawnow;

datetime=fix(clock);
timenow=datetime(4:end);
timestring=[num2str(timenow(1)),':',num2str(timenow(2)),':',num2str(timenow(3))];
mess_initialise=['Bose correction started at ',timestring,'...'];

outobjname=get(handles.Bose_outobj_edit,'String');
outfilename=get(handles.Bose_outfile_edit,'String');
temperature=get(handles.Bose_temp_edit,'String');
out_to_file=get(handles.Bose_outfile_radiobutton,'Value');
obj_to_cut='win1';

if isfield(handles,'w_in')
    win1=handles.w_in;
    %ndims1=dimensions(win1);
else
    mess='No valid object selected -- no Bose correction performed';
    set(handles.message_info_text,'String',char({mess_initialise,mess}));
    guidata(gcbo,handles);
    return;
end

%====
if isempty(outobjname)
    mess='Provide a name for the output object that will be created by Bose correction';
    set(handles.message_info_text,'String',char({mess_initialise,mess}));
    guidata(gcbo,handles);
    return;
end
%
testexp=regexpi(outobjname,'[A-Z]');
if testexp(1)~=1
    mess='The first character of the output name must be a letter, not a number or symbol';
    set(handles.message_info_text,'String',char({mess_initialise,mess}));
    guidata(gcbo,handles);
    return;
end
%====
if isempty(temperature)
    mess='Provide a temperature to allow correction';
    set(handles.message_info_text,'String',char({mess_initialise,mess}));
    guidata(gcbo,handles);
    return;
end
%====
if isnan(str2double(temperature))
    mess='Provide a valid temperature';
    set(handles.message_info_text,'String',char({mess_initialise,mess}));
    guidata(gcbo,handles);
    return;
elseif temperature<=0
    mess='Provide a valid temperature';
    set(handles.message_info_text,'String',char({mess_initialise,mess}));
    guidata(gcbo,handles);
    return;
end
%====
if out_to_file==get(handles.Bose_outfile_radiobutton,'Max')
    saveafile=true;
else
    saveafile=false;
end
%===
if saveafile && isempty(outfilename)
    outfilename='-save';
end
%===

%Now we execute the bose factor correction:
try
    if ~saveafile
            out=eval(['bose(',obj_to_cut,',',temperature,');']);
    elseif saveafile && strcmp(outfilename,'-save')
        out=eval(['bose(',obj_to_cut,',',temperature,');']);
        save(out);
    else
        out=eval(['bose(',obj_to_cut,',',temperature,');']);
        save(out,outfilename);
    end
catch
    the_err=lasterror;
    emess=the_err.message;
    nchar=strfind(emess,['at ',num2str(the_err.stack(1).line)]);
    mess1='No bose correction performed';
    mess2=emess(nchar+9:end);
    set(handles.message_info_text,'String',char({mess_initialise,mess1,mess2}));
    guidata(gcbo,handles);
    return;
end
    
assignin('base',outobjname,out);
set(handles.message_info_text,'String',char({mess_initialise,'Success!'}));
guidata(gcbo,handles);







% --- Executes on selection change in Bin_function_popupmenu.
function Bin_function_popupmenu_Callback(hObject, eventdata, handles)
% hObject    handle to Bin_function_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns Bin_function_popupmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Bin_function_popupmenu

str = get(hObject, 'String');
val = get(hObject,'Value');
funcstr=str{val};

handles.bin_funcstr=funcstr;

guidata(gcbo,handles);


% --- Executes during object creation, after setting all properties.
function Bin_function_popupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Bin_function_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Bin_outobj_edit_Callback(hObject, eventdata, handles)
% hObject    handle to Bin_outobj_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Bin_outobj_edit as text
%        str2double(get(hObject,'String')) returns contents of Bin_outobj_edit as a double


% --- Executes during object creation, after setting all properties.
function Bin_outobj_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Bin_outobj_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Bin_outfile_radiobutton.
function Bin_outfile_radiobutton_Callback(hObject, eventdata, handles)
% hObject    handle to Bin_outfile_radiobutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Bin_outfile_radiobutton



function Bin_outfile_edit_Callback(hObject, eventdata, handles)
% hObject    handle to Bin_outfile_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Bin_outfile_edit as text
%        str2double(get(hObject,'String')) returns contents of Bin_outfile_edit as a double


% --- Executes during object creation, after setting all properties.
function Bin_outfile_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Bin_outfile_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Bin_outfile_browse_pushbutton.
function Bin_outfile_browse_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to Bin_outfile_browse_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[save_filename,save_pathname,FilterIndex] = uiputfile({'*.sqw';'*.d0d';'*.d1d';'*.d2d';...
    '*.d3d';'*.d4d';'*.*'},'Save As');

if ischar(save_pathname) && ischar(save_filename)
    %i.e. the cancel button was not pressed
    set(handles.Bin_outfile_edit,'String',[save_pathname,save_filename]);
    guidata(gcbo,handles);
end


% --- Executes on selection change in Bin_obj2_popupmenu.
function Bin_obj2_popupmenu_Callback(hObject, eventdata, handles)
% hObject    handle to Bin_obj2_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns Bin_obj2_popupmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Bin_obj2_popupmenu

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
    set(handles.Bin_obj2_popupmenu,'String','No objects to select');
    guidata(gcbo, handles);
    return%if no objects that can be plotted or cut are in the workspace
    %we must exit this function
end

%drawnow;
set(handles.Bin_obj2_popupmenu,'String',cellofvars);
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
handles.w_in2_bin=w_in2;%store the object in the handles structure

guidata(gcbo,handles);


% --- Executes during object creation, after setting all properties.
function Bin_obj2_popupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Bin_obj2_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Bin_number_edit_Callback(hObject, eventdata, handles)
% hObject    handle to Bin_number_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Bin_number_edit as text
%        str2double(get(hObject,'String')) returns contents of Bin_number_edit as a double


% --- Executes during object creation, after setting all properties.
function Bin_number_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Bin_number_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Bin_obj_radiobutton.
function Bin_obj_radiobutton_Callback(hObject, eventdata, handles)
% hObject    handle to Bin_obj_radiobutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Bin_obj_radiobutton

button_state=get(hObject,'Value');
if button_state==get(hObject,'Max');%button is pressed
    set(handles.Bin_number_radiobutton,'Value',0);
end
guidata(gcbo, handles);


% --- Executes on button press in Bin_number_radiobutton.
function Bin_number_radiobutton_Callback(hObject, eventdata, handles)
% hObject    handle to Bin_number_radiobutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Bin_number_radiobutton

button_state=get(hObject,'Value');
if button_state==get(hObject,'Max');%button is pressed
    set(handles.Bin_obj_radiobutton,'Value',0);
end
guidata(gcbo, handles);


% --- Executes on button press in Bin_operate_pushbutton.
function Bin_operate_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to Bin_operate_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Clear error message
set(handles.message_info_text,'String','');
guidata(gcbo,handles);
drawnow;

datetime=fix(clock);
timenow=datetime(4:end);
timestring=[num2str(timenow(1)),':',num2str(timenow(2)),':',num2str(timenow(3))];
mess_initialise=['Binary operation started at ',timestring,'...'];

outobjname=get(handles.Bin_outobj_edit,'String');
outfilename=get(handles.Bin_outfile_edit,'String');
out_to_file=get(handles.Bin_outfile_radiobutton,'Value');
obj_to_cut='win1';

%Realise that we have to deal with some greater complexity if the first
%object is actually an array of objects
if isfield(handles,'w_in')
    win1=handles.w_in;
    if numel(win1)~=1
        for i=1:numel(win1)
            ndims1(i)=dimensions(win1(i));
        end
        if ~all(ndims1==ndims1(1))
            mess='Object#1 is an array of objects with different dimensionality -- operation not performed';
            set(handles.message_info_text,'String',char({mess_initialise,mess}));
            guidata(gcbo,handles);
            return;
        else
            ndims1=ndims1(1);
        end
    else
        ndims1=dimensions(win1);
    end
else
    mess='No valid object#1 selected -- operation not performed';
    set(handles.message_info_text,'String',char({mess_initialise,mess}));
    guidata(gcbo,handles);
    return;
end

if ~isfield(handles,'bin_funcstr')
    funcstr='minus';%default choice
    mess='Default choice of ''minus'' used for function';
    set(handles.message_info_text,'String',char({mess_initialise,mess}));
    guidata(gcbo,handles);
    pause(2);
%     return;
else
    funcstr=handles.bin_funcstr;
end

oponobj=get(handles.Bin_obj_radiobutton,'Value');
objmax=get(handles.Bin_obj_radiobutton,'Max');
oponnum=get(handles.Bin_number_radiobutton,'Value');
nummax=get(handles.Bin_number_radiobutton,'Max');
numval=get(handles.Bin_number_edit,'String');

workonobj=false;
if oponobj~=objmax && oponnum~=nummax
    mess='Select either a 2nd object (#2), or a number to operate with which to operate';
    set(handles.message_info_text,'String',char({mess_initialise,mess}));
    guidata(gcbo,handles);
    return;
elseif oponobj==objmax && oponnum~=nummax
    workonobj=true;
    if isfield(handles,'w_in2_bin')
        win2=handles.w_in2_bin;
        if numel(win2)~=1 && numel(win2)~=numel(win1)
            mess='Objects #1 and #2 are different sized arrays of objects -- operation not performed';
            set(handles.message_info_text,'String',char({mess_initialise,mess}));
            guidata(gcbo,handles);
            return;
        elseif numel(win2)~=1 && numel(win2)==numel(win1)
            %must now check that dimensions are all the same
            for i=1:numel(win2)
                if dimensions(win2(i))~=dimensions(win1(i))
                    mess='Objects #1 and #2 do not have matching dimensionality -- operation not performed';
                    set(handles.message_info_text,'String',char({mess_initialise,mess}));
                    guidata(gcbo,handles);
                    return;
                end
            end
            ndims2=dimensions(win2(1));
        elseif numel(win2)==1
            %compare aginast dimensionality of win1
            ndims2=dimensions(win2);
            if ndims2~=ndims1
                mess='Objects #1 and #2 do not have matching dimensionality -- operation not performed';
                set(handles.message_info_text,'String',char({mess_initialise,mess}));
                guidata(gcbo,handles);
                return;
            end
        else
            %throw an error
        end
        ndims2=dimensions(win2);
        obj_to_cut2='win2';
    else
        mess='No valid object#2 selected -- no operation performed';
        set(handles.message_info_text,'String',char({mess_initialise,mess}));
        guidata(gcbo,handles);
        return;
    end
elseif oponobj~=objmax && oponnum==nummax
    workonobj=false;
    if isempty(oponnum)
        mess='Choose a number with which to operate -- no operation performed yet';
        set(handles.message_info_text,'String',char({mess_initialise,mess}));
        guidata(gcbo,handles);
        return;
    end    
end

%====
if isempty(outobjname)
    mess='Provide a name for the output object that will be created by binary operation';
    set(handles.message_info_text,'String',char({mess_initialise,mess}));
    guidata(gcbo,handles);
    return;
end
%
testexp=regexpi(outobjname,'[A-Z]');
if testexp(1)~=1
    mess='The first character of the output name must be a letter, not a number or symbol';
    set(handles.message_info_text,'String',char({mess_initialise,mess}));
    guidata(gcbo,handles);
    return;
end
%====
if out_to_file==get(handles.Bin_outfile_radiobutton,'Max')
    saveafile=true;
else
    saveafile=false;
end
%===
if saveafile && isempty(outfilename)
    outfilename='-save';
end

%Need to check that the two objects being added have the same
%dimensionality!
if oponobj && (ndims1 ~= ndims2)
    mess='Objects selected have different dimensionality -- cannot do binary operation';
    set(handles.message_info_text,'String',char({mess_initialise,mess}));
    guidata(gcbo,handles);
    return;
end

%Now we execute the binary operation:
try
    if ~saveafile
        if workonobj
            out=eval([funcstr,'(',obj_to_cut,',',obj_to_cut2,');']);
        else
            out=eval([funcstr,'(',obj_to_cut,',',num2str(numval),');']);
        end
    elseif saveafile && strcmp(outfilename,'-save')
        if workonobj
            out=eval([funcstr,'(',obj_to_cut,',',obj_to_cut2,');']);
        else
            out=eval([funcstr,'(',obj_to_cut,',',num2str(numval),');']);
        end
        save(out);
    else
        if workonobj
            out=eval([funcstr,'(',obj_to_cut,',',obj_to_cut2,');']);
        else
            out=eval([funcstr,'(',obj_to_cut,',',num2str(numval),');']);
        end
        save(out,outfilename);
    end
catch
    the_err=lasterror;
    emess=the_err.message;
    nchar=strfind(emess,['at ',num2str(the_err.stack(1).line)]);
    mess1='No operation performed (formatting error?)';
    mess2=emess(nchar+9:end);
    set(handles.message_info_text,'String',char({mess_initialise,mess1,mess2}));
    guidata(gcbo,handles);
    return;
end
    
    
assignin('base',outobjname,out);
set(handles.message_info_text,'String',char({mess_initialise,'Success!'}));
guidata(gcbo,handles);



% --- Executes on selection change in Unary_func_popupmenu.
function Unary_func_popupmenu_Callback(hObject, eventdata, handles)
% hObject    handle to Unary_func_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns Unary_func_popupmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Unary_func_popupmenu

str = get(hObject, 'String');
val = get(hObject,'Value');
funcstr=str{val};

handles.un_funcstr=funcstr;

guidata(gcbo,handles);


% --- Executes during object creation, after setting all properties.
function Unary_func_popupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Unary_func_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Unary_outobj_edit_Callback(hObject, eventdata, handles)
% hObject    handle to Unary_outobj_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Unary_outobj_edit as text
%        str2double(get(hObject,'String')) returns contents of Unary_outobj_edit as a double


% --- Executes during object creation, after setting all properties.
function Unary_outobj_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Unary_outobj_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Unary_outfile_radiobutton.
function Unary_outfile_radiobutton_Callback(hObject, eventdata, handles)
% hObject    handle to Unary_outfile_radiobutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Unary_outfile_radiobutton



function Unary_outfile_edit_Callback(hObject, eventdata, handles)
% hObject    handle to Unary_outfile_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Unary_outfile_edit as text
%        str2double(get(hObject,'String')) returns contents of Unary_outfile_edit as a double


% --- Executes during object creation, after setting all properties.
function Unary_outfile_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Unary_outfile_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Unary_outfile_browse_pushbutton.
function Unary_outfile_browse_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to Unary_outfile_browse_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[save_filename,save_pathname,FilterIndex] = uiputfile({'*.sqw';'*.d0d';'*.d1d';'*.d2d';...
    '*.d3d';'*.d4d';'*.*'},'Save As');

if ischar(save_pathname) && ischar(save_filename)
    %i.e. the cancel button was not pressed
    set(handles.Unary_outfile_edit,'String',[save_pathname,save_filename]);
    guidata(gcbo,handles);
end



% --- Executes on button press in Unary_operate_pushbutton.
function Unary_operate_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to Unary_operate_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


%Clear error message
set(handles.message_info_text,'String','');
guidata(gcbo,handles);
drawnow;

datetime=fix(clock);
timenow=datetime(4:end);
timestring=[num2str(timenow(1)),':',num2str(timenow(2)),':',num2str(timenow(3))];
mess_initialise=['Unary operation started at ',timestring,'...'];

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
    mess='No valid object selected -- no operation performed';
    set(handles.message_info_text,'String',char({mess_initialise,mess}));
    guidata(gcbo,handles);
    return;
end

if ~isfield(handles,'un_funcstr')
    mess='Default choice of function ''acos'' used';
    set(handles.message_info_text,'String',char({mess_initialise,mess}));
    guidata(gcbo,handles);
    pause(2);
    %return;
    funcstr='acos';
else
    funcstr=handles.funcstr;
end

outobjname=get(handles.Unary_outobj_edit,'String');
outfilename=get(handles.Unary_outfile_edit,'String');
out_to_file=get(handles.Unary_outfile_radiobutton,'Value');
obj_to_cut='win';

%====
if isempty(outobjname)
    mess='Provide a name for the output object that will be created by unary operation';
    set(handles.message_info_text,'String',char({mess_initialise,mess}));
    guidata(gcbo,handles);
    return;
end
%
testexp=regexpi(outobjname,'[A-Z]');
if testexp(1)~=1
    mess='The first character of the output name must be a letter, not a number or symbol';
    set(handles.message_info_text,'String',char({mess_initialise,mess}));
    guidata(gcbo,handles);
    return;
end
%====
if out_to_file==get(handles.Unary_outfile_radiobutton,'Max')
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
    set(handles.message_info_text,'String',char({mess_initialise,mess1,mess2}));
    guidata(gcbo,handles);
    return;
end
    
assignin('base',outobjname,out);
set(handles.message_info_text,'String',char({mess_initialise,'Success!'}));
guidata(gcbo,handles);



% --- Executes on button press in Cutfile_rlu_1_radiobutton.
function Cutfile_rlu_1_radiobutton_Callback(hObject, eventdata, handles)
% hObject    handle to Cutfile_rlu_1_radiobutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Cutfile_rlu_1_radiobutton

button_state=get(hObject,'Value');
if button_state==get(hObject,'Max');%button is pressed
    set(handles.Cutfile_ang_1_radiobutton,'Value',0);
end
guidata(gcbo, handles);


% --- Executes on button press in Cutfile_ang_1_radiobutton.
function Cutfile_ang_1_radiobutton_Callback(hObject, eventdata, handles)
% hObject    handle to Cutfile_ang_1_radiobutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Cutfile_ang_1_radiobutton

button_state=get(hObject,'Value');
if button_state==get(hObject,'Max');%button is pressed
    set(handles.Cutfile_rlu_1_radiobutton,'Value',0);
end
guidata(gcbo, handles);


% --- Executes on button press in Cutfile_rlu_2_radiobutton.
function Cutfile_rlu_2_radiobutton_Callback(hObject, eventdata, handles)
% hObject    handle to Cutfile_rlu_2_radiobutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Cutfile_rlu_2_radiobutton

button_state=get(hObject,'Value');
if button_state==get(hObject,'Max');%button is pressed
    set(handles.Cutfile_ang_2_radiobutton,'Value',0);
end
guidata(gcbo, handles);


% --- Executes on button press in Cutfile_ang_2_radiobutton.
function Cutfile_ang_2_radiobutton_Callback(hObject, eventdata, handles)
% hObject    handle to Cutfile_ang_2_radiobutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Cutfile_ang_2_radiobutton

button_state=get(hObject,'Value');
if button_state==get(hObject,'Max');%button is pressed
    set(handles.Cutfile_rlu_2_radiobutton,'Value',0);
end
guidata(gcbo, handles);


% --- Executes on button press in Cutfile_rlu_3_radiobutton.
function Cutfile_rlu_3_radiobutton_Callback(hObject, eventdata, handles)
% hObject    handle to Cutfile_rlu_3_radiobutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Cutfile_rlu_3_radiobutton

button_state=get(hObject,'Value');
if button_state==get(hObject,'Max');%button is pressed
    set(handles.Cutfile_ang_3_radiobutton,'Value',0);
end
guidata(gcbo, handles);

% --- Executes on button press in Cutfile_ang_3_radiobutton.
function Cutfile_ang_3_radiobutton_Callback(hObject, eventdata, handles)
% hObject    handle to Cutfile_ang_3_radiobutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Cutfile_ang_3_radiobutton

button_state=get(hObject,'Value');
if button_state==get(hObject,'Max');%button is pressed
    set(handles.Cutfile_rlu_3_radiobutton,'Value',0);
end
guidata(gcbo, handles);


function Cutfile_u_edit_Callback(hObject, eventdata, handles)
% hObject    handle to Cutfile_u_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Cutfile_u_edit as text
%        str2double(get(hObject,'String')) returns contents of Cutfile_u_edit as a double


% --- Executes during object creation, after setting all properties.
function Cutfile_u_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Cutfile_u_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Cutfile_v_edit_Callback(hObject, eventdata, handles)
% hObject    handle to Cutfile_v_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Cutfile_v_edit as text
%        str2double(get(hObject,'String')) returns contents of Cutfile_v_edit as a double


% --- Executes during object creation, after setting all properties.
function Cutfile_v_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Cutfile_v_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Cutfile_w_edit_Callback(hObject, eventdata, handles)
% hObject    handle to Cutfile_w_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Cutfile_w_edit as text
%        str2double(get(hObject,'String')) returns contents of Cutfile_w_edit as a double


% --- Executes during object creation, after setting all properties.
function Cutfile_w_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Cutfile_w_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Cutfile_ax1_range_edit_Callback(hObject, eventdata, handles)
% hObject    handle to Cutfile_ax1_range_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Cutfile_ax1_range_edit as text
%        str2double(get(hObject,'String')) returns contents of Cutfile_ax1_range_edit as a double


% --- Executes during object creation, after setting all properties.
function Cutfile_ax1_range_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Cutfile_ax1_range_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Cutfile_ax2_range_edit_Callback(hObject, eventdata, handles)
% hObject    handle to Cutfile_ax2_range_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Cutfile_ax2_range_edit as text
%        str2double(get(hObject,'String')) returns contents of Cutfile_ax2_range_edit as a double


% --- Executes during object creation, after setting all properties.
function Cutfile_ax2_range_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Cutfile_ax2_range_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Cutfile_ax3_range_edit_Callback(hObject, eventdata, handles)
% hObject    handle to Cutfile_ax3_range_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Cutfile_ax3_range_edit as text
%        str2double(get(hObject,'String')) returns contents of Cutfile_ax3_range_edit as a double


% --- Executes during object creation, after setting all properties.
function Cutfile_ax3_range_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Cutfile_ax3_range_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Cutfile_ax4_range_edit_Callback(hObject, eventdata, handles)
% hObject    handle to Cutfile_ax4_range_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Cutfile_ax4_range_edit as text
%        str2double(get(hObject,'String')) returns contents of Cutfile_ax4_range_edit as a double


% --- Executes during object creation, after setting all properties.
function Cutfile_ax4_range_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Cutfile_ax4_range_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Cutfile_out_obj_edit_Callback(hObject, eventdata, handles)
% hObject    handle to Cutfile_out_obj_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Cutfile_out_obj_edit as text
%        str2double(get(hObject,'String')) returns contents of Cutfile_out_obj_edit as a double


% --- Executes during object creation, after setting all properties.
function Cutfile_out_obj_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Cutfile_out_obj_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Cutfile_out_file_radio.
function Cutfile_out_file_radio_Callback(hObject, eventdata, handles)
% hObject    handle to Cutfile_out_file_radio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Cutfile_out_file_radio



function Cutfile_out_file_edit_Callback(hObject, eventdata, handles)
% hObject    handle to Cutfile_out_file_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Cutfile_out_file_edit as text
%        str2double(get(hObject,'String')) returns contents of Cutfile_out_file_edit as a double


% --- Executes during object creation, after setting all properties.
function Cutfile_out_file_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Cutfile_out_file_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Cutfile_outfile_browse_pushbutton.
function Cutfile_outfile_browse_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to Cutfile_outfile_browse_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[save_filename,save_pathname,FilterIndex] = uiputfile({'*.sqw';'*.d0d';'*.d1d';'*.d2d';...
    '*.d3d';'*.d4d';'*.*'},'Save As');

if ischar(save_pathname) && ischar(save_filename)
    %i.e. the cancel button was not pressed
    set(handles.Cutfile_out_file_edit,'String',[save_pathname,save_filename]);
    guidata(gcbo,handles);
end



% --- Executes on button press in Cutfile_keep_pix_radiobutton.
function Cutfile_keep_pix_radiobutton_Callback(hObject, eventdata, handles)
% hObject    handle to Cutfile_keep_pix_radiobutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Cutfile_keep_pix_radiobutton


% --- Executes on button press in Cutfile_do_cut_pushbutton.
function Cutfile_do_cut_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to Cutfile_do_cut_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Clear error message
set(handles.message_info_text,'String','');
guidata(gcbo,handles);
drawnow;

datetime=fix(clock);
timenow=datetime(4:end);
timestring=[num2str(timenow(1)),':',num2str(timenow(2)),':',num2str(timenow(3))];
mess_initialise=['Cut from file started at ',timestring,'...'];

set(handles.message_info_text,'String',char({mess_initialise,'Working'}));
guidata(gcbo,handles);
pause(0.1);
drawnow;

%Clear any old variable from a previous call:
clear proj
%
%This is the most complicated bit of this GUI.
%First get that all the necessary arguments and check they have values:
filestring=get(handles.sqw_filename_edit,'String');
u=get(handles.Cutfile_u_edit,'String');
v=get(handles.Cutfile_v_edit,'String');
w=get(handles.Cutfile_w_edit,'String');
u_rlu=get(handles.Cutfile_rlu_1_radiobutton,'Value');
v_rlu=get(handles.Cutfile_rlu_2_radiobutton,'Value');
w_rlu=get(handles.Cutfile_rlu_3_radiobutton,'Value');
orth_axes=get(handles.Cutfile_orthaxes_radiobutton,'Value');
a1=get(handles.Cutfile_ax1_range_edit,'String');
a2=get(handles.Cutfile_ax2_range_edit,'String');
a3=get(handles.Cutfile_ax3_range_edit,'String');
a4=get(handles.Cutfile_ax4_range_edit,'String');
outobjname=get(handles.Cutfile_out_obj_edit,'String');
outfilename=get(handles.Cutfile_out_file_edit,'String');
keep_pixels=get(handles.Cutfile_keep_pix_radiobutton,'Value');
out_to_file=get(handles.Cutfile_out_file_radio,'Value');

if isempty(filestring)
    mess='Specify an sqw file from which to make a cut';
    set(handles.message_info_text,'String',char({mess_initialise,mess}));
    guidata(gcbo,handles);
    return;
end
%==
if isempty(u) || isempty(v)
    mess='Projection axes u and v must be specified for cut';
    set(handles.message_info_text,'String',char({mess_initialise,mess}));
    guidata(gcbo,handles);
    return;
else
    try
        u=strread(u,'%f','delimiter',',');
        v=strread(v,'%f','delimiter',',');
        if numel(u)~=3 || numel(v)~=3
            mess='u and v must comprise 3 numbers specifying h, k, and l of projection axes';
            set(handles.message_info_text,'String',char({mess_initialise,mess}));
            guidata(gcbo,handles);
            return;
        end
        if ~isempty(w)
            w=strread(w,'%f','delimiter',',');
        end
    catch
        mess='Check the format of the vectors u, v, and/or w. They must be numeric with 3 elements';
        set(handles.message_info_text,'String',char({mess_initialise,mess}));
        guidata(gcbo,handles);
        return;
    end
end
%==
angstring='';
if u_rlu==get(handles.Cutfile_rlu_1_radiobutton,'Max')
    angstring=[angstring,'r'];
else
    angstring=[angstring,'a'];
end
if v_rlu==get(handles.Cutfile_rlu_2_radiobutton,'Max')
    angstring=[angstring,'r'];
else
    angstring=[angstring,'a'];
end
if w_rlu==get(handles.Cutfile_rlu_3_radiobutton,'Max')
    angstring=[angstring,'r'];
else
    angstring=[angstring,'a'];
end
%
if orth_axes
    nonorth=0;
else
    nonorth=1;
end
%
proj.u=u'; proj.v=v';
if ~isempty(w)
    proj.w=w';
end
proj.type=angstring;
proj.nonorthogonal=nonorth;
%===
if isempty(a1) || isempty(a2) || isempty(a3) || isempty(a4)
    mess1='   Ensure binning values are entered if the form of lo,step,hi / step / lo,hi    ';
    mess2='NB: enter 0 if you wish to use intrinsic binning and entire data range along axis';
    set(handles.message_info_text,'String',char({mess_initialise,mess1,mess2}));
    guidata(gcbo,handles);
    return;
else
    try
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
            set(handles.message_info_text,'String',char({mess_initialise,mess1,mess2}));
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
            set(handles.message_info_text,'String',char({mess_initialise,mess1,mess2}));
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
            set(handles.message_info_text,'String',char({mess_initialise,mess1,mess2}));
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
            set(handles.message_info_text,'String',char({mess_initialise,mess1,mess2}));
            guidata(gcbo,handles);
            return;
        end
    catch
        mess='Check the format of the axis vectors (1-4). They must be numeric of form lo,step,hi / step / lo,hi';
        set(handles.message_info_text,'String',char({mess_initialise,mess}));
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
    set(handles.message_info_text,'String',char({mess_initialise,mess1,mess2}));
    guidata(gcbo,handles);
    return;
end

%====
if keep_pixels==get(handles.Cutfile_keep_pix_radiobutton,'Max')
    keeppix=true;
else
    keeppix=false;
end
%====
if isempty(outobjname)
    mess='Provide a name for the output object that will be created by cut';
    set(handles.message_info_text,'String',char({mess_initialise,mess}));
    guidata(gcbo,handles);
    return;
end
%
testexp=regexpi(outobjname,'[A-Z]');
if testexp(1)~=1
    mess='The first character of the output name must be a letter, not a number or symbol';
    set(handles.message_info_text,'String',char({mess_initialise,mess}));
    guidata(gcbo,handles);
    return;
end
%====
if out_to_file==get(handles.Cutfile_out_file_radio,'Max')
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
    mess1='Cut from file failed -- re-check all inputs';
    mess2=emess(nchar+9:end);
    set(handles.message_info_text,'String',char({mess_initialise,mess1,mess2}));
    guidata(gcbo,handles);
    return;
end
    
assignin('base',outobjname,out);
cc=char({mess_initialise,'Success!',['Click ''DATA IN MEMORY'' then ''Refresh List'' to make plots etc of ',outobjname]});
set(handles.message_info_text,'String',cc);
guidata(gcbo,handles);



% --- Executes on button press in refresh_list_pushbutton.
function refresh_list_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to refresh_list_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

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

%drawnow;
set(handles.obj_list_popupmenu,'String',cellofvars);
set(handles.Rebin_template_popupmenu,'String',cellofvars);
set(handles.Comb_obj2_popupmenu,'String',cellofvars);
set(handles.Rep_obj2_popupmenu,'String',cellofvars);
set(handles.Bin_obj2_popupmenu,'String',cellofvars);

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


% --- Executes on button press in smoothplot_pushbutton.
function smoothplot_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to smoothplot_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Clear error message
set(handles.message_info_text,'String','');
guidata(gcbo,handles);

datetime=fix(clock);
timenow=datetime(4:end);
timestring=[num2str(timenow(1)),':',num2str(timenow(2)),':',num2str(timenow(3))];
mess_initialise=['Smooth plotting started at ',timestring,'...'];
drawnow

if isfield(handles,'w_in');
    win=handles.w_in;
    if numel(win)~=1
        mess='No plot performed - object selected is an array of Horace objects';
        set(handles.message_info_text,'String',char({mess_initialise,mess}));
        drawnow;
        guidata(gcbo,handles);
        return;
    end
    ndims=dimensions(win);
    if is_sqw_type(sqw(win))
        mess='Object selected is sqw type -- converted to dnd to smooth';
        set(handles.message_info_text,'String',char({mess_initialise,mess}));
        drawnow;
        guidata(gcbo,handles);
        pause(2);
    end
    if ndims==1
        if isfield(handles,'plotmarker') && ~isempty(handles.plotmarker)
            amark(handles.plotmarker);
        end
        if isfield(handles,'plotcolour') && ~isempty(handles.plotcolour)
            acolor(handles.plotcolour);
        end
        if isfield(handles,'smoothwid')
            smoothing=str2double(handles.smoothwid);
        else
            smoothing=1;%default choice
        end
        [fig_handle,axis_handle,plot_handle]=dp(smooth(d1d(win),smoothing,'hat'));
        drawnow;
        handles.horacefig=fig_handle;
        set(handles.message_info_text,'String',char({mess_initialise,'Success!'}));
        drawnow;
        guidata(gcbo,handles);
    elseif ndims==2
        if isfield(handles,'smoothwid')
            smoothing=[str2double(handles.smoothwid) str2double(handles.smoothwid)];
        else
            smoothing=[1 1];%default choice
        end
        [fig_handle,axis_handle,plot_handle]=plot(smooth(d2d(win),smoothing,'hat'));
        drawnow;
        handles.horacefig=fig_handle;
        set(handles.message_info_text,'String',char({mess_initialise,'Success!'}));
        drawnow;
        guidata(gcbo,handles);
    elseif ndims==3
        if isfield(handles,'smoothwid')
            smoothing=[str2double(handles.smoothwid) str2double(handles.smoothwid) str2double(handles.smoothwid)];
        else
            smoothing=[1 1 1];%default choice
        end
        [fig_handle,axis_handle,plot_handle]=plot(smooth(d3d(win),smoothing,'hat'));
        drawnow;
        handles.horacefig=fig_handle;
        set(handles.message_info_text,'String',char({mess_initialise,'Success!'}));
        drawnow;
        guidata(gcbo,handles);
    elseif ndims==4
        mess='Selected object is 4-dimensional, so cannot plot';
        set(handles.message_info_text,'String',char({mess_initialise,mess}));
        guidata(gcbo,handles);
        return;
    end        
end

guidata(gcbo,handles);


% --- Executes on selection change in smoothing_popupmenu.
function smoothing_popupmenu_Callback(hObject, eventdata, handles)
% hObject    handle to smoothing_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns smoothing_popupmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from smoothing_popupmenu

str = get(hObject, 'String');
val = get(hObject,'Value');
%
drawnow;
if val~=1
    reqstring=str{val};
else
    reqstring='1';
end
handles.smoothwid=reqstring(1);
guidata(gcbo,handles);


% --- Executes during object creation, after setting all properties.
function smoothing_popupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to smoothing_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes on button press in choose_gen_pushbutton.
function choose_gen_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to choose_gen_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.DatafilePanel, 'Visible', 'off');
set(handles.WorkspacePanel, 'Visible', 'off');
set(handles.gen_sqw_panel, 'Visible', 'on');
drawnow;
guidata(gcbo,handles);




function gen_sqw_filename_edit_Callback(hObject, eventdata, handles)
% hObject    handle to gen_sqw_filename_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of gen_sqw_filename_edit as text
%        str2double(get(hObject,'String')) returns contents of gen_sqw_filename_edit as a double


% --- Executes during object creation, after setting all properties.
function gen_sqw_filename_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to gen_sqw_filename_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in gen_sqw_filename_browse.
function gen_sqw_filename_browse_Callback(hObject, eventdata, handles)
% hObject    handle to gen_sqw_filename_browse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[save_filename,save_pathname,FilterIndex] = uiputfile({'*.sqw';'*.*'},'Save As');

if ischar(save_pathname) && ischar(save_filename)
    %i.e. the cancel button was not pressed
    set(handles.gen_sqw_filename_edit,'String',[save_pathname,save_filename]);
    guidata(gcbo,handles);
end


% --- Executes on selection change in gen_sqw_emode_popupmenu.
function gen_sqw_emode_popupmenu_Callback(hObject, eventdata, handles)
% hObject    handle to gen_sqw_emode_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns gen_sqw_emode_popupmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from gen_sqw_emode_popupmenu

str = get(hObject, 'String');
val = get(hObject,'Value');
emode=str{val};

handles.gen_emode=emode;

guidata(gcbo,handles);


% --- Executes during object creation, after setting all properties.
function gen_sqw_emode_popupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to gen_sqw_emode_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function gen_sqw_u_edit_Callback(hObject, eventdata, handles)
% hObject    handle to gen_sqw_u_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of gen_sqw_u_edit as text
%        str2double(get(hObject,'String')) returns contents of gen_sqw_u_edit as a double


% --- Executes during object creation, after setting all properties.
function gen_sqw_u_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to gen_sqw_u_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function gen_sqw_v_edit_Callback(hObject, eventdata, handles)
% hObject    handle to gen_sqw_v_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of gen_sqw_v_edit as text
%        str2double(get(hObject,'String')) returns contents of gen_sqw_v_edit as a double


% --- Executes during object creation, after setting all properties.
function gen_sqw_v_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to gen_sqw_v_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function gen_sqw_efix_edit_Callback(hObject, eventdata, handles)
% hObject    handle to gen_sqw_efix_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of gen_sqw_efix_edit as text
%        str2double(get(hObject,'String')) returns contents of gen_sqw_efix_edit as a double


% --- Executes during object creation, after setting all properties.
function gen_sqw_efix_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to gen_sqw_efix_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function gen_sqw_alatt_edit_Callback(hObject, eventdata, handles)
% hObject    handle to gen_sqw_alatt_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of gen_sqw_alatt_edit as text
%        str2double(get(hObject,'String')) returns contents of gen_sqw_alatt_edit as a double


% --- Executes during object creation, after setting all properties.
function gen_sqw_alatt_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to gen_sqw_alatt_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function gen_sqw_angdeg_edit_Callback(hObject, eventdata, handles)
% hObject    handle to gen_sqw_angdeg_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of gen_sqw_angdeg_edit as text
%        str2double(get(hObject,'String')) returns contents of gen_sqw_angdeg_edit as a double


% --- Executes during object creation, after setting all properties.
function gen_sqw_angdeg_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to gen_sqw_angdeg_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function gen_sqw_offsets_edit_Callback(hObject, eventdata, handles)
% hObject    handle to gen_sqw_offsets_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of gen_sqw_offsets_edit as text
%        str2double(get(hObject,'String')) returns contents of gen_sqw_offsets_edit as a double


% --- Executes during object creation, after setting all properties.
function gen_sqw_offsets_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to gen_sqw_offsets_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function gen_sqw_parfile_edit_Callback(hObject, eventdata, handles)
% hObject    handle to gen_sqw_parfile_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of gen_sqw_parfile_edit as text
%        str2double(get(hObject,'String')) returns contents of gen_sqw_parfile_edit as a double


% --- Executes during object creation, after setting all properties.
function gen_sqw_parfile_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to gen_sqw_parfile_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in gen_sqw_parfile_browse_pushbutton.
function gen_sqw_parfile_browse_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to gen_sqw_parfile_browse_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[par_filename,par_pathname,FilterIndex] = uigetfile({'*.par';'*.PAR';'*.*'},'Select par file');

if ischar(par_pathname) && ischar(par_filename)
    %i.e. the cancel button was not pressed
    set(handles.gen_sqw_parfile_edit,'string',[par_pathname,par_filename]);
    guidata(gcbo,handles);
end


% --- Executes on button press in gen_sqw_spefile_browse_pushbutton.
function gen_sqw_spefile_browse_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to gen_sqw_spefile_browse_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[spe_filename,spe_pathname,FilterIndex] = uigetfile({'*.spe; *.SPE','spe files (*.spe, *.SPE)';'*.*','All files (*.*)' },...
    'Select spe files','Multiselect','on');

if ischar(spe_pathname) && ischar(spe_filename)
    %only one file
    original_string=get(handles.gen_sqw_listbox,'string');
    if ~isempty(original_string)
        new_string=char({original_string;[spe_pathname,spe_filename]});
    else
        new_string=char({[spe_pathname,spe_filename]});
    end
    set(handles.gen_sqw_listbox,'string',new_string);
    guidata(gcbo,handles);
elseif ischar(spe_pathname) && iscell(spe_filename)
    %multiple files selected
    original_string=get(handles.gen_sqw_listbox,'string');
    if ~isempty(original_string)
        the_string=original_string;
        for i=1:numel(spe_filename)
            the_string=char({the_string;[spe_pathname,spe_filename{i}]});        
        end
    else
        the_string=char({[spe_pathname,spe_filename{1}]});
        for i=2:numel(spe_filename)
            the_string=char({the_string;[spe_pathname,spe_filename{i}]});        
        end
    end   
    set(handles.gen_sqw_listbox,'string',the_string);
    guidata(gcbo,handles);
else
    %the cancel button was pressed
end



function gen_sqw_psi_edit_Callback(hObject, eventdata, handles)
% hObject    handle to gen_sqw_psi_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of gen_sqw_psi_edit as text
%        str2double(get(hObject,'String')) returns contents of gen_sqw_psi_edit as a double


% --- Executes during object creation, after setting all properties.
function gen_sqw_psi_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to gen_sqw_psi_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in gen_sqw_listbox.
function gen_sqw_listbox_Callback(hObject, eventdata, handles)
% hObject    handle to gen_sqw_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns gen_sqw_listbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from gen_sqw_listbox

index_selected = get(hObject,'Value');
%list = get(hObject,'String');
%item_selected = list(index_selected,:); % Convert from cell array to string

handles.listbox_selected=index_selected;
guidata(gcbo,handles);


% --- Executes during object creation, after setting all properties.
function gen_sqw_listbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to gen_sqw_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in gen_sqw_run_pushbutton.
function gen_sqw_run_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to gen_sqw_run_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Clear error message
set(handles.message_info_text,'String','');
guidata(gcbo,handles);
drawnow;

datetime=fix(clock);
timenow=datetime(4:end);
timestring=[num2str(timenow(1)),':',num2str(timenow(2)),':',num2str(timenow(3))];
mess_initialise=['Generation of sqw file started at ',timestring,'...'];

%Perform checks on all of the inputs - rather tedious
u=get(handles.gen_sqw_u_edit,'String');
v=get(handles.gen_sqw_v_edit,'String');
efix=get(handles.gen_sqw_efix_edit,'String');
alatt=get(handles.gen_sqw_alatt_edit,'String');
angdeg=get(handles.gen_sqw_angdeg_edit,'String');
offsets=get(handles.gen_sqw_offsets_edit,'String');
parfile=get(handles.gen_sqw_parfile_edit,'String');
sqwfile=get(handles.gen_sqw_filename_edit,'String');

%Check all is in correct format:
if isempty(offsets)
    offsets='[0,0,0,0]';%default is that these are all zero
end

if isempty(u)
    mess1='Ensure u vector is specified as a 3 element vector';
    set(handles.message_info_text,'String',char({mess_initialise,mess1}));
    guidata(gcbo,handles);
    return;
elseif isempty(v)
    mess1='Ensure v vector is specified as a 3 element vector';
    set(handles.message_info_text,'String',char({mess_initialise,mess1}));
    guidata(gcbo,handles);
    return;
elseif isempty(efix)
    mess1='Ensure incident energy is specified';
    set(handles.message_info_text,'String',char({mess_initialise,mess1}));
    guidata(gcbo,handles);
    return;  
elseif isempty(alatt)
    mess1='Ensure lattice parameters are specified as a 3 element vector';
    set(handles.message_info_text,'String',char({mess_initialise,mess1}));
    guidata(gcbo,handles);
    return;
elseif isempty(angdeg)
    mess1='Ensure lattice angles are specified as a 3 element vector';
    set(handles.message_info_text,'String',char({mess_initialise,mess1}));
    guidata(gcbo,handles);
    return;      
elseif isempty(parfile)
    mess1='Ensure you have specified a par file name';
    set(handles.message_info_text,'String',char({mess_initialise,mess1}));
    guidata(gcbo,handles);
    return;
elseif isempty(sqwfile)
    mess1='Ensure you have specified a sqw file name';
    set(handles.message_info_text,'String',char({mess_initialise,mess1}));
    guidata(gcbo,handles);
    return;    
else
    try
        %must strip out square brackets, if user has inserted them:
        s1=strfind(u,'['); s2=strfind(u,']');
        if isempty(s1) && isempty(s2)
            unew=strread(u,'%f','delimiter',',');
        elseif ~isempty(s1) && ~isempty(s2)
            u=u(s1+1:s2-1);
            unew=strread(u,'%f','delimiter',',');
        else
            mess1='Ensure u is a 3-element vector with comma-separated elements';
            set(handles.message_info_text,'String',char({mess_initialise,mess1}));
            guidata(gcbo,handles);
            return;
        end
        s1=strfind(v,'['); s2=strfind(v,']');
        if isempty(s1) && isempty(s2)
            vnew=strread(v,'%f','delimiter',',');
        elseif ~isempty(s1) && ~isempty(s2)
            v=v(s1+1:s2-1);
            vnew=strread(v,'%f','delimiter',',');
        else
            mess1='Ensure v is a 3-element vector with comma-separated elements';
            set(handles.message_info_text,'String',char({mess_initialise,mess1}));
            guidata(gcbo,handles);
            return;
        end
        s1=strfind(efix,'['); s2=strfind(efix,']');
        if isempty(s1) && isempty(s2)
            efixnew=strread(efix,'%f','delimiter',',');
        elseif ~isempty(s1) && ~isempty(s2)
            efix=efix(s1+1:s2-1);
            efixnew=strread(efix,'%f','delimiter',',');
        else
            mess1='Ensure incident energy is a single number';
            set(handles.message_info_text,'String',char({mess_initialise,mess1}));
            guidata(gcbo,handles);
            return;
        end
        s1=strfind(alatt,'['); s2=strfind(alatt,']');
        if isempty(s1) && isempty(s2)
            alattnew=strread(alatt,'%f','delimiter',',');
        elseif ~isempty(s1) && ~isempty(s2)
            alatt=alatt(s1+1:s2-1);
            alattnew=strread(alatt,'%f','delimiter',',');
        else
            mess1='Ensure lattice parameters are a 3-element vector with comma-separated elements';
            set(handles.message_info_text,'String',char({mess_initialise,mess1}));
            guidata(gcbo,handles);
            return;
        end
        s1=strfind(angdeg,'['); s2=strfind(angdeg,']');
        if isempty(s1) && isempty(s2)
            angdegnew=strread(angdeg,'%f','delimiter',',');
        elseif ~isempty(s1) && ~isempty(s2)
            angdeg=angdeg(s1+1:s2-1);
            angdegnew=strread(angdeg,'%f','delimiter',',');
        else
            mess1='Ensure lattice angles are a 3-element vector with comma-separated elements';
            set(handles.message_info_text,'String',char({mess_initialise,mess1}));
            guidata(gcbo,handles);
            return;
        end
        s1=strfind(offsets,'['); s2=strfind(offsets,']');
        if isempty(s1) && isempty(s2)
            offsetsnew=strread(offsets,'%f','delimiter',',');
        elseif ~isempty(s1) && ~isempty(s2)
            offsets=offsets(s1+1:s2-1);
            offsetsnew=strread(offsets,'%f','delimiter',',');
        else
            mess1='Ensure offset angles are a 4-element vector with comma-separated elements';
            set(handles.message_info_text,'String',char({mess_initialise,mess1}));
            guidata(gcbo,handles);
            return;
        end
    catch
        mess1='Formatting error for inputs of left-hand side - check that they are all ok';
        set(handles.message_info_text,'String',char({mess_initialise,mess1}));
        guidata(gcbo,handles);
        return;
    end
end

%Now we must check that all of the numbers from the lhs have the right
%number of elements:
if numel(unew)~=3 || numel(vnew)~=3 || numel(efixnew)~=1 || numel(alattnew)~=3 || ...
        numel(angdegnew)~=3
    mess1='Check that u, v, lattice parameters and lattice angles are all vectors with 3 elements';
    set(handles.message_info_text,'String',char({mess_initialise,mess1}));
    guidata(gcbo,handles);
    return;
end
if numel(offsetsnew)~=4
    mess1='Check that offset angle is specified by a vectors with 4 elements, or is empty';
    set(handles.message_info_text,'String',char({mess_initialise,mess1}));
    guidata(gcbo,handles);
    return;
end

if isfield(handles,'gen_emode')
    if strcmp(handles.gen_emode,'Direct')
        emode=1;
    elseif strcmp(handles.gen_emode,'Indirect')
        emode=2;
    elseif strcmp(handles.gen_emode,'Diffraction');
        emode=0;
    else
        mess1='Select a spectrometer geometry';
        set(handles.message_info_text,'String',char({mess_initialise,mess1}));
        guidata(gcbo,handles);
        return;
    end
else
    mess1='Select a spectrometer geometry';
    set(handles.message_info_text,'String',char({mess_initialise,mess1}));
    guidata(gcbo,handles);
    return;
end

%===
%Now we read in the list of spe files and psi. Must trim the strings, and
%also ensure that every spe file has an associated value of psi.
spe_psi_list=get(handles.gen_sqw_listbox,'String');
%convert to cell array:
for i=1:size(spe_psi_list,1)
    spe_psi_cell{i}=strtrim(spe_psi_list(i,:));%get rid of leading and trailing white space
end

%Now we have to ensure that every string has a psi attached to it:
spe_cell=cell(size(spe_psi_cell));%initialise the next useful quantities.
psi_vec=zeros(1,numel(spe_cell));
for i=1:numel(spe_psi_cell)
    ff=strfind(spe_psi_cell{i},'... psi=');
    if ~isempty(ff)
        %there is a value of psi for this spe file
        spe_cell{i}=strtrim(spe_psi_cell{i}(1:(ff-1)));
        ff2=strfind(spe_psi_cell{i},'psi=');
        ff3=strfind(spe_psi_cell{i},'...');
        psi_vec(i)=str2double(spe_psi_cell{i}((ff2+4):(ff3(2)-1)));        
    else
        mess1='Not every spe file has an associated value of psi - check list';
        set(handles.message_info_text,'String',char({mess_initialise,mess1}));
        guidata(gcbo,handles);
        return;
    end
end

%Now ready to run the gen_sqw function:
% gen_sqw (spe_file, par_file, sqw_file, efix, emode, alatt, angdeg,...
%       u, v, psi, omega, dpsi, gl, gs)
try
    mess1='Combining SPE files into SQW file -- working';
    set(handles.message_info_text,'String',char({mess_initialise,mess1}));
    guidata(gcbo,handles);
    pause(2);
    gen_sqw(spe_cell,parfile,sqwfile,efixnew,emode,alattnew,angdegnew,unew,vnew,...
        psi_vec,offsetsnew(1),offsetsnew(2),offsetsnew(3),offsetsnew(4));
    mess1='Success!';
    mess2='SQW file generation complete';
    set(handles.message_info_text,'String',char({mess_initialise,mess1,mess2}));
    guidata(gcbo,handles);
catch
    mess1='Formatting error of inputs';
    the_err=lasterror;
    emess=the_err.message;
    nchar=strfind(emess,['at ',num2str(the_err.stack(1).line)]);
    mess2='gen_sqw failed because:';
    mess3=emess(nchar+9:end);
    set(handles.message_info_text,'String',char({mess_initialise,mess1,mess2,mess3}));
    guidata(gcbo,handles);
    return;
end






% --- Executes on button press in gen_sqw_refresh_pushbutton.
function gen_sqw_refresh_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to gen_sqw_refresh_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Clear error message
set(handles.message_info_text,'String','');
guidata(gcbo,handles);
drawnow;

datetime=fix(clock);
timenow=datetime(4:end);
timestring=[num2str(timenow(1)),':',num2str(timenow(2)),':',num2str(timenow(3))];
mess_initialise=['Refresh psi list started at ',timestring,'...'];

%Get the string that specifies the psi angles:
psi_string=get(handles.gen_sqw_psi_edit,'String');

if isempty(psi_string)
    mess='No psi values specified - there must be as many values of psi as there are spe files';
    set(handles.message_info_text,'String',char({mess_initialise,mess}));
    drawnow;
    guidata(gcbo,handles);
    return;
else
    try
        %must strip out square brackets, if user has inserted them:
        s1=strfind(psi_string,'['); s2=strfind(psi_string,']');
        if isempty(s1) && isempty(s2)
            psinew=strread(psi_string,'%s');
        elseif ~isempty(s1) && ~isempty(s2)
            psi_string=psi_string(s1+1:s2-1);
            psinew=strread(psi_string,'%s');
        else
            mess1='check formatting of psi input - must be in form of a Matlab vector';
            set(handles.message_info_text,'String',char({mess_initialise,mess1}));
            guidata(gcbo,handles);
            return;
        end
        psinew=str2num(psinew{1});%convert to numeric format so that we can check it matches the number of files later.
        handles.psilist=psinew;
        guidata(gcbo,handles);
    catch
        mess1='Formatting error for psi input - must be in form of a Matlab vector';
        set(handles.message_info_text,'String',char({mess_initialise,mess1}));
        guidata(gcbo,handles);
        return;
    end
end

%Add the values of psi to the list box, first checking that there are some
%spe files in there already
spelist=get(handles.gen_sqw_listbox,'string');
if isempty(spelist)
    mess1='Select spe files before specifying psi values';
    set(handles.message_info_text,'String',char({mess_initialise,mess1}));
    guidata(gcbo,handles);
    return;
end
%
numfiles=size(spelist,1);%number of rows in character array of spe files
%
%convert to cell array for ease of use below
spelist_old=spelist;
spelist=cell(size(spelist_old,1),1);
for i=1:numfiles
    spelist{i}=spelist_old(i,:);
end

%Now need to work out if any of the files already have psi assinged to
%them. If so, we need to strip off the psi so that we can re-assign it in
%the loop below
spelist_old=spelist;
for i=1:numel(spelist)
    spelist{i}=strtrim(spelist{i});%trim down to start with
    if strcmp(spelist{i}(end-2:end),'...')
        ff=strfind(spelist{i},' ... psi=');
        spelist{i}=strtrim(spelist{i}(1:ff));
    end
end

if numfiles>numel(psinew)
    %we can only attach a value of psi for some of the files
    for i=1:numel(psinew)
        spelist{i}=[spelist{i},' ... psi=',num2str(psinew(i)),' ...'];
    end
else
    for i=1:numfiles
        spelist{i}=[spelist{i},' ... psi=',num2str(psinew(i)),' ...'];
    end
end
set(handles.gen_sqw_listbox,'string',char(spelist));%enusre spelist is a character array when re-assigned
mess1='File / psi list updated';
set(handles.message_info_text,'String',char({mess_initialise,mess1}));
guidata(gcbo,handles);
    

% --- Executes on button press in gen_sqw_removelist_pushbutton.
function gen_sqw_removelist_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to gen_sqw_removelist_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Clear error message
set(handles.message_info_text,'String','');
guidata(gcbo,handles);
drawnow;

datetime=fix(clock);
timenow=datetime(4:end);
timestring=[num2str(timenow(1)),':',num2str(timenow(2)),':',num2str(timenow(3))];
mess_initialise=['Removal of items from spe/psi list started at ',timestring,'...'];

if ~isfield(handles,'listbox_selected')
    %do nothing
    mess='No item(s) from spe/psi list selected for removal - click on list-box to select [click / crtl+click / shift+click]';
    set(handles.message_info_text,'String',char({mess_initialise,mess}));
    guidata(gcbo,handles);
    return;
elseif ~isempty(handles.listbox_selected) && isnumeric(handles.listbox_selected)
    %these are the files we need to delete from the list
    list_string=get(handles.gen_sqw_listbox,'string');
    vals=handles.listbox_selected;
    list_string(vals,:)=[];%remove the selected items from the character array
    %old_val=get(handles.gen_sqw_listbox,'Value');
    new_val=size(list_string,1);%number of rows, need in a moment
    if new_val>0.001
        set(handles.gen_sqw_listbox,'Value',new_val);
    else
        set(handles.gen_sqw_listbox,'Value',1);
    end
    set(handles.gen_sqw_listbox,'string',list_string);
    mess='Item(s) from spe/psi list successfully removed';
    set(handles.message_info_text,'String',char({mess_initialise,mess}));
    guidata(gcbo,handles);
else
    %there is a listbox_selected field, but it is empty, so give message to
    %that effect:
    mess='No item(s) from spe/psi list selected for removal - click on list-box to select [click / crtl+click / shift+click]';
    set(handles.message_info_text,'String',char({mess_initialise,mess}));
    guidata(gcbo,handles);
    return;
end
    
    


% --- Executes on button press in saveguiconfig_pushbutton.
function saveguiconfig_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to saveguiconfig_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Clear error message
set(handles.message_info_text,'String','');
guidata(gcbo,handles);
drawnow;

datetime=fix(clock);
timenow=datetime(4:end);
timestring=[num2str(timenow(1)),':',num2str(timenow(2)),':',num2str(timenow(3))];
mess_initialise=['Saving GUI configuration at ',timestring,'...'];

[save_filename,save_pathname,FilterIndex] = uiputfile({'*.hor';'*.*'},'Save As');

if ischar(save_pathname) && ischar(save_filename)
    %i.e. the cancel button was not pressed
    placetosave=[save_pathname,save_filename];
    %Need to tediously obtain the strings from all of the "edit" fields,
    %and radiobuttons (yawn)
    fieldstore=get_horace_fields(handles);%gives us a cell array containing all settable fields
    data_to_save=char(fieldstore);%convert to char array to save to file
    fid=fopen(placetosave,'w');
    for i=1:size(data_to_save,1)
        fprintf(fid,'%s\n',data_to_save(i,:));
    end
    fclose(fid);
    %
    mess='GUI configuration successfully saved';
    set(handles.message_info_text,'String',char({mess_initialise,mess}));
else
    mess='No file selected for GUI configuration - not saved';
    set(handles.message_info_text,'String',char({mess_initialise,mess}));
    guidata(gcbo,handles);
    return; 
end

guidata(gcbo,handles);

% --- Executes on button press in loadguiconfig_pushbutton.
function loadguiconfig_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to loadguiconfig_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Clear error message
set(handles.message_info_text,'String','');
guidata(gcbo,handles);
drawnow;

datetime=fix(clock);
timenow=datetime(4:end);
timestring=[num2str(timenow(1)),':',num2str(timenow(2)),':',num2str(timenow(3))];
mess_initialise=['Loading GUI configuration at ',timestring,'...'];

[gui_filename,gui_pathname,FilterIndex] = uigetfile({'*.hor'},'Select horace configuration (.hor) file');

%Initialise cell array where all of the editable fields will be stored:

if ischar(gui_pathname) && ischar(gui_filename)
    filetoload=[gui_pathname,gui_filename];
    %Here we need to go through all of the various edit fields and 
    %radiobuttons, and fill them in.
    %separate subfunction to do this, as rather long-winded
    fid=fopen(filetoload,'r');
    %there are 101 fields that can be saved
    for i=1:101
        data_loaded(i,:)=fgetl(fid);
    end
    fclose(fid);
    %Use subroutine to deal with this lot, and set all the handles
    %appropriately:
    handles=set_horace_fields(handles,data_loaded);
    mess='GUI configuration successfully loaded';
    set(handles.message_info_text,'String',char({mess_initialise,mess}));
    guidata(gcbo,handles); 
else
    mess='No file selected for GUI configuration - not loaded';
    set(handles.message_info_text,'String',mess);
    guidata(gcbo,handles);
    return; 
end




% --- Executes on button press in savexye_pushbutton.
function savexye_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to savexye_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Clear error message
set(handles.message_info_text,'String','');
guidata(gcbo,handles);
drawnow;

datetime=fix(clock);
timenow=datetime(4:end);
timestring=[num2str(timenow(1)),':',num2str(timenow(2)),':',num2str(timenow(3))];
mess_initialise=['Saving xye data to file started at ',timestring,'...'];

if isfield(handles,'w_in')
    win=handles.w_in;
    if numel(win)~=1
        mess='No save performed - object selected is an array of Horace objects';
        set(handles.message_info_text,'String',char({mess_initialise,mess}));
        drawnow;
        guidata(gcbo,handles);
        return;
    end
    str=get(handles.savexye_edit,'String');
    if ~isempty(str)
        try
            save_xye(win,str);
            mess=['File saved to ',str];
            set(handles.message_info_text,'String',char({mess_initialise,mess}));
        catch
            mess='Saving of file failed -- check object and/or filename';
            set(handles.message_info_text,'String',char({mess_initialise,mess}));
            return;
        end         
    else
        mess='No file written -- select a filename';
        set(handles.message_info_text,'String',char({mess_initialise,mess}));
        drawnow;
        guidata(gcbo,handles);
    end
else
    mess='No file written -- select an object to save';
    set(handles.message_info_text,'String',char({mess_initialise,mess}));
    drawnow;
    guidata(gcbo,handles);
end






function savexye_edit_Callback(hObject, eventdata, handles)
% hObject    handle to savexye_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of savexye_edit as text
%        str2double(get(hObject,'String')) returns contents of savexye_edit as a double


% --- Executes during object creation, after setting all properties.
function savexye_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to savexye_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in savexye_browse_pushbutton.
function savexye_browse_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to savexye_browse_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[save_filename,save_pathname,FilterIndex] = uiputfile({'*.txt';'*.dat';'*.*'},'Save As');

if ischar(save_pathname) && ischar(save_filename)
    %i.e. the cancel button was not pressed
    set(handles.savexye_edit,'String',[save_pathname,save_filename]);
    guidata(gcbo,handles);
end


% --- Executes on button press in peakfitting_pushbutton.
function peakfitting_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to peakfitting_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Clear error message
set(handles.message_info_text,'String','');
guidata(gcbo,handles);

datetime=fix(clock);
timenow=datetime(4:end);
timestring=[num2str(timenow(1)),':',num2str(timenow(2)),':',num2str(timenow(3))];
mess_initialise=['Opening 1d peak fitting tool at ',timestring,'...'];
drawnow;
try
    horace_fitting;
    mess='Success!';
    set(handles.message_info_text,'String',char({mess_initialise,mess}));
    drawnow;
    guidata(gcbo,handles);
catch
    mess='Unable to open 1d peak fitting tool - check Horace setup';
    set(handles.message_info_text,'String',char({mess_initialise,mess}));
    drawnow;
    guidata(gcbo,handles);
end


% --- Executes on button press in Cutfile_orthaxes_radiobutton.
function Cutfile_orthaxes_radiobutton_Callback(hObject, eventdata, handles)
% hObject    handle to Cutfile_orthaxes_radiobutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Cutfile_orthaxes_radiobutton

button_state=get(hObject,'Value');
if button_state==get(hObject,'Max');%button is pressed
    set(handles.Cutfile_nonorth_axes_radiobutton,'Value',0);
end
guidata(gcbo, handles);


% --- Executes on button press in Cutfile_nonorth_axes_radiobutton.
function Cutfile_nonorth_axes_radiobutton_Callback(hObject, eventdata, handles)
% hObject    handle to Cutfile_nonorth_axes_radiobutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Cutfile_nonorth_axes_radiobutton

button_state=get(hObject,'Value');
if button_state==get(hObject,'Max');%button is pressed
    set(handles.Cutfile_orthaxes_radiobutton,'Value',0);
end
guidata(gcbo, handles);

