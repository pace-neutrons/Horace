function obj = set_xyz_data(obj,nax,val)
% set x, y or z axis data
%
%Inputs:
% nax -- number of axis data to set
% val -- axis data
%
obj.xyz_{nax} =obj.check_xyz(val);
[ok,mess] = check_joint_fields(obj);
if ok
    obj.valid_ = true;
    obj.error_mess_ = '';
else
    obj.valid_ = false;
    obj.error_mess_ = mess;
end


