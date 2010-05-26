function this=readSPEfrom_hdf5(this)
% the functions reads the spe data fron hdf5 file
hdfFileName=fullfile(this.fileDir,[this.fileName this.hdfFileExt]);
this=read(this,hdfFileName);
end
