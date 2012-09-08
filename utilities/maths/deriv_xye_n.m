function [yd,ed] = deriv_xye_n(iax,x,y,e)
% Numerical first derivative of xye points along indicated axis
%
%   >> [yd,ed] = deriv_xye(x,y,e)
%
% Input:
% ------
%   iax axis along which to perform numerical derivative
%   x   x values
%   y   array of signal values; size along dimension iax must match length of x
%   e   standard deviations on signal: same size as signal array
%
% Output:
% -------
%   yd  Derivative of signal along axis iax
%   ed  Standard deviation
%
% 
% If there is only one point along the axis, the derivative is returned as zero.

% Check sizes of arrays
sz=size(y);
sze=size(e);
if ~(numel(sz)==numel(sze) && all(sz==sze))
    error('Check y, e array sizes are the same')
end
nax=numel(sz);
if iax<1 || iax>nax || round(iax)~=iax
    error(['Axis number to unspike must lie in range 1-',num2str(nax)])
end
if numel(x)~=sz(iax)
    error('Number of points along axis to be differentiated does not match size of signal and error arrays along that axis')
end

% Catch trivial case of empty arrays or one point
if prod(sz)==0
    yd=y;
    ed=e;
    return
elseif numel(x)==1
    yd=zeros(size(y));
    ed=zeros(size(y));
    return
end

% Catch case of one dimensional arrays (simple case)
if (iax==1 && sz(2)==1) || (iax==2 && sz(1)==1)
    [yd,ed]=deriv_xye(x,y,e);
    return
end

% More general case
% Permute, treat, and unpermute
if iax>1
    y=shiftdim(y,iax-1);
    e=shiftdim(e,iax-1);
end
sz_perm=size(y);

if size(x,1)==1, x=x(:); end  % make column vector
y=reshape(y,sz(iax),prod(sz)/sz(iax));
e=reshape(e,sz(iax),prod(sz)/sz(iax));
yd=zeros(size(y));
ed=zeros(size(e));
for i=1:prod(sz)/sz(iax)
    [yd(:,i),ed(:,i)] = deriv_xye (x,y(:,i),e(:,i));
end
yd=reshape(yd,sz_perm);
ed=reshape(ed,sz_perm);

if iax>1
    yd=shiftdim(yd,nax-iax+1);
    ed=shiftdim(ed,nax-iax+1);
end
