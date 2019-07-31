function [yd,ed] = deriv_xye(x,y,e)
% Numerical first derivative of xye points
%
%   >> [yd,ed] = deriv_xye(x,y,e)
%
% Input:
% ------
%   x   x values
%   y   signal
%   e   standard deviations on signal
%
% Output:
% -------
%   yd  Derivative of signal
%   ed  Standard deviation
%
% 
% If there is only one point in the input arrays, the derivative is returned as zero.
%
% Input arrays will be converted to vectors internally, and then reshaped to original 
% shape on exit.

% Check lengths of input arrays
np=numel(x);
if numel(y)~=np || numel(e)~=np
    error('x,y,e arrays must have equal lengths')
end
% Catch trivial case of empty arrays or one point
if np==0
    yd=y;
    ed=e;
    return
elseif np==1
    yd=0;
    ed=0;
    return
end
% Convert to column vectors
if size(x,1)~=np
    x=x(:);
end
reshape_y=false;
if size(y,1)~=np
    reshape_y=true;
    y=y(:);
end
reshape_e=false;
if size(e,1)~=np
    reshape_e=true;
    e=e(:);
end

% Calculate derivative
dx=x(3:end)-x(1:end-2);
dy=y(3:end)-y(1:end-2);
ybeg=(y(2)-y(1))/(x(2)-x(1));
yend=(y(end)-y(end-1))/(x(end)-x(end-1));
yd=[ybeg;dy./dx;yend];
ebeg=sqrt(e(2)^2 + e(1)^2)/(x(2)-x(1));
eend=sqrt(e(end)^2 + e(end-1)^2)/(x(end)-x(end-1));
ed=[ebeg;sqrt(e(3:end).^2 + e(1:end-2).^2)./dx;eend];

% Return arrays to original sizes
if reshape_y, yd=reshape(yd,size(yin)); end
if reshape_e, ed=reshape(ed,size(ein)); end
