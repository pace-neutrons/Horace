function this=saveData(this,varargin)
% save spe data to ASI or binary file depending on defaults or
% as requested by varargin;
%
% if you want to specify the format, two are currently supported
% saveData(this,'hdf') or saveData(this,'.h5') writes the data in hdf5 form
% all other values indicate that you write it as an ASCI file
%
if(~this.data_loaded)
    disp('speData:saveData','data are not loaded into the memory, nothing to do');
    return;
end
if(nargin==0)
    this=save_data(this);
    writeSPEas_hdf5(this);
else
    this=save_data_requested(this,varargin{1});
end

end
function this=save_data_requested(this,kind)
if(issting(kind))
    if(strcmp(kind,'hdf')||strcmp(kind,'.h5')||strcmp(kind,'h5'))
        this.fileExt=this.hdfFileExt;
    else
        this.fileExt=this.speFileExt;
    end
else
    disp(' the parameter specifying the data format has to be a string.',...
         ' Writing data in the default format ',this.fileExt);
end
    this=save_SPE_data(this);
end


