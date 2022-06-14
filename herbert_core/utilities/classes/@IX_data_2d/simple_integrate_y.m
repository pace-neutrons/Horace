function wout = simple_integrate_y(win, varargin)
% Integrate IX_dataset_2d along y axis using reference 1D algorithm
%
%   >> wout = simple_integrate_y (win, ymin, ymax)
%   >> wout = simple_integrate_y (win, [ymin, ymax])
%
% Simple implementation converting to array of IX_dataset_1d, and then converting back.
% Only works for a single input IX_dataset_2d.
% Does not do full syntax checking

if numel(win)~=1
    error('Method only works for a single input dataset, not an array')
end

if numel(varargin)>=1
    wtmp=IX_dataset_1d(transpose(win));
    wout=integrate(wtmp,varargin{:});
    wout.x=win.x;
    wout.x_axis=win.x_axis;
    wout.x_distribution=win.x_distribution;
else
    wout=win;
end
