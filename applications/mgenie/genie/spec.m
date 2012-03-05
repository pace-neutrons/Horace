function warr = spec (varargin)
% Read a group of spectra from the current data source into a single time-of-flight spectrum
%
% Direct specification of spectra:
% --------------------------------
%   >> w = spec(is)                    Load spectrum IS into workspace W
%   >> w = spec(is_lo, is_hi)          Loads spectra IS_LO to IS_HI into workspace,
%
%   The arguments is_lo, is_hi can be vectors:
%   >> w = spec(is)                    Sum of spsectra in IS into workspace W
%   >> w = spec(is_lo, is_hi)          Sum of spectra [is_lo(1):is_hi(1), is_lo(2):is_hi(2),...]
%
%
% Map specification: sums all spectra in the map
% ------------------
%   >> w = spec(map)                   Map is a cell array of 1D arrays, each array containing
%                                      the spectrum numbers for one workspace.
%                                       The map cell array can be read from a file using the
%                                      function load_map (type >> help load_map)
%
%
% Optional arguments: (any or all of the following in any order)
% -------------------
%   >> w = spec(...,'mask', mask_array, 'units', unitcode, 'binning', binpar, 'det', det_source, av_mode, 'period', iperiod)
%
%   mask        Array of masked spectra (default: no masking)
%               The mask array can be read from a mask file using load_mask (type >> help load_mask)
%
%   unit        Character code giving units e.g. (default: 't')
%                 't', 'd', 'lam', 'w', 'thz'
%               (type help tofspectrum/units for full set)
%
%   rebin       Rebin parameters
%                   e.g.  [xlo,xhi] or [xlo,dx,xhi]  (see >> help rebin for details)
%               Can give different parameters for each workspace as a cell array of binning parameters
%               once cell per workspace.
%
%   det         Detector parameter information (Default: use information from the raw file)
%                - name of detector.dat file
%                - structure with information read from a detector.dat file read by get_detector_par)
%
%   av_mode     Averaging scheme for workspace parameters (default: 'average'):
%                   = 'average'         take the average for all detector elements in a workspace
%                   = 'min_twotheta'    take parameters from the detector element with minimum twotheta
%                   = 'max_twotheta'    take parameters from the detector element with minimum twotheta
%                   = 'none'            no parameters calculated (only possible with output units are time-of-flight
%
%   period      Period number or array of period numbers (default: periods igonored)
%              If one or more period numbers are given, then the spectrum numbers in the map and mask information must  
%              be restricted to the first period. The resulting workspaces are then repeated for each of the
%              periods requested, with the spectrum numbers offset appropriately, and the workspaces from each
%              period are concatenated in teh final output.


nsp = double(genie_get('nsp1'));
nper= double(genie_get('nper'));
nsptot = nper*(nsp+1) - 1;    % maximum spectrum number in a multi-period run


% Find qualifiers and their values, and make basic checks 
arglist = struct(... % argument names and default values
    'mask',[],...
    'units','t',...
    'rebin',[],...
    'det','',...
    'average',0,...
    'min_twotheta',0,...
    'max_twotheta',0,...
    'none',0,...
    'period',[]);
flags = {'average','min_twotheta','max_twotheta','none'};
[par,arg,present,filled] = parse_arguments(varargin,arglist,flags);

% Check mapping description is present
if isempty(par)
    error('Must give mapping description')
end

% Check mask input
if filled.mask
    if isnumeric(arg.mask)
        mask=arg.mask(:)';  % make row vector
    else
        error('Mask array must be numeric list')
    end
else
    mask = [];
end

% Check units
if filled.units && ischar(arg.units)
    unit=arg.units;
else
    error('Check units argument')
end

% Check binning
if filled.rebin
    binning=arg.rebin;
else
    binning=[];
end

% Check averaging mode
sum_av_mode=arg.average+arg.min_twotheta+arg.max_twotheta+arg.none;
if sum_av_mode==1
    if arg.average
        av_mode='average';
    elseif arg.min_twotheta
        av_mode = 'min_twotheta';
    elseif arg.max_twotheta
        av_mode = 'max_twotheta';
    elseif arg.none
        av_mode = 'none';
    end
elseif sum_av_mode==0
    av_mode='average';
else
    error('Choose only one averaging mode')
end

% Check periods
if filled.period
    iperiod = arg.period;
    if isempty(iperiod)||~isnumeric(iperiod)
        error ('Period number(s) must be a numeric scalar or array')
    else
        iperiod=iperiod(:)';    % make row vector
        if min(iperiod)<1||max(iperiod)>nper
            error (['Period numbers must lie in range 1 -',num2str(nper)])
        end
    end
else
    iperiod=[];
end


% Check the mapping information
% ------------------------------
if numel(par)==1 && iscell(par{1})
    % Cell array - interpret as map description
    if isempty(par{1})
        error('map cannot be empty')
    end
    map=par{1}(:)';  % row vector of cells
    nw=numel(map);
    ns=zeros(1,nw);
    for i=1:length(map)
        if isnumeric(map{i})
            ns(i)=numel(map{i});
            map{i}=map{i}(:)';  % make row vector
        else
            error('Mapping data must be numeric')
        end
    end
    s=cell2mat(map);
    
elseif numel(par)==1
    % Single scalar or array
    if isempty(par{1}) || ~isnumeric(par{1})
        error('Spectrum list must be non-empty numeric array')
    end
    s=par{1}(:)';  % row vector
    ns=ones(1,numel(s));
    
elseif numel(par)==2
    % Upper and lower limits of spectrum ranges
    if isempty(par{1}) || ~isnumeric(par{1}) || isempty(par{2}) || ~isnumeric(par{2}) || numel(par{1})~=numel(par{2})
        error('Spectrum range limits must be non-empty numeric scalars or arrays of equal length')
    end
    slo=par{1}(:)';
    shi=par{2}(:)';
    if any(slo>shi)
        error('Lower limit(s) must be less than equal to corresponding upper limit(s)')
    end
    nrange=numel(slo);
    ns=ones(1,sum(shi-slo+1));
    scell=cell(1,nrange);
    for i=1:nrange,
        scell{i}=slo(i):shi(i);
    end
    s=cell2mat(scell);
       
elseif numel(par)==3
    % Upper and lower limits of spectrum ranges
    if isempty(par{1}) || ~isnumeric(par{1}) || isempty(par{2}) || ~isnumeric(par{2}) || numel(par{1})~=numel(par{2})
        error('Spectrum range limits must be non-empty numeric scalars or arrays of equal length')
    end
    slo=par{1}(:)';
    shi=par{2}(:)';
    if any(slo>shi)
        error('Lower limit(s) must be less than equal to corresponding upper limit(s)')
    end
    del=par{3}(:)';
    if any(del<1)
        error('Number of spectra per workspace must (all) be greater than zero')
    end
    if numel(del)==1
        del=del*ones(size(slo));
    elseif numel(del)~=numel(slo)
        error('Size of step array must match the limits arrays')
    end
    nrange=numel(slo);
    scell=cell(1,nrange);
    for i=1:nrange,
        scell{i}=slo(i):shi(i);
    end
    s=cell2mat(scell);
    nsper = shi-slo+1;                  % no. spectra in each range
    nwper = 1 + floor((shi-slo)./del);  % no. workspaces in each range
    nwsum = [0,cumsum(nwper)];
    ns = zeros(1,nwsum(end));           % initialise array to hold no. spectra in each workspace
    last_step = nsper - del.*(nwper-1); % no. spectra in last step
    for i=1:numel(slo)
        ns(nwsum(i)+1:nwsum(i+1))=del(i);
        ns(nwsum(i+1))=last_step(i);
    end
    
else
    error('Check the mapping of spectra to workspace has a valid format')
       
end

% Check binning information
% --------------------------
% Now that we know how many workspaces we have, make cell array of rebin parameters
if ~isempty(binning)
    nw=numel(ns);
    if isnumeric(binning)
        if size(binning,1)==1
            binpar=repmat({binning},nw,1);
        elseif size(binning,1)==nw
            binpar=mat2cell(binning,ones(1,nw),size(binning,2));
        else
            error('Check size of array of binning parameters - must be a single description, or one per workspace')
        end
    elseif iscell(binning)
        if numel(binning)==1
            binpar=repmat(binning,nw,1);
        elseif numel(binning)==nw
            binpar=binning(:);
        else
            error('Check size of cell array of binning parameters - must be a single description, or one per workspace')
        end
    else
        error('Check rebinning description')
    end
else
    binpar=[];
end


% If period number given, offset the spectrum numbers accordingly
% ----------------------------------------------------------------
% The mapping and masking information must be for the first period only if a period number is given.

s_min=min(s);
s_max=max(s);
m_min=min(mask);
m_max=max(mask);
if filled.period
    if s_min<0 || s_max>nsp
        error(['Spectrum numbers in mapping descsription must lie in the range 0 -',num2str(nsp),' if period number(s) given'])
    end
    if ~isempty(mask) && (m_min<0 || m_max>nsp)
        error(['Spectrum numbers in mask list must lie in the range 0 -',num2str(nsp)],' if period number(s) given')
    end
    % Propagate map and mask across the periods
    np=numel(iperiod);
    offset=(nsp+1)*(iperiod-1);
    ns=repmat(ns,1,np);   % the array of output spectra is repeated for each period
    s=repmat(s',1,np);    % repeat s as a series of column vectors
    for i=1:np
        s(:,i)=s(:,i)+offset(i);
    end
    s=s(:)';    % remake as row vector
    if ~isempty(mask)
        mask = repmat(mask',1,np);   % repeat mask as a series of column vectors
        for i=1:np
            mask(:,i)=mask(:,i)+offset(i);
        end
        mask=mask(:)';
    end
    % Propagate binning information across the periods
    if ~isempty(binpar)
        binpar=repmat(binpar,np,1);
    end

else
    if s_min<0 || s_max>nsptot
        error(['Spectrum numbers in mapping descsription must lie in the range 0 -',num2str(nsptot)])
    end
    if ~isempty(mask) && (m_min<0 || m_max>nsptot)
        error(['Spectrum numbers in mask list must lie in the range 0 -',num2str(nsptot)])
    end
end


% Get data:
% ---------
detpar=get_detector_par(arg.det);     % read here, as could take 1 or 2 seconds

% *** Change in spec w.r.t spec cf mspec: add all spectra together, so replace ns with sum(ns)
warr=mspec_core (sum(ns(:)), s, mask, detpar, av_mode, unit, binpar);
