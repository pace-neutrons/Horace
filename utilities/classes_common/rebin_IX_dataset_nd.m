function [wout,ok,mess] = rebin_IX_dataset_nd (win, rebin_hist_func, integrate_points_func,...
                              integrate_data, point_integration_default, iax, isdescriptor, varargin)
% Rebin an IX_dataset_nd object or array of IX_dataset_nd objects along one or more axes
%
%   >> [wout,ok,mess] = rebin_IX_dataset_nd (win, rebin_hist_func, integrate_points_func, integrate_data, iax, isdescriptor, varargin)

nax=numel(iax); % number of axes to be rebinned

% Check point integration option
if ~(numel(varargin)==1 && isa(varargin{1},class(win))) && (numel(varargin)>=1 && ~isnumeric(varargin{end}))  % last argument is point integration option
    [point_integration, ok, mess] = rebin_point_integration_check (nax, varargin{end});
    if ~ok, wout=[]; return, end
    args=varargin(1:end-1);
else
    point_integration=repmat(point_integration_default,[1,nax]);
    args=varargin;
end

% Check rebin parameters
if numel(args)==1 && isa(args{1},class(win))
    % Rebin according to bins in a reference object
    wref=args{1};
    if numel(wref)~=1
        ok=false; wout=[];  mess='Reference dataset for rebinning must be a single instance, not an array'; return
    elseif numel(wref.x)==1  % single point dataset, or histogram dataset with empty signal array
        error('Reference dataset must have at least one bin (histogram data) or two points (point data)')
    end
    xbounds=cell(1,nax);
    true_values=true(1,nax);
    for i=1:nax
        tmp=axis(wref,iax(i));
        if ishistogram(wref,iax(i))
            xbounds{i}=tmp.values;
        else
            xbounds{i}=bin_boundaries_simple(tmp.values);
        end
    end

else
    if isdescriptor
        [ok,xbounds,any_dx_zero,mess]=rebin_descriptor_check(nax,args{:});
        if ~ok, wout=[]; return, end
        true_values=false(1,nax);
        for i=1:nax
            if numel(xbounds{i})>=3 && ~any_dx_zero(i)                      % get new bin boundaries
                xbounds{i}=bin_boundaries_from_descriptor(xbounds{i},0);    % need to give dummy x bins for mex file
                true_values(i)=true;
            end
        end
    else
        [ok,xbounds,any_dx_zero,mess]=rebin_boundaries_check(nax,args{:});
        if ~ok, wout=[]; return, end
        true_values=~any_dx_zero;
    end

end


% Perform rebin
% -------------
if numel(win)==1
    wout = rebin_IX_dataset_nd_single(win,iax,xbounds,true_values,...
        rebin_hist_func,integrate_points_func,integrate_data,point_integration);
else
    ndim=dimensions(win(1));
    wout=repmat(IX_dataset_nd(ndim),size(win));
    for i=1:numel(win)
        wout(i) = rebin_IX_dataset_nd_single(win(i),iax,xbounds,true_values,...
            rebin_hist_func,integrate_points_func,integrate_data,point_integration);
    end
end
ok=true;
mess='';
