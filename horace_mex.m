function horace_mex
% Create mex files for all the Horace fortran routines

start_dir=pwd;
try
    % root directory is assumed to be that in which this function resides
    rootpath = fileparts(which('horace_mex'));
    cd(rootpath);

    in_rel_dir = ['fortran',filesep,'compaq'];
    out_rel_dir = ['@sqw',filesep,'private'];
        
    mex_single(in_rel_dir, out_rel_dir,'calc_proj_fortran.f');
    mex_single(in_rel_dir, out_rel_dir,'get_par_fortran.f');
    mex_single(in_rel_dir, out_rel_dir,'get_phx_fortran.f');
    mex_single(in_rel_dir, out_rel_dir,'get_spe_fortran.f');

    cd(start_dir);
    disp('Succesfully created all required mex files from fortran.')
catch
    disp('Problems creating mex files. Please try again.')
    cd(start_dir);
end

%----------------------------------------------------------------
function mex_single (in_rel_dir, out_rel_dir, flname)
% mex a single file
curr_dir = pwd;
flname = fullfile(curr_dir,in_rel_dir,flname);
outdir = fullfile(curr_dir,out_rel_dir);

disp(['Mex file creation from ',flname,' ...'])
mex(flname, '-outdir', outdir);
