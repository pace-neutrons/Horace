function w = plus_single (w1, w2)
% -----------------------------------------------------------------------------
% <#doc_def:>
%   doc_dir = fullfile(fileparts(which('sigvar')),'_docify')
%   doc_file_header = fullfile(doc_dir,'doc_sigvar_binary_single.m')
%
%   func_operator = '+'
%   func_name = 'plus'
% -----------------------------------------------------------------------------
% <#doc_beg:> binary_and_unary_ops
%   <#file:> <doc_file_header>
% <#doc_end:>
% -----------------------------------------------------------------------------

s = w1.signal_ + w2.signal_;

if ~isempty(w1.variance_) && ~isempty(w2.variance_)
    e = w1.variance_ + w2.variance_;
elseif ~isempty(w1.variance_)
    e = w1.variance_;
elseif ~isempty(w2.variance_)
    e = w2.variance_;
else
    e = [];
end

w = sigvar(s,e);
