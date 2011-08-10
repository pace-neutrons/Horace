%% Test 1D rebin

% Test single objects
% --------------------
batch=true;     % set to false to get plots

xdescr_1=cell(1,3);
xdescr_1{1}=[5,2,11];
xdescr_1{2}=IX_dataset_1d(6:2:10);     % should give same results
xdescr_1{3}=IX_dataset_1d(5:2:11);     % should give *different* results

tol=1e-14;
disp('===========================')
disp('    1D: Test rebin')
disp('===========================')
for i=1:numel(xdescr_1)
    disp(['=== ',num2str(i),' ==='])
    % - reference
    p1_reb_ref=rebin_ref(p1,xdescr_1{i});
    p1_reb_int_ref=rebin_ref(p1,xdescr_1{i},'int');
    if ~batch, acolor k; dd(p1); acolor r; pd(p1_reb_ref); acolor g; pd(p1_reb_int_ref); keep_figure; end

    h1_reb_ref=rebin_ref(h1,xdescr_1{i});
    h1_reb_nodist_ref=rebin_ref(dist2cnt(h1),xdescr_1{i},'int');
    if ~batch, acolor k; dd(h1); acolor r; pd(h1_reb_ref); acolor g; pd(h1_reb_nodist_ref); keep_figure; end

    % - new rebin algorithm
    p1_reb=rebin(p1,xdescr_1{i});
    p1_reb_int=rebin(p1,xdescr_1{i},'int');
    if ~batch, acolor k; dd(p1); acolor r; pd(p1_reb); acolor g; pd(p1_reb_int); keep_figure; end

    h1_reb=rebin(h1,xdescr_1{i});
    h1_reb_nodist=rebin(dist2cnt(h1),xdescr_1{i},'int');
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
disp('    1D: Test rebin')
disp('===========================')

p1_reb1_ref=rebin_ref(p1,xdescr_21);
p1_reb2_ref=rebin_ref(p1,xdescr_22{:});
p1_reb3_ref=rebin_ref(p1,xdescr_23{:});
if ~batch, acolor k; dd(p1_reb1_ref); acolor r; pd(p1_reb2_ref); acolor g; pd(p1_reb3_ref+0.02); keep_figure; end

p1_reb1=rebin(p1,xdescr_21);
p1_reb2=rebin(p1,xdescr_22{:});
p1_reb3=rebin(p1,xdescr_23{:});
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
disp(' ')




% % Test on an array of objects
% % ----------------------------
% xnew=50:10:450;
% hp_1d_rebin_ref=rebin_ref(hp_1d_big,xnew);
% da(IX_dataset_2d(hp_1d_rebin_ref))
% 
% 
% hp_1d_rebin=rebin(hp_1d_big,xnew);
% da(IX_dataset_2d(hp_1d_rebin))

%% Test 2D rebin

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
xdescr=[6,2,14];
ydescr=[4,3,10];

% Test rebin_x
% ------------
disp('===========================')
disp('    2D: Test rebin_x')
disp('===========================')
xint_arg={{xdescr},{xdescr,'int'}};
for j=1:numel(xint_arg)
    disp(['=== ',num2str(j),' ==='])
    for i=1:numel(w2ref)
        disp(['= ',num2str(i)])
        w2x_ref(i)=simple_rebin_x(w2ref(i),xint_arg{j}{:});
        w2x(i)=rebin_x(w2ref(i),xint_arg{j}{:});
        delta_IX_dataset_nd(w2x_ref(i),w2x(i),tol)
    end
end


% Test rebin_y
% ------------
disp('===========================')
disp('    2D: Test rebin_y')
disp('===========================')
yint_arg={{ydescr},{ydescr,'int'}};
for j=1:numel(yint_arg)
    disp(['=== ',num2str(j),' ==='])
    for i=1:numel(w2ref)
        disp(['= ',num2str(i)])
        w2y_ref(i)=simple_rebin_y(w2ref(i),yint_arg{j}{:});
        w2y(i)=rebin_y(w2ref(i),yint_arg{j}{:});
        delta_IX_dataset_nd(w2y_ref(i),w2y(i),tol)
    end
end


% Test rebin
% ------------
disp('===========================')
disp('    2D: Test rebin')
disp('===========================')
xyint_arg={{xdescr,ydescr},{xdescr,ydescr,'int'}};
for j=1:numel(xyint_arg)
    disp(['=== ',num2str(j),' ==='])
    for i=1:numel(w2ref)
        disp(['= ',num2str(i)])
        w2xy_ref(i)=simple_rebin(w2ref(i),xyint_arg{j}{:});
        w2xy(i)=rebin(w2ref(i),xyint_arg{j}{:});
        delta_IX_dataset_nd(w2xy_ref(i),w2xy(i),tol)
    end
end




