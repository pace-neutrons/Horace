function varargout = horace_planner(varargin)
% HORACE_PLANNER_V2 M-file for horace_planner_v2.fig
%      HORACE_PLANNER_V2, by itself, creates a new HORACE_PLANNER_V2 or raises the existing
%      singleton*.
%
%      H = HORACE_PLANNER_V2 returns the handle to a new HORACE_PLANNER_V2 or the handle to
%      the existing singleton*.
%
%      HORACE_PLANNER_V2('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in HORACE_PLANNER_V2.M with the given input arguments.
%
%      HORACE_PLANNER_V2('Property','Value',...) creates a new HORACE_PLANNER_V2 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before horace_planner_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to horace_planner_v2_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help horace_planner_v2

% Last Modified by GUIDE v2.5 30-Oct-2015 14:11:02

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @horace_planner_v2_OpeningFcn, ...
                   'gui_OutputFcn',  @horace_planner_v2_OutputFcn, ...
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


% --- Executes just before horace_planner_v2 is made visible.
function horace_planner_v2_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to horace_planner_v2 (see VARARGIN)

% Choose default command line output for horace_planner_v2
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes horace_planner_v2 wait for user response (see UIRESUME)
% uiwait(handles.Planner);


% --- Outputs from this function are returned to the command line.
function varargout = horace_planner_v2_OutputFcn(hObject, eventdata, handles) 
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
    set(handles.message_text,'String','Par file loaded successfully');
    guidata(gcbo,handles);
    drawnow;
catch
    set(handles.message_text,'String','Error - see Matlab command window for details');
    disp('ERROR - no valid par file selected');
    guidata(gcbo,handles);
    drawnow;
end



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



function ei_edit_Callback(hObject, eventdata, handles)
% hObject    handle to ei_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ei_edit as text
%        str2double(get(hObject,'String')) returns contents of ei_edit as a double


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





% --- Executes on button press in calc_pushbutton.
function calc_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to calc_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Clear error message
set(handles.message_text,'String','');
guidata(gcbo,handles);
drawnow;

u=get(handles.u_edit,'String');
v=get(handles.v_edit,'String');
ei=get(handles.ei_edit,'String');
eps=get(handles.eps_edit,'String');
psimin=get(handles.psimin_edit,'String');
psimax=get(handles.psimax_edit,'String');
alatt=get(handles.alatt_edit,'String');
angdeg=get(handles.angdeg_edit,'String');

if isempty(u) || isempty(v) || isempty(ei) || isempty(eps) || ...
        isempty(psimin) || isempty(psimax)
    set(handles.message_text,'String','Error - see Matlab command window for details');
    disp('ERROR - Ensure you have given values for u, v, Ei, eps, psi min and psi max');
    guidata(gcbo,handles);
    drawnow;
    return;
else
    %must strip out square brackets, if user has inserted them:
    s1=strfind(u,'['); s2=strfind(u,']');
    if isempty(s1) && isempty(s2)
        unew=strread(u,'%f','delimiter',',');
        unew=unew';
    elseif ~isempty(s1) && ~isempty(s2)
        u=u(s1+1:s2-1);
        unew=strread(u,'%f','delimiter',',');
    else
        set(handles.message_text,'String','Error - see Matlab command window for details');
        disp('ERROR - Ensure u is of form a,b,c or [a,b,c]');
        guidata(gcbo,handles);
        drawnow;
        return;
    end
    s1=strfind(v,'['); s2=strfind(v,']');
    if isempty(s1) && isempty(s2)
        vnew=strread(v,'%f','delimiter',',');
        vnew=vnew';
    elseif ~isempty(s1) && ~isempty(s2)
        v=v(s1+1:s2-1);
        vnew=strread(v,'%f','delimiter',',');
    else
        set(handles.message_text,'String','Error - see Matlab command window for details');
        disp('ERROR - Ensure v is of form a,b,c or [a,b,c]');
        guidata(gcbo,handles);
        drawnow;
        return;
    end
    s1=strfind(alatt,'['); s2=strfind(alatt,']');
    if isempty(s1) && isempty(s2)
        alattnew=strread(alatt,'%f','delimiter',',');
        alattnew=alattnew';
    elseif ~isempty(s1) && ~isempty(s2)
        alatt=alatt(s1+1:s2-1);
        alattnew=strread(alatt,'%f','delimiter',',');
    else
        set(handles.message_text,'String','Error - see Matlab command window for details');
        disp('ERROR - Ensure lattice angles are of form a,b,c or [a,b,c]');
        guidata(gcbo,handles);
        drawnow;
        return;
    end
    s1=strfind(angdeg,'['); s2=strfind(angdeg,']');
    if isempty(s1) && isempty(s2)
        angdegnew=strread(angdeg,'%f','delimiter',',');
        angdegnew=angdegnew';
    elseif ~isempty(s1) && ~isempty(s2)
        angdeg=angdeg(s1+1:s2-1);
        angdegnew=strread(angdeg,'%f','delimiter',',');
    else
        set(handles.message_text,'String','Error - see Matlab command window for details');
        disp('ERROR - Ensure lattice angles are of form alpha,beta,gamma or [alpha,beta,gamma]');
        guidata(gcbo,handles);
        drawnow;
        return;
    end
end

try
    if ischar(unew)
        u=str2num(unew);
    else
        u=unew;
    end   
    if numel(u) ~=3
        disp_error('Ensure u have 3 elements');
        return;        
    end
    if ischar(vnew)
        v=str2num(vnew);
    else
        v=vnew;
    end
    if numel(v) ~=3
        disp_error('Ensure v have 3 elements');        
        return;        
    end
     
    ei=str2num(ei);
    if numel(ei) ~=1
        disp_error('Ensure Ei has 1 element');                
        return;        
    end
    
    eps=str2num(eps);
    psimin=str2num(psimin);
    psimax=str2num(psimax);
    
    if ischar(alattnew)
        alatt=str2num(alattnew);
    else
        alatt=alattnew;
    end
    if numel(alatt) ~=3
        disp_error('Ensure lattice have 3 elements');                        
        return;        
    end
    
    if ischar(angdegnew)
        angdeg=str2num(angdegnew);
    else
        angdeg=angdegnew;
    end
    if numel(angdeg) ~=3
        disp_error('Ensure angdeg have 3 elements');                                
        return;        
    end
    
    if  numel(eps)~=1 || numel(psimin)~=1 || numel(psimax)~=1 
        disp_error('eps, psi min and psi max have 1 element');                                        
        return;
    end    
catch
    disp_error('Ensure u, v, lattice, Ei, eps, psi min and psi max are all numeric');                                            
    return;
end

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

%Now make the plots:
axes(handles.axes1);
cla;%clear pre-existing plots on these axes
counter=1;
accumx=[]; accumy=[]; accumz=[];
jj=jet(30);

set(handles.message_text,'String','Calculating detector coverage...');
guidata(gcbo,handles);
drawnow;

%Calculate concave hull for first sample orientation
cloud=[xcoords{1}',ycoords{1}',zcoords{1}'];
cloud = cloud + (rand(size(cloud))-0.5)*0.001;%noisify points to avoid coplanar triangulation
cloud2=sortrows(cloud,[1,2,3]);%sort results
ind=[1:8:size(cloud2,1)];%now only use every 8th point (less dense point cloud)
cloud3=cloud2(ind,:);

%Look at distance from one point to its neighbours
dx=diff(cloud3(:,1)); dy=diff(cloud3(:,2)); dz=diff(cloud3(:,3));
dr=sqrt(dx.^2 + dy.^2 + dz.^2);
mdr=mean(dr);
mdz=max(dz);
dd=mean([mean(abs(dz)) mean(abs(dy)) mean(abs(dx))]);%some sort of measure of nn distance

%perform the triangulation / concave hull
%tic
[triHull, vbOutside, vbInside] = AlphaHull(cloud3,2*dd);
%toc

%Plot the first orientation:
%figure;
tt=trisurf(triHull(vbOutside,:),cloud3(:,1),cloud3(:,2),cloud3(:,3),... 
    'FaceColor',jj(1,:),'FaceAlpha',0.1);
set(tt,'EdgeColor','none');
hold on;
axis equal
drawnow

%Keep a running tab of the max/min values along the 3 axes
maxx=max(cloud3(:,1)); minx=min(cloud3(:,1));
maxy=max(cloud3(:,2)); miny=min(cloud3(:,2));
maxz=max(cloud3(:,3)); minz=min(cloud3(:,3));

%Now rotate the triangulation stepwise and plot:
psivals=linspace(psimin,psimax,30);
for i=2:numel(psivals)
    dpsi=psivals(i)-psivals(1);%relative change in orientation
    rotmat=[cosd(dpsi) sind(dpsi) 0; -sind(dpsi) cosd(dpsi) 0; 0 0 1];
    cloud4=(rotmat*cloud3')';
    
    %See if extent in any of the planes has changed:
    maxx2=max(cloud4(:,1)); minx2=min(cloud4(:,1));
    maxy2=max(cloud4(:,2)); miny2=min(cloud4(:,2));
    maxz2=max(cloud4(:,3)); minz2=min(cloud4(:,3));
    if minx2<minx; minx=minx2; end
    if maxx2>maxx; maxx=maxx2; end
    if miny2<miny; miny=miny2; end
    if maxy2>maxy; maxy=maxy2; end
    if minz2<minz; minz=minz2; end
    if maxz2>maxz; maxz=maxz2; end
    
    tt=trisurf(triHull(vbOutside,:),cloud4(:,1),cloud4(:,2),cloud4(:,3),... 
        'FaceColor',jj(i,:),'FaceAlpha',0.1);
    set(tt,'EdgeColor','none');
    hold on;
    axis equal
    drawnow;
end

%Finally, draw on the reciprocal lattice:
ptlabs(pts(:,1)>maxx)=[]; pts(pts(:,1)>maxx,:)=[]; 
ptlabs(pts(:,2)>maxy)=[]; pts(pts(:,2)>maxy,:)=[];
ptlabs(pts(:,3)>maxz)=[]; pts(pts(:,3)>maxz,:)=[];

ptlabs(pts(:,1)<minx)=[]; pts(pts(:,1)<minx,:)=[];
ptlabs(pts(:,2)<miny)=[]; pts(pts(:,2)<miny,:)=[];
ptlabs(pts(:,3)<minz)=[]; pts(pts(:,3)<minz,:)=[];

try
    plot3(pts(:,1),pts(:,2),pts(:,3),'ok','MarkerFaceColor','k');
    for i=1:size(pts,1)
        text(pts(i,1)+0.1,pts(i,2)+0.1,pts(i,3)+0.1,ptlabs{i});
    end
catch
    %something went wrong - e.g. invalid lattice pars or angles
    disp_error('non-trivial error on execution of calculations. (suspected invalid lattice pars or angles) Check lattice inputs carefully...');                  
    return;
end

colormap jet
cbarlab=colorbar;
caxis([psimin,psimax]);
%axis tight
xlabel('Q // u (Ang^-^1)');
ylabel('Q perp u [in uv-plane] (Ang^-^1)');
zlabel('Q perp uv-plane (Ang^-1^1)');
tt=title(['Ei=',num2str(ei),'meV, E=',num2str(eps),'meV, ',...
     num2str(psimin),'<psi<',num2str(psimax)]);
xlab=xlabel(cbarlab,'dataset psi vals');
xlabpos=get(xlab,'Position');
xlabpos(2)=psimax+0.08*abs(psimax-psimin);
set(xlab,'Position',xlabpos);


set(handles.message_text,'String','Calculation performed successfully');
guidata(gcbo,handles);
drawnow;

function disp_error(err_code)
disp(['ERROR: ',err_code]);
set(handles.message_text,'String','Error - see Matlab command window for details');
guidata(gcbo,handles);
drawnow;



% --------------------------------------------------------------------
function Untitled_1_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
