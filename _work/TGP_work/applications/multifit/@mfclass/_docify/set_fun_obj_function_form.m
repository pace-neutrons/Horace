%   function wcalc = my_function (w,p)
%
% or, more generally:
%   function wcalc = my_function (w,p,c1,c2,...)
%
% where
%   w           Object on which to evaluate the function
%   p           A vector of numeric parameters that define the
%              function (e.g. [A,x0,w] as area, position and
%              width of a peak)
%   c1,c2,...   Any further arguments needed by the function (e.g.
%              they could be the filenames of lookup tables)
