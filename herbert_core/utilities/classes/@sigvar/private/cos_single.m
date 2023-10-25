function w1 = cos_single (w)
% -----------------------------------------------------------------------------
% <#doc_def:>
%   doc_dir = fullfile(fileparts(which('sigvar')),'_docify')
%   doc_file_header = fullfile(doc_dir,'doc_sigvar_unary_single.m')
%
%   func_name = 'cos'
% -----------------------------------------------------------------------------
% <#doc_beg:> binary_and_unary_ops
%   <#file:> <doc_file_header>
% <#doc_end:>
% -----------------------------------------------------------------------------
w1=w;
s = cos(w.signal_);
if ~isempty(w.variance_)
    w1.variance_ = abs(1-s.^2).*w.variance_;     % ensure positive
else
    w1.variance_ = [];
end
w1.signal_ = s;
w1.msk     = []; % this is how the initial operation was performed.
%                  Is it what was intended?