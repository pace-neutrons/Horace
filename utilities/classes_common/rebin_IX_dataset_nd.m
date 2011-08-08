function wout = rebin_IX_dataset_nd (win, class_ref, rebin_hist_func, integrate_points_func, iax, isdescriptor, varargin)
% Rebin an IX_dataset_nd object or array of IX_dataset_nd objects along one or more axes
%
%   >> wout = rebin_IX_dataset_nd (win, class_ref, rebin_hist_func, integrate_points_func, iax, isdescriptor, varargin)

nax=numel(iax); % number of axes in object

% Check point integration option
if ~(numel(varargin)==1 && isa(varargin{1},class(win))) && (numel(varargin)>=1 && ~isnumeric(varargin{end}))  % last argument is point integration option
    [point_integration, ok, mess] = rebin_point_integration_check (nax, varargin{end});
    if ~ok, error(mess), end
    args=varargin{1:end-1};
else
    point_integration=true(1,nax);
    args=varargin;
end

% Check rebin parameters
if numel(args)==1 && isa(args{1},class(win))
    % Rebin according to bins in a reference object
    wref=args{1};
    if numel(wref)~=1
        error('Reference dataset for rebinning must be a single instance, not an array')
    end
    xbounds=cell(1,nax);
    true_values=true(1,nax);
    for i=1:nax
        if ishistogram(wref,iax(i))
            xbounds{i}=axis(wref,iax(i));
        else
            xbounds{i}=bin_boundaries_simple(axis(wref,iax(i)));
        end
    end

elseif numel(args)>0
    if isdescriptor
        [ok,xbounds,any_dx_zero,mess]=rebin_descriptor_check(varargin{:});
        true_values=false(1,nax);
        if ok
            for i=1:nax
                if numel(xbounds{i})>=3 && ~any_dx_zero(i)              % get new bin boundaries
                    xbounds{i}=bin_boundaries_from_descriptor(xbounds{i},0);  % need to give dummy x bins
                    true_values(i)=true;
                end
            end
        else
            error(mess)
        end
    else
        [ok,xbounds,mess]=rebin_boundaries_check(varargin{:});
        if ok
            for i=1:nax
                if numel(xbounds{i})<2 || any(diff(xbounds{i})<=0)
                    error('Rebin boundaries must be strictly monotonic increasing i.e. bin widths all > 0')
                end
            end
        else
            error(mess)
        end
    end
else
    error('Check rebinning parameters')
end


% Perform rebin
% -------------
if numel(win)==1
    wout = rebin_IX_dataset_nd_single(win,iax,xbounds,true_values,rebin_hist_func,integrate_points_func,point_integration);
else
    wout=repmat(class_ref,size(win));
    for i=1:numel(win)
        wout(i) = rebin_IX_dataset_nd_single(win(i),iax,xbounds,true_values,rebin_hist_func,integrate_points_func,point_integration);
    end
end
