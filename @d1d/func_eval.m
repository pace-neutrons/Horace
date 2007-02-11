function wout = func_eval (win, func_handle, p, opt)
% Evaluate a function at the x and y values of 1D datset or array of 1D datasets
% Syntax:
%   >> wout = func_eval (win, func, p)
%   >> wout = func_eval (win, func, p, 'all')
%
% Input:
% ======
%   win         Dataset or array of datasets; the function will be evaluated
%              at the p1 values of the dataset(s)
%
%   func        Handle to the function to be evaluated
%              Function must be of form y = my_func(x1,p)
%               e.g. y = gauss (x1, [ht, cent, sig])
%              and must accept an array that contain the x1 values. It
%              return an array of the function values.
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
%   >> wout = func_eval (w, @gauss, [ht, cent, sig])
%
%   where the function gauss appears on the matlab path
%           function y = gauss2d (x1, p)
%           y = p(1)*exp(-0.5*(x1-p(2))./p(3));

% *** A superior algorithm would be only evaluate the function at the points where
% there is data - can avoid singularities. ***

wout = win;
for i = 1:length(win)
    p1 = 0.5*(win(i).p1(1:end-1)+win(i).p1(2:end));
    wout(i).s = func_handle(p1,p);
    wout(i).e = zeros(size(win(i).e));  
    if ~exist('opt')  % no option given
        wout(i).n = double(wout(i).n~=0);   % return data only at the points where there is data
    elseif ischar(opt) && strmatch(lower(opt),'all')==1    % option 'all' given
        wout(i).n = ones(size(wout(i).n));
    else
        error('Unrecognised option')
    end
end
