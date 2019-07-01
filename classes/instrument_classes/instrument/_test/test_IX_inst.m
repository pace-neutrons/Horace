%==========================================================================
% Test IX_inst_DGfermi
instru=maps_instrument_for_tests(500,600,'S');

mm=instru.moderator;
aa=instru.aperture;
ff=instru.fermi_chopper;

kk = IX_inst_DGfermi(mm,aa,ff);

if kk.moderator.distance~=12
    error('Distance should be 12m')
end

mmnew = mm;
mmnew.distance = 199;
mmnew.pp(1) = 42;
kk.moderator = mmnew;
if kk.moderator.distance~=199
    error('Distance should be 199m')
end

if kk.moderator.energy~=0
    error('Energy should be 0')
end

ei_new = 254;
kk.energy = ei_new;
if kk.moderator.energy~=ei_new
    error('Energy not changed to new value')
end


%==========================================================================
% test IX_inst_DGdisk
efix=8;
make_msm = @(x)IX_mod_shape_mono(x.moderator,x.chop_shape,x.chop_mono);
instru = let_instrument_for_tests (efix, 280, 140, 20, 2, 2);
instru.chop_shape.frequency=171;

mm=instru.moderator;
ss=instru.chop_shape;
cc=instru.chop_mono;
hh = instru.horiz_div;
vv = instru.vert_div;

xx = IX_inst_DGdisk (mm,ss,cc,hh,vv);

if xx.moderator.energy~=0
    error('Energy should be 0')
end

ei_new = 8.04;
xx.energy = ei_new;
if xx.moderator.energy~=ei_new
    error('Energy not changed to new value')
end



