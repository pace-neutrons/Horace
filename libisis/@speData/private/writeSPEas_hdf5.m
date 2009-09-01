function this=writeSPEas_hdf5(this)
% the function writes the data, usually kept in spe file as hdf5 file
% it has to be consistent with readSPEfrom_hdf5(fileName) function,
% and number of other functions which read hdf5 directly;
if(~exist(this.fileDir,'dir'))
    this.fileDir=pwd;
end
hdf_fileName=fullfile(this.fileDir,[this.fileName this.hdfFileExt]);    

hdf5write(hdf_fileName,this.enName,this.en,...
                       this.SName,this.S,...
                       this.ErrName,this.ERR);

end
