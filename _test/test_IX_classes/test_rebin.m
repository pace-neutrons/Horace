function test_rebin (varargin)
% Test rebin functions, optionally writing results to output file or testing against stored output
%
%   >> test_rebin           % Compare with previously saved results in test_rebin_output.mat
%                           % in the same folder as this function
%   >> test_rebin ('save')  % Save to test_rebin_output.mat in tempdir (type >> help tempdir
%                           % for information about the system specific location returned by tempdir)
%
% Reads IX_dataset_1d and IX_dataset_2d from .mat file as input to the tests
%
% Author: T.G.Perring

banner_to_screen(mfilename)

data_filename='testdata_IX_datasets_ref.mat';
results_filename='test_rebin_output.mat';

if nargin==1
    if ischar(varargin{1}) && size(varargin{1},1)==1 && isequal(lower(varargin{1}),'save')
        save_output=true;
    else
        error('Unrecognised option')
    end
elseif nargin==0
    save_output=false;
else
    error('Check number of input arguments')
end

%% =====================================================================================================================
%  Load data and setup reference functions (fortran or matlab)
% ======================================================================================================================
rootpath=fileparts(mfilename('fullpath'));

warning('off','MATLAB:unknownObjectNowStruct');
clob = onCleanup(@()warning('on','MATLAB:unknownObjectNowStruct'));

ld= load(fullfile(rootpath,data_filename));
% old classes conversion
flds =fieldnames(ld);
for i=1:numel(flds)
    fld = flds{i};
    if isstruct(ld.(fld))
        %assignin('caller', fld,IX_dataset_1d(ld.(fld)))
        eval([fld,' = IX_dataset_1d(ld.(fld));']);
    else
        %assignin('caller', fld,ld.(fld))
        eval([fld,' = ld.(fld);']);
    end
end


set(herbert_config,'force_mex_if_use_mex',true,'-buffer');


%% =====================================================================================================================
%  Test 1D rebin
% ======================================================================================================================
clear ('p1_reb_mex', 'p1_reb_int_mex', 'h1_reb_mex', 'h1_reb_nodist_mex', 'p1_reb', 'p1_reb_int', 'h1_reb', 'h1_reb_nodist')
clear ('p1_reb1_mex','p1_reb2_mex','p1_reb3_mex','p1_reb1','p1_reb2','p1_reb3')

% Test single objects
% --------------------
batch=true;     % set to false to get plots

xdescr_1=cell(1,4);
xdescr_1{1}=[5,2,11];
xdescr_1{2}=IX_dataset_1d(6:2:10);     % should give same results
xdescr_1{3}=IX_dataset_1d(5:2:11);     % should give *different* results
xdescr_1{4}=[5,11];

p1_reb_mex       =repmat(IX_dataset_1d,1,numel(xdescr_1));
p1_reb_int_mex   =repmat(IX_dataset_1d,1,numel(xdescr_1));
h1_reb_mex       =repmat(IX_dataset_1d,1,numel(xdescr_1));
h1_reb_nodist_mex=repmat(IX_dataset_1d,1,numel(xdescr_1));
p1_reb           =repmat(IX_dataset_1d,1,numel(xdescr_1));
p1_reb_int       =repmat(IX_dataset_1d,1,numel(xdescr_1));
h1_reb           =repmat(IX_dataset_1d,1,numel(xdescr_1));
h1_reb_nodist    =repmat(IX_dataset_1d,1,numel(xdescr_1));

tol=1e-13;
disp('===========================')
disp('    1D: Test rebin - part 1')
disp('===========================')
for i=1:numel(xdescr_1)
    disp(['=== ',num2str(i),' ==='])
    % - mex
    set(herbert_config,'use_mex',true,'-buffer');
    
    p1_reb_mex(i)=rebin(p1,xdescr_1{i});
    p1_reb_int_mex(i)=rebin(p1,xdescr_1{i},'int');
    if ~batch, acolor k; dd(p1); acolor r; pd(p1_reb_mex(i)); acolor g; pd(p1_reb_int_mex(i)); keep_figure; end
    
    h1_reb_mex(i)=rebin(h1,xdescr_1{i});
    h1_reb_nodist_mex(i)=rebin(dist2cnt(h1),xdescr_1{i},'int');
    if ~batch, acolor k; dd(h1); acolor r; pd(h1_reb_mex(i)); acolor g; pd(h1_reb_nodist_mex(i)); keep_figure; end
    
    % - matlab
    set(herbert_config,'use_mex',false,'-buffer');
    
    p1_reb(i)=rebin(p1,xdescr_1{i});
    p1_reb_int(i)=rebin(p1,xdescr_1{i},'int');
    if ~batch, acolor k; dd(p1); acolor r; pd(p1_reb(i)); acolor g; pd(p1_reb_int(i)); keep_figure; end
    
    h1_reb(i)=rebin(h1,xdescr_1{i});
    h1_reb_nodist(i)=rebin(dist2cnt(h1),xdescr_1{i},'int');
    if ~batch, acolor k; dd(h1); acolor r; pd(h1_reb(i)); acolor g; pd(h1_reb_nodist(i)); keep_figure; end
    if batch
        disp('= 1')
        delta_IX_dataset_nd(p1_reb_mex(i),p1_reb(i),tol)
        disp('= 2')
        delta_IX_dataset_nd(p1_reb_int_mex(i),p1_reb_int(i),tol)
        disp('= 3')
        delta_IX_dataset_nd(h1_reb_mex(i),h1_reb(i),tol)
        disp('= 4')
        delta_IX_dataset_nd(h1_reb_nodist_mex(i),h1_reb_nodist(i),tol)
    end
end
disp(' ')
disp(' ')


% Quick test of alternative syntax
% ------------------------------------
xdescr_21=[5,2,11];
xdescr_22={5,11};
xdescr_23={5,2,11};

disp('===========================')
disp('    1D: Test rebin - part 2')
disp('===========================')

set(herbert_config,'use_mex',true,'-buffer');
p1_reb1_mex=rebin(p1,xdescr_21);
p1_reb2_mex=rebin(p1,xdescr_22{:});
p1_reb3_mex=rebin(p1,xdescr_23{:});
if ~batch, acolor k; dd(p1_reb1_mex); acolor r; pd(p1_reb2_mex); acolor g; pd(p1_reb3_mex+0.02); keep_figure; end

set(herbert_config,'use_mex',false,'-buffer');
p1_reb1=rebin(p1,xdescr_21);
p1_reb2=rebin(p1,xdescr_22{:});
p1_reb3=rebin(p1,xdescr_23{:});
if ~batch, acolor k; dd(p1_reb1); acolor r; pd(p1_reb2); acolor g; pd(p1_reb3+0.02); keep_figure; end

if batch
    disp('= 1')
    delta_IX_dataset_nd(p1_reb1_mex,p1_reb1,tol)
    disp('= 2')
    delta_IX_dataset_nd(p1_reb2_mex,p1_reb2,tol)
    disp('= 3')
    delta_IX_dataset_nd(p1_reb3_mex,p1_reb3,tol)
end


disp(' ')
disp('Done')
disp(' ')




%% =====================================================================================================================
%  Test 2D rebin
% ======================================================================================================================
clear ('w2x_sim','w2y_sim','w2xy_sim','w2x_mex','w2y_mex','w2xy_mex','w2x','w2y','w2xy','w2binx','w2biny','w2binxy')

% Create IX_dataset_2d to be rebinned
pp1b=pp1; pp1.x_distribution=true;  pp1.y_distribution=true;
hp1b=hp1; hp1.x_distribution=false; hp1.y_distribution=true;
ph1b=ph1; ph1.x_distribution=true;  ph1.y_distribution=false;
hh1b=hh1; hh1.x_distribution=false; hh1.y_distribution=false;

w2ref=[pp1,hp1,ph1,hh1,pp1b,hp1b,ph1b,hh1b];

% Create set of rebin arguments
xdescr=[6,2,14];    % for rebin
ydescr=[4,3,10];
xdescrbin=6:2:14;   % equivalent for rebin2
ydescrbin=4:3:10;
xint_arg={{xdescr},{xdescr,'int'}};
xintbin_arg={{xdescrbin},{xdescrbin,'int'}};
yint_arg={{ydescr},{ydescr,'int'}};
yintbin_arg={{ydescrbin},{ydescrbin,'int'}};
xyint_arg={{xdescr,ydescr},{xdescr,ydescr,'int'}};
xyintbin_arg={{xdescrbin,ydescrbin},{xdescrbin,ydescrbin,'int'}};

% Create IX_dataset_2d arrays for output
w2x_sim  =repmat(IX_dataset_2d,numel(w2ref),numel(xint_arg));
w2x_mex  =repmat(IX_dataset_2d,numel(w2ref),numel(xint_arg));
w2x      =repmat(IX_dataset_2d,numel(w2ref),numel(xint_arg));
w2binx   =repmat(IX_dataset_2d,numel(w2ref),numel(xint_arg));
w2y_sim  =repmat(IX_dataset_2d,numel(w2ref),numel(yint_arg));
w2y_mex  =repmat(IX_dataset_2d,numel(w2ref),numel(yint_arg));
w2y      =repmat(IX_dataset_2d,numel(w2ref),numel(yint_arg));
w2biny   =repmat(IX_dataset_2d,numel(w2ref),numel(yint_arg));
w2xy_sim =repmat(IX_dataset_2d,numel(w2ref),numel(xyint_arg));
w2xy_mex =repmat(IX_dataset_2d,numel(w2ref),numel(xyint_arg));
w2xy     =repmat(IX_dataset_2d,numel(w2ref),numel(xyint_arg));
w2binxy  =repmat(IX_dataset_2d,numel(w2ref),numel(xyint_arg));

% Set tolerance
tol=1e-13;

% Test rebin_x
% -------------
disp('===========================')
disp('    2D: Test rebin_x')
disp('===========================')
for j=1:numel(xint_arg)
    disp(['=== ',num2str(j),' ==='])
    for i=1:numel(w2ref)
        disp(['= ',num2str(i)])
        set(herbert_config,'use_mex',false,'-buffer');
        w2x_sim(i,j)=simple_rebin_x(w2ref(i),xint_arg{j}{:});
        set(herbert_config,'use_mex',true,'-buffer');
        w2x_mex(i,j)=rebin_x(w2ref(i),xint_arg{j}{:});
        set(herbert_config,'use_mex',false,'-buffer');
        w2x(i,j)=rebin_x(w2ref(i),xint_arg{j}{:});
        w2binx(i,j)=rebin2_x(w2ref(i),xintbin_arg{j}{:});
        delta_IX_dataset_nd(w2x_sim(i,j),w2x_mex(i,j),tol)
        delta_IX_dataset_nd(w2x_sim(i,j),w2x(i,j),tol)
        delta_IX_dataset_nd(w2x_sim(i,j),w2binx(i,j),tol)
    end
end


% Test rebin_y
% ------------
disp('===========================')
disp('    2D: Test rebin_y')
disp('===========================')
for j=1:numel(yint_arg)
    disp(['=== ',num2str(j),' ==='])
    for i=1:numel(w2ref)
        disp(['= ',num2str(i)])
        set(herbert_config,'use_mex',false,'-buffer');
        w2y_sim(i,j)=simple_rebin_y(w2ref(i),yint_arg{j}{:});
        set(herbert_config,'use_mex',true,'-buffer');
        w2y_mex(i,j)=rebin_y(w2ref(i),yint_arg{j}{:});
        set(herbert_config,'use_mex',false,'-buffer');
        w2y(i,j)=rebin_y(w2ref(i),yint_arg{j}{:});
        w2biny(i,j)=rebin2_y(w2ref(i),yintbin_arg{j}{:});
        delta_IX_dataset_nd(w2y_sim(i,j),w2y_mex(i,j),tol)
        delta_IX_dataset_nd(w2y_sim(i,j),w2y(i,j),tol)
        delta_IX_dataset_nd(w2y_sim(i,j),w2biny(i,j),tol)
    end
end


% Test rebin
% ------------
disp('===========================')
disp('    2D: Test rebin')
disp('===========================')
for j=1:numel(xyint_arg)
    disp(['=== ',num2str(j),' ==='])
    for i=1:numel(w2ref)
        disp(['= ',num2str(i)])
        set(herbert_config,'use_mex',false,'-buffer');
        w2xy_sim(i,j)=simple_rebin(w2ref(i),xyint_arg{j}{:});
        set(herbert_config,'use_mex',true,'-buffer');
        w2xy_mex(i,j)=rebin(w2ref(i),xyint_arg{j}{:});
        set(herbert_config,'use_mex',false,'-buffer');
        w2xy(i,j)=rebin(w2ref(i),xyint_arg{j}{:});
        w2binxy(i,j)=rebin2(w2ref(i),xyintbin_arg{j}{:});
        delta_IX_dataset_nd(w2xy_sim(i,j),w2xy_mex(i,j),tol)
        delta_IX_dataset_nd(w2xy_sim(i,j),w2xy(i,j),tol)
        delta_IX_dataset_nd(w2xy_sim(i,j),w2binxy(i,j),tol)
    end
end

disp(' ')
disp('Done')
disp(' ')



%% =====================================================================================================================
%  Test 3D rebin
% ======================================================================================================================
clear('w3x_sim','w3y_sim','w3z_sim','w3xyz_sim','w3x_mex','w3y_mex','w3z_max','w3xyz_mex','w3x','w3y','w3z','w3xyz')

disp('===========================')
disp('    3D: Test rebin')
disp('===========================')

tol=-1e-13;

set(herbert_config,'use_mex',false,'-buffer');
w3x_sim=simple_rebin_x(ppp1,[5,0.5,10]);
w3y_sim=simple_rebin_y(ppp1,[5,0.5,10]);
w3z_sim=simple_rebin_z(ppp1,[5,0.5,10]);
w3xyz_sim=simple_rebin(ppp1,[9,0.6,15],[6,0.25,11],[3,0.5,5]);

set(herbert_config,'use_mex',true,'-buffer');
w3x_mex=rebin_x(ppp1,[5,0.5,10]);
w3y_mex=rebin_y(ppp1,[5,0.5,10]);
w3z_mex=rebin_z(ppp1,[5,0.5,10]);
w3xyz_mex=rebin(ppp1,[9,0.6,15],[6,0.25,11],[3,0.5,5]);
delta_IX_dataset_nd(w3x_sim,w3x_mex,tol)
delta_IX_dataset_nd(w3y_sim,w3y_mex,tol)
delta_IX_dataset_nd(w3z_sim,w3z_mex,tol)
delta_IX_dataset_nd(w3xyz_sim,w3xyz_mex,tol)

set(herbert_config,'use_mex',false,'-buffer');
w3x=rebin_x(ppp1,[5,0.5,10]);
w3y=rebin_y(ppp1,[5,0.5,10]);
w3z=rebin_z(ppp1,[5,0.5,10]);
w3xyz=rebin(ppp1,[9,0.6,15],[6,0.25,11],[3,0.5,5]);
delta_IX_dataset_nd(w3x_sim,w3x,tol)
delta_IX_dataset_nd(w3y_sim,w3y,tol)
delta_IX_dataset_nd(w3z_sim,w3z,tol)
delta_IX_dataset_nd(w3xyz_sim,w3xyz,tol)


disp(' ')
disp('Done')
disp(' ')


%% =====================================================================================================================
% Compare with saved output
% ======================================================================================================================
if ~save_output
    disp('====================================')
    disp('    Comparing with saved output')
    disp('====================================')
    output_file=fullfile(rootpath,results_filename);
    old=load(output_file);
    nam=fieldnames(old);
    tol=-1.0e-13;
    for i=1:numel(nam)
        fld = nam{i};
        if isstruct(old.(fld)) && isa(eval(fld),'IX_dataset_1d')
            old.(fld) = IX_dataset_1d(old.(fld));
        end
        [ok,mess]=equal_to_tol(eval(fld),  old.(fld), tol);
        assertTrue(ok,['[',nam{i},']',mess]);
        
    end
    % Success announcement
    banner_to_screen([mfilename,': Test(s) passed (matches are within requested tolerances)'],'bot')
end


%% =====================================================================================================================
% Save data
% ======================================================================================================================
if save_output
    disp('===========================')
    disp('    Save output')
    disp('===========================')
    
    output_file=fullfile(tempdir,results_filename);
    save(output_file, 'p1_reb_mex', 'p1_reb_int_mex', 'h1_reb_mex', 'h1_reb_nodist_mex', 'p1_reb', 'p1_reb_int', 'h1_reb', 'h1_reb_nodist',...
        'p1_reb1_mex','p1_reb2_mex','p1_reb3_mex','p1_reb1','p1_reb2','p1_reb3',...
        'w2x_sim','w2y_sim','w2xy_sim','w2x_mex','w2y_mex','w2xy_mex','w2x','w2y','w2xy','w2binx','w2biny','w2binxy',...
        'w3x_sim','w3y_sim','w3z_sim','w3xyz_sim','w3x_mex','w3y_mex','w3z_mex','w3xyz_mex','w3x','w3y','w3z','w3xyz')
    
    disp(' ')
    disp(['Output saved to ',output_file])
    disp(' ')
end
