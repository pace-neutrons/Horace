function pix_transf = transform_pix_to_img_(obj,pix_cc,varargin)
% Transform pixels expressed in crystal cartezian coordinate systems
% into image coordinate system
%
% Input:
% pix_data -- [3xNpix] or [4xNpix] array of pix coordinates
%             expressed in crystal Cartesian coordinate system
% Returns:
% pix_transformed -- the pixels transformed into coordinate
%             system, related to image (often hkl system)
%

ndim = size(pix_cc,1);
if isempty(obj.projaxes_)
    pix_transf  = pix_cc;
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
            evalc('disp(size(pix_cc))'));
    end
    % convert shift, expressed in hkl into crystal Cartesian
    shift = u_to_rlu\shift';
    %
    pix_transf= u_to_rlu*(bsxfun(@minus,pix_cc,shift));
end
