function [ok,mess,Sout] = isvalid (this,S)
% Check that the fields of the Horace configuration are valid
%
%   >> [ok,mess,Sout] = isvalid (this,S)
%
% Input:
% ------
%   this    An instance of the class
%   S       A structure with fieldnames that are configuration parameters
%          and values that are to be tested as valid
%
% Output:
% -------
%   ok      True if all OK, false otherwise
%   mess    Message if not ok, empy otherwise
%   Sout    A structure with the fields possibly updated
%          For example, it may be that a field is required to be a logical
%          but this routine can be used to convert a numeric to a logical
%          as Sout.myflag=logical(S.myflag)

% Default return
ok=true;
Sout=S;
mess='';

% Perform checks
if ~is_whole_number(Sout.mem_chunk_size,[1,1e15])
    ok=false; mess='mem_chunk_size: must be a positive integer'; return
end

if ~is_whole_number(Sout.threads,[1,1e15])
    ok=false; mess='threads: Number of threads for c++ algorithms must be a positive integer'; return
end

if is_log_or_num_scalar(Sout.ignore_nan)
    Sout.ignore_nan=logical(Sout.ignore_nan);   % ensure is logical
else
    ok=false; mess='ignore_nan: Must be logical true or false, or integer 0 or 1'; return
end

if is_log_or_num_scalar(Sout.ignore_inf)
    Sout.ignore_inf=logical(Sout.ignore_inf);   % ensure is logical
else
    ok=false; mess='ignore_inf: Must be logical true or false, or integer 0 or 1'; return
end

if ~is_whole_number(Sout.horace_info_level,[-Inf,Inf])
    ok=false; mess='horace_info_level: must be an integer'; return
end

if is_log_or_num_scalar(Sout.use_mex)
    Sout.use_mex=logical(Sout.use_mex);         % ensure is logical
else
    ok=false; mess='use_mex: Must be logical true or false, or integer 0 or 1'; return
end

if is_log_or_num_scalar(Sout.delete_tmp)
    Sout.delete_tmp=logical(Sout.delete_tmp);   % ensure is logical
else
    ok=false; mess='delete_tmp: Must be logical true or false, or integer 0 or 1'; return
end


%==================================================================================================
function ok=is_whole_number(val,range)
% Check if an argument is an integer in the given range (which can include -Inf and +Inf
if isnumeric(val) && isscalar(val) && ~isnan(val) && val>=range(1) && val<=range(2) && ...
        (isinf(val)||rem(val,1)==0)
    ok=true;
else
    ok=false;
end

function ok=is_log_or_num_scalar(val)
% Determine if a value is a (non-empty) scalar logical, or is numeric 0 or 1
if isscalar(val) && (islogical(val) || (isnumeric(val) && (val==0 ||val==1)))
    ok=true;
else
    ok=false;
end
