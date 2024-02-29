function wout = binary_op_manager_single(w1, w2, binary_op,varargin)
% -----------------------------------------------------------------------------
% <#doc_def:>
%   doc_dir = fullfile(fileparts(which('sigvar')),'_docify')
%
%   doc_file_header = fullfile(doc_dir,'doc_binary_op_manager_header.m')
%   doc_file_IO = fullfile(doc_dir,'doc_binary_scalar_args_IO_description.m')
%   doc_file_notes = fullfile(doc_dir,'doc_binary_op_manager_single_notes.m')
%   doc_file_sigvar_notes = fullfile(doc_dir,'doc_sigvar_notes.m')
%
%   list_operator_arg = 1
% -----------------------------------------------------------------------------
% <#doc_beg:> binary_and_unary_ops
%   <#file:> <doc_file_header>
%
%   <#file:> <doc_file_IO> <list_operator_arg>
%
%
% NOTES:
%   <#file:> <doc_file_notes>
%
%   <#file:> <doc_file_sigvar_notes>
% <#doc_end:>
% -----------------------------------------------------------------------------
% varargin -- not used and provided to adhere to common binary_op_manager interface


% One or both of w1, w2 is an instance of the class for which this a method
% because otherwise this method would not have been called. Furthermore, it
% must be the superior class (assuming that a method with this name is
% defined for both classes)
%
% We make a copy of whichever of w1 or w2 is the superior class, so that
% any of the additional properties are carried through unchanged. If both
% are instances of class classname, then w1 is assumed dominant.

sz1  = sigvar_size(w1);
sz2  = sigvar_size(w2);
if ~(isequal(sz1,sz2) || isequal(sz1,[1,1]) || isequal(sz2,[1,1]))
    error('HERBERT:sigvar:invalid_argument', ...
        'Sizes of signal arrays for operand1(%s) and operand 2(%d) are inconsistent.', ...
        disp2str(sz1),disp2str(sz2));
end

if ~isa(w2, 'sigvar')
    % w1 is an instance of classname, w2 is a double
    w2 = sigvar(w2);
end
if ~isa(w1, 'sigvar') % ? Never happens as this is sigvar method?
    % w2 is an instance of sigvar, w1 is a double
    w1 = sigvar(w1);
end
wout = binary_op(w1,w2);

