function w = mpower_single (w1, w2)
% -----------------------------------------------------------------------------
% <#doc_def:>
%   doc_dir = fullfile(fileparts(which('sigvar')),'_docify')
%   doc_file_header = fullfile(doc_dir,'doc_sigvar_binary_single.m')
%
%   func_operator = '^'
%   func_name = 'mpower'
% -----------------------------------------------------------------------------
% <#doc_beg:> binary_and_unary_ops
%   <#file:> <doc_file_header>
% <#doc_end:>
% -----------------------------------------------------------------------------

tmp = w1.signal_ .^ (w2.signal_-1);     % intermediate variable to save time calculating error bars
s = tmp .* w1.signal_;

if ~isempty(w1.variance_) && ~isempty(w2.variance_)
    e = ((w2.signal_.*tmp).^2).*w1.variance_ + ((s.*log(w1.signal_)).^2).*w2.variance_;
elseif ~isempty(w1.variance_)
    e = (w2.signal_.^2).*w1.variance_;
elseif ~isempty(w2.variance_)
    e = (w1.signal_.^2).*w2.variance_;
else
    e = [];
end

w = sigvar(s,e);
