function pix_cc = transform_img_to_pix_(obj,pix_data)
% Transform pixels expressed in image coordinate coordinate systems
% into crystal cartezian coordinate system
%
% Input:
% pix_data -- [3xNpix] or [4xNpix] array of pix coordinates
%             expressed in crystal image coordinate systed (mainly hkl)
% Returns
% pix_cc -- pixels coordinates expressed in Crystal Cartesian coordinate
%           system

ndim = size(pix_data,1);
if isempty(obj.projaxes_)
    pix_cc  = pix_data;
else
    [rlu_to_ustep, u_to_rlu] = projaxes_to_rlu(obj.projaxes_,obj.alatt, obj.angdeg, [1,1,1]);
    b_mat  = bmatrix(obj.alatt, obj.angdeg);
    rot_to_img = rlu_to_ustep/b_mat;
    
    %rot_ustep = rlu_to_ustep*this.data_upix_to_rlu_
    %data_transf = obj.get_data_pix_to_rlu();
    if ndim==4
        shift  = obj.uoffset';
        u_to_rlu  = [u_to_rlu,[0;0;0];[0,0,0,1]];
        rot_to_img = [rot_to_img,[0;0;0];[0,0,0,1]];
    elseif ndim == 3
        shift  = obj.uoffset(1:3)';
    else
        error('PROJECTION:transformatons:invalid_argument',...
            'The size of the pixels array should be [3xNpix] or [4xNpix], actually it is: %s',...
            evalc('disp(size(pix_cc))'));
    end
    % convert shift, expressed in hkl into crystal Cartesian
    shift = u_to_rlu\shift';
    %
    pix_cc= ((bsxfun(@plus,pix_data,shift))'/(rot_to_img'))';
end
