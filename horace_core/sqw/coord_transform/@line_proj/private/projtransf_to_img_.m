function [q_to_img,ulen,b_mat,obj] = projtransf_to_img_(obj)
% Determine matrices to convert rlu <=> projection axes, and the scaler
%
%
%   >> [q_to_img,ulen,b_mat,obj] = projaxes_to_rlu_(proj)
%
% The projection axes are three vectors that may or may not be orthogonal
% which are used to create the bins in an sqw object. The bin sizes are in ustep
%
% Input:
% ------
%   proj   line_proj object containing information about the transformation
%          (type >> help line_proj for details)
%
% Output:
% -------
%   q_to_img    Matrix to convert components of a vector expressed
%               in Crystal Cartesian coordinate system to the components 
%               along the image axes
%               u1,u2,u3, as multiples of the step size along those axes
%                   Vstep(i) = rlu_to_ustep(i,j)*Vrlu(j)
%   ulen        Row vector of scales of ui in Ang^-1
%   b_mat       Matrix transforming hkl coordinate system into Crystal
%               Cartesian coordinate system
%   obj         the projection object iteslf modified if necessary so that
%               u,v,w form a rh set if initial object wectors were not
%
%
% Original author: T.G.Perring; J. van Duijn; Horace v0.1
%
% Substantially changed in 2023 for Horace 4.0;


[b_mat,rlu_vec_len] = bmatrix(obj.alatt, obj.angdeg);
b_vec_directions = b_mat./rlu_vec_len;
u=obj.u;
v=obj.v;
[ubmat,umat] = ubmatrix(u,v,b_mat);  % get UB matrix normalized by rlu vector length
% umatrix contains its vectors arranged in rows

type=obj.type;
if isempty(obj.w) %
    if obj.nonorthogonal
        % the possible purpose of selecting default w with 'r' scale would be
        % providing the same thickness expressed in hkl cut regardless of the
        % cut direction. This may not have physical meaning for triclinic
        % lattice, but in this case you should provide w manually
        %
        % Above is the idea, have not been implemented. Just make w-vector
        % orthogonal to u,v plain
        u_ortho = b_mat*u(:);
        v_ortho = b_mat*v(:);
        uv_ortho = [u_ortho(:)/norm(u_ortho),v_ortho(:)/norm(v_ortho)];
        w = cross(uv_ortho(:,1),uv_ortho(:,2));  % this is w orthogonal to u,v
        w = w/norm(w);                           % in Crystal Cartesian
        w = b_vec_directions\w; % this is unit-length vector w in hkl-aligned system;
        obj.w_ = w(:)';
    else
        % w it is not used in orthogonal case, just provided for convenience.
        % Used in non-orthogonal case only. 'p' which would use w, is not
        % possible 
        w = zeros(3,1);
    end
else
    w=obj.w;
    if ubmat(3,:)*w'<0
        w=-w;       % ensure u,v,w make a rh set
        obj.w_ = w;
    end
end

uvw=[u(:),v(:),w(:)];
ulen = zeros(1,3);
uvw_orth=ubmat*uvw;  % u,v,w in the orthonormal
%                   coordinate system frame defined by u (along u) and v and
%                   aligned with rotated Crystal Cartesian system
%                   in (A^-1)
if obj.nonorthogonal       % V_c = Transf*B*V_hkl -- Defining Transformation
    transf  = b_mat*uvw; % The vectors of the projection in Crystal 
    %                      Cartesian coordinates
    % define appropriate normalization.
    for i=1:3        
        % make the transformation vectors to be unit vectors to be able 
        %to project data  without distortions        
        transf(:,i) = transf(:,i)/norm(transf(:,i));
        veclen = norm(uvw_orth(:,i));
        if lower(type(i))=='r'      % normalise so ui has max(abs(h,k,l))=1
            ulen(i) = veclen/max(abs(uvw(:,i)));
        elseif lower(type(i))=='a'  % ui normalised to 1 Ang^-1
            ulen(i) = 1;
        elseif lower(type(i))=='p'  % normalise so ui has length of projection of u,v,w along ui
            ulen(i) =veclen;
        end
    end
    % transpose transformation matrix to be consistent with umat below.
    % as u-matrix arrangement is rows, make transf arranged in rows
    q_to_img = inv(transf)./(ulen(:));
else                                        % V_c = U*B*V_hkl -- defining U
    ubmatinv = inv(ubmat);
    for i=1:3
        if lower(type(i))=='r' 
            % The scale sets the lengs of projection of i-th reciprocal lattice vector
            % rotated into target coordinate system onoto original hkl system, equal to 1
            ulen(i) = 1/max(abs(ubmatinv(:,i))); 
            %                          % each axis of UB coordinates to be
        elseif lower(type(i))=='a'  % ui normalised to 1 Ang^-1
            ulen(i) = 1;            % length of ui in Ang^-1
        elseif lower(type(i))=='p'  % normalise so ui has length of projection of u,v,w along ui
            ulen(i) = abs(uvw_orth(i,i)); % lentgh of the projections of
            % the Q-coordinates onto the axes of the rotated according to U
            % orthonormal coordinate system with x-axis along b_1
        end
    end
    % u-matrix here is arranged in rows to be multipled by b-matrix. What
    % about normalization in columns? Look at goniometer equation
    % (Boosing &Levy) to choose correct order.
    % Here we do umat in lhs arranged into rows, so transformed to columns
    % (one inversion) inverted to be on rhs (other inversion). 
    % so umat (one inversion looks missing? or what?. This gives previous Horace result)
    q_to_img = (umat./(ulen(:)));
end
