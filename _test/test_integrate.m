%% =====================================================================================================================
% Setup location of reference functions (fortran or matlab)
% ======================================================================================================================
load('T:\SVN_area\Herbert_trunk\_test\test_IX_classes\test_IX_datasets_ref.mat');

set(herbert_config,'force_mex_if_use_mex',true);


%% =====================================================================================================================
% Test 1D integration
% ======================================================================================================================

clear('ih1_mex','ih1b_mex','ip1_mex','ip1b_mex','ihpa_mex','ihpb_mex','ihpc_mex',...
      'ih1',    'ih1b',    'ip1',    'ip1b',    'ihpa',    'ihpb',    'ihpc')
  
tol=-1e-14;

disp('===========================')
disp('    1D: Test integrate')
disp('===========================')

set(herbert_config,'use_mex',true);
ih1_mex=integrate(h1,5,10);
set(herbert_config,'use_mex',false);
ih1    =integrate(h1,5,10);
delta_IX_dataset_nd(ih1_mex,ih1,tol)
% disp_valerr(ih1_mex)
% disp_valerr(ih1)

set(herbert_config,'use_mex',true); 
ih1b_mex=integrate(h1,0,20);
set(herbert_config,'use_mex',false);
ih1b    =integrate(h1,0,20);
delta_IX_dataset_nd(ih1b_mex,ih1b,tol)
% disp_valerr(ih1b_mex)
% disp_valerr(ih1b)


set(herbert_config,'use_mex',true); 
ip1_mex=integrate(p1,5,10);
set(herbert_config,'use_mex',false);
ip1    =integrate(p1,5,10);
delta_IX_dataset_nd(ip1_mex,ip1,tol)
% disp_valerr(ip1_mex)
% disp_valerr(ip1)

set(herbert_config,'use_mex',true); 
ip1b_mex=integrate(p1,0,20);
set(herbert_config,'use_mex',false);
ip1b    =integrate(p1,0,20);
delta_IX_dataset_nd(ip1b_mex,ip1b,tol)
% disp_valerr(ip1b_mex)
% disp_valerr(ip1b)


% Big array
% ----------
tol=-1e-14;

set(herbert_config,'use_mex',true); 
ihpa_mex=integrate(hp_1d_big,105,110);
set(herbert_config,'use_mex',false);
ihpa    =integrate(hp_1d_big,105,110);
delta_IX_dataset_nd(ihpa_mex,ihpa,tol);

set(herbert_config,'use_mex',true); 
ihpb_mex=integrate(hp_1d_big,-10,550);
set(herbert_config,'use_mex',false);
ihpb    =integrate(hp_1d_big,-10,550);
delta_IX_dataset_nd(ihpb_mex,ihpb,tol);

set(herbert_config,'use_mex',true); 
ihpc_mex=integrate(hp_1d_big,-20,620);
set(herbert_config,'use_mex',false);
ihpc    =integrate(hp_1d_big,-20,620);
delta_IX_dataset_nd(ihpc_mex,ihpc,tol);


disp(' ')
disp('Done')
disp(' ')


%% =====================================================================================================================
% Test 2D integration
% ======================================================================================================================
clear('w2x_sim','w2y_sim','w2xy_sim','w2x_mex','w2y_mex','w2xy_mex','w2x','w2y','w2xy')

% Create IX_dataset_1d to be rebinned
pp1b=pp1; pp1.x_distribution=true;  pp1.y_distribution=true;
hp1b=hp1; hp1.x_distribution=false; hp1.y_distribution=true;
ph1b=ph1; ph1.x_distribution=true;  ph1.y_distribution=false;
hh1b=hh1; hh1.x_distribution=false; hh1.y_distribution=false;

w2ref=[pp1,hp1,ph1,hh1,pp1b,hp1b,ph1b,hh1b];

% Integration arguments
xdescr=[6,14];
ydescr=[4,10];
xint_arg={{xdescr}};
yint_arg={{ydescr}};
xyint_arg={{xdescr,ydescr}};

% Create arguments for output
clear tmp; tmp.val=0; tmp.err=0;
w2x_sim =repmat(IX_dataset_1d,size(w2ref));
w2y_sim =repmat(IX_dataset_1d,size(w2ref));
w2xy_sim=repmat(tmp,size(w2ref));
w2x_mex =repmat(IX_dataset_1d,size(w2ref));
w2y_mex =repmat(IX_dataset_1d,size(w2ref));
w2xy_mex=repmat(tmp,size(w2ref));
w2x =repmat(IX_dataset_1d,size(w2ref));
w2y =repmat(IX_dataset_1d,size(w2ref));
w2xy=repmat(tmp,size(w2ref));

% Set tolerance
tol=-1e-14;

% Test integrate_x
% ------------
disp('===========================')
disp('    2D: Test integrate_x')
disp('===========================')
for j=1:numel(xint_arg)
    disp(['=== ',num2str(j),' ==='])
    for i=1:numel(w2ref)
        disp(['= ',num2str(i)])
        set(herbert_config,'use_mex',false); 
        w2x_sim(i,j)=simple_integrate_x(w2ref(i),xint_arg{j}{:});
        set(herbert_config,'use_mex',true);
        w2x_mex(i,j)=integrate_x(w2ref(i),xint_arg{j}{:});
        set(herbert_config,'use_mex',false);
        w2x(i,j)=integrate_x(w2ref(i),xint_arg{j}{:});
        delta_IX_dataset_nd(w2x_sim(i,j),w2x_mex(i,j),tol)
        delta_IX_dataset_nd(w2x_sim(i,j),w2x(i,j),tol)
    end
end


% Test integrate_y
% ------------
disp('===========================')
disp('    2D: Test integrate_y')
disp('===========================')
for j=1:numel(yint_arg)
    disp(['=== ',num2str(j),' ==='])
    for i=1:numel(w2ref)
        disp(['= ',num2str(i)])
        set(herbert_config,'use_mex',false); 
        w2y_sim(i,j)=simple_integrate_y(w2ref(i),yint_arg{j}{:});
        set(herbert_config,'use_mex',true);
        w2y_mex(i,j)=integrate_y(w2ref(i),yint_arg{j}{:});
        set(herbert_config,'use_mex',false);
        w2y(i,j)=integrate_y(w2ref(i),yint_arg{j}{:});
        delta_IX_dataset_nd(w2y_sim(i,j),w2y_mex(i,j),tol)
        delta_IX_dataset_nd(w2y_sim(i,j),w2y(i,j),tol)
    end
end


% Test integrate
% ------------
disp('===========================')
disp('    2D: Test integrate')
disp('===========================')
for j=1:numel(xyint_arg)
    disp(['=== ',num2str(j),' ==='])
    for i=1:numel(w2ref)
        disp(['= ',num2str(i)])
        set(herbert_config,'use_mex',false); 
        w2xy_sim(i,j)=simple_integrate(w2ref(i),xyint_arg{j}{:});
        set(herbert_config,'use_mex',true);
        w2xy_mex(i,j)=integrate(w2ref(i),xyint_arg{j}{:});
        set(herbert_config,'use_mex',false);
        w2xy(i,j)=integrate(w2ref(i),xyint_arg{j}{:});
        delta_IX_dataset_nd(w2xy_sim(i,j),w2xy_mex(i,j),tol)
        delta_IX_dataset_nd(w2xy_sim(i,j),w2xy(i,j),tol)
    end
end

disp(' ')
disp('Done')
disp(' ')




%% =====================================================================================================================
% Test 3D integration
% ====================================================================================================================== 
clear('w3x_sim','w3y_sim','w3z_sim','w3xyz_sim','w3x_mex','w3y_mex','w3z_max','w3xyz_mex','w3x','w3y','w3z','w3xyz')

disp('===========================')
disp('    3D: Test integrate')
disp('===========================')

set(herbert_config,'use_mex',false); 
w3x_sim=simple_integrate_x(ppp1,[5,10]);
w3y_sim=simple_integrate_y(ppp1,[5,10]);
w3z_sim=simple_integrate_z(ppp1,[5,10]);
w3xyz_sim=simple_integrate(ppp1,[9,15],[6,11],[3,5]);

set(herbert_config,'use_mex',true); 
w3x_mex=integrate_x(ppp1,[5,10]);
w3y_mex=integrate_y(ppp1,[5,10]);
w3z_mex=integrate_z(ppp1,[5,10]);
w3xyz_mex=integrate(ppp1,[9,15],[6,11],[3,5]);
delta_IX_dataset_nd(w3x_sim,w3x_mex,-1e-14)
delta_IX_dataset_nd(w3y_sim,w3y_mex,-1e-14)
delta_IX_dataset_nd(w3z_sim,w3z_mex,-1e-14)
delta_IX_dataset_nd(w3xyz_sim,w3xyz_mex,-1e-14)

set(herbert_config,'use_mex',false); 
w3x=integrate_x(ppp1,[5,10]);
w3y=integrate_y(ppp1,[5,10]);
w3z=integrate_z(ppp1,[5,10]);
w3xyz=integrate(ppp1,[9,15],[6,11],[3,5]);
delta_IX_dataset_nd(w3x_sim,w3x,-1e-14)
delta_IX_dataset_nd(w3y_sim,w3y,-1e-14)
delta_IX_dataset_nd(w3z_sim,w3z,-1e-14)
delta_IX_dataset_nd(w3xyz_sim,w3xyz,-1e-14)


disp(' ')
disp('Done')
disp(' ')



%% =====================================================================================================================
% Save data
% ====================================================================================================================== 
% Save objects
output_file='c:\temp\test_integrate_output_new.mat';
save(output_file,'ih1_mex','ih1b_mex','ip1_mex','ip1b_mex','ihpa_mex','ihpb_mex','ihpc_mex',...
                 'ih1',    'ih1b',    'ip1',    'ip1b',    'ihpa',    'ihpb',    'ihpc',...
                 'w2x_sim','w2y_sim','w2xy_sim','w2x_mex','w2y_mex','w2xy_mex','w2x','w2y','w2xy',...
                 'w3x_sim','w3y_sim','w3z_sim','w3xyz_sim','w3x_mex','w3y_mex','w3z_mex','w3xyz_mex','w3x','w3y','w3z','w3xyz')
             
