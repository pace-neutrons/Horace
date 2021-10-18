function varargout = horace_planner(varargin)
% HORACE_PLANNER M-file for horace_planner.fig
%      HORACE_PLANNER, by itself, creates a new HORACE_PLANNER or raises the existing
%      singleton*.
%
%      H = HORACE_PLANNER returns the handle to a new HORACE_PLANNER or the handle to
%      the existing singleton*.
%
%      HORACE_PLANNER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in HORACE_PLANNER.M with the given input arguments.
%
%      HORACE_PLANNER('Property','Value',...) creates a new HORACE_PLANNER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before horace_planner_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to horace_planner_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help horace_planner

% Last Modified by GUIDE v2.5 17-Oct-2021 23:55:13

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @horace_planner_OpeningFcn, ...
    'gui_OutputFcn',  @horace_planner_OutputFcn, ...
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


function [cm,tooltips,inp3,gui_validators,gui_errors]=getControlsMap(varargin)
persistent controlHandlesMap;
persistent controlTooltips;
persistent triple_sinlgle_input;
persistent gui_var_validators;
persistent gui_errors_map;

control_keys = ...
    {'u','v','ei','en_transf',  'psimin','psimax','alatt','angdeg','latpt'};
if nargin>0
    control_defaults  = varargin{1};
    controlHandlesMap = containers.Map(control_keys,control_defaults);
else
    control_defaults = ...
        {'1,0,0','0,1,0','100','50','0','90','2.83,2.83,2.83','90,90,90','1,1,1'};
end
if isempty(controlTooltips)
    % what inputs can be entered as a single value but should be returned
    % as triple value
    triple_input=...
        {false,false,false,false,false,false',true,true,true};
    control_tooltips = ...
        {'Q-space direction parallel to the incident beam when the crystal rotation angle, psi, is equal to 0',...
        'Q-space vector lying in the equatorial plane of the detectors (horizontal for most instruments)',...
        'Incident energy of neutrons',...
        'Energy transfer to evaluate coverage at',...
        'Initial goniometer angle of the rotating crystal',...
        'Final goniometer angle of the rotating crystal',...
        'Lattice parameters (A). Three different values or one if all values are the same',...
        'Lattice angles (deg). Three different values or one if all values are the same',...
        ['Density of reciprocal space points to plot.\n',...
        ' 1 -- each lattice point, 1,2,3, -- each in h, every second in k, every third -- in l']};
    % check input variables
    var_validators  = {...
        @(u)  (~isempty(u)&&(numel(u)==3)),...
        @(v)  (~isempty(v)&&(numel(v)==3)),...
        @(Ei) (~isempty(Ei)&&(Ei>0)&&(numel(Ei)==1)),...
        @(entr)(~isempty(entr)&&(numel(entr)==1)),... %entr
        @(pmi)(~isempty(pmi)),... %
        @(pma)(~isempty(pma)),... %
        @(lat)(~isempty(lat)&&(numel(lat)==3)||(numel(lat)==1)),...
        @(ang)(~isempty(ang)&&(numel(ang)==3)||(numel(ang)==1)),...
        @(pd) (~isempty(pd)&&(numel(pd)==3||numel(pd)==1)&&all(pd>0))};
    gui_error_codes = {...
        'u has to have form h,k,l or [h,k,l]',...
        'v has to have form h,k,l or [h,k,l]',...
        'Ei can not be empty, has to be numeric and must be single and positive',...
        'Energy transfer has to be numeric, can not be empty and must be single and positive',...
        'psimin has to be numeric and can not be empty',...
        'psimax has to be numeric and can not be empty',...
        'Lattice param. have to be 3 numbers in a form: a,b,c or [a,b,c] or a single number if all parameters are the same',...
        'Lattice angles have to be 3 numbers in a form: a,b,c or [a,b,c] or be a single number if all parameters are the same',...
        'Lattice points density can not be empty and must contan one or 3 positive integers' };
    %
    controlHandlesMap    = containers.Map(control_keys,control_defaults);
    controlTooltips      = containers.Map(control_keys,control_tooltips);
    triple_sinlgle_input = containers.Map(control_keys,triple_input);
    gui_var_validators   = containers.Map(control_keys,var_validators);
    gui_errors_map       = containers.Map(control_keys,gui_error_codes);
end
cm         = controlHandlesMap;
tooltips   = controlTooltips;
inp3       = triple_sinlgle_input;
gui_validators = gui_var_validators;
gui_errors = gui_errors_map;


% --- Executes just before horace_planner is made visible.
function horace_planner_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to horace_planner (see VARARGIN)

% Choose default command line output for horace_planner
handles.output = hObject;
pc = planner_config();

% Update handles structure
guidata(hObject, handles);
par_file = pc.par_file;
[filepath,filename,fex] = fileparts(par_file);
set(handles.parfile_edit,'String',[filename,fex],'UserData',filepath);
% get all other config;
config_data=pc.get_data_to_store();
config_data = rmfield(config_data,'par_file');
defaults = struct2cell(config_data);
defaults = cellfun(@(x)convert_par_to_str(x),defaults,'UniformOutput',false);
%
% Set up default values of the input parameters and tooltips
[cm,ct] = getControlsMap(defaults);
contr = cm.keys;
for i=1:numel(contr)
    key = contr{i};
    set(handles.([key,'_edit']),'String',cm(key),'Tooltip',ct(key),...
        'BackgroundColor',[0.1,0.5,0.1],'FontWeight','bold');
end
function str = convert_par_to_str(val)
if numel(val)>1
    str = sprintf('%g,%g,%g',val);
else
    str = sprintf('%g',val);
end
% UIWAIT makes horace_planner wait for user response (see UIRESUME)
% uiwait(handles.Planner);


% --- Outputs from this function are returned to the command line.
function varargout = horace_planner_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function parfile_edit_Callback(hObject, eventdata, handles)
% hObject    handle to parfile_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of parfile_edit as text
%        str2double(get(hObject,'String')) returns contents of parfile_edit as a double
contents = get(handles.parfile_edit,'String');
[fpath,fname,fext] = fileparts(contents);
if isempty(fpath)
    fpath = pwd;
end
file = fullfile(fpath,[fname,fext]);
if ~is_file(file)
    err_mess = sprintf('File %s does not exist',file);
    set(handles.message_text,'String',...
        err_mess,'BackgroundColor','r');
    set(handles.parfile_edit,'BackgroundColor','r');    
    return;
end
pc = planner_config;
pc.par_file = file;
set(handles.parfile_edit,'String',[fname,fext],'UserData',fpath);
% clear previous detpar to load new detectors file on calculations
set(handles.parfile_text,'UserData',[]);
set(hObject,'BackgroundColor',[0.01,0.5,0.01]);
set(handles.message_text,'String',...
    'new par file has been selected successfully','BackgroundColor','w');



% --- Executes during object creation, after setting all properties.
function parfile_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to parfile_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in select_pushbutton.
function select_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to select_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
pc = planner_config;
par_file = pc.par_file;
if ~isempty(par_file)
    par_path = fileparts(par_file);
    current_dir = pwd;
    clob = onCleanup(@()cd(current_dir));
    cd(par_path);
end

[par_filename,par_pathname,FilterIndex] = uigetfile({'*.par','*.PAR'},'Select par file');
%
file = fullfile(par_pathname,par_filename);

if ischar(par_pathname) && ischar(par_filename)
    %i.e. the cancel button was not pressed
    set(handles.parfile_edit,'String',par_filename,...
        'UserData',par_pathname);
    guidata(gcbo,handles);
    drawnow;    
    pc.par_file = file;
else
    return;
end
load_par_file(handles);

%
function u_edit_Callback(hObject, eventdata, handles)
% hObject    handle to u_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of u_edit as text
%        str2double(get(hObject,'String')) returns contents of u_edit as a double
set(hObject,'BackgroundColor','white','FontWeight','normal');

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
set(hObject,'BackgroundColor','white','FontWeight','normal');


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


function ei_edit_Callback(hObject, eventdata, handles)
% hObject    handle to ei_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ei_edit as text
%        str2double(get(hObject,'String')) returns contents of ei_edit as a double
set(hObject,'BackgroundColor','white','FontWeight','normal');

% --- Executes during object creation, after setting all properties.
function ei_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ei_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white','FontWeight','normal');
end

function en_transf_edit_Callback(hObject, eventdata, handles)
% hObject    handle to en_transf_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of en_transf_edit as text
%        str2double(get(hObject,'String')) returns contents of en_transf_edit as a double
set(hObject,'BackgroundColor','white','FontWeight','normal');

% --- Executes during object creation, after setting all properties.
function en_transf_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to en_transf_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white','FontWeight','normal');
end

function psimin_edit_Callback(hObject, eventdata, handles)
% hObject    handle to psimin_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of psimin_edit as text
%        str2double(get(hObject,'String')) returns contents of psimin_edit as a double
set(hObject,'BackgroundColor','white','FontWeight','normal');

% --- Executes during object creation, after setting all properties.
function psimin_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to psimin_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white','FontWeight','normal');
end

function psimax_edit_Callback(hObject, eventdata, handles)
% hObject    handle to psimax_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of psimax_edit as text
%        str2double(get(hObject,'String')) returns contents of psimax_edit as a double
set(hObject,'BackgroundColor','white','FontWeight','normal');

% --- Executes during object creation, after setting all properties.
function psimax_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to psimax_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white','FontWeight','normal');
end

function alatt_edit_Callback(hObject, eventdata, handles)
% hObject    handle to alatt_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of alatt_edit as text
%        str2double(get(hObject,'String')) returns contents of alatt_edit as a double
set(hObject,'BackgroundColor','white','FontWeight','normal');

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

function angdeg_edit_Callback(hObject, eventdata, handles)
% hObject    handle to angdeg_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of angdeg_edit as text
%        str2double(get(hObject,'String')) returns contents of angdeg_edit as a double
set(hObject,'BackgroundColor','white','FontWeight','normal');

% --- Executes during object creation, after setting all properties.
function angdeg_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to angdeg_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white','FontWeight','normal');
end

function detpar=load_par_file(handles)
% load detector's file defined selected from GUI
try
    filename=handles.parfile_edit.String;
    filepath=handles.parfile_edit.UserData;
    file = fullfile(filepath,filename);
    detpar=get_par(file);
    set(handles.message_text,'String','Par file loaded successfully',...
        'BackgroundColor','w');
    set(handles.parfile_edit,'BackgroundColor','w');
    % store detpar in user data of message 
    set(handles.parfile_text,'UserData',detpar);
catch ME
    set(handles.message_text,'String',...
        'Ensure a valid par file is selected and loaded. See Matlab command window for additional details',...
        'BackgroundColor','r');
    set(handles.parfile_edit,'BackgroundColor','r');
    
    fprintf(2,'ERROR - par file %s is not valid par file or error loading it\n',file);
    fprintf(2,'*****   Reason: %s',ME.message);
    
    rethrow(ME);
end


function [value,ok] = parse_runparameters_input_box(handles,control_name)
% function to parse input from control box of the user interface
%

persistent err_codes;
persistent err_validators;
persistent triple_input;
if isempty(err_codes)
    [~,~,triple_input,err_validators,err_codes]=getControlsMap();
end

try
    ok = true;
    val_string = get(handles.([control_name,'_edit']),'String');
    %must strip out square brackets, if user has inserted them
    s1=strfind(val_string,'['); s2=strfind(val_string,']');
    if isempty(s1) && isempty(s2)
        val_string=val_string';
    elseif ~isempty(s1) && ~isempty(s2)
        val_string=val_string(s1+1:s2-1);
    else
        ok = false;
        set(handles.([control_name,'_edit']),'BackgroundColor','r');
        %
        err_mess = sprinft('Can not retrieve input: %s',control_name);
        set(handles.message_text,'String',err_mess,'BackgroundColor','r');
        fprintf(2,'**** ERROR: %s\n',err_mess);
        
        guidata(gcbo,handles);
        drawnow;
        return;
    end
    value=textscan(val_string,'%f','delimiter',',');
    if iscell(value)
        value = value{:};
    end
    % check obtained value:
    check_correct = err_validators(control_name);
    if ~check_correct(value)
        ok = false;
        set(handles.([control_name,'_edit']),'BackgroundColor','r');
        %
        err_mess = sprintf('%s',err_codes(control_name));
        set(handles.message_text,'String',err_mess,'BackgroundColor','r');
        fprintf(2,'**** control "%s" ERROR: %s \n',control_name,err_mess);
        
        guidata(gcbo,handles);
        drawnow;
        return;
    end
    % triple some inputs if this is appropriate
    if triple_input(control_name) && numel(value) == 1
        value = [value,value,value];
    end
    
    % Put back obtained values for parameters control
    if numel(value) > 1
        val_string = sprintf('%s,%s,%s',num2str(value(1)),num2str(value(2)),num2str(value(3)));
    else
        val_string = sprintf('%s',num2str(value));
    end
    set(handles.([control_name,'_edit']),'String',val_string,...
        'BackgroundColor','g','FontWeight','normal');
catch ME
    set(handles.([control_name,'_edit']),'BackgroundColor','r');
    
    err_mess = sprintf('Input throws error: %s',ME.message);
    set(handles.message_text,'String',err_mess,'BackgroundColor','r');
    fprintf(2,'**** ERROR in control "%s":\n ****%s\n',control_name,err_mess);
    rethrow(ME);
end

% --- Executes on button press in calc_pushbutton.
function calc_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to calc_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Clear error message
set(handles.message_text,'String','','BackgroundColor','w');
guidata(gcbo,handles);
drawnow;
pc = planner_config;

%Turn off annoying warning messages:
ws = warning('off');
clob = onCleanup(@()warning(ws));
cm = getControlsMap();
control = cm.keys;
result = cell(1,numel(control));
for i=1:numel(control)
    [result{i},ok] = parse_runparameters_input_box(handles,control{i});
    if ~ok
        return;
    end
    if numel(result{i})==3
        eval(sprintf('%s=[%g,%g,%g];',control{i},result{i}));
    else
        eval(sprintf('%s=%g;',control{i},result{i}));
    end
    pc.(control{i})=result{i};
end

% do some global checks
if en_transf>ei
    set(handles.en_transf_edit,'BackgroundColor','r');
    set(handles.ei_edit,'BackgroundColor','r');
    disp_error(handles,'Ensure energy transfer is smaller than Ei');
    return;
end
if norm(cross(u,v))<1.e-7
    set(handles.u_edit,'BackgroundColor','r');
    set(handles.v_edit,'BackgroundColor','r');
    disp_error(handles,'u and v vectors can not be parallel');
    return
end

detpar = get(handles.parfile_text,'UserData');
if isempty(detpar)
    detpar = load_par_file(handles);    
end

%If we get to this stage, then all of the inputs are OK, and we can
%proceed.
try
    [xcoords,ycoords,zcoords,pts,ptlabs]=...
        calc_coverage_from_detpars_v2(ei,en_transf,psimin,psimax,detpar,u,v,alatt,angdeg);
catch ME
    disp_error(handles,'non-trivial error on execution of calculations. Check inputs carefully...');
    rethrow(ME)
end

%Generate point labels with specified density
[pts2,ptlabs2]=generate_rlps(ei,u,v,alatt,angdeg,latpt);


%==========================================================================
%Now make the plots
%==========================================================================

%==========================================================================
%XY plane
axes(handles.axes5);
cla;%clear pre-existing plots on these axes

try
    jj=parula(50);
catch
    jj=jet(50);%in case old version of Matlab without Parula colormap used
end

set(handles.message_text,'String','Calculating detector coverage...',...
    'BackgroundColor','b');
guidata(gcbo,handles);
drawnow;

%===
%Make the figure
%===

zval = str2num( get(handles.zoff_edit,'String') );%get the value of the z slider

xlims=[]; ylims=[]; zmin=[]; zmax=[];
for i=1:50
    plot(xcoords{i}(zcoords{i}<zval+0.1 & zcoords{i}>zval-0.1),...
        ycoords{i}(zcoords{i}<zval+0.1 & zcoords{i}>zval-0.1),...
        'ok','MarkerFaceColor',jj(i,:),'MarkerEdgeColor','none');
    hold on
    xlims=[xlims; ...
        min(xcoords{i}(zcoords{i}<zval+0.1 & zcoords{i}>zval-0.1)), ...
        max(xcoords{i}(zcoords{i}<zval+0.1 & zcoords{i}>zval-0.1))];
    ylims=[ylims; ...
        min(ycoords{i}(zcoords{i}<zval+0.1 & zcoords{i}>zval-0.1)), ...
        max(ycoords{i}(zcoords{i}<zval+0.1 & zcoords{i}>zval-0.1))];
    %Also need zlims for later (different purposes)
    zmin=[zmin min(zcoords{i})]; zmax=[zmax max(zcoords{i})];
end
zmin=min(zmin); zmax=max(zmax);
caxis([psimin,psimax]);
cbarlab=colorbar;
%handle case when parula colormap not included (old Matlab version)
try
    colormap('parula');
catch
    colormap('jet');
end

try
    xmin=min(xlims); xmin=xmin(1);
    xmax=max(xlims); xmax=xmax(2);
    ymin=min(ylims); ymin=ymin(1);
    ymax=max(ylims); ymax=ymax(2);
    
    %Find points that are inside the axes and plot them as circles
    ff=find(pts2(:,3)<zval+0.1 & pts2(:,3)>zval-0.1 & pts2(:,1)>xmin-0.1 & ...
        pts2(:,1)<xmax+0.1 & pts2(:,2)>ymin-0.1 & pts2(:,2)<ymax+0.1);
    plot(pts2(ff,1),pts2(ff,2),'ok','MarkerFaceColor','k');
    
    %Add labels
    for i=1:numel(ff)
        text(pts2(ff(i),1)+0.1,pts2(ff(i),2)+0.1,ptlabs2{ff(i)},'Clipping','on');
    end
    
    set(gca,'XAxisLocation','top');%ensure x-labels don't interfere with slider
    %note that label is automatically put at the top as well if we do this
    xlab=xlabel('Q // u (Angstrom^-^1)');
    %set(xlab,'Interpreter','latex');
    ylab=ylabel('Q perp u [in uv-plane] (Angstrom^-^1)');
    %set(ylab,'Interpreter','latex');
    %zlabel('Q perp uv-plane (Ang^-1^1)');
    ylab=ylabel(cbarlab,'dataset psi vals');
    %set(ylab,'Rotation',-90);
    
    %============
    %We also need to modify the z slider range and step size based on what we
    %have done here so that we can slide over the full data range
    set(handles.zoff_slider,'Min',zmin);
    set(handles.zoff_slider,'Max',zmax);
catch
    %catch case when no data to be plotted because of choice of offset
    axis([-1 1 -1 1]);
    text(0,0,'No data to be plotted','Clipping','on');
    warning('on');
end


%==========================================================================
%XZ-plane
axes(handles.axes4);
cla;%clear pre-existing plots on these axes

try
    jj=parula(50);
catch
    jj=jet(50);%in case old version of Matlab without Parula colormap used
end

%===
%Make the figure
%===

yval = str2num( get(handles.yoff_edit,'String') );%get the value of the z slider

xlims=[]; ylims=[]; zmin=[]; zmax=[];
for i=1:50
    plot(xcoords{i}(ycoords{i}<yval+0.1 & ycoords{i}>yval-0.1),...
        zcoords{i}(ycoords{i}<yval+0.1 & ycoords{i}>yval-0.1),...
        'ok','MarkerFaceColor',jj(i,:),'MarkerEdgeColor','none');
    hold on
    xlims=[xlims; ...
        min(xcoords{i}(ycoords{i}<yval+0.1 & ycoords{i}>yval-0.1)), ...
        max(xcoords{i}(ycoords{i}<yval+0.1 & ycoords{i}>yval-0.1))];
    ylims=[ylims; ...
        min(zcoords{i}(ycoords{i}<yval+0.1 & ycoords{i}>yval-0.1)), ...
        max(zcoords{i}(ycoords{i}<yval+0.1 & ycoords{i}>yval-0.1))];
    %Also need zlims for later (different purposes)
    zmin=[zmin min(ycoords{i})]; zmax=[zmax max(ycoords{i})];
end
zmin=min(zmin); zmax=max(zmax);
caxis([psimin,psimax]);
%cbarlab=colorbar;
%handle case when parula colormap not included (old Matlab version)
try
    colormap('parula');
catch
    colormap('jet');
end

try
    xmin=min(xlims); xmin=xmin(1);
    xmax=max(xlims); xmax=xmax(2);
    ymin=min(ylims); ymin=ymin(1);
    ymax=max(ylims); ymax=ymax(2);
    
    %Find points that are inside the axes and plot them as circles
    ff=find(pts2(:,2)<yval+0.1 & pts2(:,2)>yval-0.1 & pts2(:,1)>xmin-0.1 & ...
        pts2(:,1)<xmax+0.1 & pts2(:,3)>ymin-0.1 & pts2(:,3)<ymax+0.1);
    plot(pts2(ff,1),pts2(ff,3),'ok','MarkerFaceColor','k');
    
    %Add labels
    for i=1:numel(ff)
        text(pts2(ff(i),1)+0.1,pts2(ff(i),3)+0.1,ptlabs2{ff(i)},'Clipping','on');
    end
    
    set(gca,'XAxisLocation','top');%ensure x-labels don't interfere with slider
    %note that label is automatically put at the top as well if we do this
    xlab=xlabel('Q // u (Angstrom^-^1)');
    %set(xlab,'Interpreter','latex');
    %ylab=ylabel('Q out of plane (Angstrom^-^1)');
    %set(ylab,'Interpreter','latex');
    %zlabel('Q perp uv-plane (Ang^-1^1)');
    %ylab=ylabel(cbarlab,'dataset psi vals');
    %set(ylab,'Rotation',-90);
    
    %============
    %We also need to modify the z slider range and step size based on what we
    %have done here so that we can slide over the full data range
    set(handles.yoff_slider,'Min',zmin);
    set(handles.yoff_slider,'Max',zmax);
catch
    %catch case when no data to be plotted because of choice of offset
    axis([-1 1 -1 1]);
    text(0,0,'No data to be plotted','Clipping','on');
end

%==========================================================================
%YZ-plane
axes(handles.axes1);
cla;%clear pre-existing plots on these axes

try
    jj=parula(50);
catch
    jj=jet(50);%in case old version of Matlab without Parula colormap used
end

%===
%Make the figure
%===

xval = str2num( get(handles.xoff_edit,'String') );%get the value of the z slider

xlims=[]; ylims=[]; zmin=[]; zmax=[];
for i=1:50
    plot(ycoords{i}(xcoords{i}<xval+0.1 & xcoords{i}>xval-0.1),...
        zcoords{i}(xcoords{i}<xval+0.1 & xcoords{i}>xval-0.1),...
        'ok','MarkerFaceColor',jj(i,:),'MarkerEdgeColor','none');
    hold on
    xlims=[xlims; ...
        min(ycoords{i}(xcoords{i}<xval+0.1 & xcoords{i}>xval-0.1)), ...
        max(ycoords{i}(xcoords{i}<xval+0.1 & xcoords{i}>xval-0.1))];
    ylims=[ylims; ...
        min(zcoords{i}(xcoords{i}<xval+0.1 & xcoords{i}>xval-0.1)), ...
        max(zcoords{i}(xcoords{i}<xval+0.1 & xcoords{i}>xval-0.1))];
    %Also need zlims for later (different purposes)
    zmin=[zmin min(xcoords{i})]; zmax=[zmax max(xcoords{i})];
end
zmin=min(zmin); zmax=max(zmax);
caxis([psimin,psimax]);
%cbarlab=colorbar;
%handle case when parula colormap not included (old Matlab version)
try
    colormap('parula');
catch
    colormap('jet');
end

try
    xmin=min(xlims); xmin=xmin(1);
    xmax=max(xlims); xmax=xmax(2);
    ymin=min(ylims); ymin=ymin(1);
    ymax=max(ylims); ymax=ymax(2);
    
    %Find points that are inside the axes and plot them as circles
    ff=find(pts2(:,1)<xval+0.1 & pts2(:,1)>xval-0.1 & pts2(:,2)>xmin-0.1 & ...
        pts2(:,2)<xmax+0.1 & pts2(:,3)>ymin-0.1 & pts2(:,3)<ymax+0.1);
    plot(pts2(ff,2),pts2(ff,3),'ok','MarkerFaceColor','k');
    
    %Add labels
    for i=1:numel(ff)
        text(pts2(ff(i),2)+0.1,pts2(ff(i),3)+0.1,ptlabs2{ff(i)},'Clipping','on');
    end
    
    set(gca,'XAxisLocation','top');%ensure x-labels don't interfere with slider
    set(gca,'YAxisLocation','right');
    %note that label is automatically put at the top as well if we do this
    xlab=xlabel('Q perp u [uv-plane] (Angstrom^-^1)');
    %set(xlab,'Interpreter','latex');
    ylab=ylabel('Q out of plane (Angstrom^-^1)');
    %set(ylab,'Interpreter','latex');
    %zlabel('Q perp uv-plane (Ang^-1^1)');
    %ylab=ylabel(cbarlab,'dataset psi vals');
    %set(ylab,'Rotation',-90);
    
    %============
    %We also need to modify the z slider range and step size based on what we
    %have done here so that we can slide over the full data range
    set(handles.xoff_slider,'Min',zmin);
    set(handles.xoff_slider,'Max',zmax);
catch
    %catch case when no data to be plotted because of choice of offset
    axis([-1 1 -1 1]);
    text(0,0,'No data to be plotted');
    warning('on');
end

set(handles.message_text,'String','Calculation performed successfully',...
    'BackgroundColor','g');
guidata(gcbo,handles);
drawnow;


function disp_error(handles,err_code)
fprintf(2,'ERROR: %s\n',err_code);
set(handles.message_text,'String',['ERROR: ',err_code],...
    'BackgroundColor','r');
guidata(gcbo,handles);
drawnow;


% --------------------------------------------------------------------
% --- Executes on slider movement.
function zoff_slider_Callback(hObject, eventdata, handles)
% hObject    handle to zoff_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

sliderValue = num2str( get(handles.zoff_slider,'Value') );
set(handles.zoff_edit,'String', sliderValue);
guidata(gcbo,handles);
drawnow;


% --- Executes during object creation, after setting all properties.
function zoff_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to zoff_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function yoff_slider_Callback(hObject, eventdata, handles)
% hObject    handle to yoff_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

sliderValue = num2str( get(handles.yoff_slider,'Value') );
set(handles.yoff_edit,'String', sliderValue);
guidata(gcbo,handles);
drawnow;


% --- Executes during object creation, after setting all properties.
function yoff_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to yoff_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function xoff_slider_Callback(hObject, eventdata, handles)
% hObject    handle to xoff_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

sliderValue = num2str( get(handles.xoff_slider,'Value') );
set(handles.xoff_edit,'String', sliderValue);
guidata(gcbo,handles);
drawnow;

% --- Executes during object creation, after setting all properties.
function xoff_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to xoff_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function yoff_edit_Callback(hObject, eventdata, handles)
% hObject    handle to yoff_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of yoff_edit as text
%        str2double(get(hObject,'String')) returns contents of yoff_edit as a double

textValue = str2num( get(handles.yoff_edit,'String') );
set(handles.yoff_slider,'Value',textValue);
guidata(gcbo,handles);
drawnow;

% --- Executes during object creation, after setting all properties.
function yoff_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to yoff_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function xoff_edit_Callback(hObject, eventdata, handles)
% hObject    handle to xoff_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of xoff_edit as text
%        str2double(get(hObject,'String')) returns contents of xoff_edit as a double

textValue = str2num( get(handles.xoff_edit,'String') );
set(handles.xoff_slider,'Value',textValue);
guidata(gcbo,handles);
drawnow;

% --- Executes during object creation, after setting all properties.
function xoff_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to xoff_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white','FontWeight','normal');
end



function zoff_edit_Callback(hObject, eventdata, handles)
% hObject    handle to zoff_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of zoff_edit as text
%        str2double(get(hObject,'String')) returns contents of zoff_edit as a double

textValue = str2num( get(handles.zoff_edit,'String') );
set(handles.zoff_slider,'Value',textValue);
guidata(gcbo,handles);
drawnow;


% --- Executes during object creation, after setting all properties.
function zoff_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to zoff_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function latpt_edit_Callback(hObject, eventdata, handles)
% hObject    handle to latpt_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of latpt_edit as text
%        str2double(get(hObject,'String')) returns contents of latpt_edit as a double
set(hObject,'BackgroundColor','white','FontWeight','normal');

% --- Executes during object creation, after setting all properties.
function latpt_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to latpt_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function select_pushbutton_CreateFcn(hObject, eventdata, handles)
% hObject    handle to select_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
