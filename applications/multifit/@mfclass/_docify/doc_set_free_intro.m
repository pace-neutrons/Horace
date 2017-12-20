% Description of function syntax for set_free and set_bfree
%
% -----------------------------------------------------------------------------
% <#doc_def:>
%   type = '#1'     % 'back' or 'fore'
%   pre  = '#2'     % 'b' or ''
%
% -----------------------------------------------------------------------------
% <#doc_def:>
%   type = '#1'     % 'back' or 'fore'
%   pre  = '#2'     % 'b' or ''
%
%   is_free = 1
%   is_fun = 0
%
%   mfclass_doc = fullfile(fileparts(which('mfclass')),'_docify')
%   doc_arg_free = fullfile(mfclass_doc,'doc_arg_free.m')
%   doc_arg_ifun = fullfile(mfclass_doc,'doc_arg_ifun.m')
%
% -----------------------------------------------------------------------------
% <#doc_beg:>
% Set which <type>ground function parameters are free and which are fixed
%
% Set fixed/free status for all <type>ground functions
%   >> obj = obj.set_<pre>free (free)
%
% Set for one or more specific <type>ground function(s)
%   >> obj = obj.set_<pre>free (ifun, free)
%
% Input:
% ------
%   <#file:> <doc_arg_free> <type> <pre> is_free is_fun
%
% Optional argument:
%   <#file:> <doc_arg_ifun>
% <#doc_end:>
% -----------------------------------------------------------------------------
