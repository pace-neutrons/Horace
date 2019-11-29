function this=save_SPE_data(this)
% the function wries the spe data as ascii or as hdf5 file on request

switch(this.fileExt)
    case this.hdfFileExt
     this=use_hdf(this,1);
    otherwise
     this=use_hdf(this,0);               
end
this=save(this);