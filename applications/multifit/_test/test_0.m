function test_0
% First tests

% Test function evaluation
% -------------------------
% Assumes have created a data file
mftest_dir = fileparts(mfilename('fullpath'));
S=load(fullfile(mftest_dir,'/data/testdata_multifit_1.mat'));


%%--------------------------------------------------------------------------------------------------------------------
% Test structures into mfclass

SS.warr3 = [shift(S.w1,10),shift(S.w2,30),shift(S.w3,60)];


% Functions
kk = mfclass(IX_to_struct(SS.warr3));
kk = kk.set_fun (@mftest_gauss, [100,45,10]);
kk = kk.set_bfun (@mftest_bkgd, {[10,0],[20,0],[30,0]});
kk = kk.set_options('listing',2);

[wcalc, fitcalc] = kk.simulate;
wcalc=struct_to_IX(wcalc);

acolor r b k
dp(SS.warr3)
pl(wcalc)


% No background function for second dataset
kk = mfclass(IX_to_struct(SS.warr3));
kk = kk.set_fun (@mftest_gauss, [100,45,10]);
kk = kk.set_bfun (1,@mftest_bkgd, [10,0]);
kk = kk.set_bfun (3,@mftest_bkgd, [30,0]);
kk = kk.set_options('listing',2);

[wcalc, fitcalc] = kk.simulate;
wcalc=struct_to_IX(wcalc);

acolor r b k
dp(SS.warr3)
pl(wcalc)


% No background functions
kk = mfclass(IX_to_struct(SS.warr3));
kk = kk.set_fun (@mftest_gauss, [100,45,10]);
kk = kk.set_options('listing',2);

[wcalc, fitcalc] = kk.simulate;
wcalc=struct_to_IX(wcalc);

acolor r b k
dp(SS.warr3)
pl(wcalc)


% No foreground function
kk = mfclass(IX_to_struct(SS.warr3));
kk = kk.set_bfun (1,@mftest_bkgd, [10,0]);
kk = kk.set_bfun (3,@mftest_bkgd, [20,0]);
kk = kk.set_bfun (3,@mftest_bkgd, [30,0]);
kk = kk.set_options('listing',2);

[wcalc, fitcalc] = kk.simulate;
wcalc=struct_to_IX(wcalc);

acolor r b k
dp(SS.warr3)
pl(wcalc)



% No foreground function, and no background for dataset 2
kk = mfclass(IX_to_struct(SS.warr3));
kk = kk.set_bfun (1,@mftest_bkgd, [10,0]);
kk = kk.set_bfun (3,@mftest_bkgd, [30,0]);
kk = kk.set_options('listing',2);

[wcalc, fitcalc] = kk.simulate;
wcalc=struct_to_IX(wcalc);

acolor r b k
dp(SS.warr3)
pl(wcalc)


% No functions at all
kk = mfclass(IX_to_struct(SS.warr3));

try
    [wcalc, fitcalc] = kk.simulate;
    wcalc=struct_to_IX(wcalc);
    failed=false;
catch
    failed=true;
end
if ~failed
    error('Should have failed, as no foreground or background fit functions')
end


%%--------------------------------------------------------------------------------------------------------------------
% Test structures into multifit

% Functions
kk = multifit(IX_to_struct(SS.warr3));
kk = kk.set_fun (@mftest_gauss, [100,45,10]);
kk = kk.set_bfun (@mftest_bkgd, {[10,0],[20,0],[30,0]});
kk = kk.set_options('listing',2);

[wcalc, fitcalc] = kk.simulate;
wcalc=struct_to_IX(wcalc);

acolor r b k
dp(SS.warr3)
pl(wcalc)



