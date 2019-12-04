function [xout,yout,sout,eout,nout]=symmetrise_2d_diag(xin,yin,sin,ein,nin,v1,v2,v3,type,win)
%
% Function to symmetrise a 2d dataset along a diagonal (which is defined by
% the plane given by v1, v2, and v3.
%
% RAE 13/1/10

%First do some error checking:
if ~isequal(size(sin),size(ein)) || ~isequal(size(sin),size(nin))
    error('Symmetrise error: input arrays of signals, errors and npix must all be the same size');
end
if ~isequal(size(xin),size(yin))
    error('Symmetrise error: input array of x and y coordinates must be the same size');
end
if ~isequal(size(xin),(size(sin)+1))
    error('Symmetrise error: input array of coordinates must have 1 fewer row and 1 fewer column than signal array');
end
%Check that xin and yin are the results of an "ndgrid" command:
if ~isequal((xin-circshift(xin,[0,-1])),zeros(size(xin)))
    error('Symmetrise error: the 1st input array of x coordinates must be of ndgrid form (all elements in each row the same');
end
if ~isequal((yin-circshift(yin,-1)),zeros(size(yin)))
    error('Symmetrise error: the input array of y coordinates must be of ndgrid form (all elements in each column the same');
end

if numel(v1)~=3 || numel(v2)~=3 || numel(v3)~=3
    error('Symmetrise error: the vectors v1, v2 and v3 must all have 3 elements');
end

if size(v1)==[3,1]
    v1=v1';
end
if size(v2)==[3,1]
    v2=v2';
end
if size(v3)==[3,1]
    v3=v3';
end

if ~isscalar(type)
    error('Symmetrise error: the identifier type must be a single number, equal to 1 or 2');
end

if type~=1
    if type~=2
        error('Symmetrise error: the identifier type must be a single number, equal to 1 or 2');
    end
end

if ~isa(win,'sqw')
    error('Symmetrise error: input object must be of sqw type');
end
  
%==========================================================================
%==========================================================================

ulen=win.data.ulen;
u_to_rlu=win.data.u_to_rlu;

conversion=2*pi./win.data.alatt;
vec1=diag(conversion,0) * v1';
vec2=diag(conversion,0) * v2';
vec3=diag(conversion,0) * v3';

% vec1=diag(ulen(1:3),0) * v1';
% vec2=diag(ulen(1:3),0) * v2';
% vec3=diag(ulen(1:3),0) * v3';

if size(vec1)==[3,1]
    vec1=vec1';
end
if size(vec2)==[3,1]
    vec2=vec2';
end
if size(vec3)==[3,1]
    vec3=vec3';
end

vec1p=inv(u_to_rlu([1:3],[1:3]))*vec1';
vec2p=inv(u_to_rlu([1:3],[1:3]))*vec2';
vec3p=inv(u_to_rlu([1:3],[1:3]))*vec3';

%OLD CODE
% vec1p=(u_to_rlu([1:3],[1:3]))'*vec1';
% vec2p=(u_to_rlu([1:3],[1:3]))'*vec2';
% vec3p=(u_to_rlu([1:3],[1:3]))'*vec3';

trans=vec3p;
normvec=cross(vec1p,vec2p);

%For a diagonal reflection we have either x->y, y->x; or x->-y, y->-x.
%Type=1 means x->y
%Type=2 means x->-y

%============
%No longer needed if we get trans in rlu
% xnorm=xin.*ulen(win.data.pax(1));
% ynorm=yin.*ulen(win.data.pax(2));%this is required in case the length of the axes are different
% %e.g. for an orthorhombic system.

% xintrans=xnorm-trans(1);
% yintrans=ynorm-trans(2);
%============

xintrans=xin-trans(1);
yintrans=yin-trans(2);

%make reflected dataset:
if type==1
    xtmp=yintrans';
    ytmp=xintrans';
    stmp=sin'; etmp=ein'; ntmp=nin';
elseif type==2
    xtmp=-1*yintrans';
    ytmp=-1.*xintrans';
    stmp=sin'; etmp=ein'; ntmp=nin';
else
    error('Horace symmetrisation error: logic flaw. Contact R. Ewings for help');
end

%Now test whether the (translated) co-ordinates are on the rhs of the
%mirror plane or not:
if type==1
    %diagonal is (1,1,0)
    okin=((xintrans>=0 & yintrans<=0) | ...
        (xintrans>=0 & yintrans<=xintrans) | ...
        (xintrans<=0 & yintrans<=xintrans));
    oktmp=((xtmp>=0 & ytmp<=0) | ...
        (xtmp>=0 & ytmp<=xtmp) | ...
        (xtmp<=0 & ytmp<=xtmp));
elseif type==2
    %diagonal is (-1,1,0)
    okin=((xintrans>=0 & yintrans>=0) | ...
        (xintrans>=0 & abs(yintrans)<=xintrans) | ...
        (xintrans<=0 & yintrans>=0 & yintrans>=abs(xintrans)));
    oktmp=((xtmp>=0 & ytmp>=0) | ...
        (xtmp>=0 & abs(ytmp)<=xtmp) | ...
        (xtmp<=0 & ytmp>=0 & ytmp>=abs(xtmp)));
else
    error('Horace symmetrisation error: logic flaw. Contact R. Ewings for help');
end

%Make the ok matrices the same size as sin and stmp:
okinnew=okin([1:end-1],[1:end-1]) .* okin([2:end],[2:end]);
oktmpnew=oktmp([1:end-1],[1:end-1]) .* oktmp([2:end],[2:end]);

sin=sin.*okinnew; ein=ein.*okinnew; nin=nin.*okinnew;
stmp=stmp.*oktmpnew; etmp=etmp.*oktmpnew; ntmp=ntmp.*oktmpnew;

%translate reflected co-ords back to original reference frame:
xtmp=xtmp+trans(1);
ytmp=ytmp+trans(2);

[xout,yout,sout,eout,nout]=combine_2d(xin,yin,sin,ein,nin,xtmp,ytmp,stmp,etmp,ntmp,[]);
%
%Final step is to get the axes correctly normalised again.
%xout=xout./ulen(win.data.pax(1));
%yout=yout./ulen(win.data.pax(2));





