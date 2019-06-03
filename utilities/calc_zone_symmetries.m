function transf=calc_zone_symmetries(v1,v2)
% the procedure calculates transfomration matrix, used by combine
% equivalent zones routine to transform one zone, with centre, defined by
% hkl vector v1 into another zone, defined by hkl vector v2
%
%
% $Revision:: 1751 ($Date:: 2019-06-03 09:47:49 +0100 (Mon, 3 Jun 2019) $)
%

%Crude test to ensure that v1 and v2 are equivalent wavevectors:
if sum(v1.^2)~=sum(v2.^2)
    error('ZONE_SYMMETRIES:invalid_argument','Horace error: Brillouin zone centres are not equivalent');
end
transf=zeros(3,3);

if v1==v2
    transf(1,1)=1;
    transf(2,2)=1;
    transf(3,3)=1;
    return;
end

%Create a vector that has h and k swapped relative to v2
v2swap=[v2(1); v2(1); v2(3)];

%Also ensure that v1 and v2 are column vectors:
if ~isequal(size(v1),[3,1])
    v1=v1';
end
if ~isequal(size(v2),[3,1])
    v2=v2';
end

%Now work out which way the permutation has been done:
av1=abs(v1); av2=abs(v2); av2swap=abs(v2swap);
if av2==av1
    shift=0;
elseif av2==circshift(av1,[1,0]);
    shift=1;
elseif av2==circshift(av1,[2,0]);
    shift=2;
elseif av1==av2swap
    shift=3;
elseif av2swap==circshift(av1,[1,0]);
    shift=4;
elseif av2swap==circshift(av1,[2,0]);
    shift=5;
end

%Next we must determine whether we need to flip an axis round:
transf=zeros(3,3);
switch shift
    case 0
        ax=v2./v1;
        indx=[1; 2; 3];
    case 1
        ax=v2./circshift(v1,1);
        indx=[3; 1; 2];
        
    case 2
        ax=v2./circshift(v1,2);
        indx=[2; 3; 1];
    case 3
        ax=v2swap./v1;
        indx=[2; 1; 3];
    case 4
        ax=v2swap./circshift(v1,1);
        indx=[3; 2; 1];
        
    case 5
        ax=v2swap./circshift(v1,2);
        indx=[1; 3; 2];
end
nans = isnan(ax);
axt = ax;
axt(nans) = 1;
transf(1,indx(1))=axt(1);
transf(2,indx(2))=axt(2);
transf(3,indx(3))=axt(3);
