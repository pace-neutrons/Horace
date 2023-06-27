function [rez, n_errors] = check_herbert_mex()
% function checks if horace mex files are compiled correctly and returns
% their versions.
%
% Usage:
%
%   >>[rez,n_errors]=check_herbert_mex();
%
% If some mex files are can not be launched,the function returns the number of
% files not launched as n_errors. mex-files versions strings become empty.
%
% rez is cellarray, which contains reply from mex files queried about their
% version
%

% list of the function names used in nice formatted messages formed by the
% function
functions_name_list = {
    'get_ascii_file    : ', ...
    'cpp_communicator  : ', ...
    'c_serialize       : ', ...    
    'c_deserialize     : ', ...    
    'c_serial_sise     : ', ...        
};
% list of the mex files handles used by Horace and verified by this script.
functions_handle_list = {@get_ascii_file, @cpp_communicator,...
    @c_serialize,@c_deserialize,@c_serial_size};

rez = cell(numel(functions_name_list), 1);
n_errors = 0;
for i = 1:numel(functions_name_list)
    try
        rez{i} = [functions_name_list{i}, functions_handle_list{i}()];
    catch Err
        rez{i} = [' Error in ', functions_name_list{i}, Err.message];
        n_errors = n_errors + 1;
    end
end
