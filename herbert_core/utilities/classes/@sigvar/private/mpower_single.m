function w = mpower_single (w1, w2)
% Implement w1 ^ w2 for objects
%
%   >> w = mpower_single(w1, w2)
%
% Input:
% ------
%   w1, w2      Scalar sigvar objects:
%               - signal arrays are the same size
%               - one of sigvar objects has a scalar signal array
%
% Output:
% -------
%   w           Output sigvar object.
%               - signal array the same size as the input objects if they
%                 both had the same size
%               - signal array the same size as the sigvar object with the
%                 larger number of elements if one was a scalar

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
