function [u,v,w,type,nonortho]=uv_from_rlu_mat_(obj,u_to_img,ulen,varargin)
% Extract initial u/v vectors, defining the plane in hkl from
% lattice parameters and the matrix converting vectors in
% crystal Cartesian coordinate system into rlu.
%
% partially inverting projaxes_to_rlu function of line_proj class
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
else
    b_mat = bmatrix(obj.alatt,obj.angdeg); % converts hkl to Crystal Cartesian
end
%u_rot_mat = b_mat\u_rot_mat; % old style transformation matrix need this
% to define the transformation

%umat = (u_to_img.*ulen(:)')'; %Recover umat, umat vectors arranged in rows
transf_mat = (u_to_img.*ulen(:)); %Recover umat, umat vectors arranged in rows
err = 1.e-8;
cross_proj = [transf_mat(1,:)*transf_mat(2,:)',transf_mat(1,:)*transf_mat(3,:)',transf_mat(2,:)*transf_mat(3,:)'];
if any(abs(cross_proj) > err)
    ortho = false;
else
    ortho = true;
end
nonortho = ~ortho;
if ortho
    ubmat = transf_mat*b_mat; % correctly recovered ubmatrix; ulen matrix extracted
    ubmatinv = inv(ubmat);


    % orthogonolize to suppress round-off errors
    transf_mat(2,:) = transf_mat(2,:)- (transf_mat(1,:)*cross_proj(1)+transf_mat(3,:)*cross_proj(2));
    transf_mat(3,:) = transf_mat(3,:)- (transf_mat(1,:)*cross_proj(2)+transf_mat(2,:)*(transf_mat(2,:)*transf_mat(3,:)'));

    uvw_orth_hkl = (b_mat\transf_mat');   % orthogonal part of u,v,w
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
    uvw_cc = inv(transf_mat); % that's uvw in CC
    u_cc = uvw_cc(:,1);
    v_cc = uvw_cc(:,2);
    uvw  = b_mat\uvw_cc;
    ubmat = ubmatrix(u_cc,v_cc,b_mat);
    uvw_orth = ubmat*uvw;

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