function [spe_data,tmp_file] = gensqw_build_input_datafiles(dummy,spe_file,sqw_file)

% Make names of intermediate files
tmp_file = cell(size(spe_file));
spe_data = cell(size(spe_file));
nfiles   = numel(spe_file);

sqw_path=fileparts(sqw_file);
for i=1:nfiles
 % build spe data structure on the basis of spe or hdf files 
    spe_data{i}=speData(spe_file{i});% The files can be found by its name. 
                                     % If the files can not be found,the
                                     % constructor fails (throw an error)
    [spe_path,spe_name,spe_ext]=fileparts(spe_file{i});
    if strcmpi(spe_ext,'.tmp')
        error('Extension type ''.tmp'' not permitted for spe input files. Rename file(s)')
    end
    tmp_file{i}=fullfile(sqw_path,[spe_name,'.tmp']);
end



