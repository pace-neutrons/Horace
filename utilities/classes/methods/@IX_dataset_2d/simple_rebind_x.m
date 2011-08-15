function wout = simple_rebind_x(win, varargin)
% Integrate IX_dataset_2d along x axis using reference 1D algorithm
%
%   >> wout = simple_rebind_x(win, xlo, xhi)       % keep data between xlo and xhi, retaining existing bins
%	>> wout = simple_rebind_x(win, xlo, dx, xhi)   % rebin from xlo to xhi in intervals of dx
%   >> wout = simple_rebind_x(win,wref)            % rebin win with the bin boundaries of wref (a 1D dataset)
%   >> wout = simple_rebind_x(..., 'int')          % trapezoidal integration if point data
%
% See IX_dataset_1d/rebin_ref for full help
%
% Simple implementation converting to array of IX_dataset_1d, and then converting back.
% Only works for a single input IX_dataset_2d.
% Does not do full syntax checking

if numel(win)~=1
    error('Method only works for a single input dataset, not an array')
end

if numel(varargin)>=1
    wtmp=IX_dataset_1d(win);
    wouttmp=rebin_ref(wtmp,varargin{:});
    wout=IX_dataset_2d(wouttmp);
    wout.y=win.y;
    wout.y_axis=win.y_axis;
    wout.y_distribution=win.y_distribution;
else
    wout=win;
end
