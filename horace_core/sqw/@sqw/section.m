function [wout,irange] = section (win,varargin)
% Takes a section out of an sqw object
%
% This is essentially a cut from the DnD without recomputing bins
%  and extracts the bins wholesale from the underlying object
% This makes the process more efficient but does not allow transformation of projections
%
%   >> wout = section (win, [ax_1_lo, ax_1_hi], [ax_2_lo, ax_2_hi], ...)
%
% Input:
% ------
%   win                 Input sqw object
%
%   [ax_1_lo, ax_1_hi]  Lower and upper limits for the first axis. Bins are retained whose
%                      centres lie in this range.
%                       To retain the limits of the input structure, type '', [], or the scalar '0'
%
%   [ax_2_lo, ax_2_hi]  Lower and upper limits for the second axis
%
%           :                       :
%
%       for as many axes as there are plot axes
%
% Output:
% -------
%   wout                Output dataset.
%
%
% Example: to alter the limits of the first and third axes of a 3D sqw object:
%   >> wout = section (win, [1.9,2.1], [], [-0.55,-0.45])


% Original author: T.G.Perring
%

% Initialise output argument
wout = copy(win);
if isempty(varargin)
    % Trivial case of no section arguments
    return
end

% Dimension of input data structures
ndim=dimensions(win(1));
if ndim==0  % no sectioning possible
    error('HORACE:sqw:invalid_argument', ...
        'Cannot section a zero dimensional object')
end

if numel(win) > 1 && any(arrayfun(@dimensions, win(2:end)) ~= ndim)
    error('HORACE:sqw:invalid_argument', ...
        'All objects must have same dimensionality for sectioning to work')
end

if length(varargin) ~= ndim
    error('HORACE:sqw:invalid_argument',...
        'Check number of arguments')
end

page_op = PageOp_section();
for n = 1:numel(win)
    [img,irange] = section(wout(n).data, varargin{:});

    % Section the pix array, if sqw type, and update img_range
    if has_pixels(win(n))
        page_op = page_op.init(wout(n),img,irange);
        wout(n) = sqw.apply_op(wout(n),page_op);
    else
        wout(n).data = img;
    end
end
