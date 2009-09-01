function this=readSPEfrom_hdf5(this)
% the functions reads the spe data fron hdf5 file
% these data have been previously written into this file by the function
% writeSPEas_hdf5.m
hdfFileName=fullfile(this.fileDir,[this.fileName this.hdfFileExt]);
if(exist(hdfFileName,'file'))
    this.en =hdf5read(hdfFile,this.enName);
    this.S  =hdf5read(hdfFile,this.SName);
    this.ERR=hdf5read(hdfFile,this.ErrName);
    this.data_loaded=true;
else
    data.en=[];
    data.S=[];
    data.ERR=[];
    this.data_loaded=false;    
    disp([' hdf file ' hdfFileName ' does not exist']);
end

end
