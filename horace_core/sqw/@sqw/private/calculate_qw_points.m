function [qw1,qw2]=calculate_qw_points(win,x)
% Calculate qh,qk,ql,en for set of points in an n-dimensional sqw dataset
%
%   >> qw=calculate_qw_points(win)          % (Q,w) when energy is the implicit variable for a direct geometry cut
%   >> [qw1,qw2]=calculate_qw_points(win)   % in general two roots for other cases
%
% Input:
% ------
%   win     Input sqw object created from a single spe file
%
%   x       Vector of coordinates in the display axes of an sqw object
%           The number of coordinates must match the dimensionality of the object.
%          e.g. for a 2D sqw object, x=[x1,x2], where x1, x2 are column vectors.
%           More than one point can be provided by giving more rows
%          e.g.  [1.2,4.3; 1.1,5.4; 1.32, 6.7] for 3 points from a 2D object.
%           Generally, an (n x nd) array, where n is the number of points, nd
%          the dimensionality of the object.
%
% Output:
% -------
%   qw1     Components of momentum (in rlu) and energy for each bin in the dataset
%           Generally, will be (n x 4) array, where n is the number of points
%
%   qw2     For the second root
%
%   If direct geometry, and
%    - energy transfer is the implicit variable to be determined:
%           there is only one root and qw2=[];
%    - if a component of Q is implicit variable to be determined
%           in general there are either zero or two roots
%             - if two roots
%                 qw1 corresponds to the root with more negative component along the infinite integration axis
%                 qw2 corresponds to the more positive component
%             - if no roots
%                 all elements of the corresponding row in qw1, qw2 set to NaN
%
%   If indirect geometry, and
%    - energy transfer is the implicit variable to be determined:
%           can be zero, one or two roots;
%             - if no roots, corresponding row in qw1 and qw2 set to NaN
%             - if there is a root, it will be in qw1, and the row in qw2 set to naN
%             - if two roots, the larger energy trasnfer root is always in qw1
%           
%    - if a component of Q is implicit variable to be determined
%           in general there are either zero or two roots, just as for direct geometry.
%
%

% Algorithm applies for the case when the following two conditions are met
%    - data originates from a single spe file
%    - one, and only one, of the integration axes has range [-Inf,Inf], [-Inf,<finite>] or [<finite>,Inf]]
% This is the situation when Horace is being used is mslice mode.

% Original author: T.G.Perring
%
% $Revision:: 1758 ($Date:: 2019-12-16 18:18:50 +0000 (Mon, 16 Dec 2019) $)


nd=size(x,2);   % number of dimensions - assume already checked for consistency between win and x
np=size(x,1);   % number of points

% Fixed energy
c=neutron_constants;
k_to_e = c.c_k_to_emev;
efix=win.header.efix;
kfix=sqrt(efix/k_to_e);


% Some useful shorthand names to elements of input sqw object
u0=win.data.uoffset;
u=win.data.u_to_rlu;
iax=win.data.iax;
iint=win.data.iint;
pax=win.data.pax;
dax=win.data.dax;


% Get matrix to convert projection axes to spectrometer axes:
[spec_to_u, u_to_rlu, spec_to_rlu] = calc_proj_matrix (win.header.alatt, win.header.angdeg, win.header.cu, win.header.cv,...
    win.header.psi, win.header.omega, win.header.dpsi, win.header.gl, win.header.gs);
M=spec_to_rlu\u(1:3,1:3);   % convert projection axes to spectrometer axes


% Get coordinates in frame of projection axes, accounting for offset and centre of integration axes
ptot=u0;
for i=1:length(iax)
    % get offset from integration axis, accounting for non-finite limit(s)
    if isfinite(iint(1,i)) && isfinite(iint(2,i))
        iint_ave=0.5*(iint(1,i)+iint(2,i));
    else
        iint_ave=0;
        inf_ax=iax(i);  % keep the infinite axis index for later use
    end
    ptot=ptot+iint_ave*u(:,iax(i));  % overall displacement of plot volume in (rlu;en)
end
ud=u(:,pax(dax));   % need to permute the vectors to match the display (cf. plot) axes
prlu=repmat(ptot,[1,np])+ud*x'; % (4 x np) array of coordinates as rlu and energy
qspec=spec_to_rlu\prlu(1:3,:);  % (3 x np) array of coordinates in spectrometer coordinates
eps=prlu(4,:);                  % split out energy for later convenience

% if the unknown axis is energy transfer, qspec is the momentum vector, and eps=0
% if the unknown is a Q axis, qspec will contain the offset vector to the point where the the component along
% the unknown projectioon axis is zero, and the energy transfer will be correct.

% Compute missing coordinate
if inf_ax==4    % Missing coordinate is energy transfer
    if win.header.emode==1          % direct geometry
        kf=repmat([kfix;0;0],[1,np])-qspec;
        eps=efix-k_to_e*dot(kf,kf,1);
        qw1=[prlu(1:3,:);eps]';
        qw2=[];
    else
        sintheta=sqrt(dot(qspec(2:3,:),qspec(2:3,:),1))/kfix;
        sintheta(sintheta>1)=NaN;   % no solution possible
        ki=q1+kfix*cos(asin(sintheta));
        ki(ki<=0)=NaN;              % cannot have negative |ki|
        eps1=k_to_e*ki.^2;
        ki=q1-kfix*cos(asin(sintheta));
        ki(ki<=0)=NaN;              % cannot have negative |ki|
        eps2=k_to_e*ki.^2;
        qw1=[prlu(1:3,:);eps1]';
        qw2=[prlu(1:3,:);eps2]';
    end

else            % Missing coordinate is one of the Q coordinates
    if win.header.emode==1          % direct geometry
        del=repmat([kfix;0;0],[1,np])-qspec;
        M0=M(:,inf_ax);
        acoeff=dot(M0,M0)*ones(1,np);
        bcoeff=-2*dot(del,repmat(M0,[1,np]),1);
        ccoeff=dot(del,del,1)-(efix-eps)/k_to_e;
        [p1,p2]=real_quadratic_roots (acoeff,bcoeff,ccoeff);
    else
        ki=sqrt(efix+eps)/k_to_e;
        del=[ki;zeros(2,np)]-qspec;
        M0=M(:,inf_ax);
        acoeff=dot(M0,M0)*ones(1,np);
        bcoeff=-2*dot(del,repmat(M0,[1,np]),1);
        ccoeff=dot(del,del,1)-efix/k_to_e;
        [p1,p2]=real_quadratic_roots (acoeff,bcoeff,ccoeff);
    end
    qw1=(prlu+u(:,inf_ax)*p1)';
    qw2=(prlu+u(:,inf_ax)*p2)';
    
end
bad=~isfinite(sum(qw1,2)); qw1(bad,:)=NaN;
bad=~isfinite(sum(qw2,2)); qw2(bad,:)=NaN;

%===============================================================================
function [x1,x2]=real_quadratic_roots (a,b,c)
% Find real roots of a quadratic equation
%
%   >> [x1,x2]=real_quadratic_roots (a,b,c)
%
%   a, b, c     Coefficients of a*x^2 + b*x + c = 0
%               Can be arrays of same size. Must be real
%
%   x1,x2       Arrays containing the roots, x1<=x2.
%               If no real roots for ith coefficients, then returns x1(i)=x2(i)=NaN

b2m4ac=b.^2-4*a.*c;
b2m4ac(b2m4ac<0)=NaN;
q=-0.5*(b+sign(b).*sqrt(b2m4ac));
x1tmp=q./a;
x2tmp=c./q;
x1=min(x1tmp,x2tmp);
x2=max(x1tmp,x2tmp);

