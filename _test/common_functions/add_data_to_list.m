function new_list=add_data_to_list(initial_list,varargin)
% generic function to add one list to another excluding the members which
% already exist

% Used as part of TestCaseWithSave class
%
if iscell(varargin{1})
    new_files=varargin{1};
else
    new_files = varargin;
end

if isempty(initial_list)
    new_list = new_files;
    return
end
already_exist=ismember(varargin,initial_list);
if all(already_exist)
    new_list=initial_list;
    return
    
end


new_files = new_files(~already_exist);

if iscell(new_files)
    new_list = {initial_list{:},new_files{:}};
else
    new_list = {initial_list{:},{new_files}};
end

