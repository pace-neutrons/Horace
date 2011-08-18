%% Setup location of reference functions (fortran or matlab)
ref_loc=true;
test_loc=true;

%% Test 1D integration

use_mex(ref_loc)
ih1_ref=integrate_ref(h1,5,10);
use_mex(test_loc)
ih1    =integrate(h1,5,10);
disp_valerr(ih1_ref)
disp_valerr(ih1)

use_mex(ref_loc)
ih1_ref=integrate_ref(h1,0,20);
use_mex(test_loc)
ih1    =integrate(h1,0,20);
%ih1b   =integrate(h1)
disp_valerr(ih1_ref)
disp_valerr(ih1)
%disp_valerr(ih1b)


use_mex(ref_loc)
ip1_ref=integrate_ref(p1,5,10);
use_mex(test_loc)
ip1    =integrate(p1,5,10);
disp_valerr(ip1_ref)
disp_valerr(ip1)

use_mex(ref_loc)
ip1_ref=integrate_ref(p1,0,20);
use_mex(test_loc)
ip1    =integrate(p1,0,20);
ip1b   =integrate(p1);
disp_valerr(ip1_ref)
disp_valerr(ip1)
%disp_valerr(ip1b)


% Big array
% ----------
tol=-1e-14;

use_mex(ref_loc)
ihp_ref=integrate_ref(hp_1d_big,105,110);
use_mex(test_loc)
ihp    =integrate(hp_1d_big,105,110);
ans=delta_IX_dataset_nd(ihp_ref,ihp,tol);

use_mex(ref_loc)
ihp_ref=integrate_ref(hp_1d_big,-10,550);
use_mex(test_loc)
ihp    =integrate(hp_1d_big,-10,550);
ans=delta_IX_dataset_nd(ihp_ref,ihp,tol);

use_mex(ref_loc)
ihp_ref=integrate_ref(hp_1d_big,-20,620);
use_mex(test_loc)
ihp    =integrate(hp_1d_big,-20,620);
%ihpb   =integrate(hp_1d_big);
ans=delta_IX_dataset_nd(ihp_ref,ihp,tol);
%ans=delta_IX_dataset_nd(ihp_ref,ihpb,tol);



%% Test 2D integrate

pp1b=pp1; pp1.x_distribution=true;  pp1.y_distribution=true;
hp1b=hp1; hp1.x_distribution=false; hp1.y_distribution=true;
ph1b=ph1; ph1.x_distribution=true;  ph1.y_distribution=false;
hh1b=hh1; hh1.x_distribution=false; hh1.y_distribution=false;

w2ref=[pp1,hp1,ph1,hh1,pp1b,hp1b,ph1b,hh1b];
w2x_ref =repmat(IX_dataset_2d,size(w2ref));
w2y_ref =repmat(IX_dataset_2d,size(w2ref));
w2xy_ref=repmat(IX_dataset_2d,size(w2ref));
w2x =repmat(IX_dataset_2d,size(w2ref));
w2y =repmat(IX_dataset_2d,size(w2ref));
w2xy=repmat(IX_dataset_2d,size(w2ref));

tol=1e-14;
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





