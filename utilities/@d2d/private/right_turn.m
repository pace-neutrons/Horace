function out=right_turn(a,b,c)
%
% determine if the line drawn connecting points a-b-c makes a right turn
%

thesign=(b(1)-a(1)).*(c(2)-a(2)) - (b(2)-a(2)).*(c(1)-a(1));

%out=thesign<0;

tmp=thesign<0;
if abs(thesign)<eps
    out=-1;
else
    out=tmp;
end