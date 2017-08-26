function R = calculate_transform (obj, Minv)
% Transformation matrix for the symmetry operator in an orthonormal frame
%
%   >> R = calculate_transform (obj, M)
%
% Input:
% ------
%   obj     Symmetry operator object
%   Minv    Matrix to convert components of a vector given in rlu to those
%          in an orthonormal frame
%
% Output:
% -------
%   R       Transformation matrix to be applied to the components of a 
%          vector given in the orthonormal frame for which Minv is defined

if is_empty(obj)
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
    