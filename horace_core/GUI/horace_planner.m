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

% Last Modified by GUIDE v2.5 21-Aug-2017 13:41:06

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
function [cm,tooltips,inp3,gui_validators,gui_errors]=getControlsMap()
persistent controlHandlesMap;
persistent controlTooltips;
persistent triple_sinlgle_input;
persistent gui_var_validators;
persistent gui_errors_map;
if isempty(controlHandlesMap)
    control_keys = ...
        {'u','v','ei','eps',  'psimin','psimax','alatt','angdeg','latpt'};
    % what inputs can be entered as a single value but should be returned
    % as triple value
    triple_input=...
        {false,false,false,false,false,false',true,true,true};
    control_defaults = ...
        {'1,0,0','0,1,0','100','95','0','90','2.83,2.83,2.83','90,90,90','1,1,1'};
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
        @(eps)(~isempty(eps)&&(numel(eps)==1)),... %eps
        @(pmi)(~isempty(pmi)),... %
        @(pma)(~isempty(pma)),... %
        @(lat)(~isempty(lat)&&(numel(lat)==3)||(numel(lat)==1)),...
        @(ang)(~isempty(ang)&&(numel(ang)==3)||(numel(ang)==1)),...
        @(pd) (~isempty(pd)&&(numel(px)==3||numel(pd)==1)&&all(pd>0))};
    gui_error_codes = ...
        {'u has to have form a,b,c or [a,b,c]',...
        'v has to have form a,b,c or [a,b,c]',...
        'Ei can not be empty and must be single and positive',...
        'eps can not be empty',...
        'psimin can not be empty',...
        'psimax can not be empty',...
        'lattice parameters has to have form a,b,c or [a,b,c] or be a single number if all parameters are the same',...
        'lattice angles have to have a form a,b,c or [a,b,c] or be a single number if all parameters are the same',...
        'points density can not be empty and must contan one or 3 positive integers' };
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


% Update handles structure
guidata(hObject, handles);
%
% Set up default values of the input parameters and tooltips
[cm,ct] = getControlsMap();
contr = cm.keys;
for i=1:numel(contr)
    key = contr{i};
    set(handles.([key,'_edit']),'String',cm(key),'Tooltip',ct(key));
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


% --- Executes on button press in browse_pushbutton.
function browse_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to browse_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[par_filename,par_pathname,FilterIndex] = uigetfile({'*.par','*.PAR'},'Select par file');

if ischar(par_pathname) && ischar(par_filename)
    %i.e. the cancel button was not pressed
    set(handles.parfile_edit,'string',[par_pathname,par_filename]);
    guidata(gcbo,handles);
end



% --- Executes on button press in loadpar_pushbutton.
function loadpar_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to loadpar_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Clear error message
set(handles.message_text,'String','');
guidata(gcbo,handles);
drawnow;
try
    filename=get(handles.parfile_edit,'string');
    par=get_par(filename);
    handles.detpar=par;
    set(handles.message_text,'String','Par file loaded successfully',...
        'BackgroundColor','w');
catch ERR
    set(handles.message_text,'String','Error - see Matlab command window for details',...
        'BackgroundColor','r');
    fprintf(2,'ERROR - par file %s is not valid par file\n',filename);
    fprintf(2,'*****   Reason: %s',ERR.message);
end
guidata(gcbo,handles);
drawnow;




function u_edit_Callback(hObject, eventdata, handles)
% hObject    handle to u_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of u_edit as text
%        str2double(get(hObject,'String')) returns contents of u_edit as a double
set(hObject,'BackgroundColor','white');

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
set(hObject,'BackgroundColor','white');


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
set(hObject,'BackgroundColor','white');

% --- Executes during object creation, after setting all properties.
function ei_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ei_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function eps_edit_Callback(hObject, eventdata, handles)
% hObject    handle to eps_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of eps_edit as text
%        str2double(get(hObject,'String')) returns contents of eps_edit as a double
set(hObject,'BackgroundColor','white');

% --- Executes during object creation, after setting all properties.
function eps_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to eps_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function psimin_edit_Callback(hObject, eventdata, handles)
% hObject    handle to psimin_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of psimin_edit as text
%        str2double(get(hObject,'String')) returns contents of psimin_edit as a double
set(hObject,'BackgroundColor','white');



% --- Executes during object creation, after setting all properties.
function psimin_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to psimin_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function psimax_edit_Callback(hObject, eventdata, handles)
% hObject    handle to psimax_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of psimax_edit as text
%        str2double(get(hObject,'String')) returns contents of psimax_edit as a double
set(hObject,'BackgroundColor','white');


% --- Executes during object creation, after setting all properties.
function psimax_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to psimax_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function alatt_edit_Callback(hObject, eventdata, handles)
% hObject    handle to alatt_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of alatt_edit as text
%        str2double(get(hObject,'String')) returns contents of alatt_edit as a double
set(hObject,'BackgroundColor','white');

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
set(hObject,'BackgroundColor','white');

% --- Executes during object creation, after setting all properties.
function angdeg_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to angdeg_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
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
        err_mess = sprinft('%s',err_codes(control_name));
        set(handles.message_text,'String',err_mess,'BackgroundColor','r');
        fprintf(2,'**** control %s ERROR: %s \n',control_name,err_mess);
        
        guidata(gcbo,handles);
        drawnow;
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
        'BackgroundColor','g');
catch ME
    ok = false;
    set(handles.([control_name,'_edit']),'BackgroundColor','r');
    
    err_mess = sprintf('parsing input exception: %s',ME.message);
    set(handles.message_text,'String',err_mess,'BackgroundColor','r');
    fprintf(2,'**** ERROR in control %s: %s\n',control_name,err_mess);
end

% --- Executes on button press in calc_pushbutton.
function calc_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to calc_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Clear error message
set(handles.message_text,'String','');
guidata(gcbo,handles);
drawnow;

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
        eval(sprintf('%s=[%g,%g,%g]',control{i},result{i}));
    else
        eval(sprintf('%s=%g',control{i},result{i}));
    end

end

% u=get(handles.u_edit,'String');
% v=get(handles.v_edit,'String');
% ei=get(handles.ei_edit,'String');
% eps=get(handles.eps_edit,'String');
% psimin=get(handles.psimin_edit,'String');
% psimax=get(handles.psimax_edit,'String');
% alatt=get(handles.alatt_edit,'String');
% angdeg=get(handles.angdeg_edit,'String');
%
% density=get(handles.latpt_edit,'String');

% if isempty(u) || isempty(v) || isempty(ei) || isempty(eps) || ...
%         isempty(psimin) || isempty(psimax)
%     set(handles.message_text,'String','Error - see Matlab command window for details');
%     disp('ERROR - Ensure you have given values for u, v, Ei, eps, psi min and psi max');
%     guidata(gcbo,handles);
%     drawnow;
%     warning('on');
%     return;
% end

% %must strip out square brackets, if user has inserted them:
% s1=strfind(u,'['); s2=strfind(u,']');
% if isempty(s1) && isempty(s2)
%     unew=textscan(u,'%f','delimiter',',');
%     unew=unew';
% elseif ~isempty(s1) && ~isempty(s2)
%     u=u(s1+1:s2-1);
%     unew=textscan(u,'%f','delimiter',',');
% else
%     set(handles.message_text,'String','Error - see Matlab command window for details');
%     disp('ERROR - Ensure u is of form a,b,c or [a,b,c]');
%     guidata(gcbo,handles);
%     drawnow;
%     warning('on');
%     return;
% end
% s1=strfind(v,'['); s2=strfind(v,']');
% if isempty(s1) && isempty(s2)
%     vnew=textscan(v,'%f','delimiter',',');
%     vnew=vnew';
% elseif ~isempty(s1) && ~isempty(s2)
%     v=v(s1+1:s2-1);
%     vnew=textscan(v,'%f','delimiter',',');
% else
%     set(handles.message_text,'String','Error - see Matlab command window for details');
%     disp('ERROR - Ensure v is of form a,b,c or [a,b,c]');
%     guidata(gcbo,handles);
%     drawnow;
%     warning('on');
%     return;
% end
% s1=strfind(alatt,'['); s2=strfind(alatt,']');
% if isempty(s1) && isempty(s2)
%     alattnew=textscan(alatt,'%f','delimiter',',');
%     alattnew=alattnew';
% elseif ~isempty(s1) && ~isempty(s2)
%     alatt=alatt(s1+1:s2-1);
%     alattnew=textscan(alatt,'%f','delimiter',',');
% else
%     set(handles.message_text,'String','Error - see Matlab command window for details');
%     disp('ERROR - Ensure lattice angles are of form a,b,c or [a,b,c]');
%     guidata(gcbo,handles);
%     drawnow;
%     warning('on');
%     return;
% end
% s1=strfind(angdeg,'['); s2=strfind(angdeg,']');
% if isempty(s1) && isempty(s2)
%     angdegnew=textscan(angdeg,'%f','delimiter',',');
%     angdegnew=angdegnew';
% elseif ~isempty(s1) && ~isempty(s2)
%     angdeg=angdeg(s1+1:s2-1);
%     angdegnew=textscan(angdeg,'%f','delimiter',',');
% else
%     set(handles.message_text,'String','Error - see Matlab command window for details');
%     disp('ERROR - Ensure lattice angles are of form alpha,beta,gamma or [alpha,beta,gamma]');
%     guidata(gcbo,handles);
%     drawnow;
%     warning('on');
%     return;
% end
% 
% 
% if isempty(density)
%     denno=[1,1,1];%default case with point density is to assume all points plotted
%     dennew='';
% else
%     %must strip out square brackets, if user has inserted them:
%     s1=strfind(density,'['); s2=strfind(density,']');
%     if isempty(s1) && isempty(s2)
%         dennew=textscan(density,'%f','delimiter',',');
%         dennew=dennew';
%     elseif ~isempty(s1) && ~isempty(s2)
%         density=density(s1+1:s2-1);
%         dennew=textscan(density,'%f','delimiter',',');
%     else
%         set(handles.message_text,'String','Error - see Matlab command window for details');
%         disp('ERROR - Ensure lattice point density of form a,b,c; [a,b,c]; or empty');
%         guidata(gcbo,handles);
%         drawnow;
%         warning('on');
%         return;
%     end
% end
% 
% try
%     if ischar(unew)
%         u=str2num(unew);
%     elseif iscell(unew)
%         u = unew{:};
%     else
%         u=unew;
%     end
%     if numel(u) ~=3
%         disp_error('Ensure u has 3 elements');
%         warning('on');
%         return;
%     end
%     if ischar(vnew)
%         v=str2num(vnew);
%     elseif iscell(vnew)
%         v = vnew{:};
%     else
%         v=vnew;
%     end
%     if numel(v) ~=3
%         disp_error('Ensure v has 3 elements');
%         warning('on');
%         return;
%     end
%     
%     ei=str2num(ei);
%     if numel(ei) ~=1
%         disp_error('Ensure Ei has 1 element');
%         warning('on');
%         return;
%     end
%     
%     eps=str2num(eps);
%     psimin=str2num(psimin);
%     psimax=str2num(psimax);
%     
%     if ischar(alattnew)
%         alatt=str2num(alattnew);
%     elseif iscell(alattnew)
%         alatt=alattnew{:};
%     else
%         alatt=alattnew;
%     end
%     if numel(alatt) ~=3
%         disp_error('Ensure lattice have 3 elements');
%         warning('on');
%         return;
%     end
%     
%     if ischar(angdegnew)
%         angdeg=str2num(angdegnew);
%     elseif iscell(angdegnew)
%         angdeg = angdegnew{:};
%     else
%         angdeg=angdegnew;
%     end
%     if numel(angdeg) ~=3
%         disp_error('Ensure angdeg have 3 elements');
%         warning('on');
%         return;
%     end
%     
%     if  numel(eps)~=1 || numel(psimin)~=1 || numel(psimax)~=1
%         disp_error('eps, psi min and psi max have 1 element');
%         warning('on');
%         return;
%     end
%     
%     if ischar(dennew)
%         density=str2num(dennew);
%     elseif iscell(dennew)
%         density=dennew{:};
%     else
%         density=dennew;
%     end
%     if isempty(dennew)
%         density=[1,1,1];
%     end
%     if numel(density) ~=3
%         disp_error('Ensure lattice point density has 3 elements');
%         warning('on');
%         return;
%     end
% catch
%     disp_error('Ensure u, v, lattice, Ei, eps, psi min, psi max and lattice point density are all numeric');
%     warning('on');
%     return;
% end

if eps>ei
    disp_error('Ensure eps is smaller than Ei');
    return;
end

if isfield(handles,'detpar')
    detpar=handles.detpar;
else
    disp_error('Ensure a valid par file is selected and loaded');
    return;
end

%If we get to this stage, then all of the inputs are OK, and we can
%proceed.

try
    [xcoords,ycoords,zcoords,pts,ptlabs]=...
        calc_coverage_from_detpars_v2(ei,eps,psimin,psimax,detpar,u,v,alatt,angdeg);
catch
    disp_error('non-trivial error on execution of calculations. Check inputs carefully...');
    return;
end

%Generate point labels with specified density
[pts2,ptlabs2]=generate_rlps(ei,u,v,alatt,angdeg,density);


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


function disp_error(err_code)
fprintf(2,'ERROR: %s\n',err_code);
set(handles.message_text,'String',['ERROR: ',err_code],...
    'BackgroundColor','r');
guidata(gcbo,handles);
drawnow;



% --------------------------------------------------------------------
function Untitled_1_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


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
    set(hObject,'BackgroundColor','white');
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
