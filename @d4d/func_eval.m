function wout = func_eval (win, func_handle, p, opt)
% Evaluate a function at the x and y values of 4D datset or array of 4D datasets
% Syntax:
%   >> wout = func_eval (win, func, p)
%   >> wout = func_eval (win, func, p, 'all')
%
% Input:
% ======
%   win         Dataset or array of datasets; the function will be evaluated
%              at the p1, p2, p3 and p4 values of the dataset(s)
%
%   func        Handle to the function to be evaluated
%              Function must be of form y = my_func(x1,x2,x3,x4,p)
%               e.g. y=gauss4d(x1,x2,x3,x4,[ht,x1_0,x2_0,x3_0,x4_0,sig1,sig2,sig3,sig4])
%              and must accept two equal sized arrays that contain the
%              x1,x2,x3 and x4 values. It return an array of the function values.
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
%   >> wout = func_eval (w, @gauss4d, [ht,x1_0,x2_0,x3_0,x4_0,sig1,sig2,sig3,sig4])
%
%   where the function gauss appears on the matlab path
%           function y = gauss2d (x1, x2, x3, x4, p)
%           y = (p(1)/(sig*sqrt(2*pi))) * ...

% *** A superior algorithm would be only evaluate the function at the points where
% there is data - can avoid singularities. ***

wout = win;
for i = 1:length(win)
    p1 = 0.5*(win(i).p1(1:end-1)+win(i).p1(2:end));
    p2 = 0.5*(win(i).p2(1:end-1)+win(i).p2(2:end));
    p3 = 0.5*(win(i).p3(1:end-1)+win(i).p3(2:end));
    p4 = 0.5*(win(i).p4(1:end-1)+win(i).p4(2:end));
    [p1, p2, p3, p4] = ndgrid(p1,p2,p3,p4); % mesh x and y 
    p1 = reshape(p1,numel(p1),1);   % get x into single column
    p2 = reshape(p2,numel(p2),1);   % get y into single column
    p3 = reshape(p3,numel(p3),1);   % get y into single column
    p4 = reshape(p4,numel(p4),1);   % get y into single column
    wout(i).s = reshape(func_handle(p1,p2,p3,p4,p),size(win(i).s));
    wout(i).e = zeros(size(win(i).e));  
    if ~exist('opt','var')  % no option given
        % Do nothing
    elseif ischar(opt) && ~isempty(strmatch(lower(opt),'all'))    % option 'all' given
        index = isnan(wout(i).s);
        wout(i).s(index) = 0;
        wout(i).e(index) = 0;
    else
        error('Unrecognised option')
    end
end
