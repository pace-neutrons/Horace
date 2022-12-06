function obj=define_upgrade_map_(obj,file_exist,old_ldr)
%
log_level = config_store.instance().get_value('herbert_config','log_level');
new_filename = obj.full_filename;
%
if file_exist
    obj.upgrade_headers_ = false;    
    if isempty(old_ldr) && log_level > 1
        fprintf('*** Existing file:  %s will be overwritten.\n',new_filename);
        return
    end
    
    col = class(old_ldr);
    if isa(obj,col)
        this_pos = old_ldr.get_pos_info();
        upgrade_map = const_blocks_map(this_pos);
        obj.upgrade_map_ = upgrade_map;
        if log_level>1;   fprintf('*** Existing file:  %s can be upgraded with new object data.\n',new_filename);  end
        return;
    end
    

    can_upgrade = sqw_formats_factory.instance().check_compatibility(old_ldr,obj);
    if ~can_upgrade
        if log_level > 1;  fprintf('*** Existing file:  %s will be overwritten.\n',new_filename);end
        return
    end
    [ok,upgrade_map] = check_upgrade(obj,old_ldr,log_level);
    if ~ok
        obj.upgrade_map_ = [];
        if log_level > 1; fprintf('*** Existing file:  %s will be overwritten.\n',new_filename); end
    else
        old_ldr = old_ldr.fclose(); % close old loader input file to avoid copying file permissions
        obj = obj.copy_contents(old_ldr,true);
        obj.upgrade_map_ = upgrade_map;
        if log_level>1;   fprintf('*** Existing file:  %s can be upgraded with new object data.\n',new_filename);  end
    end

else
    obj.upgrade_map_ = [];
    obj.upgrade_headers_ = true;
end


function [ok,upgrade_map_obj] = check_upgrade(obj,old_ldr,log_level)
%
this_pos = obj.get_pos_info();
this_map = const_blocks_map(this_pos);



other_pos       = old_ldr.get_pos_info();
upgrade_map_obj = const_blocks_map(other_pos);

[ok,mess] = upgrade_map_obj.check_equal_sizes(this_map);
if ~ok && log_level>1
    fprintf('*** %s\n',mess);
end



