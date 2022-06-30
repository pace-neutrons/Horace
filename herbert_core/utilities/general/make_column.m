function b=make_column(a)
% Force the array into a column.
%
%   >> b=make_column(a)
%
% Useful to avoid having to clear up temporary results e.g.
%   >> wout = accumarray (ind, make_column(val(ok))), [nbin,ne]);
% instead of:
%   >> tmp=val(ok)
%   >> wout = accumarray (ind, tmp(:), [nbin,ne]);
%   >> clear tmp


% Only perform operation if required - save memory and time
if ~iscolvector(a)
    b=a(:);
else
    b=a;
end
