%% test integration
ih1_ref=integrate_ref(h1,5,10);
ih1    =integrate(h1,5,10);
disp_valerr(ih1_ref)
disp_valerr(ih1)

ih1_ref=integrate_ref(h1,0,20);
ih1    =integrate(h1,0,20);
ih1b    =integrate(h1);
disp_valerr(ih1_ref)
disp_valerr(ih1)
disp_valerr(ih1b)


ip1_ref=integrate_ref(p1,5,10);
ip1    =integrate(p1,5,10);
disp_valerr(ip1_ref)
disp_valerr(ip1)

ip1_ref=integrate_ref(p1,0,20);
ip1    =integrate(p1,0,20);
ip1b    =integrate(p1);
disp_valerr(ip1_ref)
disp_valerr(ip1)
disp_valerr(ip1b)


%% old stuff
pp1_1d=IX_dataset_1d(pp1);

pp1t=transpose(pp1);
pp1t_1d=IX_dataset_1d(pp1t);

xlo=3;
xhi=5;
wi=integrate(pp1_1d,xlo,xhi);   % integration via 1D case




