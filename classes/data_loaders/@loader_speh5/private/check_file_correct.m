function full_file_name= check_file_correct(full_file_name)
% the method verify if the file, provided exist and is correct hfd5 file

if ~isa(full_file_name,'char')
      error('LOAD_SPEH5:invalid_argument',' first parameter has to be a file name');                
else
    [ok,mess,full_file_name]=check_file_exist(full_file_name,{'.spe_h5'});
    if ~ok
        error('LOAD_SPEH5:invalid_argument',mess);
    end
end

if ~H5F.is_hdf5(full_file_name)
      error('LOAD_SPEH5:invalid_argument','file %s is not proper hdf5 file\n',full_file_name);
end

end

