function  delete_all_files( this )
%method deletes all configuration files loaded to config_store

% $Revision:: 839 ($Date:: 2019-12-16 18:18:44 +0000 (Mon, 16 Dec 2019) $)

%
fields = fieldnames(this.config_storage_);
for i=1:numel(fields)
    class_name = fields{i};
    filename = fullfile(this.config_folder,[class_name,'.mat']);
    if exist(filename,'file')
        delete(filename);
    end
end



