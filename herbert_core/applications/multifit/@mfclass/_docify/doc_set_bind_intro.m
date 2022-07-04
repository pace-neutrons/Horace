% Description of function syntax for set_bind, add_bind, set_bbind add_bbind
%
% -----------------------------------------------------------------------------
% <#doc_def:>
%   type = '#1'     % 'back' or 'fore'
%   pre  = '#2'     % 'b' or ''
%   atype = '#3'    % 'back' or 'fore' (opposite of type)
%   func = '#4'     % 'set' or 'add'
%
%   is_bind = 1
%   is_fun = 0
%
%   mfclass_doc = fullfile(fileparts(which('mfclass')),'_docify')
%   doc_arg_bind = fullfile(mfclass_doc,'doc_arg_bind.m')
%   doc_arg_ifun = fullfile(mfclass_doc,'doc_arg_ifun.m')
%
% -----------------------------------------------------------------------------
% <#doc_beg:>
% Set one or more bindings
%   >> obj = obj.<func>_<pre>bind (bind)
%   >> obj = obj.<func>_<pre>bind (b1, b2, b3...)
%
% Set one or more bindings for one or more specific <type>ground function(s)
%   >> obj = obj.<func>_<pre>bind (ifun, bind)
%   >> obj = obj.<func>_<pre>bind (ifun, b1, b2, b3...)
%
% Input:
% ------
%   <#file:> <doc_arg_bind> <type> <pre> <atype> is_bind is_fun
%
% Optional argument:
%   <#file:> <doc_arg_ifun>
% <#doc_end:>
% -----------------------------------------------------------------------------
