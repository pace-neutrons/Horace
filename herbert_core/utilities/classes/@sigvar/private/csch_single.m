function w = csch_single (w1)
% Implements csch(w1) for a sigvar object
%
%   >> w = csch_single(w1)
%
% Input:
% ------
%   w1          Sigvar object. Scalar instance only (but signal and variance
%               arrays can be scalar or multiple element).
%
% Output:
% -------
%   w           Output sigvar object.

% -----------------------------------------------------------------------------
% <#doc_def:>
%   doc_dir = fullfile(fileparts(which('sigvar')),'_docify')
%   doc_file_header = fullfile(doc_dir,'doc_sigvar_unary_single.m')
%
%   func_name = 'csch'
% -----------------------------------------------------------------------------
% <#doc_beg:> binary_and_unary_ops
%   <#file:> <doc_file_header>
% <#doc_end:>
% -----------------------------------------------------------------------------

s = csch(w1.signal_);
if ~isempty(w1.variance_)
    e = (s.^2+1).*(s.^2).*w1.variance_;
else
    e = [];
end

w = sigvar(s,e);
