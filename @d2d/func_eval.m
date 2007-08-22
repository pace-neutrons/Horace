function wout = func_eval (win, varargin)
% Evaluate a function at the x and y values of an d2d or array of d2d)
% Syntax:
%   >> wout = func_eval (w, func, args)
% Input:
% ======
%   w           Dataset or array of datasets; the function will be evaluated
%              at the x and y values of the dataset(s)
%
%   func        Handle to the function to be evaluated
%              Function must be of form z = my_func(x,y,arg1,arg2,...)
%               e.g. z = gauss2d (x, y, [height, cent_x, cent_y, sigxx, sigxy, sigyy])
%              and must accept two vectors of equal length that contain the
%              x and y values. It return a vector of the function values.
%
%   arg1,arg2...Arguments needed by the function. Typically there is only
%               one argument, which is a numeric array, as in the example above
%
% Output:
% =======
%   wout        Output d2d or array of d2d 
%
% e.g.
%   >> wout = func_eval (w, @gauss, [height, cent_x, cent_y, sigxx, sigxy, sigyy])
%
%   where the function gauss appears on the matlab path
%           function z = gauss2d (x, y, p)
%           z = (p(1)/(sig*sqrt(2*pi))) * ...

wout = dnd_data_op(win, @func_eval, 'd2d' , 2, varargin{:});