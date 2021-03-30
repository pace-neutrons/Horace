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
    [~, u_to_rlu] = projaxes_to_rlu(obj.projaxes_,obj.alatt, obj.angdeg, [1,1,1]);
    if ndim==4
        u_to_rlu = [u_to_rlu,[0;0;0];[0,0,0,1]];
        shift  = obj.uoffset';
    elseif ndim == 3
        shift  = obj.uoffset(1:3)';
    else
        error('PROJECTION:invalid_argument',...
            'The size of the pixels array should be [3xNpix] or [4xNpix], actually it is: %s',...
            evalc('disp(size(pix_data))'));
    end
    % convert shift, expressed in hkl into crystal Cartesian
    shift = u_to_rlu\shift';
    %
    pix_cc= u_to_rlu\(bsxfun(@plus,pix_data,shift));
end
