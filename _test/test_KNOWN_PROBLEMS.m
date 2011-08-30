%% ----------------------
%  Rebin error
% -----------------------
hh=IX_dataset_2d(h1);
kk=rebin(hh,[5,15],[0.5,0.9]);

kk=rebin(hh,[5,15],[0.5,0.9],'int');


%% ----------------------
%  Why different?
% -----------------------
idef=integrate(p1);
iint=integrate(p1,'int');   % integration over x range, so does not coincide with p1
iave=integrate(p1,'ave');   % this is the same as p1; it should be as nout=1 for each bin
                            % - but it does look strange, as it is not an integral
acolor k; dd(p1); acolor r; pd(iint); acolor b; pd(iave)
keep_figure

rdef=rebin(p1);
rint=rebin(p1,'int');       % the end points are half the height of the input points.
rave=rebin(p1,'ave');       % this is the same as p1, as it should be because by construction only one point per bin
acolor k; dd(p1); acolor r; pd(rint); acolor b; pd(rave)
keep_figure


%% ----------------------
%  Why different?
% -----------------------
da(hp1)
lx 2 14; ly 4 7; lc 0 8
keep_figure
c2=cut(hp1,[2,0,14],[4,0,7]);
da(c2)
lc 0 8
keep_figure


%% =============================================================================================
% Solved
% ==============================================================================================

%% ----------------------
%  Shouldn't integrate result in integrals in output ?
% -----------------------
kk=integrate(h1);
acolor b
dh(h1)
acolor r
ph(kk)
