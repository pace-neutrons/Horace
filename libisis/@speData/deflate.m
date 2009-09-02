function this=deflate(this)
% the function removes the spe data from memory to save memory
% if the data are initially in ASCI fomat, it also writes the data file in hdf5
% format for faster access in a future
%
%% $Revision$ ($Date$)
if(strcmp(this.fileExt,this.speFileExt)) % then the data are written in a very
                                         %inefficient spe format, let's fix it
     writeSPEas_hdf5(this);              % and rewrite it as an hdf5, it will not take essential time
     this.fileExt=this.hdfFileExt;
end
this.S=[];
this.ERR=[];
end
