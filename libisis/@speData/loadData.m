function this=loadData(this)
% the function loads the data from a file, initially bind to the class
% in the class constructor
%
%% $Revision$ ($Date$)
%
if(isempty(this.fileName))
  disp(' spe object is not bound to a file, can not load the data');
  this.data_loaded=false;
  return;
else

fullFileName=fullfile(this.fileDir,[this.fileName this.fileExt]);
if(~exist(fullFileName,'file'))
    error('speData:loadData','file %s can not be found',fullFileName);
end
switch(lower(this.fileExt))
    case (this.hdfFileExt)

        this.S   = hdf5read(fullFileName,this.SName);
        this.ERR = hdf5read(fullFileName,this.ErrName);
        this.data_loaded=true;
    case (this.speFileExt)
        try
            [this.S,this.ERR,this.en] = get_ascii_file(fullFileName,'spe');
            this.data_loaded=true;
        catch
            warning(' can not read data using fortran routines -- reverted to Matlab')
            [this.S,this.ERR,this.en] = get_spe_matlab(fullFileName);
            this.data_loaded=true;
        end
    otherwise
        error('speData:loadData',' unsupported file extension %s',this.fileExt);
end
end
