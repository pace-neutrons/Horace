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
    b_mat = varargin{1};
else
    b_mat = bmatrix(obj.alatt,obj.angdeg); % converts hkl to Crystal Cartesian
end
%u_rot_mat = b_mat\u_rot_mat; % old style transformation matrix need this
% to define the transformation

umatinv = u_to_img.*ulen(:)';
err = 1.e-8;
if umatinv(:,1)'*umatinv(:,2) > err || ...
   umatinv(:,1)'*umatinv(:,3) > err || ...
   umatinv(:,2)'*umatinv(:,3) > err 
    ortho = false;
else
    ortho = true;
end
nonortho = ~ortho;

if ortho
    %ulen_inv = 1./ulen(:)';
    
    umat = inv(umatinv);
    ubmat = umatinv\b_mat; % correctly recovered ubmatrix; ulen matrix extracted

    %
    u_dir = umat(:,1);
    % unit vector, parallel to u:
    u = u_dir/norm(u_dir);

    % the length of the v-vector, orthogonal to u (unit vector)
    % in fact real v-vector is not fully recoverable. We can
    % recover only its orthogonal part
    v_tr = umat(:,2);
    v = v_tr/norm(v_tr);
    %
    w=umat(:,3)/norm(umat(:,3));  % perpendicular to u and v

    uvw=[u(:),v(:),w(:)];
    uvw_orth=ubmat'*uvw;  % u,v,w in the orthonormal
    %   frame defined by u and v
    ulen_new = abs(diag(uvw_orth));
    lt = cell(3,1);
    for i=1:3
        if ulen(i)==1
            lt{i} = 'a';
        elseif abs(ulen(i)-ulen_new(i))<1.e-7
            lt{i} = 'p';
        else % should be 'p' or 'r' depending on the length of the
            % initial u v or w vector
            if abs(ulen(i)-max(abs(ubmat(:,i))))<1.e-7
                lt{i} = 'r';
            else
                lt{i} = 'p';
                uvw(:,i) = uvw(:,i)*(ulen(i)/ulen_new(i));
            end
        end
    end
    u = uvw(:,1);
    v = uvw(:,2);
    w = uvw(:,3);
    %     if lt{3} == 'r'
    %         w = [];
    %     end
    type = [lt{:}];
else % non-ortho
    uvw = [uu',vv',ww'];
    type = cell(3,1);
    for i=1:3
        type{i} = find_type(u_to_img(i,:),ulen(i));
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