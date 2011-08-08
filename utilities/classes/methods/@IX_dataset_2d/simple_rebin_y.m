function wout = simple_rebin_y(win, varargin)
% Integrate IX_dataset_2d along y axis using same algorithm as 
%
%   >> wout = simplerebin_y(win, ylo, yhi)       % keep data between ylo and yhi, retaining existing bins
%	>> wout = simplerebin_y(win, ylo, dy, yhi)   % rebin from ylo to yhi in intervals of dy
%   >> wout = simplerebin_y(win,wref)            % rebin win with the bin boundaries of wref (a 1D dataset)
%   >> wout = simplerebin_y(..., 'int')          % trapezoidal integration if point data
%
% See IX_dataset_1d/rebin for full help
%
% Simple implementation converting to array of IX_dataset_1d, and then converting back.
% Only works for a single input IX_dataset_2d.
% Does not do full syntax checking

if numel(win)~=1
    error('Method only works for a single input dataset, not an array')
end

if numel(varargin)>=1
    wtmp=IX_dataset_1d(transpose(win));
    wouttmp=rebin_ref(wtmp,varargin{:});
    wout=transpose(IX_dataset_2d(wouttmp));
    wout.x=win.x;
    wout.x_axis=win.x_axis;
    wout.x_distribution=win.x_distribution;
else
    wout=win;
end
