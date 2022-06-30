function w = csc_single (w1)
% -----------------------------------------------------------------------------
% <#doc_def:>
%   doc_dir = fullfile(fileparts(which('sigvar')),'_docify')
%   doc_file_header = fullfile(doc_dir,'doc_sigvar_unary_single.m')
%
%   func_name = 'csc'
% -----------------------------------------------------------------------------
% <#doc_beg:> binary_and_unary_ops
%   <#file:> <doc_file_header>
% <#doc_end:>
% -----------------------------------------------------------------------------

s = csc(w1.signal_);
if ~isempty(w1.variance_)
    e = abs(s.^2-1).*(s.^2).*w1.variance_;     % ensure positive
else
    e = [];
end

w = sigvar(s,e);
