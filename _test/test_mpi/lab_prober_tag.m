function [avail,tag] = lab_prober_tag(lab_num,tag)

% check requested message
[tag_avail,~,tag_req] = labProbe(lab_num,tag);
% check if fail message has been send from the lab specified
[fail_avail,~,tag_fail] = labProbe(lab_num,0);
avail = tag_avail | fail_avail;

if fail_avail
    tag = tag_fail(1);
elseif tag_req
    tag = tag_req(1);
else
    tag = -1;
end

end


function [tal,num,tag] = labProbe(lab_num,tag)
num = lab_num;
tal =  any(lab_num == [2,4,7]);

end
