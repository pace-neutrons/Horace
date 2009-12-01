function this=deflate(this,varargin)
% the function removes the spe data from memory to save memory
% if the data are initially in ASCI fomat, it also writes the data file in hdf5
% format for faster access in a future
%
% defaults have changed temporary -- if no varargin is present, the subroutine does not write hdf
% 
% if varargin is present, and set to 'hdf' (default) it works as no
% varargin is present
% if varargin has any other value, the sub does not write hdf at all
%
%% $Revision$ ($Date$)
% 
if(isempty(this.S)&& isempty(this.ERR))
    return;
end

if(isempty(varargin))
    write_hdf =false;
else
    if(strcmp(varargin{1},'hdf'))
            write_hdf =true;
    else
            write_hdf =false;        
    end
end

if(write_hdf)
    if(strcmp(this.fileExt,this.speFileExt)) % then the data are written in a very
                                         %inefficient spe format, let's fix it
         writeSPEas_hdf5(this);              % and rewrite it as an hdf5, it will not take essential time
         this.fileExt=this.hdfFileExt;
    end
end
this.S=[];
this.ERR=[];
end
