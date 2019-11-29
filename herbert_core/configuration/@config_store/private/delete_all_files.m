function  delete_all_files( this )
%method deletes all configuration files loaded to config_store

% $Revision:: 833 ($Date:: 2019-10-24 20:46:09 +0100 (Thu, 24 Oct 2019) $)

%
fields = fieldnames(this.config_storage_);
for i=1:numel(fields)
    class_name = fields{i};
    filename = fullfile(this.config_folder,[class_name,'.mat']);
    if exist(filename,'file')
        delete(filename);
    end
end


