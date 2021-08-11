function delete_tmp_files_(obj)
% delete temporary files crated during gen_sqw phase
tmp_files = cellfun(@gen_tmp_name,obj.test_source_files_list_,...
    'UniformOutput',false);

for i=1:numel(tmp_files)
    if is_file(tmp_files{i})
        delete(tmp_files{i});
    end
end

function tmp_name = gen_tmp_name(fname)
[fp,fn] = fileparts(fname);
tmp_name = fullfile(fp,[fn,'.tmp']);

