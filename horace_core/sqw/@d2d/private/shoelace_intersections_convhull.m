function [intpoints,numpoints]=shoelace_intersections_convhull(xout,yout,xin,yin,i)
%
combx=[xout; xin(:,i)]; comby=[yout; yin(:,i)];
K=convhull(combx,comby);%indices of convex hull of the 2 polygons together.
%use sail polygon triangulation to calculate from the "bridges" of the
%convex hull where the polyon interection points are.
%See "A Simple Linear Algorithm For Intersecting Convex Polygons", by G.
%T. Toussaint for details.
%
% First must identify the bridges:
%Start at the first point on the convex hull:
hullx=combx(K); hully=comby(K);
ptx=combx(K(1)); pty=comby(K(1));
%determine if this is on the input or output bin:
if K(1)<4
    whichpoly=[1 1 1 1 2 2 2 2];%start on the output bin
else
    whichpoly=[2 2 2 2 1 1 1 1];
end
%whichpoly=[1 1 1 1 2 2 2 2];%tells us which polygon corresponds to which index
j=1; bridge_lo=[]; bridge_hi=[]; %thepoly=whichpoly(K(1));
while j<numel(K)
    oldpoly=whichpoly(K(j));
    j=j+1;
    newpoly=whichpoly(K(j));
    %thepoly=[thepoly; newpoly];
    if newpoly~=oldpoly
        bridge_lo=[bridge_lo; K(j-1)];
        bridge_hi=[bridge_hi; K(j)];
    end
end
intpoints=[];
%if the variable bridge is empty then one bin is completely inside the other.
if isempty(bridge_lo)
%     insideit=shoelace_check_in_quad([xout(1) yout(1)],[xout(2) yout(2)],...
%      [xout(3) yout(3)],[xout(4) yout(4)],[xin(1,i) yin(1,i)],[xin(2,i) yin(2,i)],...
%      [xin(3,i) yin(3,i)],[xin(4,i) yin(4,i)]);
    insideit=(hullx(1:end-1)==xout) & (hully(1:end-1)==yout);
    if insideit
        intpoints=[xin(:,i) yin(:,i)];
    else
        intpoints=[xout yout];%the output bin is fully contained within the input bin
    end
else
    %We do have some kind of non-trivial intersection, so must
    %triangulate on the crossing point.
    %
    %First make backward lists of in and out bins:
    xin_back=flipud(xin(:,i)); yin_back=flipud(yin(:,i));
    xout_back=flipud(xout); yout_back=flipud(yout);
    %
%     clf;
%     patch(xin(:,i),yin(:,i),[1 1 1]);
%     patch(xout,yout,[1 1 1]);
%     drawnow;
    xoutp=[xout; xout ; xout]; youtp=[yout; yout; yout];
    xin_backp=[xin_back; xin_back; xin_back]; yin_backp=[yin_back; yin_back; yin_back];
    xinp=[xin(:,i); xin(:,i); xin(:,i)]; yinp=[yin(:,i); yin(:,i); yin(:,i)];
    xout_backp=[xout_back; xout_back; xout_back];
    yout_backp=[yout_back; yout_back; yout_back];
    for j=1:numel(bridge_lo)
        if bridge_lo(j)<=4
            %started on output bin
%             x1=circshift(xout,[bridge_lo(j)-1]);
%             x2=circshift(xin_back,[bridge_hi(j)-4]);
%             y1=circshift(yout,[bridge_lo(j)-1]);
%             y2=circshift(yin_back,[bridge_hi(j)-4]);
            %
%             x1=xoutp(6-bridge_lo(j):9-bridge_lo(j));
%             x2=xin_backp(9-bridge_hi(j):12-bridge_hi(j));
%             y1=youtp(6-bridge_lo(j):9-bridge_lo(j));
%             y2=yin_backp(9-bridge_hi(j):12-bridge_hi(j));
            x1=xoutp(bridge_lo(j):bridge_lo(j)+3);
            x2=xin_backp(9-bridge_hi(j):12-bridge_hi(j));
            y1=youtp(bridge_lo(j):bridge_lo(j)+3);
            y2=yin_backp(9-bridge_hi(j):12-bridge_hi(j));
%             if ~isequal(x1,x1p) || ~isequal(x2,x2p) || ~isequal(y1,y1p) || ~isequal(y2,y2p)
%                 why;
%             end
            [xc,yc]=shoelace_intersections_turning(x1,y1,x2,y2);
            intpoints=[intpoints; [xc yc]];
        else
            %started on input bin
%             x1=circshift(xin(:,i),[5-bridge_lo(j)]);
%             x2=circshift(xout_back,[bridge_hi(j)]);
%             y1=circshift(yin(:,i),[5-bridge_lo(j)]);
%             y2=circshift(yout_back,[bridge_hi(j)]);
            %
            x1=xinp(bridge_lo(j):3+bridge_lo(j));
            x2=xout_backp(9-bridge_hi(j):12-bridge_hi(j));
            y1=yinp(bridge_lo(j):3+bridge_lo(j));
            y2=yout_backp(9-bridge_hi(j):12-bridge_hi(j));
            %
%             if ~isequal(x1,x1p) || ~isequal(x2,x2p) || ~isequal(y1,y1p) || ~isequal(y2,y2p)
%                 why;
%             end
            [xc,yc]=shoelace_intersections_turning(x1,y1,x2,y2);
            intpoints=[intpoints; [xc yc]];
        end

    end
    %We have not yet finished, because we need to join up the intersection
    %points in the correct way. Note that it is OK if we have repeated
    %vertices, as this is dealt with later.
    intpoints2=shoelace_check_in_quad([xout(1) yout(1)],[xout(2) yout(2)],...
        [xout(3) yout(3)],[xout(4) yout(4)],[xin(1,i) yin(1,i)],[xin(2,i) yin(2,i)],...
        [xin(3,i) yin(3,i)],[xin(4,i) yin(4,i)]);
    intpoints=[intpoints; intpoints2];
end

numpoints=numel(intpoints);
