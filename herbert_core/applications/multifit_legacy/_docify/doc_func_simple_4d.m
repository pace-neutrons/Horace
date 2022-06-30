%               ycalc = my_function (x1,x2,x3,x4,p)
%
%             or, more generally:
%               ycalc = my_function (x1,x2,x3,x4,p,c1,c2,...)
%
%             where
%               - x1,x2,... Arrays of x values along first, second, third
%                          and fourth dimensions
%               - p         A vector of numeric parameters that define the
%                          function (e.g. [A,x0,w] as area, position and
%                          width of a peak)
%               - c1,c2,... Any further arguments needed by the function (e.g.
%                          they could be the filenames of lookup tables)