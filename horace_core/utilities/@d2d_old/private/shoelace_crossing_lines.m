function ps=shoelace_crossing_lines(a,b,c,d)
%finds crossing points of lines a->b and c->d

dum=b-a;
aa=dum(1); cc=dum(2);
dum=d-c;
bb=dum(1); dd=dum(2);

detr=aa*dd - bb*cc;
ps=[];

% if abs(detr)<1e-10
%     ps=false;
% else
%     cross_x = (a(2)-c(2)).*aa.*bb - a(1).*bb.*cc + c(1).*aa.*dd;
%     cross_y = (a(2)*aa - a(1)*cc)*dd - (c(2)*bb - c(1)*dd)*cc;
%     pstmp=[cross_x./detr,cross_y./detr];
%     test=double(~(shoelace_between(a',b',ps') & shoelace_between(c',d',ps')));
%     switch test
%         case 1
%             ps=[];
%     end
% end

if abs(detr)<1e-10
    ps=false;
else
    cross_x = (a(2)-c(2)).*aa.*bb - a(1).*bb.*cc + c(1).*aa.*dd;
    cross_y = (a(2)*aa - a(1)*cc)*dd - (c(2)*bb - c(1)*dd)*cc;
    pstmp=[cross_x./detr,cross_y./detr];
    ps=pstmp((shoelace_between(a',b',pstmp') & shoelace_between(c',d',pstmp')),:);
end