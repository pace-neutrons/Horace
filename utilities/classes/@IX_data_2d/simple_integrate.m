function wout = simple_integrate(win, varargin)
% Integrate IX_dataset_2d along x and y axes using reference 1D algorithm
%
%   >> wout = simple_integrate (win, xmin, xmax, ymin, ymax)
%   >> wout = simple_integrate (win, [xmin, xmax, ymin, ymax])
%   >> wout = simple_integrate (win, [xmin, xmax], [ymin, ymax])
%
% Simple implementation converting to array of IX_dataset_1d, and then converting back.
% Only works for a single input IX_dataset_2d.
% Does not do full syntax checking

if numel(win)~=1
    error('Method only works for a single input dataset, not an array')
end
if numel(varargin)==1
    xdescr=varargin{1}(1:2);
    ydescr=varargin{1}(3:4);
elseif numel(varargin)==2
    xdescr=varargin{1};
    ydescr=varargin{2};
elseif numel(varargin)==4
    xdescr=[varargin{1},varargin{2}];
    ydescr=[varargin{3},varargin{4}];
else
    error('Check input arguments')
end
    
    
% The operations of simple_integrate_x and simple_integrate_y should be commutative:
integrate_x_first=false;
if integrate_x_first
    wout = simple_integrate_x(win,  xdescr);
    wout = integrate(wout, ydescr);
else
    wout = simple_integrate_y(win,  ydescr);
    wout = integrate(wout, xdescr);
end
