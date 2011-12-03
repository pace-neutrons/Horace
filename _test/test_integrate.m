%% =====================================================================================================================
% Setup location of reference functions (fortran or matlab)
% ======================================================================================================================
ref_loc='fortran';
test_loc='matlab';


%% =====================================================================================================================
% Test 1D integration
% ======================================================================================================================

tol=0;

disp('===========================')
disp('    1D: Test integrate')
disp('===========================')

use_mex(ref_loc)
ih1_ref=integrate(h1,5,10);
use_mex(test_loc)
ih1    =integrate(h1,5,10);
delta_IX_dataset_nd(ih1_ref,ih1,tol)
% disp_valerr(ih1_ref)
% disp_valerr(ih1)

use_mex(ref_loc)
ih1b_ref=integrate(h1,0,20);
use_mex(test_loc)
ih1b    =integrate(h1,0,20);
delta_IX_dataset_nd(ih1b_ref,ih1b,tol)
% disp_valerr(ih1b_ref)
% disp_valerr(ih1b)


use_mex(ref_loc)
ip1_ref=integrate(p1,5,10);
use_mex(test_loc)
ip1    =integrate(p1,5,10);
delta_IX_dataset_nd(ip1_ref,ip1,tol)
% disp_valerr(ip1_ref)
% disp_valerr(ip1)

use_mex(ref_loc)
ip1b_ref=integrate(p1,0,20);
use_mex(test_loc)
ip1b    =integrate(p1,0,20);
delta_IX_dataset_nd(ip1b_ref,ip1b,tol)
% disp_valerr(ip1b_ref)
% disp_valerr(ip1b)


% Big array
% ----------
tol=-1e-14;

use_mex(ref_loc)
ihpa_ref=integrate(hp_1d_big,105,110);
use_mex(test_loc)
ihpa    =integrate(hp_1d_big,105,110);
ans=delta_IX_dataset_nd(ihpa_ref,ihpa,tol);

use_mex(ref_loc)
ihpb_ref=integrate(hp_1d_big,-10,550);
use_mex(test_loc)
ihpb    =integrate(hp_1d_big,-10,550);
ans=delta_IX_dataset_nd(ihpb_ref,ihpb,tol);

use_mex(ref_loc)
ihpc_ref=integrate(hp_1d_big,-20,620);
use_mex(test_loc)
ihpc    =integrate(hp_1d_big,-20,620);
ans=delta_IX_dataset_nd(ihpc_ref,ihpc,tol);


disp(' ')
disp('Done')
disp(' ')


%% =====================================================================================================================
% Test 2D integrate
% ======================================================================================================================

pp1b=pp1; pp1.x_distribution=true;  pp1.y_distribution=true;
hp1b=hp1; hp1.x_distribution=false; hp1.y_distribution=true;
ph1b=ph1; ph1.x_distribution=true;  ph1.y_distribution=false;
hh1b=hh1; hh1.x_distribution=false; hh1.y_distribution=false;

clear tmp; tmp.val=0; tmp.err=0;
w2ref=[pp1,hp1,ph1,hh1,pp1b,hp1b,ph1b,hh1b];
w2x_ref =repmat(IX_dataset_1d,size(w2ref));
w2y_ref =repmat(IX_dataset_1d,size(w2ref));
w2xy_ref=repmat(tmp,size(w2ref));
w2x =repmat(IX_dataset_1d,size(w2ref));
w2y =repmat(IX_dataset_1d,size(w2ref));
w2xy=repmat(tmp,size(w2ref));

tol=-1e-14;
xdescr=[6,14];
ydescr=[4,10];

% Test integrate_x
% ------------
disp('===========================')
disp('    2D: Test integrate_x')
disp('===========================')
xint_arg={{xdescr}};
for j=1:numel(xint_arg)
    disp(['=== ',num2str(j),' ==='])
    for i=1:numel(w2ref)
        use_mex(ref_loc)
        disp(['= ',num2str(i)])
        w2x_ref(i)=simple_integrate_x(w2ref(i),xint_arg{j}{:});
        use_mex(test_loc)
        w2x(i)=integrate_x(w2ref(i),xint_arg{j}{:});
        delta_IX_dataset_nd(w2x_ref(i),w2x(i),tol)
    end
end


% Test integrate_y
% ------------
disp('===========================')
disp('    2D: Test integrate_y')
disp('===========================')
yint_arg={{ydescr}};
for j=1:numel(yint_arg)
    disp(['=== ',num2str(j),' ==='])
    for i=1:numel(w2ref)
        use_mex(ref_loc)
        disp(['= ',num2str(i)])
        w2y_ref(i)=simple_integrate_y(w2ref(i),yint_arg{j}{:});
        use_mex(test_loc)
        w2y(i)=integrate_y(w2ref(i),yint_arg{j}{:});
        delta_IX_dataset_nd(w2y_ref(i),w2y(i),tol)
    end
end


% Test integrate
% ------------
disp('===========================')
disp('    2D: Test integrate')
disp('===========================')
xyint_arg={{xdescr,ydescr}};
for j=1:numel(xyint_arg)
    disp(['=== ',num2str(j),' ==='])
    for i=1:numel(w2ref)
        use_mex(ref_loc)
        disp(['= ',num2str(i)])
        w2xy_ref(i)=simple_integrate(w2ref(i),xyint_arg{j}{:});
        use_mex(test_loc)
        w2xy(i)=integrate(w2ref(i),xyint_arg{j}{:});
        delta_IX_dataset_nd(w2xy_ref(i),w2xy(i),tol)
    end
end

disp(' ')
disp('Done')
disp(' ')




%% =====================================================================================================================
% Test 3D rebind
% ====================================================================================================================== 
disp('===========================')
disp('    3D: Test integrate')
disp('===========================')

xx=simple_integrate_x(ppp1,[5,10]);
yy=simple_integrate_y(ppp1,[5,10]);
zz=simple_integrate_z(ppp1,[5,10]);
ii=simple_integrate(ppp1,[9,15],[6,11],[3,5]);
xxref=integrate_x(ppp1,[5,10]);
yyref=integrate_y(ppp1,[5,10]);
zzref=integrate_z(ppp1,[5,10]);
iiref=integrate(ppp1,[9,15],[6,11],[3,5]);
delta_IX_dataset_nd(xx,xxref,-1e-14)
delta_IX_dataset_nd(yy,yyref,-1e-14)
delta_IX_dataset_nd(zz,zzref,-1e-14)
delta_IX_dataset_nd(ii,iiref,-1e-14)

disp(' ')
disp('Done')
disp(' ')



%% =====================================================================================================================
% Save data
% ====================================================================================================================== 
% Save objects
output_file='c:\temp\test_integrate_output.mat';
save(output_file,'ih1_ref','ih1b_ref','ip1_ref','ip1b_ref','ihpa_ref','ihpb_ref','ihpc_ref',...
                 'w2x_ref','w2y_ref','w2xy_ref','xxref','yyref','zzref','iiref',...
                 'ih1','ih1b','ip1','ip1b','ihpa','ihpb','ihpc','w2x','w2y','w2xy','xx','yy','zz','ii')
             
