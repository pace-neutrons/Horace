% Description of function syntax for clear_free and clear_bfree
%
% -----------------------------------------------------------------------------
% <#doc_def:>
%   type = '#1'     % 'back' or 'fore'
%   pre  = '#2'     % 'b' or ''
%
% -----------------------------------------------------------------------------
% <#doc_beg:>
% Free all parameters to vary in fitting for one or more <type>ground functions
%
% Free all parameters for all <type>ground functions
%   >> obj = obj.clear_<pre>free
%   >> obj = obj.clear_<pre>free ('all')
%
% Free all parameters for one or more specific <type>ground function(s)
%   >> obj = obj.clear_<pre>free (ifun)
%
% Input:
% ------
%   ifun    Row vector of <type>ground function indicies [Default: all functions]
% <#doc_end:>
% -----------------------------------------------------------------------------
