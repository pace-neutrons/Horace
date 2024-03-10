function [u,v,w,type,nonortho]=uv_from_u_to_rlu_(obj,u_to_rlu,ulen,varargin)
% Extract initial u/v vectors, defining the plane in hkl from
% lattice parameters and the matrix converting vectors in
% crystal Cartesian coordinate system into image coordinate system.
%
% partially inverting projaxes_to_rlu function of line_proj class
% as only orthogonal to u part of the v-vector can be recovered
%
% Inputs:
% q_to_img -- matrix used for conversion from pixel coordinate
%            system to the image coordinate system divided by B-matrix
%          If it is orthogonal coordinate system, the matrix is rotation
%          matrix but if it does not -- it is
%
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

if ~isempty(varargin)
    b_mat       = varargin{1};
else
    b_mat = bmatrix(obj.alatt,obj.angdeg); % converts hkl to Crystal Cartesian
end
ub_inv = u_to_rlu./ulen(:)'; % every column divided by proper ulen;
%u_rot_mat = b_mat\u_rot_mat; % old style transformation matrix need this
% to define the transformation

umat = (b_mat*ub_inv(1:3,1:3))';%Recover umat, umat vectors arranged in rows and it
% should be rotation matrix for orthogonal coordinate system
err = 1.e-8;
cross_proj = [umat(1,:)*umat(2,:)',umat(1,:)*umat(3,:)',umat(2,:)*umat(3,:)'];
if any(abs(cross_proj) > err)
    ortho = false;
else
    ortho = true;
end
nonortho = ~ortho;
if ortho
    ubmat = umat*b_mat; % correctly recovered ubmatrix; ulen matrix extracted
    ubmatinv = inv(ubmat);

    % DOES NOT LOOK LIKE THIS CORRECT on 08/03/2024 Does not recovers line_proj from ubmat_proj:
    % orthogonolize to suppress round-off errors
    %umat(2,:) = umat(2,:)- (umat(1,:)*cross_proj(1)+umat(3,:)*umat(2));
    %umat(3,:) = umat(3,:)- (umat(1,:)*cross_proj(2)+umat(2,:)*(umat(2,:)*umat(3,:)'));

    uvw_orth_hkl = (b_mat\umat');   % orthogonal part of u,v,w
    %  in hkl frame defined by u and v

    %
    lt = cell(3,1);

    for i=1:3
        ulen_i_r = 1/max(abs(ubmatinv(:,i)));
        if ulen(i)==1
            lt{i} = 'a';
        else % should be 'p' or 'r' depending on the length of the
            % initial u v or w vector
            if abs(ulen(i)-ulen_i_r)<1.e-7
                lt{i} = 'r';
            else
                lt{i} = 'p'; % p includes vector length so it has to be adjusted
                uvw_orth_hkl(:,i) = uvw_orth_hkl(:,i)*ulen(i);
            end
        end
    end
    u = uvw_orth_hkl(:,1);
    v = uvw_orth_hkl(:,2);
    w = uvw_orth_hkl(:,3);

    type = [lt{:}];
else % non-ortho
    transf_cc = umat'; % that's nonorthogonal transformation (row 85 in projtransf_to_img)
    uvw  = b_mat\transf_cc;
    uvw_orth = transf_cc;

    type = cell(3,1);
    for i=1:3
        veclen  = norm(uvw_orth(:,i));
        [type{i},scale] = find_type(veclen,ulen(i),uvw(:,i));
        if scale ~=1
            uvw(:,i) = scale*uvw(:,i);
        end
    end
    type = [type{:}];
    u = uvw(:,1);
    v = uvw(:,2);
    w = uvw(:,3);
end

function  [type,scale] = find_type(veclen,ulen,vec)
scale = 1;
if abs(veclen-ulen)< 4*eps('single')
    type = 'p';
elseif ulen == 1
    type = 'a';
else
    scale_p = ulen/veclen;
    scale_r = sqrt(ulen/veclen/max(abs(vec)));
    if abs(veclen*scale_r - ulen)<4*eps("single")
        scale = scale_r;
        type = 'r';
    else
        scale = scale_p;
        type = 'p';
    end
end