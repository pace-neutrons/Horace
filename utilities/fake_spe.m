function fake_spe(ndet,emin,de,emax,filename,filepath)

%This file generates a fake .spe file that can then be passed to Tobyfit so
%that simulations can be performed.
%
%Make a structure array of the correct form for a .spe file, then uses
%put_spe to turn it into a .spe file.
%
%ndet is no. of detectors; emin is minimum neutron energy transfer; emax is
%maximum neutron energy transfer; de is energy step size; filename is the
%name of the spe file to be generated; filepath is where it will end up;
%
%ndet=36864 for MAPS.
%ndet=69632 for Merlin/LET
%
%RE 8/4/08


energy=[emin:de:emax];
energy=energy';
energy_cen=[emin+(de/2):de:emax-(de/2)];
energy_cen=energy_cen';

length_en=length(energy);
S=ones(length_en-1,ndet);
ERR=S;%make S and ERR matrix of ones, so that when combined in an SQW file
%we should be able to work out how good the errorbars on our measurement
%will be.

temp.filename=filename;
temp.filepath=filepath;
temp.S=S;
temp.ERR=ERR;
temp.en=energy;

newloc=[filepath,filename];
%put_spe(temp,newloc);
w=spe(temp);%make independent of mgenie, and use libisis instead.
save(w,newloc);
