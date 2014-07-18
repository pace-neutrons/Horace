function [mex_messages,n_errors,minVer,maxVer,compilation_date]=check_horace_mex
% Checks if Horace mex files are compiled correctly and return information about mex files
%
%   >> [mex_messages,n_errors,minVer,maxVer,compilation_date] = check_horace_mex
%
% Output:
% -------
%   mex_messages        Cell array of strings with information about mex files
%   n_errors            Number of mex files which failed to launch
%   minVer              Least recent version number of a mex code file
%                      If n_errors>0, minVer=[]
%   maxVer              Most recent version number of a mex code file
%                      If n_errors>0, maxVer=[]
%   compilation_date    Date of the most recently compiled mex file
%                      If n_errors>0, set to ''
%
%
% $Revision$    $Date$


% List of the function names used in nice formatted messages formed by the function
functions_name_list={'accumulate_cut_c: ','bin_pixels_c    : ','calc_projections: ','sort_pixels_by_b: '};

% List of the mex files handles used by horace and verified by this script.
functions_handle_list={@accumulate_cut_c,@bin_pixels_c,@calc_projections_c,@sort_pixels_by_bins};
mex_messages = cell(numel(functions_name_list),1);

n_errors=0;
for i=1:numel(functions_name_list)
    try
        mex_messages{i}=[functions_name_list{i},functions_handle_list{i}()];
    catch Err
        mex_messages{i}=[' Error in',functions_name_list{i},Err.message];
        n_errors=n_errors+1;
    end
end

% Calculate minimum and maximum version numbers of mex files. If there are errors
% in deploying mex-files, the versions become undefined.
if n_errors==0 && nargout>2
    minVer = 1e+32;
    maxVer = -1;
    compilation_date=[];
    n_mex=numel(mex_messages);
    for i=1:n_mex
        ver_str=mex_messages{i};
        ind = regexp(ver_str,':');
        ver_s=ver_str(ind(3)+1:ind(3)+5);
        ver=sscanf(ver_s,'%d');
        if ver>maxVer;
            maxVer=ver;
            al=regexp(ver_str,'\(','split');
            compilation_date = al{2};
        end
        if ver<minVer
            minVer=ver;
        end
    end
else
    minVer=[];
    maxVer=[];
    compilation_date='';
end
