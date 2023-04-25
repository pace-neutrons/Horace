function [u,v,w,type,nonortho]=uv_from_rlu_mat_(obj,u_rot_mat,ulen)
% Extract initial u/v vectors, defining the plane in hkl from
% lattice parameters and the matrix converting vectors in
% crystal Cartesian coordinate system into rlu.
%
% partially inverting projaxes_to_rlu function of ortho_proj class
% as only orthogonal to u part of the v-vector can be recovered
%
% Inputs:
% u_rot_mat -- matrix used for conversion from pixel coordinate
%          system to the image coordinate system (normally
%          expressed in rlu)
% ulen  -- length of the unit vectors of the reciprocal lattice
%          units, the Horace image is expressed in
% Outputs:
% u     -- [1x3] vector expressed in rlu and defining the cut
%          direction
% v     -- [1x3] vector expressed in rlu, and together with u
%          defining the cut plain
% w    --  [1x3] vector expressed in rlu, defining the cut area. May be
%          empty
% type --
%u_rot_mat(:,i) = ubinv(:,i)*ulen(i);

b_mat = bmatrix(obj.alatt,obj.angdeg); % converts hkl to Crystal Cartesian
% get_proj_and_pbin(w) T.G.Perring   30 September 2018
% Extracted from it on 19/07/2022;
uu = u_rot_mat(:, 1)';
vv = u_rot_mat(:, 2)';
ww = u_rot_mat(:, 3)';
ux = b_mat * uu';
vx = b_mat * vv';
nx = cross(ux, vx);  nx = nx/norm(nx);
wx = b_mat * ww'  ;  wx = wx/norm(wx);
if norm(cross(nx, wx)) > 1e-8
    ortho = false;
else
    ortho = true;
end
nonortho = ~ortho;

if ortho    
    ulen_inv = 1./ulen(:)';
    ubinv = u_rot_mat.*repmat(ulen_inv,3,1);
    ubmat = inv(ubinv); % correctly recovered ubmatrix; ulen matrix extracted

    %ubmat = umat*b_mat;
    umat = ubmat/b_mat;
    %
    u_dir = (b_mat\umat(1,:)')';
    % unit vector, parallel to u:
    u = u_dir/norm(u_dir);

    % the length of the v-vector, orthogonal to u (unit vector)
    % in fact real v-vector is not fully recoverable. We can
    % recover only its orthogonal part
    v_tr =  (b_mat\umat(2,:)')';
    v = v_tr/norm(v_tr);
    %
    w=ubinv(:,3)';  % perpendicular to u and v, length 1 Ang^-1, forms rh set with u and v

    uvw=[u(:),v(:),w(:)];
    uvw_orthonorm=ubinv\uvw;    % u,v,w in the orthonormal (Crystal Cartesian)
    %   frame defined by u and v
    ulen_new = diag(uvw_orthonorm);
    lt = cell(3,1);
    for i=1:3
        if ulen(i)==1
            lt{i} = 'a';
        elseif abs(ulen(i)-ulen_new(i))<1.e-7
            lt{i} = 'p';
        else % either new projection 'p' or 'r'
            if i==3
                lt{i} = 'r';
            else
                scale = ulen(i)/ulen_new(i);
                if i==1
                    u = u*scale;
                else % i==2
                    v = v*scale;
                end
                lt{i} = 'p';
            end
        end
    end
    if lt{3} ~= 'p'
        w = [];
    end
    type = [lt{:}];    
else % non-ortho
    uvw = [uu',vv',ww'];
    type = cell(3,1);
    for i=1:3
        type{i} = find_type(u_rot_mat(i,:),ulen(i));
        if type{i} ~= 'a'
            uvw(:,i) =  uvw(:,i)/ulen(i);
        end
    end
    type = [type{:}];
    u = uvw(:,1);
    v = uvw(:,2);
    w = uvw(:,3);
end

function  [type] = find_type(u_rot_vec,ulen)
Li = norm(u_rot_vec);
if abs(Li-ulen)< 4*eps('single')
    type = 'p';
elseif ulen == 1
    type = 'a';
    % check?
else
    type = 'r';
end