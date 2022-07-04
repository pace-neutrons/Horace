function wout = simple_integrate(win, varargin)
% Integrate IX_dataset_3d along x, y and z axes using reference 1D algorithm
%
%   >> wout = simple_integrate (win, xmin, xmax, ymin, ymax, zmin, zmax)
%   >> wout = simple_integrate (win, [xmin, xmax, ymin, ymax, zmin, zmax])
%   >> wout = simple_integrate (win, [xmin, xmax], [ymin, ymax], [zmin, zmax])
%
% Simple implementation converting to array of IX_dataset_1d, and then converting back.
% Only works for a single input IX_dataset_3d.
% Does not do full syntax checking

if numel(win)~=1
    error('Method only works for a single input dataset, not an array')
end
if numel(varargin)==1
    xdescr=varargin{1}(1:2);
    ydescr=varargin{1}(3:4);
    zdescr=varargin{1}(5:6);
elseif numel(varargin)==3
    xdescr=varargin{1};
    ydescr=varargin{2};
    zdescr=varargin{3};
elseif numel(varargin)==6
    xdescr=[varargin{1},varargin{2}];
    ydescr=[varargin{3},varargin{4}];
    zdescr=[varargin{5},varargin{6}];
else
    error('Check input arguments')
end

integrate_first=3;
if integrate_first==1
    wout = simple_integrate_x(win,  xdescr);
    wout = simple_integrate(wout, ydescr, zdescr);
elseif integrate_first==2
    wout = simple_integrate_y(win,  ydescr);
    wout = simple_integrate(wout, xdescr, zdescr);
elseif integrate_first==3
    wout = simple_integrate_z(win,  zdescr);
    wout = simple_integrate(wout, xdescr, ydescr);
end
