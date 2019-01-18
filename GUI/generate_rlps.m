function [pts,ptlabs]=generate_rlps(Ei,u,v,alatt,angdeg,density)
% Original code R.A.Ewings
% Modified 15/01/2019 by T.G.Perring to always include 0,0,0

lam=sqrt(81.81/Ei);%neutron wavelength

[bm,arlu]=bmatrix(alatt,angdeg);
ub=ubmatrix(u,v,bm);

if numel(density)==1
    density=[density,density,density];
elseif numel(density)~=3
    error('Point density should be scalar or vector with 3 elements');
end

%Calculate the space that might be covered, in rlu, with the requested point density
xlist = ind_range(eps+ceil((2*pi*2/lam)./arlu(1)), round(density(1)));
ylist = ind_range(eps+ceil((2*pi*2/lam)./arlu(2)), round(density(2)));
zlist = ind_range(eps+ceil((2*pi*2/lam)./arlu(3)), round(density(3)));

pts=[];
counter=1;
for i=1:numel(xlist)
    for j=1:numel(ylist)
        for k=1:numel(zlist)
            qp=xlist(i)*ub*[1,0,0]' + ylist(j)*ub*[0,1,0]' + zlist(k)*ub*[0,0,1]';
            if sqrt(sum(qp.^2))<=2*pi*2/lam
                pts=[pts; qp'];
                ptlabs{counter}=num2str(round([xlist(i) ylist(j) zlist(k)]));
                counter=counter+1;
            end
        end
    end
end

%--------------------------------------------------------------------------
function ind = ind_range (N,m)
% Given N and m, return array ind  0,+/-m, +/-2*m,... for abs(ind)<=N
% The array ind is placed in numerically increasing order

ind = 0:m:N;
if numel(ind)>0
    ind = [-fliplr(ind(2:end)),ind];
end
