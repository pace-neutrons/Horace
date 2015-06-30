function  self  = define_transformation(self,data,ustep)
% Method defines coordinate transformation, used to 
% convert sqw or dnd data into new cut
%

[rlu_to_ustep, u_to_rlu] = self.rlu_to_ustep_matrix (data.alatt, data.angdeg,ustep);
uin_to_rlu = data.u_to_rlu(1:3,1:3);
% convert components from data input proj. axes to output proj. axes
self.rot_ = inv(u_to_rlu)*uin_to_rlu;     
% offset between the origins of input and output proj. axes, in input proj. coords
self.trans_ = inv(uin_to_rlu)*(self.uoffset(1:3)-data.uoffset(1:3));  


