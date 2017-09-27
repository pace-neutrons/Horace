% Description of function syntax for set_free and set_bfree
%
% -----------------------------------------------------------------------------
% <#doc_def:>
%   type = '#1'     % 'back' or 'fore'
%   pre  = '#2'     % 'b' or ''
%
%   is_pin = 1
%   is_fun = 0
%
%   mfclass_doc = fullfile(fileparts(which('mfclass')),'_docify')
%   doc_arg_pin = fullfile(mfclass_doc,'doc_arg_pin.m')
%   doc_arg_ifun = fullfile(mfclass_doc,'doc_arg_ifun.m')
%
% -----------------------------------------------------------------------------
% <#doc_beg:>
% Set the initial values of <type>ground function parameters
%
% Set initial values for all <type>ground functions
%   >> obj = obj.set_<pre>pin (pin)
%
% Set for one or more specific <type>ground function(s)
%   >> obj = obj.set_<pre>pin (ifun, pin)
%
% Input:
% ------
%   <#file:> <doc_arg_pin> <type> <pre> is_pin is_fun
%
% Optional argument:
%   <#file:> <doc_arg_ifun>
% <#doc_end:>
% -----------------------------------------------------------------------------
