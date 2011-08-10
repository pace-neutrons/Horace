function [wout,ok,mess] = integrate_IX_dataset_nd (win, ndim, rebin_hist_func, integrate_points_func, varargin)
% Integrate an IX_dataset_nd object or array of IX_dataset_nd objects along all axes
%
%   >> [wout,ok,mess] = rebin_IX_dataset_nd (win, ndim, rebin_hist_func, integrate_points_func, varargin)

% Check point integration option
if ~(numel(varargin)==1 && isa(varargin{1},class(win))) && (numel(varargin)>=1 && ~isnumeric(varargin{end}))  % last argument is point integration option
    [point_integration, ok, mess] = rebin_point_integration_check (ndim, varargin{end});
    if ~ok, wout=[]; return, end
    args=varargin(1:end-1);
else
    point_integration=false(1,ndim);
    args=varargin;
end

% Check integration parameters
if numel(args)>0
    default_full_range=false;
    [ok,xbounds,mess]=integrate_ranges_check(args{:});
    if ~ok, wout=[]; return, end
    if numel(xbounds)~=ndim
        ok=false; wout=[];  mess='Check number of input rebin descriptors matches number of rebin axes'; return
    end
    true_values=true(1,ndim);
else
    % Integration ranges will be full extent of the data
    default_full_range=true;
    xbounds=cell(1,ndim);
    true_values=true(1,ndim);
end


% Perform integration
% -------------------
iax=1:ndim;
integrate_data=true;
if numel(win)==1
    if default_full_range
        for id=1:ndim
            x=axis(win,id);
            xbounds{id}=[x(1),x(end)];
        end
    end
    [dummy,val,err] = rebin_IX_dataset_nd_single(win,iax,xbounds,true_values,...
        rebin_hist_func,integrate_points_func,integrate_data,point_integration);
    wout.val=val;
    wout.err=err;
else
    val=zeros(numel(win),1);
    err=zeros(numel(win),1);
    for i=1:numel(win)
        if default_full_range
            for id=1:ndim
                x=axis(win,id);
                xbounds{id}=[x(1),x(end)];
            end
        end
        [dummy,val(i),err(i)] = rebin_IX_dataset_nd_single(win(i),iax,xbounds,true_values,...
            rebin_hist_func,integrate_points_func,integrate_data,point_integration);
    end
    x_axis=IX_axis('Dataset index');
    if ndim==1  % one-dimensional input datasets
        s_axis=IX_axis(['Integral between ',num2str(xbounds{1}(1)),' and ',num2str(xbounds{1})]);
    end
    wout=IX_dataset_1d(1:numel(win),val,err,win(1).title,x_axis,s_axis,false);
end
ok=true;
mess='';
