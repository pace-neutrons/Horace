function [wout,ok,mess] = rebin_IX_dataset_nd (win, integrate_data, point_integration_default, iax, descriptor_opt, varargin)
% Rebin an IX_dataset_nd object or array of IX_dataset_nd objects along one or more axes
%
%   >> [wout,ok,mess] = rebin_IX_dataset_nd (win, integrate_data, point_integration_default, iax, isdescriptor,...
%                                            range_1, range_2, ..., point_integration)
%
% Input:
% ------
%   win                 IX_dataset_nd object or array of objects (n=1,2,3...ndim, ndim=dimensoionality of object)
%                      that is to be integrated
%   integrate_data      Integrate(true) or rebin (false)
%   point_integration_default   Default averging method for axes with point data (ignored by any axes with histogram data)
%                         true:  Trapezoidal integration
%                         false: Point averaging
%   iax                 Array of axis indices (chosen from 1,2,3... to a maximum of ndim) to be rebinned or integrated
%                      It is assumed that the input is valid.
%   descriptor_opt      Options that describe the interpretation of rebin/integration intervals. Fields are:
%                               empty_is_full_range     true: [] or '' ==> [-Inf,Inf];
%                                                       false ==> [-Inf,0,Inf]
%                               range_is_one_bin        true: [x1,x2]  ==> one bin
%                                                       false ==> [x1,0,x2]
%                               array_is_descriptor     true:  interpret array of three or more elements as descripor
%                                                       false: interpet as actual bin boundaries
%                               bin_boundaries          true:  intepret x values as bin boundaries
%                                                       false: interpret as bin centres
%   range_1, range_2    Arrays of rebin/integration intervals, one per rebin/integration axis. Depending on isdescriptor,
%                      there are a number of different formats and defaults that are valid.
%                       If win is one dimensional, then if all the arguments can be scalar they are treated as the
%                      elements of range_1
%         *OR*    
%   wref                Reference dataset from which to take bins. Must be a scalar, and same dimensionality as the elements of win
%
%   point_integration   Averaging method if point data (if not given, then uses default determined by point_integration_default above)
%                        - character string 'integration' or 'average'
%                        - cell array with number of entries equalling number of rebin/integration axes (i.e. numel(iax))
%                          each entry the character string 'integration' or 'average'
%                       If an axis is a histogram data axis, then its corresponding entry is ignored
%
% Output:
% -------
%   wout                IX_dataset_nd object or array of objects following the rebinning/integration
%   ok                  True if no problems, false otherwise
%   mess                Error message; empty if ok

[use_mex,force_mex]=get(herbert_config,'use_mex','force_mex_if_use_mex');
%use_mex=get(herbert_config,'use_mex');
%force_mex=get(herbert_config,'force_mex_if_use_mex');

nax=numel(iax); % number of axes to be rebinned

% Check point integration option
% ------------------------------
if ~(numel(varargin)==1 && isa(varargin{1},class(win))) && (numel(varargin)>=1 && ~isnumeric(varargin{end}))  % last argument is point integration option
    [point_integration, ok, mess] = rebin_point_integration_check (nax, varargin{end});
    if ~ok, wout=[]; return, end
    args=varargin(1:end-1);
else
    point_integration=repmat(point_integration_default,[1,nax]);
    args=varargin;
end

% Check rebin parameters
% ----------------------
% If the rebin boundaries are the same for all input datasets (i.e. no knowledge of their axes is required to
% resolve infinities in the lower of upper rebin limits, or retain original bin widths for some regions) then
% construct the new bin boundaries here to avoid repeated calculation in a loop over the size of win.

if numel(args)==1 && isa(args{1},class(win))
    % Rebin according to bins in a reference object; for axes with point data, construct bin boundaries by taking the half-way points between the points
    wref=args{1};
    if numel(wref)~=1
        ok=false; wout=[];  mess='Reference dataset for rebinning must be a single instance, not an array'; return
    end
    for i=1:nax
        ax=axis(wref,iax(i));
        if numel(ax.values)<=1  % single point dataset, or histogram dataset with empty signal array
            error('Reference dataset must have at least one bin (histogram data) or two points (point data)')
        end
    end
    xbounds=cell(1,nax);
    true_values=true(1,nax);
    for i=1:nax
        tmp=axis(wref,iax(i));
        if ishistogram(wref,iax(i))
            xbounds{i}=tmp.values;
        else
            [xbounds{i},ok,mess]=bin_boundaries_simple(tmp.values);
            if ~ok
                wout=[]; mess=['Unable to construct bin boundaries for point data axis number ',num2str(iax(i)),': ',mess]; return
            end
        end
    end
    is_descriptor=false(1,nax);

else
    % Use rebin description to define new bin boundaries
    [ok,xbounds,any_lim_inf,is_descriptor,any_dx_zero,mess]=rebin_boundaries_description_parse(nax,descriptor_opt,args{:});
    if ~ok, wout=[]; return, end
    true_values= ~(any_lim_inf|any_dx_zero);   % true bin boundaries
    for i=find(true_values&is_descriptor)
        xbounds{i}=bin_boundaries_from_descriptor(xbounds{i},0,use_mex,force_mex);  % need to give dummy x bins for mex file
    end
    
end


% Perform rebin
% -------------
if numel(win)==1
    [wout,ok,mess] = rebin_IX_dataset_nd_single(win,iax,xbounds,true_values,is_descriptor,integrate_data,point_integration,use_mex,force_mex);
else
    ndim=dimensions(win(1));
    wout=repmat(IX_dataset_nd(ndim),size(win));
    for i=1:numel(win)
        [wout(i),ok,mess] = rebin_IX_dataset_nd_single(win(i),iax,xbounds,true_values,is_descriptor,integrate_data,point_integration,use_mex,force_mex);
        if ~ok, return, end
    end
end
