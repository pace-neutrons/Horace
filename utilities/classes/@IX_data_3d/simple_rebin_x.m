function wout = simple_rebin_x(win, varargin)
% Rebin IX_dataset_3d along x axis using reference 1D algorithm
%
%   >> wout = simple_rebin_x(win, xlo, xhi)       % keep data between xlo and xhi, retaining existing bins
%	>> wout = simple_rebin_x(win, xlo, dx, xhi)   % rebin from xlo to xhi in intervals of dx
%   >> wout = simple_rebin_x(win,wref)            % rebin win with the bin boundaries of wref (a 1D dataset)
%   >> wout = simple_rebin_x(..., 'int')          % trapezoidal integration if point data
%
% See IX_dataset_1d/rebin for full help
%
% Simple implementation converting to array of IX_dataset_1d, and then converting back.
% Only works for a single input IX_dataset_3d.
% Does not do full syntax checking

if numel(win)~=1
    error('Method only works for a single input dataset, not an array')
end

if numel(varargin)>=1
    order=[1,2,3];
    [nd,sz]=dimensions(win);
    keepdims=order([2,3]);
    wtmp=IX_dataset_1d(permute(win,order));
    wtmp=rebin(wtmp,varargin{:});
    nreb=numel(wtmp(1).signal);
    sz_new=[nreb,sz(keepdims)];
    signal=zeros(sz_new);
    err=zeros(sz_new);
    for iw=1:numel(wtmp)
        signal(:,iw)=wtmp(iw).signal;
        err(:,iw)=wtmp(iw).error;
    end
    unorder(order)=1:numel(order);  % inverse of order
    signal=permute(signal,unorder);
    err=permute(err,unorder);
    wout=win;
    wout.signal=signal;
    wout.error=err;
    if order(1)==1, wout.x=wtmp(1).x; end
    if order(1)==2, wout.y=wtmp(1).x; end
    if order(1)==3, wout.z=wtmp(1).x; end
else
    wout=win;
end
