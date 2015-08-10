function b=make_row(a)
% Force the array into a row.
%
%   >> b=make_row(a)
%
% Useful to avoid having to clear up temporary results e.g.
%   >> wout = myfunc (w, make_row(val(ok))));
% instead of:
%   >> tmp=val(ok)
%   >> wout = myfunc (w, tmp);
%   >> clear tmp

b=a(:)';
