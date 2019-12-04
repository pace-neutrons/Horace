function obj = check_and_set_uoffset_(obj,uoffset)
% Verify correct values for uoffset and set interbal uoffset projaxes field
% if validation is succsessful
%
%
%   Detailed explanation goes here


if isnumeric(uoffset)
    if (numel(uoffset)==3 || (numel(uoffset)==4 && uoffset(4)==0))
        if numel(uoffset)==3
            obj.uoffset_=[uoffset(:);0];
        else
            obj.uoffset_=uoffset(:);
        end
        if  norm(uoffset)<obj.tol_
            obj.uoffset_ = [0;0;0;0];
        end
    else
        error('PROJAXES:invalid_argument',...
            'Vector uoffset must have form [h0,k0,l0] or [h0,k0,l0,0] or be empty');        
    end
elseif isempty(uoffset)
    obj.uoffset_ = [0;0;0;0];
else
    error('PROJAXES:invalid_argument',...
        'Vector uoffset must have form [h0,k0,l0] or [h0,k0,l0,0] or be empty');
end


