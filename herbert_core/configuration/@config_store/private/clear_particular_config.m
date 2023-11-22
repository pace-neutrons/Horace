function  clear_particular_config(this,class_inst_or_name,clear_file)
% internal method to remove particular configuration from memory
%
% if clear_file == true also deletes the correspondent configuration file
%
%
%
if ischar(class_inst_or_name)
    class_name = class_inst_or_name;
else
    class_name = class_inst_or_name.class_name;
end

if isfield(this.config_storage_,class_name)
    this.config_storage_=rmfield(this.config_storage_,class_name);
    if this.saveable_.isKey(class_name)
        this.saveable_.remove(class_name);
    end
end
if clear_file
    filename = fullfile(this.config_folder,[class_name,'.mat']);
    if is_file(filename)
        delete(filename)
    end
end
