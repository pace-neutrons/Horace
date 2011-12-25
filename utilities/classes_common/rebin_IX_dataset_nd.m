function [wout,ok,mess] = rebin_IX_dataset_nd (win, integrate_data, point_integration_default, iax, isdescriptor, varargin)
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
%   iax                 Array of axis indices (chosen from 1,2,3... to a maximum of ) to be rebinned or integrated
%   isdescriptor        Rebin/integration intervals are given by a descriptor of the values (true) or
%                      an array of actual values (false)
%   range_1, range_2    Arrays of rebin/integration intervals, one per rebin/integration axis. Depending on isdescriptor,
%                      there are a number of different formats and defaults that are valid.
%                       If win is one dimensional, then if all the arguments can be scalar they are treated as the
%                      elements of range_1
%   point_integration   Averaging method if point data
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

use_mex=get(herbert_config,'use_mex');
force_mex=get(herbert_config,'force_mex_if_use_mex');

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
        [ok,xbounds,any_dx_zero,mess]=rebin_boundaries_descriptor_check(nax,args{:});
        if ~ok, wout=[]; return, end
        true_values=false(1,nax);
        for i=1:nax
            if numel(xbounds{i})>=3 && ~any_dx_zero(i)  % get new bin boundaries
                xbounds{i}=bin_boundaries_from_descriptor(xbounds{i},0,use_mex,force_mex);  % need to give dummy x bins for mex file
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
    [wout,ok,mess] = rebin_IX_dataset_nd_single(win,iax,xbounds,true_values,integrate_data,point_integration,use_mex,force_mex);
else
    ndim=dimensions(win(1));
    wout=repmat(IX_dataset_nd(ndim),size(win));
    for i=1:numel(win)
        [wout(i),ok,mess] = rebin_IX_dataset_nd_single(win(i),iax,xbounds,true_values,integrate_data,point_integration,use_mex,force_mex);
        if ~ok, return, end
    end
end
