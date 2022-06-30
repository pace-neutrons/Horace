% Description of function syntax for clear_pin and clear_bpin
%
% -----------------------------------------------------------------------------
% <#doc_def:>
%   type = '#1'     % 'back' or 'fore'
%   pre  = '#2'     % 'b' or ''
%
% -----------------------------------------------------------------------------
% <#doc_beg:>
% Clear all parameters and constraints for one or more <type>ground functions
%
% Clear all parameters for all <type>ground functions
%   >> obj = obj.clear_<pre>pin
%   >> obj = obj.clear_<pre>pin ('all')
%
% Clear all parameters for one or more specific <type>ground function(s)
%   >> obj = obj.clear_<pre>pin (ifun)
%
% Input:
% ------
%   ifun    Row vector of <type>ground function indicies [Default: all functions]
% <#doc_end:>
% -----------------------------------------------------------------------------
