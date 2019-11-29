function [wout,ok,mess] = rebin_IX_dataset_nd (win, integrate_data, point_integration_default, iax, descriptor_opt, varargin)
% Rebin an IX_dataset_nd object or array of IX_dataset_nd objects along one or more axes
%
%   >> [wout,ok,mess] = rebin_IX_dataset_nd (win, integrate_data, point_integration_default, iax, isdescriptor,...
%                                            range_1, range_2, ..., point_integration)
% OR
%   >> [wout,ok,mess] = rebin_IX_dataset_nd (win, integrate_data, point_integration_default, iax, isdescriptor,...
%                                            wref, point_integration)
%
% Input:
% ------
%   win                 IX_dataset_nd, or array or IX_dataset_nd (n=1,2,3)
%                   *OR*
%                       Structure array, where the fields of each element are
%                           win(i).x              Cell array of arrays containing the x axis baoundaries or points (each a row vector)
%                           win(i).signal         Signal array
%                           win(i).err            Array of standard deviations
%                           win(i).distribution   Array of elements, one per axis that is true if a distribution, false if not
%
%   integrate_data      Integrate(true) or rebin (false)
%   point_integration_default   Default averaging method for axes with point data (ignored by any axes with histogram data)
%                         true:  Trapezoidal integration
%                         false: Point averaging
%   iax                 Array of axis indices (chosen from 1,2,3... to a maximum of ndim) to be rebinned or integrated
%                      It is assumed that the input is valid.
%   descriptor_opt      Options that describe the interpretation of rebin/integration intervals. Fields are:
%                               empty_is_full_range     true: [] or '' ==> [-Inf,Inf];
%                                                       false ==> [-Inf,0,Inf]
%                               range_is_one_bin        true: [x1,x2]  ==> one bin
%                                                       false ==> [x1,0,x2]
%                               array_is_descriptor     true:  interpret array of three or more elements as descriptor
%                                                       false: interpet as actual bin boundaries
%                               bin_boundaries          true:  intepret x values as bin boundaries
%                                                       false: interpret as bin centres
%   range_1, range_2    Arrays of rebin/integration intervals, one per rebin/integration axis. Depending on isdescriptor,
%                      there are a number of different formats and defaults that are valid.
%                       If win is one dimensional, then if all the arguments can be scalar they are treated as the
%                      elements of range_1
%         *OR*
%   wref                Reference dataset from which to take bins. Must be a scalar, and the same class as win
%                      Only those axes indicated by input argument iax are taken from the reference object.
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
%                   *OR*
%                       Structure array, where the fields of each element are
%                           wout(i).x             Cell array of arrays containing the x axis boundaries or points
%                           wout(i).signal        Signal array
%                           wout(i).err           Array of standard deviations
%                           wout(i).distribution  Array of elements, one per axis that is true if a distribution, false if not
%
%   ok                  True if no problems, false otherwise
%   mess                Error message; empty if ok



% % *** TEMPORARY STUFF FOR TESTING INPUT AS STRUCTURE *****************************
% test_struct=true;
% if test_struct
%     win_store=win;
%     win=get_xsigerr(win);
%     if numel(varargin)>0 && (isa(varargin{1},'IX_dataset_1d')||isa(varargin{1},'IX_dataset_2d')||isa(varargin{1},'IX_dataset_3d'))
%         varargin{1}=get_xsigerr(varargin{1});
%     end
% end
% % ********************************************************************************
% Determine data input class
% --------------------------
nds = numel(win);
if isstruct(win)
    is_IX_dataset_nd=false;
    win_size = size(win);
    
    win = reshape(win,nds,1);
    if iscell(win.x)
        ndim = numel(win.x);
    else
        ndim = 1;
    end
    win = repmat(IX_dataset_nd(ndim),nds,1);
    for i=1:nds
        if iscell(win(i).x)
            dist = {win(i).distribution(:)};
            argi = [win(i).x{:},win(i).signal,win(i).err,dist{:}];
        else
            argi = {win(i).x,win(i).signal,win(i).err,win(i).distribution};
        end
        win(i) = win(i).init(argi{:});
    end
elseif isa(win,'IX_dataset')
    is_IX_dataset_nd=true;
else
    error('IX_dataset_nd:invalid_argument',...
        'Dataset to be rebinned has unrecognised type');
end

[wout,ok,message] = IX_dataset.rebin_IX_dataset(win,integrate_data, point_integration_default, iax, descriptor_opt, varargin{:});
if ~ok
    error('IX_dataset_nd:runtime_error',message);
end

if ~is_IX_dataset_nd
    wouts=struct('x',{{}},'signal',[],'err',[],'distribution',false);
    wouts=repmat(wouts,nds);
    for i=1:nds
        wouts(i).x = wout(i).get_xyz;
        wouts(i).signal = wout(i).signal;
        wouts(i).err = wout(i).error;
        wouts(i).distribution = wout(i).get_isdistribution();
    end
    wout = reshape(wouts,win_size);
end
