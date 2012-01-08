function wout = simple_rebin(win, xdescr, ydescr, zdescr, opt)
% Rebin IX_dataset_3d along x, y and z axes using reference 1D algorithm
%
%   >> wout = simple_rebin(win, xdescr, ydescr, zdescr)
%   >> wout = simple_rebin(win, xdescr, ydescr, zdescr, 'int')    % trapezoidal integration of point data
%
% xdescr, ydescr are the rebin descriptors along the x and y axes
% See IX_dataset_1d/rebin for full help
%
% Simple implementation converting to array of IX_dataset_1d, and then converting back.
% Only works for a single input IX_dataset_3d.
% Does not do full syntax checking

if numel(win)~=1
    error('Method only works for a single input dataset, not an array')
end

integrate=false;
if nargin==5
    if isstringmatchi(opt,'integrate')
        integrate=true;
    else
        error('Check optional arguments')
    end
end

% The operations of simple_rebin_x , _y and _z are commutative:

% if integrate
%     wout = simple_rebin_x(win,  xdescr, 'int');
%     wout = simple_rebin_y(wout, ydescr, 'int');
%     wout = simple_rebin_z(wout, zdescr, 'int');
% else
%     wout = simple_rebin_x(win,  xdescr);
%     wout = simple_rebin_y(wout, ydescr);
%     wout = simple_rebin_z(wout, zdescr);
% end

if integrate
    wout = simple_rebin_z(win,  zdescr, 'int');
    wout = simple_rebin_x(wout, xdescr, 'int');
    wout = simple_rebin_y(wout, ydescr, 'int');
else
    wout = simple_rebin_z(win,  zdescr);
    wout = simple_rebin_x(wout, xdescr);
    wout = simple_rebin_y(wout, ydescr);
end
