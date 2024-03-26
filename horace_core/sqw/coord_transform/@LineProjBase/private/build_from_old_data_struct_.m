function proj =  build_from_old_data_struct_(proj,data_struct,varargin)
% build projection from a structure, stored by previous version(s) of Horace
%
if isfield(data_struct,'ulabel')
    data_struct.label = data_struct.ulabel;
end
if isfield(data_struct,'u_to_rlu_legacy')
    data_struct.u_to_rlu  = data_struct.u_to_rlu_legacy;
end

if isfield(data_struct,'ulen')
    data_struct.img_scales = data_struct.ulen;
end
if isfield(data_struct,'uoffset')
    uoffset_profided = true;
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
else
    uoffset_profided = false;
end
use_u_to_rlu_transitional =  isfield(data_struct,'u_to_rlu');
if use_u_to_rlu_transitional
    proj = ubmat_proj();
    if uoffset_profided
        proj.do_check_combo_arg = false;
        proj.uoffset = data_struct.uoffset;
    end
end
proj = proj.from_bare_struct(data_struct);
