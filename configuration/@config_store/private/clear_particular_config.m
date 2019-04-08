function  clear_particular_config(this,class_instance,clear_file)
% internal method to remove particular configuration from memory 
%
% if clear_file == true also deletes the correspondent configuration file
%
%
% $Revision:: 830 ($Date:: 2019-04-08 17:54:30 +0100 (Mon, 8 Apr 2019) $)
%

class_name =  class_instance.class_name;
if isfield(this.config_storage_,class_name)
    this.config_storage_=rmfield(this.config_storage_,class_name);
    if this.saveable_.isKey(class_name)
        this.saveable_.remove(class_name);
    end
end
if clear_file
    filename = fullfile(this.config_folder,[class_name,'.mat']);
    if exist(filename,'file')
        delete(filename)
    end
end
