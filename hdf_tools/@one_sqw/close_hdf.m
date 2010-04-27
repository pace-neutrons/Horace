function this=close_hdf(this)
              
H5F.close (this.dnd_file_ID);

% properly account for number of opened one_sqw files
global nInstances;
nInstances=nInstances-1;
this.nInstance=nInstances;
this.file_is_opened=false;
