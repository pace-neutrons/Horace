%% =====================================================================================================================
%  Setup location of reference functions (fortran or matlab)
% ======================================================================================================================
load('T:\SVN_area\Herbert_trunk\_test\test_IX_classes\test_IX_datasets_ref.mat');

set(herbert_config,'force_mex_if_use_mex',true);


%% =====================================================================================================================
%  Test 1D rebin
% ======================================================================================================================

% Test single objects
% --------------------
batch=true;     % set to false to get plots

xdescr_1=cell(1,4);
xdescr_1{1}=[5,2,11];
xdescr_1{2}=IX_dataset_1d(6:2:10);     % should give same results
xdescr_1{3}=IX_dataset_1d(5:2:11);     % should give *different* results
xdescr_1{4}=[5,11];

tol=1e-14;
disp('===========================')
disp('    1D: Test rebind')
disp('===========================')
for i=1:numel(xdescr_1)
    disp(['=== ',num2str(i),' ==='])
    % - reference
    set(herbert_config,'use_mex',true);

    p1_reb_ref=rebind(p1,xdescr_1{i});
    p1_reb_int_ref=rebind(p1,xdescr_1{i},'int');
    if ~batch, acolor k; dd(p1); acolor r; pd(p1_reb_ref); acolor g; pd(p1_reb_int_ref); keep_figure; end

    h1_reb_ref=rebind(h1,xdescr_1{i});
    h1_reb_nodist_ref=rebind(dist2cnt(h1),xdescr_1{i},'int');
    if ~batch, acolor k; dd(h1); acolor r; pd(h1_reb_ref); acolor g; pd(h1_reb_nodist_ref); keep_figure; end

    % - new rebind algorithm
    set(herbert_config,'use_mex',false);

    p1_reb=rebind(p1,xdescr_1{i});
    p1_reb_int=rebind(p1,xdescr_1{i},'int');
    if ~batch, acolor k; dd(p1); acolor r; pd(p1_reb); acolor g; pd(p1_reb_int); keep_figure; end

    h1_reb=rebind(h1,xdescr_1{i});
    h1_reb_nodist=rebind(dist2cnt(h1),xdescr_1{i},'int');
    if ~batch, acolor k; dd(h1); acolor r; pd(h1_reb); acolor g; pd(h1_reb_nodist); keep_figure; end
    if batch
        disp(['= 1'])
        delta_IX_dataset_nd(p1_reb_ref,p1_reb,tol)
        disp(['= 2'])
        delta_IX_dataset_nd(p1_reb_int_ref,p1_reb_int,tol)
        disp(['= 3'])
        delta_IX_dataset_nd(h1_reb_ref,h1_reb,tol)
        disp(['= 4'])
        delta_IX_dataset_nd(h1_reb_nodist_ref,h1_reb_nodist,tol)
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
disp('    1D: Test rebind')
disp('===========================')

set(herbert_config,'use_mex',true);
p1_reb1_ref=rebind(p1,xdescr_21);
p1_reb2_ref=rebind(p1,xdescr_22{:});
p1_reb3_ref=rebind(p1,xdescr_23{:});
if ~batch, acolor k; dd(p1_reb1_ref); acolor r; pd(p1_reb2_ref); acolor g; pd(p1_reb3_ref+0.02); keep_figure; end

set(herbert_config,'use_mex',false);
p1_reb1=rebind(p1,xdescr_21);
p1_reb2=rebind(p1,xdescr_22{:});
p1_reb3=rebind(p1,xdescr_23{:});
if ~batch, acolor k; dd(p1_reb1); acolor r; pd(p1_reb2); acolor g; pd(p1_reb3+0.02); keep_figure; end

if batch
    disp(['= 1'])
    delta_IX_dataset_nd(p1_reb1_ref,p1_reb1,tol)
    disp(['= 2'])
    delta_IX_dataset_nd(p1_reb2_ref,p1_reb2,tol)
    disp(['= 3'])
    delta_IX_dataset_nd(p1_reb3_ref,p1_reb3,tol)
end


disp(' ')
disp('Done')
disp(' ')




%% =====================================================================================================================
%  Test 2D rebin
% ======================================================================================================================

% Create IX_dataset_2d to be rebinned
pp1b=pp1; pp1.x_distribution=true;  pp1.y_distribution=true;
hp1b=hp1; hp1.x_distribution=false; hp1.y_distribution=true;
ph1b=ph1; ph1.x_distribution=true;  ph1.y_distribution=false;
hh1b=hh1; hh1.x_distribution=false; hh1.y_distribution=false;

w2ref=[pp1,hp1,ph1,hh1,pp1b,hp1b,ph1b,hh1b];

% Create set of rebin arguments
xdescr=[6,2,14];    % for rebind
ydescr=[4,3,10];
xdescrbin=6:2:14;   % equivalent for rebin
ydescrbin=4:3:10;
xint_arg={{xdescr},{xdescr,'int'}};
xintbin_arg={{xdescrbin},{xdescrbin,'int'}};
yint_arg={{ydescr},{ydescr,'int'}};
yintbin_arg={{ydescrbin},{ydescrbin,'int'}};
xyint_arg={{xdescr,ydescr},{xdescr,ydescr,'int'}};
xyintbin_arg={{xdescrbin,ydescrbin},{xdescrbin,ydescrbin,'int'}};

% Create IX_dataset_2d arrays for output
w2x_ref =repmat(IX_dataset_2d,size(w2ref),numel(xint_arg));
w2x =repmat(IX_dataset_2d,size(w2ref),numel(xint_arg));
w2y_ref =repmat(IX_dataset_2d,size(w2ref),numel(yint_arg));
w2y =repmat(IX_dataset_2d,size(w2ref),numel(yint_arg));
w2xy_ref=repmat(IX_dataset_2d,size(w2ref),numel(xyint_arg));
w2xy=repmat(IX_dataset_2d,size(w2ref),numel(xyint_arg));
w2binx =repmat(IX_dataset_2d,size(w2ref),numel(xint_arg));
w2biny =repmat(IX_dataset_2d,size(w2ref),numel(yint_arg));
w2binxy=repmat(IX_dataset_2d,size(w2ref),numel(xyint_arg));

% Set tolerance
tol=1e-14;

% Test rebind_x
% -------------
disp('===========================')
disp('    2D: Test rebind_x')
disp('===========================')
for j=1:numel(xint_arg)
    disp(['=== ',num2str(j),' ==='])
    for i=1:numel(w2ref)
        set(herbert_config,'use_mex',true);
        disp(['= ',num2str(i)])
        w2x_ref(i,j)=simple_rebind_x(w2ref(i),xint_arg{j}{:});
        set(herbert_config,'use_mex',false);
        w2x(i,j)=rebind_x(w2ref(i),xint_arg{j}{:});
        delta_IX_dataset_nd(w2x_ref(i),w2x(i),tol)
        w2binx(i,j)=rebin_x(w2ref(i),xintbin_arg{j}{:});
        delta_IX_dataset_nd(w2x_ref(i),w2binx(i),tol)
    end
end


% Test rebind_y
% ------------
disp('===========================')
disp('    2D: Test rebind_y')
disp('===========================')
for j=1:numel(yint_arg)
    disp(['=== ',num2str(j),' ==='])
    for i=1:numel(w2ref)
        set(herbert_config,'use_mex',true);
        disp(['= ',num2str(i)])
        w2y_ref(i,j)=simple_rebind_y(w2ref(i),yint_arg{j}{:});
        set(herbert_config,'use_mex',false);
        w2y(i,j)=rebind_y(w2ref(i),yint_arg{j}{:});
        delta_IX_dataset_nd(w2y_ref(i),w2y(i),tol)
        w2biny(i,j)=rebin_y(w2ref(i),yintbin_arg{j}{:});
        delta_IX_dataset_nd(w2y_ref(i),w2biny(i),tol)
    end
end


% Test rebind
% ------------
disp('===========================')
disp('    2D: Test rebind')
disp('===========================')
for j=1:numel(xyint_arg)
    disp(['=== ',num2str(j),' ==='])
    for i=1:numel(w2ref)
        set(herbert_config,'use_mex',true);
        disp(['= ',num2str(i)])
        w2xy_ref(i,j)=simple_rebind(w2ref(i),xyint_arg{j}{:});
        set(herbert_config,'use_mex',false);
        w2xy(i,j)=rebind(w2ref(i),xyint_arg{j}{:});
        delta_IX_dataset_nd(w2xy_ref(i),w2xy(i),tol)
        w2binxy(i,j)=rebin(w2ref(i),xyintbin_arg{j}{:});
        delta_IX_dataset_nd(w2xy_ref(i),w2binxy(i),tol)
    end
end

disp(' ')
disp('Done')
disp(' ')



%% =====================================================================================================================
%  Test 3D rebin
% ======================================================================================================================
disp('===========================')
disp('    3D: Test rebind')
disp('===========================')

xx=simple_rebind_x(ppp1,[5,0.5,10]);
yy=simple_rebind_y(ppp1,[5,0.5,10]);
zz=simple_rebind_z(ppp1,[5,0.5,10]);
ii=simple_rebind(ppp1,[9,0.6,15],[6,0.25,11],[3,0.5,5]);
xxref=rebind_x(ppp1,[5,0.5,10]);
yyref=rebind_y(ppp1,[5,0.5,10]);
zzref=rebind_z(ppp1,[5,0.5,10]);
iiref=rebind(ppp1,[9,0.6,15],[6,0.25,11],[3,0.5,5]);
delta_IX_dataset_nd(xx,xxref,-1e-14)
delta_IX_dataset_nd(yy,yyref,-1e-14)
delta_IX_dataset_nd(zz,zzref,-1e-14)
delta_IX_dataset_nd(ii,iiref,-1e-14)

disp(' ')
disp('Done')
disp(' ')







