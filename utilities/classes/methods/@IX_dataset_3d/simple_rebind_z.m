function wout = simple_rebind_z(win, varargin)
% Rebin IX_dataset_3d along z axis using reference 1D algorithm
%
%   >> wout = simple_rebind_z(win, ylo, yhi)       % keep data between ylo and yhi, retaining existing bins
%	>> wout = simple_rebind_z(win, ylo, dy, yhi)   % rebin from ylo to yhi in intervals of dy
%   >> wout = simple_rebind_z(win,wref)            % rebin win with the bin boundaries of wref (a 1D dataset)
%   >> wout = simple_rebind_z(..., 'int')          % trapezoidal integration if point data
%
% See IX_dataset_1d/rebind for full help
%
% Simple implementation converting to array of IX_dataset_1d, and then converting back.
% Only works for a single input IX_dataset_3d.
% Does not do full syntax checking

if numel(win)~=1
    error('Method only works for a single input dataset, not an array')
end

if numel(varargin)>=1
    order=[3,1,2];
    [nd,sz]=dimensions(win);
    keepdims=order([2,3]);
    wtmp=IX_dataset_1d(permute(win,order));
    wtmp=rebind_ref(wtmp,varargin{:});
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
