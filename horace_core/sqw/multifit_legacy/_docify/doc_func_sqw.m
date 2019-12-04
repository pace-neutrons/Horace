%               weight = my_sqwfunc (qh,qk,ql,en,p)
%
%             or, more generally:
%               weight = my_sqwfunc (qh,qk,ql,en,p,c1,c2,..)
%
%             where
%               - qh,qk,ql,en Arrays containing the coordinates of a set of 
%                            points in momentum-energy space
%               - p           A vector of numeric parameters that define the
%                            function e.g. [A,j1,j2,gam] as intensity, exchange
%                            constants, inverse lifetime
%               - c1,c2,...   Any further arguments needed by the function (e.g.
%                            they could be the filenames of lookup tables)