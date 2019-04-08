function this=loadData(this)
% the function loads the data from a file, initially binded to the class
% in the class constructor
%
%% $Revision:: 830 ($Date:: 2019-04-08 16:16:02 +0100 (Mon, 8 Apr 2019) $)
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
        use_mex=get(hor_config,'use_mex');
        if use_mex
            try
                [this.S,this.ERR,this.en] = get_ascii_file(fullFileName,'spe');
                this.data_loaded=true;
            catch 
                warning('HORACE:using_mex',' Can not read data using C++ routines -- reverted to Matlab\n Reason: %s',lasterr());
                use_mex=false;
            end
        end
        if ~use_mex
            [this.S,this.ERR,this.en] = get_spe_matlab(fullFileName);
            this.data_loaded=true;            
        end
    otherwise
        error('speData:loadData',' unsupported file extension %s',this.fileExt);
end
end
