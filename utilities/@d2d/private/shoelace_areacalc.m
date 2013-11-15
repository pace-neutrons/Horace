function Area = shoelace_areacalc(xout,yout,xin,yin,inarea,outarea)
%
% Area = shoelace_areacalc(xout,yout,xin,yin,inarea,outarea)
%
% Compute which of the quadrilaterals specified by xout/yout overlap the
% quadrilaterals specified by xin/yin, and the area of overlap
%
% Speed-up possible by using the routine intersection points, which is
% based on vectors, rather than the more tedious linear algebra approach.
%

sz=size(xin);%sz(2) gives us the number of input bins
%
%Initialise the output:
Area=zeros(1,sz(2));


%Work out if an input vertex is indside an output bin or not:
in=inpolygon(xin,yin,xout,yout);
inside=logical(in);

%==========
%At this point we can achieve a speed-up by noticing that if a given input
%bin is contained entirely within the output bin, then the overlap area will simply be
%the area of the input bin itself, which we have already calculated.

%inside is a 4-by-npix array.
totinside=sum(inside);
testinside=(totinside==4);%gives ones where an input bin is completely within an output bin
indinside=find(testinside);%gives the indices where this is the case
Area(indinside)=inarea(indinside);

%==========

%Work out the intersection co-ordinates for all 4
%sides of the input bin, and then work out which intersection co-ordinate lies
%on the line between the relevant output bin vertices.

%For each overlap polygon we now must pick a point and then, assuming our
%overlap shape is convex, calculate the polar angle to each of the other
%points. We then re-order them according to increasing polar angle so that
%we can use polyarea/shoelace algorithms. Notice that we do not bother with
%the calculation if there is no overlap, or if we have already worked out
%that the input bin is entirely within the output bin.

%===========
%Can probably achieve a significant speed-up by noticing that we do not
%need to calculate the intersection points for input bins that are fully
%inside the output bin
intersection_test=shoelace_calculate_all_intersections(xout,yout,xin,yin,totinside);

% clf;
% sz=size(xin);
% patch(xin,yin,ones(1,sz(2)));
% patch(xout,yout,0);

%==========
%There is a problem here if we have repeated points, so remove them:
for i=1:numel(intersection_test)
    toremove=[];
    if ~isempty(intersection_test{i})
        intersection_test{i}=sortrows_special(sortrows_special(intersection_test{i},1),2);%sort by 1st column, then by 2nd.
        [introw,intcol]=size(intersection_test{i});
        for j=1:introw-1
%             if isequal(intersection_test{i}(j,:),intersection_test{i}(j+1,:))
%                 toremove=[toremove,j];
%             end
%             3 commented out lines above did not work because of rounding
%             errors!!!
              if sum(abs(intersection_test{i}(j,:) - intersection_test{i}(j+1,:)))<eps
                  toremove=[toremove,j];
              end
        end
        if ~isempty(toremove)
            intersection_test{i}(toremove,:)=[];
        end
    end
end

for i=1:sz(2)
    if ~isempty(intersection_test{i}) && Area(i)==0
        xv=intersection_test{i}(:,1); yv=intersection_test{i}(:,2);
        [miny,indy]=min(yv);%pick out lowest point in y-coord
        minx=xv(indy);%corresponding x-coord
        newx=xv-minx; newy=yv-miny;
        polang=atan2(newy,newx);
        [polsort,ix]=sort(polang);
        Area(i)=polyarea(newx(ix),newy(ix));
    end
end

% Area
% why;
