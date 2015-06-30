function [rot,trans]=get_box_transf_(this)

if isempty(this.projaxes_)
    rot = eye(3);
    trans = [0;0;0];    
else
    [~, u_to_rlu] = projaxes_to_rlu(this.projaxes_,this.alatt_, this.angdeg_, [1,1,1]);   
    rot = u_to_rlu\this.data_u_to_rlu_ ;      % convert components from data input proj. axes to output proj. axes
    trans = this.data_u_to_rlu_\(this.uoffset(1:3)-this.data_uoffset_(1:3));  % offset between the origins of input and output proj. axes, in input proj. coords
end
