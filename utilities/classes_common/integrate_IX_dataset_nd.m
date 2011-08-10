function [wout,ok,mess] = integrate_IX_dataset_nd (win, ndim, rebin_hist_func, integrate_points_func, varargin)
% Integrate an IX_dataset_nd object or array of IX_dataset_nd objects along all axes
%
%   >> [wout,ok,mess] = rebin_IX_dataset_nd (win, ndim, rebin_hist_func, integrate_points_func, varargin)

% Check point integration option
if ~(numel(varargin)==1 && isa(varargin{1},class(win))) && (numel(varargin)>=1 && ~isnumeric(varargin{end}))  % last argument is point integration option
    [point_integration, ok, mess] = rebin_point_integration_check (nax, varargin{end});
    if ~ok, wout=[]; return, end
    args=varargin(1:end-1);
else
    point_integration=false(1,nax);
    args=varargin;
end

% Check integration parameters
if numel(args)>0
    [ok,xbounds,mess]=integrate_ranges_check(args{:});
    if ~ok, wout=[]; return, end
    if numel(xbounds)~=ndim
        ok=false; wout=[];  mess='Check number of input rebin descriptors matches number of rebin axes'; return
    end
else
    ok=false; wout=[];  mess='Must give integration ranges'; return
end


% Perform integration
% -------------------
iax=1:ndim;
if numel(win)==1
    wout = rebin_IX_dataset_nd_single(win,iax,xbounds,true_values,rebin_hist_func,integrate_points_func,point_integration);
else
    wout=repmat(class_ref,size(win));
    for i=1:numel(win)
        wout(i) = rebin_IX_dataset_nd_single(win(i),iax,xbounds,true_values,rebin_hist_func,integrate_points_func,point_integration);
    end
end

***