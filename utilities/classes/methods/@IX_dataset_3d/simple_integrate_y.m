function wout = simple_integrate_y(win, varargin)
% Integrate IX_dataset_3d along y axis using reference 1D algorithm
%
%   >> wout = simple_integrate_y (win, ymin, ymax)
%   >> wout = simple_integrate_y (win, [ymin, ymax])
%
% Simple implementation converting to array of IX_dataset_1d, and then converting back.
% Only works for a single input IX_dataset_3d.
% Does not do full syntax checking

if numel(win)~=1
    error('Method only works for a single input dataset, not an array')
end

if numel(varargin)>=1
    order=[2,1,3];
    [nd,sz]=dimensions(win);
    keepdims=order([2,3]);
    sz_new=sz(keepdims);
    wtmp=IX_dataset_1d(permute(win,order));
    tmp=integrate_ref(wtmp,varargin{:});
    signal=reshape(tmp.signal,sz_new);
    err=reshape(tmp.error,sz_new);
    ax=axis(win,keepdims);
    wout=IX_dataset_nd(win.title,signal,err,win.s_axis,ax);
else
    wout=win;
end
