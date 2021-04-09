function w = csch (w1)
% Implement csch(w1) for objects
%
%   >> w = csch(w1)
%
% The input argument can be a scalar object or array of objects

% -----------------------------------------------------------------------------
% <#doc_def:>
%   doc_dir = fullfile(fileparts(which('sigvar')),'_docify')
%   doc_file = fullfile(doc_dir,'doc_unary.m')
%
%   func_name = 'csch'
% -----------------------------------------------------------------------------
% <#doc_beg:> binary_and_unary_ops
%   <#file:> <doc_file>
% <#doc_end:>
% -----------------------------------------------------------------------------

w = unary_op_manager (w1, @csch);
