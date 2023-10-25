function obj = set_xyz_data(obj,nax,val)
% set x, y or z axis data
%
%Inputs:
% nax -- number of axis data to set
% val -- axis data
%
obj.xyz_{nax} =obj.check_xyz(val);


