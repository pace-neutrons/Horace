function [rez, n_errors, can_use_mex_4_combine] = check_horace_mex()
% function checks if horace mex files are compiled correctly and returns
% their version string.
%
% Usage:
%   >>[rez, n_errors] = check_horace_mex();
%   >>[rez, n_errors, can_use_mex_4_combine] = check_horace_mex();
%
% If some mex files are cannot be launched,the function returns the number of
% files not launched as n_errors, these mex files' versions strings will be
% empty.
%
% rez is cellarray, which contains the reply from mex files queried about their
% version
%
%

% list of the function names used in nice formatted messages formed by the
% function
functions_name_list={
    'accumulate_cut_c  : ', ...
    'bin_pixels_c      : ', ...
    'calc_projections  : ', ...
    'sort_pixels_by_bin: ', ...
    'recompute_bin_data: ', ...
    'combine_sqw       : ', ...
    'mtimesx_mex       : ', ...
    'hdf_mex_reader    : '
   };

% provide special treatment for combine_sqw function
combine_num = numel(functions_name_list)-2;

% list of the mex file handles used by Horace and verified by this script.
functions_handle_list={
    @accumulate_cut_c, ...
    @bin_pixels_c, ...
    @calc_projections_c, ...
    @sort_pixels_by_bins, ...
    @compute_pix_sums_c, ...
    @combine_sqw, ...
    @mtimesx_mex, ...
    @hdf_mex_reader
    };
rez = cell(numel(functions_name_list), 1);

n_errors=0;
can_use_mex_4_combine = true;
for i=1:numel(functions_name_list)
    try
        rez{i}=[functions_name_list{i},functions_handle_list{i}()];
    catch Err
        rez{i}=[' Error in ',functions_name_list{i},Err.message];
        if strcmpi(functions_name_list{combine_num},functions_name_list{i})
            can_use_mex_4_combine=false;
        else
            n_errors=n_errors+1;
        end
    end
end
