function [rez, n_errors, can_use_mex_4_combine,can_use_MPI] = check_horace_mex()
% function checks if horace mex files are compiled correctly and returns
% their version string.
%
% Usage:
%   >>[rez, n_errors] = check_horace_mex();
%   >>[rez, n_errors, can_use_mex_4_combine,can_use_herbert_mpi] = check_horace_mex();
%
% Returns:
% rez  -- cellarray, which contains the reply from mex files queried about their
%         version
% n_errors
%      -- If some mex files cannot be launched,the function returns the
%         number of files not launched as n_errors. These mex files'
%         versions strings will be empty or contain error returned by the
%         function
% combine_sqw and cpp_communicator mex files are tested separately and
% their failure are not counted in total n_errors.
%
% can_use_mex_4_combine
%      -- returns true if combine_sqw returns valid version
% can_use_MPI
%      -- returns true if cpp_communicator returns valid version.
%
% These two options are responsible for possibility of using threading in
% IO and custom MPI parallel extensions correspondignly.
%
% NOTE:
% TODO: currently routine does not counts hdf_mex_reader function errors
%       because this function is used in tests only. If the situation changes,
%       the routine has to be modified
%
%

% list of the function names used in nice formatted messages formed by the
% function
functions_name_list={
    'c_serialize       : ', ...
    'c_deserialize     : ', ...
    'c_serial_size     : ', ...
    'accumulate_cut_c  : ', ...
    'bin_pixels_c      : ', ...
    'calc_projections  : ', ...
    'sort_pixels_by_bin: ', ...
    'compute_pix_sums  : ', ...
    'mtimesx_mex       : ', ...
    'GetMD5            : ', ...
    'combine_sqw       : ', ...
    'cpp_communicator  : '  ...
    };

% list of the mex file handles used by Horace and verified by this script.
functions_handle_list={
    @c_serialize,@c_deserialize,@c_serial_size,...
    @accumulate_cut_c, ...
    @bin_pixels_c, ...
    @calc_projections_c, ...
    @sort_pixels_by_bins, ...
    @compute_pix_sums_c, ...
    @mtimesx_mex, ...
    @GetMD5, ...
    @combine_sqw, ...
    @cpp_communicator ...
    };
rez = cell(numel(functions_name_list), 1);

n_errors=0;
can_use_mex_4_combine = true;
can_use_MPI = true;
for i=1:numel(functions_name_list)
    try
        rez{i}=[functions_name_list{i},functions_handle_list{i}()];
    catch Err
        rez{i}=[' Error in ',functions_name_list{i},Err.message];

        if contains(functions_name_list{i},'combine_sqw') % provide special treatment
            % for combine_sqw function
            can_use_mex_4_combine=false;
        elseif contains(functions_name_list{i},'cpp_communicator')
            can_use_MPI = false;
        else
            n_errors=n_errors+1;
        end
    end
end
