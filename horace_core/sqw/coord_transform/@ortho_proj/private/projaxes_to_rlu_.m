function [u_to_img,ulen,b_mat,obj] = projaxes_to_rlu_(obj)
% Determine matrices to convert rlu <=> projection axes, and the scaler
%
%
%   >> [img_to_u, u_to_img, ulen] = projaxes_to_rlu_(proj)
%
% The projection axes are three vectors that may or may not be orthogonal
% which are used to create the bins in an sqw object. The bin sizes are in ustep
%
% Input:
% ------
%   proj    ortho_proj object containing information about projection axes
%          (type >> help ortho_proj for details)
%
% Output:
% -------
%   img_to_u    Matrix to convert components of a vector expressed
%               in image coordinate system to the components along the projection axes
%               u1,u2,u3, as multiples of the step size along those axes
%                   Vstep(i) = rlu_to_ustep(i,j)*Vrlu(j)
%   ulen        Row vector of scales of ui in Ang^-1
%   b_mat       Matrix transforimng hkl coordinate system into Crystal
%               Cartesian coordinate system
%   obj         the projection object iteslf modified if necessary so that
%               u,v,w form a rh set if initial object wectors were not
%
%
% Original author: T.G.Perring; J. van Duijn; Horace v0.1
%
% Substantially changed in 2023 for Horace 4.0;


[b_mat,rlu_vec_len] = bmatrix(obj.alatt, obj.angdeg);

u=obj.u;
v=obj.v;
b_vec_directions = b_mat./rlu_vec_len;
[ubmat,umat] = ubmatrix(u,v,b_mat);  % get UB matrix normalized by rlu vector length


type=obj.type;
if isempty(obj.w) %
    % the purpose of selecting default w with 'r' scale would be
    % providing the same thickness expressed in hkl cut regardless of the
    % cut direction. This may not have physical meaning for triclinic
    % lattice, but in this case you should provide w manually
    %
    % Above is the idea, have not been implemented. Just make w-vector
    % orthogonal to u,v plain
    uv_ortho = b_vec_directions*[u(:),v(:)];
    w = cross(uv_ortho(:,1),uv_ortho(:,2));
    w = w/norm(w); % this is w orthogonal to u,v in Crystal Cartesian
    w = b_mat\w;   % this is this w in hkl;
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


if obj.nonorthogonal
    transf = b_vec_directions*uvw;
    i=1:3;
    veclen = arrayfun(@(i)norm(uvw_orth(:,i)),i);
    % Keep non-orthogonality of u,v, and w (if given)
    for i=1:3
        transf(:,i) = transf(:,i)/norm(transf(:,i));
        if lower(type(i))=='r'      % normalise so ui has max(abs(h,k,l))=1
            ulen(i) = max(abs(uvw_orth(:,i)));
        elseif lower(type(i))=='a'  % ui normalised to 1 Ang^-1
            ulen(i) = 1;
        elseif lower(type(i))=='p'  % normalise so ui has length of projection of u,v,w along ui
            ulen(i) = veclen(i);
        end
    end
    % transpose transformation matrix to be consistent with umat below,
    % whihc arranged in rows
    u_to_img = inv(transf')./(ulen(:)');
else

    % Different r normalization. Is it more reasonable then the other one?
    %vec_len = arrayfun(@(i)norm(ubmat(:,i)),i);
    % r_norm = min(vec_len);
    for i=1:3
        if lower(type(i))=='r'      % normalise so ui has max(abs(h,k,l))=1
            %ulen(i) = r_norm; -- is this what corresponds to the statement
            %                     above?
            ulen(i) = max(abs(ubmat(:,i))); % make the projection of Q-vector to
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
    % (Boosing &Levy) to choose correct order
    u_to_img = inv(umat)./(ulen(:)');
end


