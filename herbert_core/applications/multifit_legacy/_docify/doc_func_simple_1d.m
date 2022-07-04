%               ycalc = my_function (x,p)
%
%             or, more generally:
%               ycalc = my_function (x,p,c1,c2,...)
%
%             where
%               - x         Arrays of x values
%               - p         A vector of numeric parameters that define the
%                          function (e.g. [A,x0,w] as area, position and
%                          width of a peak)
%               - c1,c2,... Any further arguments needed by the function (e.g.
%                          they could be the filenames of lookup tables)
%
%             Type >> help gauss  or >> help mexpon for examples