function w = unary_op_manager (w1, unary_op)
% Implements a unary operation for objects with a signal and a variance array.
%
%   >> w = unary_op_manager(w1, unary_op)
%
% Most unary operations on Matlab double arrays are permitted (e.g. acos,
% sqrt, log10...) and are applied element by element to the signal and
% variance arrays.
%
% Input:
% ------
%   w1          Input object or array of objects on which to apply the
%               unary operator.
%
%   unary_op    Function handle to the unary operator.
%
% Output:
% -------
%   w           Output object or array of objects.
%
%
% NOTES:
% This is a generic template method - works for any class (including sigvar)
% but the indicated blocks may need to be edited for a particular class.
%
% Requires that objects have the following methods to find the size of the
% public signal and variance arrays, create a sigvar object from those
% arrays, and set them from another sigvar object.
%
%	>> sz = sigvar_size(obj)    % Returns size of public signal and variance
%                               % arrays
%	>> w = sigvar(obj)          % Create a sigvar object from the public
%                               % signal and variance arrays
%	>> obj = sigvar_set(obj,w)  % Set signal and variance in an object from
%                               % those in a sigvar object

% -----------------------------------------------------------------------------
% <#doc_def:>
%   doc_dir = fullfile(fileparts(which('sigvar')),'_docify')
%
%   doc_file_header = fullfile(doc_dir,'doc_unary_op_manager_header.m')
%   doc_file_IO = fullfile(doc_dir,'doc_unary_general_args_IO_description.m')
%   doc_file_notes = fullfile(doc_dir,'doc_unary_op_manager_notes.m')
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


w = w1;
for i=1:numel(w1)
    if has_pixels(w1(i))
        w(i) = w(i).get_new_handle();
        w(i).pix = w(i).pix.do_unary_op(unary_op);
        w(i) = recompute_bin_data(w(i));
    else
        result = unary_op(sigvar(w1(i)));
        w(i) = sigvar_set(w(i),result);
    end
end
