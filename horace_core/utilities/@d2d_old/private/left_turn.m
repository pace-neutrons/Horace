function out=left_turn(a,b,c)
%
% determine if the line drawn connecting points a-b-c makes a left turn
%

thesign=(b(1)-a(1)).*(c(2)-a(2)) - (b(2)-a(2)).*(c(1)-a(1));

%need to be a bit cleverer about what happens if we have a straight line.
%simply saying we do not have a left turn is not good enought in this
%situation.

tmp=thesign>0;
if abs(thesign)<eps
    out=-1;
else
    out=tmp;
end
