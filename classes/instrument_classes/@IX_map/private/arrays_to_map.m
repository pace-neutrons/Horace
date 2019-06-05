function [w,ok,mess] = arrays_to_map(varargin)
% Convert arrays into map structure
%
%   >> [w,ok,mess] = arrays_to_map(isp)                      % Single workspace with a single spectrum
%   >> [w,ok,mess] = arrays_to_map(isp_arr)                  % Map with one spectrum per workspace
%   >> [w,ok,mess] = arrays_to_map(isp_lo, isp_hi)           % Map with one spectrum per workspace,
%                                                             equivalent to IX_map(isp_lo:isp_hi)
%   >> [w,ok,mess] = arrays_to_map(isp_lo, isp_hi, nstep)    % Map with each workspace containing
%                                                             nstep spectra starting at isp_lo,
%                                                             isp_lo+nstep, isp_lo+2*nstep,...
%
%   The arguments is_lo, is_hi, nstep, can be vectors. The result is equivalent
%   to the concatenation of arrays_to_map applied to the arguments element-by-element i.e.
%       arrays_to_map (is_lo, is_hi, step)
%   is equivalent to a combination of the output of
%       arrays_to_map(is_lo(1),is_hi(1),nstep(1)), arrays_to_map(is_lo(2),is_hi(2),nstep(2)), ...

if numel(varargin)==1
    % Single scalar or array
    if isempty(varargin{1}) || ~isnumeric(varargin{1}) || any(rem(varargin{1},1)~=0)
       w=[]; ok=false; mess='Spectrum list must be non-empty scalar or array'; return
    end
    w.ns=ones(1,numel(varargin{1}));
    w.s=varargin{1}(:)';  % row vector
    
elseif numel(varargin)==2
    % Upper and lower limits of spectrum ranges
    if isempty(varargin{1}) || ~isnumeric(varargin{1}) || any(rem(varargin{1},1)~=0) ||...
            isempty(varargin{2}) || ~isnumeric(varargin{2}) || any(rem(varargin{2},1)~=0)|| numel(varargin{1})~=numel(varargin{2})
        w=[]; ok=false; mess='Spectrum range limits must be non-empty numeric scalars or arrays of equal length'; return
    end
    slo=varargin{1}(:)';
    shi=varargin{2}(:)';
    if any(slo>shi)
        w=[]; ok=false; mess='Lower limit(s) must be less than or equal to corresponding upper limit(s)'; return
    end
    nrange=numel(slo);
    w.ns=ones(1,sum(shi-slo+1));
    scell=cell(1,nrange);
    for i=1:nrange
        scell{i}=slo(i):shi(i);
    end
    w.s=cell2mat(scell);
       
elseif numel(varargin)==3
    % Upper and lower limits of spectrum ranges
    if isempty(varargin{1}) || ~isnumeric(varargin{1}) || any(rem(varargin{1},1)~=0) ||...
            isempty(varargin{2}) || ~isnumeric(varargin{2}) || any(rem(varargin{1},1)~=0) || numel(varargin{1})~=numel(varargin{2})
        w=[]; ok=false; mess='Spectrum range limits must be non-empty numeric scalars or arrays of equal length'; return
    end
    slo=varargin{1}(:)';
    shi=varargin{2}(:)';
    if any(slo>shi)
        w=[]; ok=false; mess='Lower limit(s) must be less than equal to corresponding upper limit(s)'; return
    end
    del=varargin{3}(:)';
    if any(del<1) || any(rem(del,1)~=0)
        w=[]; ok=false; mess='Number of spectra per workspace must (all) be integers greater than zero'; return
    end
    if numel(del)==1
        del=del*ones(size(slo));
    elseif numel(del)~=numel(slo)
        w=[]; ok=false; mess='Size of step array must match the limits arrays'; return
    end
    nrange=numel(slo);
    scell=cell(1,nrange);
    for i=1:nrange
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
    w.ns=ns;
    w.s=s;
    
else
    w=[]; ok=false; mess='Check number of input arguments'; return
end

% OK if got to here
ok=true;
mess='';
