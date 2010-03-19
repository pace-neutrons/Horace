function [xright,yright,sright,eright,nright]=discard_lhs(x,y,s,e,n,win,v1,v2,v3)
%
% Subroutine to get rid of any data which lies on the left-hand side of the
% specified mirror plane.
%
% RAE 12/1/10

win=sqw(win);

xright=x; yright=y; sright=s; eright=e; nright=n;

% conversion=2*pi./win.data.alatt;
% vec1=diag(conversion,0) * v1';
% vec2=diag(conversion,0) * v2';
% vec3=diag(conversion,0) * v3';

vec1=v1';
vec2=v2';
vec3=v3';

% vec1=diag(win.data.ulen(1:3),0) * v1';
% vec2=diag(win.data.ulen(1:3),0) * v2';
% vec3=diag(win.data.ulen(1:3),0) * v3';

if size(vec1)==[3,1]
    vec1=vec1';
end
if size(vec2)==[3,1]
    vec2=vec2';
end
if size(vec3)==[3,1]
    vec3=vec3';
end

vec1p=inv(win.data.u_to_rlu([1:3],[1:3]))*vec1';
vec2p=inv(win.data.u_to_rlu([1:3],[1:3]))*vec2';
vec3p=inv(win.data.u_to_rlu([1:3],[1:3]))*vec3';

% vec1p=(win.data.u_to_rlu([1:3],[1:3]))'*vec1';
% vec2p=(win.data.u_to_rlu([1:3],[1:3]))'*vec2';
% vec3p=(win.data.u_to_rlu([1:3],[1:3]))'*vec3';

trans=vec3p;
normvec=cross(vec1p,vec2p);

transnew=trans(1:2);
sz=size(x(1,:));
transrep=repmat(transnew,1,sz(2));

%Can determine which side of the plane a given point is on by taking the
%dot product of the normal and the coordinate of the point relative to some
%position in the plane.

c1=[x(1,:); y(1,:)]; c2=[x(2,:); y(2,:)]; c3=[x(3,:); y(3,:)]; c4=[x(4,:); y(4,:)];

c1t=c1-transrep; c2t=c2-transrep; c3t=c3-transrep; c4t=c4-transrep;

normmat=repmat(normvec(1:2),1,sz(2));

side_dot1=dot(normmat,c1t); side_dot2=dot(normmat,c2t);
side_dot3=dot(normmat,c3t); side_dot4=dot(normmat,c4t);

allok=(side_dot1<=0 & side_dot2<=0 & side_dot3<=0 & side_dot4<=0);

xright=xright(:,allok);
yright=yright(:,allok);
sright=sright(allok);
eright=eright(allok);
nright=nright(allok);





