function wout = simple_rebindd(win, xdescr, ydescr, opt)
% Integrate IX_dataset_2d along x and y axes using reference 1D algorithm
%
%   >> wout = simple_rebind_x(win, xdescr, ydescr)
%   >> wout = simple_rebind_x(win, xdescr, ydescr, 'int')    % trapezoidal integration of point data
%
% xdescr, ydescr are the rebin descriptors along the x and y axes
% See IX_dataset_1d/rebin_ref for full help
%
% Simple implementation converting to array of IX_dataset_1d, and then converting back.
% Only works for a single input IX_dataset_2d.
% Does not do full syntax checking

if numel(win)~=1
    error('Method only works for a single input dataset, not an array')
end

integrate=false;
if nargin==4
    if isstringmatchi(opt,'integrate')
        integrate=true;
    else
        error('Check optional arguments')
    end
end

% The operations of simple_rebind_x and simple_rebind_y are commutative:

% if integrate
%     wout = simple_rebind_x(win,  xdescr, 'int');
%     wout = simple_rebind_y(wout, ydescr, 'int');
% else
%     wout = simple_rebind_x(win,  xdescr);
%     wout = simple_rebind_y(wout, ydescr);
% end

if integrate
    wout = simple_rebind_y(win,  ydescr, 'int');
    wout = simple_rebind_x(wout, xdescr, 'int');
else
    wout = simple_rebind_y(win,  ydescr);
    wout = simple_rebind_x(wout, xdescr);
end
