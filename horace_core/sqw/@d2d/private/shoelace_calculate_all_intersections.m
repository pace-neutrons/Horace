function intersection=shoelace_calculate_all_intersections(xout,yout,xin,yin,totinside)
%
% Subroutine to calculate the x and y coordinates of intersections between
% input and output bins. Also includes vertices of ins inside outs, and
% vertices of outs inside ins.
%
% Makes use of the intersection_points and crossing_lines subroutines from
% JRS' work.
%
% RAE 17/9/09

sz=size(xin); ninputs=sz(2);
intersection=cell(1,ninputs);

for i=1:ninputs
    %[intpoints,numpoints]=shoelace_intersection_points([xout(1) yout(1)],[xout(2) yout(2)],...
    %     [xout(3) yout(3)],[xout(4) yout(4)],[xin(1,i) yin(1,i)],[xin(2,i) yin(2,i)],...
    %     [xin(3,i) yin(3,i)],[xin(4,i) yin(4,i)]);
    %
    %test line for debug:
    if totinside(i)<3.9
        [intpoints,numpoints]=shoelace_intersections_convhull(xout,yout,xin,yin,i);
        if numpoints>0
            intersection{i}=intpoints;
        else
        intersection{i}=[];
        end
    else
        intersection{i}=[xin(:,i) yin(:,i)];
    end
end

