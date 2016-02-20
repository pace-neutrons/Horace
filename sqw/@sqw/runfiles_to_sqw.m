function [grid_size,urange]=runfiles_to_sqw(sqw_dummy_obj,conversion_par_list)
% interface to private rundata_write_to_sqw conversion function
%
% Used to run a conversion job on a separate matlab session, spawn from 
% gen_sqw so no checks on parameters validity are performed.
%
% Read a single rundata object, and create a single sqw file.
%
%   >> [grid_size, urange] = rundata_write_to_sqw (run_file, conversion_par_list)
%
% Input:
%  conversion_par_list cellarray of the structures containing the job parameters, 
%                      namely structures fith following fields:
% ------
%   run_file        initiated rundata object
%   sqw_file        full file name of output sqw file
%   grid_size_in    Scalar or row vector of grid dimensions.
%   urange_in       Range of data grid for output. If not given, then uses smallest hypercuboid
%                   that encloses the whole data range
%   instrument      object containing instrument information
%   sample          objects containing sample geometry information
%
% Output:
% -------
%   grid_size       Actual grid size used (size is unity along dimensions
%                   where there is zero range of the data points)
%   urange          Actual range of grid
% 
%
% $Revision$ ($Date$)
%


% catch case of single parameters set provided as structure and not an
% cellarray
%if ~iscell(conversion_par_list) 
%    conversion_par_list = {conversion_par_list};
%end

n_files = numel(conversion_par_list);
run_files    = cell(n_files,1);
tmp_fnames   = cell(n_files,1);

instrument_ref= conversion_par_list(1).instrument;
sample_ref    =conversion_par_list(1).sample;
instr         = repmat(instrument_ref,n_files,1);
sample        = repmat(sample_ref,n_files,1);

grid_size_in = conversion_par_list(1).grid_size_in;
urange_in = conversion_par_list(1).urange_in;
for i=1:n_files
    run_files{i}  = conversion_par_list(i).runfile;
    tmp_fnames{i} = conversion_par_list(i).sqw_file_name;
    instr(i)      = conversion_par_list(i).instrument;
    sample(i)     = conversion_par_list(i).sample;
end

[grid_size,urange] = rundata_write_to_sqw (run_files,tmp_fnames,...
            grid_size_in,urange_in,instr,sample,false);

