function this = check_and_set_transf_matr_(this,val)
% Verify transformation matrix and set it for future usage
%
% the transformation matrix here is the matrix used to transform pixels
% information from crystal cartezian coordinate system (lab frame) to hkl
% frame
%
if ~isnumeric(val)
    error('PROJECTION:invalid_arguments',...
        'transformation matrix must be 3x3 or 4x4 numeric array')
end

if all(size(val)==[3,3])
    val = [val,[0;0;0];[0,0,0,1]];
elseif all(size(val)==[4,4])
    if ~(all(val(:,4) == [0;0;0;1]) || all(val(4,:) == [0,0,0,1]))
        error('PROJECTION:invalid_arguments',...
            '4x4 transformation matrix can only be matrix with last row equal to [0,0,0,1] and column equal to [0;0;0;1]')
    end
else
    error('PROJECTION:invalid_arguments',...
        'Input transformation matrix can be only 3x3 or 4x4 matrix to convert pixels in crystal cartezian coordinate system into hkl system')
end

this.u_to_rlu_ = val;
