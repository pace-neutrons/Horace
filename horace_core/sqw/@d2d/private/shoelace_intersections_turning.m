function [xc,yc]=shoelace_intersections_turning(x1,y1,x2,y2)
%
% calculate crossing point after convex hull method.
%

ii=[1:4 1]; jj=[1:4 1];

i=1; j=1; finished=false; straight=false; first=false; second=false;
%v1=[x1 y1]; v2=[x2 y2];
v1=[x2 y2]; v2=[x1 y1];

while finished==false && j<=3 && i<=3
    finished=true;
    isleft=left_turn(v1(ii(i),:),v1(ii(i)+1,:),v2(jj(j+1),:));
    if isleft>0.99 && j<=3
        j=j+1; finished=false;
    elseif isleft<-0.99
        straight=true; first=true;
    end
    isright=right_turn(v2(jj(j),:),v2(jj(j+1),:),v1(ii(i+1),:));
    if isright>0.99
        i=i+1; finished=false;
    elseif isright<-0.99
        straight=true; second=true;
    end
end

if ~finished
    %stepped all the way round the quadrilateral without finding an
    %intersection line, so quads do not intersect at all:
    xc=[]; yc=[]; return;
end

%We now know the indices of the points on both curves which, when joined,
%make a crossing point. i.e. the crossing is on the intersection if
%v1(i,:)->v1(i+1,:) and v2(j,:)->v2(j+1,:)

%===========================================
if ~straight
    a=v1(i,:); b=v1(i+1,:); c=v2(j,:); d=v2(j+1,:);
    dum=b-a;
    aa=dum(1); cc=dum(2);
    dum=d-c;
    bb=dum(1); dd=dum(2);

    detr=aa*dd - bb*cc;
    ps=[];

    if abs(detr)<1e-10
        xc=[]; yc=[];
    else
        cross_x = (a(2)-c(2)).*aa.*bb - a(1).*bb.*cc + c(1).*aa.*dd;
        cross_y = (a(2)*aa - a(1)*cc)*dd - (c(2)*bb - c(1)*dd)*cc;
        xc=cross_x./detr;
        yc=cross_y./detr;
    end
elseif first
    xc=v2(jj(j+1),1); yc=v2(jj(j+1),2);
elseif second
    xc=v1(ii(i+1),1); yc=v1(ii(i+1),2);
else
    error('Shoelace convex hull intersction logic problem. Contact R.A. Ewings');
end