function  clear_particular_config(this,class_instance,clear_file)
% internal method to remove particular configuration from memory 
%
% if clear_file == true also deletes the correspondent configuration file
%
%
% $Revision: 313 $ ($Date: 2013-12-02 11:31:41 +0000 (Mon, 02 Dec 2013) $)
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
