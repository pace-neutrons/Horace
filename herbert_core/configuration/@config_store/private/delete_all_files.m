function  delete_all_files( this )
%method deletes all configuration files loaded to config_store

% $Revision:: 840 ($Date:: 2020-02-10 16:05:56 +0000 (Mon, 10 Feb 2020) $)

%
fields = fieldnames(this.config_storage_);
for i=1:numel(fields)
    class_name = fields{i};
    filename = fullfile(this.config_folder,[class_name,'.mat']);
    if is_file(filename)
        delete(filename);
    end
end



