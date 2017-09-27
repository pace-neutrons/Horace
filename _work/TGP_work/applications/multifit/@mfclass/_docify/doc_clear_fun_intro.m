% Description of function syntax for clear_fun and clear_bfun
%
% -----------------------------------------------------------------------------
% <#doc_def:>
%   type = '#1'     % 'back' or 'fore'
%   pre  = '#2'     % 'b' or ''
%
% -----------------------------------------------------------------------------
% <#doc_beg:>
% Clear <type>ground fit function(s), clearing any corresponding constraints
%
% Clear all <type>ground functions
%   >> obj = obj.clear_<pre>fun
%   >> obj = obj.clear_<pre>fun ('all')
%
% Clear a particular <type>ground function or set of <type>ground functions
%   >> obj = obj.clear_<pre>fun (ifun)
%
% Input:
% ------
%   ifun    Row vector of <type>ground function indicies [Default: all functions]
% <#doc_end:>
% -----------------------------------------------------------------------------
