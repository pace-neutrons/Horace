function [pts,ptlabs]=generate_rlps(Ei,u,v,alatt,angdeg,density)

lam=sqrt(81.81/Ei);%neutron wavelength

[bm,arlu,angrlu]=bmatrix(alatt,angdeg);
ub=ubmatrix(u,v,bm);

%Calculate the space that might be covered, in rlu
xlist=[floor((-2*pi*2/lam)./arlu(1)):eps+ceil((2*pi*2/lam)./arlu(1))];
ylist=[floor((-2*pi*2/lam)./arlu(2)):eps+ceil((2*pi*2/lam)./arlu(2))];
zlist=[floor((-2*pi*2/lam)./arlu(3)):eps+ceil((2*pi*2/lam)./arlu(3))];

counter=1;
pts=[];
dd=int8(density);
if numel(dd)==1
    dd=[dd,dd,dd];
elseif numel(dd)~=3
    error('Point density should be scalar or vector with 3 elements');
end
for i=1:dd(1):numel(xlist)
    for j=1:dd(2):numel(ylist)
        for k=1:dd(3):numel(zlist)
            qp=[xlist(i)*ub*[1,0,0]'] + [ylist(j)*ub*[0,1,0]'] + [zlist(k)*ub*[0,0,1]'];
            if sqrt(sum(qp.^2))<=2*pi*2/lam
                pts=[pts; qp'];
                ptlabs{counter}=num2str(round([xlist(i) ylist(j) zlist(k)]));
                counter=counter+1;
            end
        end
    end
end
