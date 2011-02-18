function this=deflate(this,varargin)
% the function removes the spe data from memory to save memory
% if the data are initially in ASCI fomat, it also writes the data file in hdf5
% format for faster access in a future
%
% if varargin is present, and set to 'hdf' it writes hdf file
%
% if varargin has any other value, the sub does not write hdf file
%
% defaults what to do if no varargin is present are defined by the
% constructor 
% 

% $Revision$ ($Date$)
% 
% 
if(isempty(varargin))
     write_hdf =this.ifTransfer2hdf;
else
     if(strcmp(varargin{1},'hdf'))
             write_hdf =true;
     else
             write_hdf =false;        
     end
end
 
if(write_hdf)
   if(strcmpi(this.fileExt,this.speFileExt)) % then the data are written in a very
                                             %inefficient spe format, let's fix it
          this=use_hdf(this,1);              % and rewrite it as an hdf5, it will be quick
          this=save(this);       
          this.fileExt=this.hdfFileExt;
   end
 end
this=delete(this);
