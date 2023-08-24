function is = is_legacy_aligned(filename)
% IS_LEGACY_ALIGNED: small utility which checks if sqw file,
% provided as input is legacy aligned
% Inputs:
% filename -- name of sqw

try
    ld = sqw_formats_factory.instance().get_loader(filename);
catch ME
    if strcmp(ME.identifier,'HORACE:file_io:runtime_error')
        is = false;
        return
    else
        rethrow(ME);
    end
end
clOb = onCleanup(@()delete(ld));
if ld.faccess_version >= 4 % new files can not be legacy aligned
    is = false;
    return;
end
if ~ld.sqw_type % dnd objects can not be legacy aligned
    is = false;
    return;
end
exp = ld.get_exp_info();
hav = exp.header_average;
if isfield(hav,'u_to_rlu') % legacy aligned file
    is = true;
else
    is = false;
end


