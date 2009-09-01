function this=save_SPE_data(this)
% the function wries the spe data as ascii or as hdf5 file on request
switch(this.fileExt)
    case this.hdfFileExt
      writeSPEas_hdf5(this);
    otherwise
    % Write spe file using fortran routine
    file_tmp = fullfile(this.fileDir,[this.fileName '.spe']);
    disp(['Fortran writing of  ascii .spe file : ' file_tmp]);
    ierr=libisisexc('IXTutility','putspe',file_tmp,this.S,this.ERR,this.en');
    %ierr=put_spe_fortran(file_tmp,data.S,data.ERR,data.en);

    if round(ierr)~=0
        error(['Error writing spe data to ',file_tmp])
    end   
end
end