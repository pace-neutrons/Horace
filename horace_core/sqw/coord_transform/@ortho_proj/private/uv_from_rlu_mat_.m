function [u,v,w,type,nonortho]=uv_from_rlu_mat_(obj,u_to_img,ulen,varargin)
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

if ~isempty(varargin)
    b_mat       = varargin{1};
    rlu_vec_len = varargin{2};
else
    [b_mat,rlu_vec_len] = bmatrix(obj.alatt,obj.angdeg); % converts hkl to Crystal Cartesian
end
%u_rot_mat = b_mat\u_rot_mat; % old style transformation matrix need this
% to define the transformation

umatinv = u_to_img.*ulen(:)';
err = 1.e-8;
if abs(umatinv(:,1)'*umatinv(:,2)) > err || ...
        abs(umatinv(:,1)'*umatinv(:,3)) > err || ...
        abs(umatinv(:,2)'*umatinv(:,3)) > err
    ortho = false;
else
    ortho = true;
end
nonortho = ~ortho;

if ortho
    umat = inv(umatinv);
    ubmat = umatinv\b_mat; % correctly recovered ubmatrix; ulen matrix extracted

    uvw_orth_hkl = (b_mat\umat');   % orthogonal part of u,v,w
    %  in hkl frame defined by u and v

    %
    lt = cell(3,1);
    for i=1:3
        if ulen(i)==1
            lt{i} = 'a';
        else % should be 'p' or 'r' depending on the length of the
            % initial u v or w vector
            if abs(ulen(i)-max(abs(ubmat(:,i))))<1.e-7
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
    uvw_cc = inv(umatinv)'; % that's uvw in CC
    type = cell(3,1);
    for i=1:3
        type{i} = find_type(u_to_img(i,:),ulen(i));
    end
    type = [type{:}];
    uvw_cc = b_mat\uvw_cc;
    u = uvw_cc(:,1);
    v = uvw_cc(:,2);
    w = uvw_cc(:,3);
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