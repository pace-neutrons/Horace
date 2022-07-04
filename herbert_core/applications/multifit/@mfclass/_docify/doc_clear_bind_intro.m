% Description of function syntax for clear_bind and clear_bbind
%
% -----------------------------------------------------------------------------
% <#doc_def:>
%   type = '#1'     % 'back' or 'fore'
%   pre  = '#2'     % 'b' or ''
%
% -----------------------------------------------------------------------------
% <#doc_beg:>
% Clear any binding of parameters for one or more <type>ground functions
%
% Clear for all parameters for all <type>ground functions
%   >> obj = obj.clear_<pre>bind
%   >> obj = obj.clear_<pre>bind ('all')
%
% Clear for all parameters for one or more specific <type>ground function(s)
%   >> obj = obj.clear_<pre>bind (ifun)
%
% Input:
% ------
%   ifun    Row vector of <type>ground function indicies [Default: all functions]
% <#doc_end:>
% -----------------------------------------------------------------------------
