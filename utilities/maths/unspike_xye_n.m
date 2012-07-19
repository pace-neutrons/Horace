function [yout, eout] = unspike_xye_n (iax,xin,yin,ein,varargin)
% Remove points deemed spikes from x-y-e data, and replace with values interpolated between good points
%
%   >> [yout, eout] = unspike_xye (xin,yin,ein,ymin,ymax,fac,sfac)
%
% Input:
% ------
%   iax     axis along which to remove spikes
%   xin     x coordinates along that axis
%   yin     signal values: size along dimension iax must match length of xin
%   ein     standard deviations: same size as signal array
%   ymin    Lower filter (all points less than this will be removed) NaN or -Inf to ignore (default)
%   ymax    Upper filter (all points greater than this will be removed) NaN or Inf to ignore (default)
%   fac     Peak threshold factor (default=2):
%               A point is a spike if signal is smaller or larger than both neighbours by this factor,
%              all three signals with same sign and satisfies 
%   sfac    Peak fluctuation threshold (default=5):
%               A point is a spike if differs from it neighbours by this factor of standard deviations,
%              differeing by the same sign
%
%   Both the peak threshold and peak fluctuation criteria must be satisfied.
%
% Output:
% -------
%   yout    Unspiked signal values (obtained by linear interpolation between nearest good flanking points)
%   eout    Unspiked standard deviations (error estimated on interpolated values)

% Check sizes of arrays
sz=size(yin);
sze=size(ein);
if ~(numel(sz)==numel(sze) && all(sz==sze))
    error('Check y, e array sizes are the same')
end
nax=numel(sz);
if iax<1 || iax>nax || round(iax)~=iax
    error(['Axis number to unspike must lie in range 1-',num2str(nax)])
end
if numel(xin)~=sz(iax)
    error('Number of points along axis to be unspiked does not match size of signal and error arrays along that axis')
end

% Catch case of empty input arrays
if prod(sz)==0
    yout=yin;
    eout=ein;
    return
end

% Catch case of one dimensional arrays (simple case)
if (iax==1 && sz(2)==1) || (iax==2 && sz(1)==1)
    [yout,eout]=unspike_xye(xin,yin,ein,varargin{:});
    return
end

% More general case
% Permute, treat, and unpermute
if iax>1
    yin=shiftdim(yin,iax-1);
    ein=shiftdim(ein,iax-1);
end
sz_perm=size(yin);

if size(xin,1)==1, xin=xin(:); end  % make column vector
yin=reshape(yin,sz(iax),prod(sz)/sz(iax));
ein=reshape(ein,sz(iax),prod(sz)/sz(iax));
yout=zeros(size(yin));
eout=zeros(size(ein));
for i=1:prod(sz)/sz(iax)
    [yout(:,i),eout(:,i)] = unspike_xye (xin,yin(:,i),ein(:,i),varargin{:});
end
yout=reshape(yout,sz_perm);
eout=reshape(eout,sz_perm);

if iax>1
    yout=shiftdim(yout,nax-iax+1);
    eout=shiftdim(eout,nax-iax+1);
end
