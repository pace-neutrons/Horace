function obj = init_pix_access_(obj)
%INIT_PIX_ACCESS_  Initialize binary access to pixels, stored in sqw file
obj.clean_obj_ = onCleanup(@()close_faccessors(obj));
n_ldrs = numel(obj.infiles_);
obj.loaders_list_ = cell(n_ldrs,1);
try
    obj.loaders_list_{1} = ...
        sqw_formats_factory.instance.get_loader(obj.infiles{1});
    obj.binary_access_ = false;
catch ME
    if strcmp(ME.identifier,'')        
        obj.binary_access_ = true;
    else
        rethrow(ME);
    end
end
if obj.binary_access_
    for i=1:n_ldrs
        obj.loaders_list_{i} =sqw_fopen(obj.infiles{i},'r');
    end
else
    for i=2:n_ldrs
        obj.loaders_list_{i} = ...
            sqw_formats_factory.instance.get_loader(obj.infiles{i});
    end
end
