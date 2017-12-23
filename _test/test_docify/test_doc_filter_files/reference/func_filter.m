function y = func_undocified (x)
% <#doc_beg:> main
%   Main function documentation
% <#doc_end:>

y = sub_func(x);

function y = sub_func (x)
% <#doc_beg:>
%   Main function documentation
% <#doc_end:>

y = base_func(x);

function y = base_func (x)
%   Main function documentation

%-------------------------------------------------------------------------------
% <#doc_beg:> base
%   Main function documentation
% <#doc_end:>
%-------------------------------------------------------------------------------

y = 2*x;
