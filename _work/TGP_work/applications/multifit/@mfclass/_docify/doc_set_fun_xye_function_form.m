% Description for fit function for x-y-e data
%
% -----------------------------------------------------------------------------
% <#doc_def:>
%       x_arg = '#1'
%       x_descr = '#2'
% -----------------------------------------------------------------------------
% <#doc_beg:>
%   function ycalc = my_function (<x_arg>,p)
%
% or, more generally:
%   function ycalc = my_function (<x_arg>,p,c1,c2,...)
%
% where
%   <x_descr>
%   p           A vector of numeric parameters that define the
%              function (e.g. [A,x0,w] as area, position and
%              width of a peak)
%   c1,c2,...   Any further arguments needed by the function (e.g.
%              they could be the filenames of lookup tables)
% <#doc_end:>
% -----------------------------------------------------------------------------
