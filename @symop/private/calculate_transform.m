function R = calculate_transform (obj, Minv)
% Get transformation matrix for the symmetry operator in an orthonormal frame
%
% The transformation matrix converts the components of a vector which is 
% related by the symmetry operation into the equivalent vector. The 
% coordinates of the vector are expressed in an orthonormal frame.
%
% For example, if the symmetry operation is a rotation by 90 degrees about
% [0,0,1] in a cubic lattice with lattice parameter 2*pi, the point [0.3,0.1,2]
% is transformed into [0.1,-0.3,2].
%
% The transformation matrix accounts for reflection or rotation, but not
% translation associated with the offset in the symmetry operator.
%
%   >> R = calculate_transform (obj, Minv)
%
% Input:
% ------
%   obj     Symmetry operator object (scalar)
%   Minv    Matrix to convert components of a vector given in rlu to those
%          in an orthonormal frame
%
% Output:
% -------
%   R       Transformation matrix to be applied to the components of a 
%          vector given in the orthonormal frame for which Minv is defined


if is_identity(obj)
    R = eye(3);
    
elseif is_reflection(obj)
    % Determine the representation of u and v in the orthonormal frame
    e1 = Minv * obj.u_';
    e2 = Minv * obj.v_';
    n = cross(e1,e2);
    n = n / norm(n);
    % Create reflection matrix in the orthonormal frame
    R = eye(3) - 2*(n*n');
    
elseif is_rotation(obj)
    % Express rotation vector in orthonormal frame
    n = Minv * obj.n_';
    % Perform active rotation (hence reversal of sign of theta
    R = rotvec_to_rotmat (-obj.theta_deg_*n/norm(n));
end
    