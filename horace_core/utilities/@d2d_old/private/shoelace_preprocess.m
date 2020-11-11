function likely = shoelace_preprocess(xin,yin,xout,yout)
%
% Pre-process input/output information so that we only try to calculate
% overlap areas between in/out that are actually near to each
% other.
%
% RAE 17/9/09


%Intialise the output cell array:
sz=size(xout);
likely=cell(1,sz(2));
%==

xinwid=(max(xin)-min(xin)); yinwid=(max(yin)-min(yin));
xoutwid=(max(xout)-min(xout)); youtwid=(max(yout)-min(yout));

xout_min=min(xout); yout_min=min(yout);
xout_max=max(xout); yout_max=max(yout);

xin_min=min(xin); yin_min=min(yin);
xin_max=max(xin); yin_max=max(yin);

%testit=[];
for i=1:sz(2)
    x1_lo=(xin(1,:)-xinwid <= xout_max(i)) & (xin(1,:)+xinwid >=xout_min(i)); 
    x2_lo=(xin(2,:)-xinwid <= xout_max(i)) & (xin(2,:)+xinwid >=xout_min(i)); 
    x3_lo=(xin(3,:)-xinwid <= xout_max(i)) & (xin(3,:)+xinwid >=xout_min(i)); 
    x4_lo=(xin(4,:)-xinwid <= xout_max(i)) & (xin(4,:)+xinwid >=xout_min(i)); 
    %
    y1_lo=(yin(1,:)-yinwid <= yout_max(i)) & (yin(1,:)+yinwid >=yout_min(i)); 
    y2_lo=(yin(2,:)-yinwid <= yout_max(i)) & (yin(2,:)+yinwid >=yout_min(i)); 
    y3_lo=(yin(3,:)-yinwid <= yout_max(i)) & (yin(3,:)+yinwid >=yout_min(i)); 
    y4_lo=(yin(4,:)-yinwid <= yout_max(i)) & (yin(4,:)+yinwid >=yout_min(i));
    %
    overlap1=(x1_lo & y1_lo);
    %ind1=find(overlap1);%for debug
    overlap2=(x2_lo & y2_lo);
    %ind2=find(overlap2);
    overlap3=(x3_lo & y3_lo);
    %ind3=find(overlap3);
    overlap4=(x4_lo & y4_lo);
    %ind4=find(overlap4);
    
    %Must also consider the case where the input bins are larger than the
    %output bins, and an output bin is enclosed (partially or fully) by an
    %input bin.
    x_enclosed=(xin_min<=xout_min(i) & xin_max>=xout_max(i));
    y_enclosed=(yin_min<=yout_min(i) & yin_max>=yout_max(i));
    enclosed=(x_enclosed & y_enclosed);%this line is perhaps dodgy - return to it in testing.
    %ind5=find(enclosed);
    likely{i}=find(overlap1 | overlap2 | overlap3 | overlap4 | enclosed);
    %
    %for debug:
%     if ~isempty(likely{i})
%         testit=[testit i];
%     end
    
end



%========================
%OLD ALGORITH - DID NOT WORK PROPERLY!
%========================
% xout_min=min(xout); yout_min=min(yout);
% xout_max=max(xout); yout_max=max(yout);
% 
% xin_min=min(xin); yin_min=min(yin);
% xin_max=max(xin); yin_max=max(yin);
% %these 8 arrays are row vectors telling us the min/max x and y values for
% %each output bin and input bin
% 
% for i=1:sz(2)
%     %work out if  overlap
%     xoverlap_min=(xin_min>=xout_min(i) & xin_min<=xout_max(i));
%     xoverlap_max=(xin_max>=xout_min(i) & xin_max<=xout_max(i));
%     yoverlap_min=(yin_min>=yout_min(i) & yin_min<=yout_max(i));
%     yoverlap_max=(yin_max>=yout_min(i) & yin_max<=yout_max(i));
%     %
%     overlap=(xoverlap_min | xoverlap_max) & (yoverlap_min | yoverlap_max);
%     ind=find(overlap);%ind is a row vector
%     %=======
%     %Must also consider the case where the input bins are larger than the
%     %output bins, and an output bin is enclosed (partially or fully) by an
%     %input bin.
%     x_enclosed=(xin_min<=xout_min(i) & xin_max>=xout_max(i));
%     y_enclosed=(yin_min<=yout_min(i) & yin_max>=yout_max(i));
%     enclosed=(x_enclosed & y_enclosed);%this line is perhaps dodgy - return to it in testing.
%     ind2=find(enclosed);
%     %
%     %======
% %     overlap2=(xoverlap_min & xoverlap_max) & ~(yoverlap_min & yoverlap_max);
% %     overlap3=~(xoverlap_min & xoverlap_max) & (yoverlap_min & yoverlap_max);
% %     overlap4=overlap2 | overlap3;
% %     ind3=find(overlap4);
%     %======
%     likely{i}=[ind ind2];
% %     likely{i}=[ind ind2 ind3];
%     
% end
