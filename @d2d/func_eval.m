function wout = func_eval (win, func_handle, p, opt)
% Evaluate a function at the x and y values of 2D datset or array of 2D datasets
% Syntax:
%   >> wout = func_eval (win, func, p)
%   >> wout = func_eval (win, func, p, 'all')
%
% Input:
% ======
%   win         Dataset or array of datasets; the function will be evaluated
%              at the p1 and p2 values of the dataset(s)
%
%   func        Handle to the function to be evaluated
%              Function must be of form y = my_func(x1,x2,p)
%               e.g. y = gauss2d (x1, x2, [ht, x1_0, x2_0, cov11, cov12, cov22])
%              and must accept two equal sized arrays that contain the
%              x1 and x2 values. It return an array of the function values.
%
%   p           Row vector containing arguments needed by the function.
%
%   'all'       [option] Requests that the calculated function be returned over
%              the whole of the domain of the input dataset. If not given, then
%              the function will be returned only at those points of the dataset
%              that contain data.
%
% Output:
% =======
%   wout        Output dataset or array of datasets 
%
% e.g.
%   >> wout = func_eval (w, @gauss2d, [ht, x1_0, x2_0, cov11, cov12, cov22])
%
%   where the function gauss appears on the matlab path
%           function y = gauss2d (x1, x2, p)
%           y = (p(1)/(sig*sqrt(2*pi))) * ...

% *** A superior algorithm would be only evaluate the function at the points where
% there is data - can avoid singularities. ***

wout = win;
for i = 1:length(win)
    p1 = 0.5*(win(i).p1(1:end-1)+win(i).p1(2:end));
    p2 = 0.5*(win(i).p2(1:end-1)+win(i).p2(2:end));
    [p1, p2] = ndgrid(p1,p2);       % mesh x and y 
    p1 = reshape(p1,numel(p1),1);   % get x into single column
    p2 = reshape(p2,numel(p2),1);   % get y into single column
    wout(i).s = reshape(func_handle(p1,p2,p),size(win(i).s));
    wout(i).e = zeros(size(win(i).e));  
    if ~exist('opt')  % no option given
        wout(i).n = double(wout(i).n~=0);   % return data only at the points where there is data
    elseif ischar(opt) && strmatch(lower(opt),'all')==1    % option 'all' given
        wout(i).n = ones(size(wout(i).n));
    else
        error('Unrecognised option')
    end
end
