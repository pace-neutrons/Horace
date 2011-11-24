function wd = deriv(w)
% Calculate numerical first derivative of an IX_dataset_1d or array of IX_datasset_1d
%
%   >> wd = deriv (w)
%
%   w   input IX_dataset_1d
%   wd  output IX_dataset_1d

wd=w;
for i=1:numel(w)
    if numel(w(i).x)==numel(w(i).signal)
        xp=w(i).x';
    else
        xp=0.5*(w(i).x(1:end-1)+w(i).x(2:end))';
    end
    [yd,ed]=yderiv(xp,w(i).signal,w(i).error);
    wd(i).signal=yd;
    wd(i).error=ed;
end

%------------------------------------------------------------
function [yd,ed] = yderiv(x,y,e)
% Numerical first derivative of xye points
% Arrays must be column vectors
% If length<2 then tries to do something sensible

if numel(x)>=2
    dx=x(3:end)-x(1:end-2);
    dy=y(3:end)-y(1:end-2);
    ybeg=(y(2)-y(1))/(x(2)-x(1));
    yend=(y(end)-y(end-1))/(x(end)-x(end-1));
    yd=[ybeg;dy./dx;yend];
    ebeg=sqrt(e(2)^2 + e(1)^2)/(x(2)-x(1));
    eend=sqrt(e(end)^2 + e(end-1)^2)/(x(end)-x(end-1));
    ed=[ebeg;sqrt(e(3:end).^2 + e(1:end-2).^2)./dx;eend];
elseif numel(x)==1
    yd=0;
    ed=0;
else
    yd=[];
    ed=[];
end
