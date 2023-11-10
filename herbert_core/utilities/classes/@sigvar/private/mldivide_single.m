function w = mldivide_single (w1, w2)
% -----------------------------------------------------------------------------
% <#doc_def:>
%   doc_dir = fullfile(fileparts(which('sigvar')),'_docify')
%   doc_file_header = fullfile(doc_dir,'doc_sigvar_binary_single.m')
%
%   func_operator = '\'
%   func_name = 'mldivide'
% -----------------------------------------------------------------------------
% <#doc_beg:> binary_and_unary_ops
%   <#file:> <doc_file_header>
% <#doc_end:>
% -----------------------------------------------------------------------------

s = w2.signal_ ./ w1.signal_;

if ~isempty(w2.variance_) && ~isempty(w1.variance_)
    e = w2.variance_./(w1.signal_ignal_.^2) + w1.variance_.*((s./w1.signal_ignal_).^2);
elseif ~isempty(w2.variance_)
    e = w2.variance_./(w1.signal_ignal_.^2);
elseif ~isempty(w1.variance_)
    e = w1.variance_.*((s./w1.signal_ignal_).^2);
else
    e = [];
end

w = sigvar(s,e);
