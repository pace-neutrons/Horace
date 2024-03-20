function proj =  build_from_old_data_struct_(proj,data_struct,varargin)
% build projection from a structure, stored by previous version(s) of Horace
%
if isfield(data_struct,'ulabel')
    data_struct.label = data_struct.ulabel;
end
if isfield(data_struct,'u_to_rlu_legacy')
    data_struct.u_to_rlu  = data_struct.u_to_rlu_legacy;
end
% if isfield(data_struct,'u_to_rlu')
%     disp('*** U_to_rlu stored:')
%     disp(data_struct.u_to_rlu )
% end

if isfield(data_struct,'ulen')
    % disp('*** ulen stored:')
    % disp(data_struct.ulen)
    data_struct.img_scales = data_struct.ulen;
end
if isfield(data_struct,'uoffset')
    %offset = proj.transform_img_to_hkl(data_struct.uoffset(:));
    data_struct.offset = data_struct.uoffset; % This is probably incorrect
    % but no checks are available. uoffset refers to source coordinate
    % system rather then target so conversion is incorrect if source
    % is not in hkle. May be better
    % just to remove this piece of code and do conversion on different
    % level.
    if ~isfield(data_struct,'warn_on_legacy_data') || data_struct.warn_on_legacy_data
        if any(abs(data_struct.offset)>4*eps('single'))
            warning('HORACE:legacy_interface',['\n'...
                '***********************************************************************\n' ...
                '*** using old interface for offset by setting uoffset property.     ***\n' ...
                '*** assuming provided value is expressed in hkle coordinate system  ***\n' ...
                '***********************************************************************\n' ...
                '*** rename uoffset to offset expressed it in hkle to avoid this message\n' ...
                '***********************************************************************'])
        end
    end
end
use_u_to_rlu_transitional =  isfield(data_struct,'u_to_rlu');
if use_u_to_rlu_transitional
    proj = ubmat_proj();
end
proj = proj.from_bare_struct(data_struct);
% disp(proj)
% if proj.alatt_defined && proj.angdeg_defined
%     disp('*** proj.transform_pix_to_img(eye(3)):')    
%     proj.transform_pix_to_img(eye(3))
% end
