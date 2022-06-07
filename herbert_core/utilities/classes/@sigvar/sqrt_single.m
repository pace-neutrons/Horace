function w = sqrt_single (w1)
% -----------------------------------------------------------------------------
% <#doc_def:>
%   doc_dir = fullfile(fileparts(which('sigvar')),'_docify')
%   doc_file_header = fullfile(doc_dir,'doc_sigvar_unary_single.m')
%
%   func_name = 'sqrt'
% -----------------------------------------------------------------------------
% <#doc_beg:> binary_and_unary_ops
%   <#file:> <doc_file_header>
% <#doc_end:>
% -----------------------------------------------------------------------------

s = sqrt(w1.signal_);
if ~isempty(w1.variance_)
    e = w1.variance_./(4*w1.signal_);
else
    e = [];
end

w = sigvar(s,e);
