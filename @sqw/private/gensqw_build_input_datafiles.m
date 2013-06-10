function spe_data = gensqw_build_input_datafiles(input_data_files,par_file,alatt,angdeg,efix,psi,omega,dpsi,gl,gs)


% Input files
if ischar(input_data_files) && ~isempty(input_data_files) && size(input_data_files,1)==1
    input_data_files=cellstr(input_data_files);
elseif ~iscellstr(input_data_files)
    error('input_data_files (first argument) must be a single file name or cell array of file names')
end

if is_herbert_used() % =============================> rundata files processing
    % generate list of runfiles
    spe_data = gen_runfiles(input_data_files,par_file,alatt,angdeg,efix,psi,omega,dpsi,gl,gs);   
else
    % generate list of speData files    
    spe_data =  gensqw_build_input_datafiles_libisis(input_data_files);
end


function spe_data = gensqw_build_input_datafiles_libisis(spe_file)

% Input files

% Make names of intermediate files
spe_data = cell(size(spe_file));
nfiles   = numel(spe_file);


wk_ext  = get(hor_config,'sqw_ext');
for i=1:nfiles
 % build spe data structure on the basis of spe or hdf files 
    spe_data{i}=speData(spe_file{i});% The files can be found by its name. 
                                     % If the files can not be found,the
                                     % constructor fails (throw an error)
    [spe_path,spe_name,spe_ext]=fileparts(spe_file{i});
    if strcmpi(spe_ext,wk_ext)
        error('Extension type ''',wk_ext,''' not permitted for spe input files. Rename file(s)')
    end
end



