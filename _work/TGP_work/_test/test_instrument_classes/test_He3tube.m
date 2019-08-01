function [walf,weff,wdel,wvard,wvarw]=test_He3tube
% Test the random points function 

%% Test the efficiency routines

mydet=IX_He3tube(0.0254,10,6.35e-4);

% Logarithmically spaced energies:
wvec=sqrt(logspace(-1,5,1e6)/2.07214);   


alf=macro_xs_dia(mydet,wvec);
walf=IX_dataset_1d(wvec,alf);

eff=effic(mydet,wvec);
weff=IX_dataset_1d(wvec,eff);
aeff=IX_dataset_1d(alf,eff);

del=del_d(mydet,wvec);
wdel=IX_dataset_1d(wvec,del);
adel=IX_dataset_1d(alf,del);

vard=var_d(mydet,wvec);
wvard=IX_dataset_1d(wvec,vard);
avard=IX_dataset_1d(alf,vard);

varw=var_w(mydet,wvec);
wvarw=IX_dataset_1d(wvec,varw);
avarw=IX_dataset_1d(alf,varw);


%% Limiting cases to check against analytic values. OK as of 28/9/15
wvec=0.5;

det_0=IX_He3tube(0.0254,0,6.35e-4);    % alf=0

det_m4=IX_He3tube(0.0254,0.414033901236988e-4,6.35e-4);    % alf=1e-4

det_p4=IX_He3tube(0.0254,4.140339012369877e4,6.35e-4);     % alf=1e4

det_inf=IX_He3tube(0.0254,Inf,6.35e-4);


irad=det_0.inner_rad;
ans_0=[det_0.effic(wvec),det_0.del_d(wvec)/irad,...
    sqrt(det_0.var_d(wvec))/irad,sqrt(det_0.var_w(wvec))/irad];

ans_m4=[det_m4.effic(wvec),det_m4.del_d(wvec)/irad,...
    sqrt(det_m4.var_d(wvec))/irad,sqrt(det_m4.var_w(wvec))/irad];

ans_inf=[det_inf.effic(wvec),det_inf.del_d(wvec)/irad,...
    det_inf.var_d(wvec)/irad^2,det_inf.var_w(wvec)/irad^2];


%% Test random_points

% For wvec=2, sintheta=1:
%   atms = 0      alf=0
%   atms = 0.001  alf=6.038e-4
%   atms = 0.01   alf=6.038e-3
%   atms = 2      alf=1.2076
%   atms = 20     alf=12.076
%   atms = Inf    alf=Inf


atms_arr=[0.001,0.01,2,20,Inf];
np=100000;
sintheta=1;
wvec=2;

% Test single pressure and wavevecetor
for iatms=1:numel(atms_arr)
    disp('-------------------------------------------------------------------')
    disp(['atms = ',num2str(atms_arr(iatms))])
    disp('-------------------------------------------------------------------')
    det_test=IX_He3tube(0.0254,atms_arr(iatms),6.35e-4);
    
    % Moments from special functions
    moms0=[det_test.effic(wvec),det_test.del_d(wvec),...
        sqrt(det_test.var_d(wvec)),sqrt(det_test.var_w(wvec))];
    
    % Moments from random sampling
    nrep=5;
    moms=zeros(nrep,4);
    tic
    for i=1:nrep
        [x,y] = random_points (det_test, wvec, sintheta, [np,10]);
        moms(i,:)=[NaN, mean(x(:)), sqrt(var(x(:))), sqrt(var(y(:)))];
    end
    t=1e6*toc/(nrep*numel(x))   % microseconds per random point
    
    % List results
    moms_mean = mean(moms,1);
    moms_std = std(moms,1);
    ndiff=round((moms0-moms_mean)./moms_std,3);
    [moms0(2:end);moms_mean(2:end);ndiff(2:end);moms_std(2:end)]
    
    disp(' ')
end

%% Now test random_points for a selection of alf all randomised

% For atms=0.2, sintheta=1
%   wvec = 1000 alf = 2.415e-4
%   wvec = 100  alf = 2.415e-3
%   wvec = 0.1  alf = 2.415
%   wvec = 0.01 alf = 24.15
%   wvec = 0    alf = Inf

wvec_arr = [1000,100,0.1,0.01,0];
np=100000;
sintheta=1;

det_test=IX_He3tube(0.0254,0.2,6.35e-4);
moms0=NaN(numel(wvec_arr),4);
moms_mean=NaN(numel(wvec_arr),4);
moms_std=NaN(numel(wvec_arr),4);
moms2_mean=NaN(numel(wvec_arr),4);

% First each alf separately
t=0;
nwvec=numel(wvec_arr);
for iwvec=1:nwvec
    wvec = wvec_arr(iwvec);

    % Moments from special functions
    moms0(iwvec,:)=[det_test.effic(wvec),det_test.del_d(wvec),...
        sqrt(det_test.var_d(wvec)),sqrt(det_test.var_w(wvec))];
    
    % Moments from random sampling
    nrep=5;
    moms=zeros(nrep,4);
    tic;
    for i=1:nrep
        [x,y] = random_points (det_test, wvec, sintheta, [np,10]);
        moms(i,:)=[NaN, mean(x(:)), sqrt(var(x(:))), sqrt(var(y(:)))];
    end
    t = t+toc;
    moms_mean(iwvec,:) = mean(moms,1);
    moms_std(iwvec,:) = std(moms,1);

end
t = 1e6*t/(nwvec*nrep*numel(x))

% Now compute all alf together in random order
kf = make_column(repmat(wvec_arr,[50*np,1]));
ind=randperm(numel(kf));
kf=kf(ind);
ok=cell(nwvec,1);
for i=1:nwvec
    ok{i}=(kf==wvec_arr(i));
end
kfcell={kf,kf',reshape(kf,[50*nwvec,np])};

t2=0;
for ikf=1:numel(kfcell)
    tic
    [xref,yref]=random_points (det_test, kfcell{ikf}, sintheta);
    t2=t2+toc;
    
    for iwvec=1:nwvec
        x=xref(ok{iwvec});
        y=yref(ok{iwvec});
        moms2_mean(iwvec,:)=[NaN, mean(x(:)), sqrt(var(x(:))), sqrt(var(y(:)))];
    end
end
t2 = 1e6*t2/(numel(kfcell)*numel(xref))


round(abs(moms0-moms_mean)./moms_std,3)
round(abs(moms0-moms2_mean)./moms_std,3)









