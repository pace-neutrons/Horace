function new_list=add_data_to_list(initial_list,varargin)
% generic function to add one list to another excluding the members which
% already exist

% Used as part of TestCaseWithSave class
%
already_exist=ismember(varargin,initial_list);
if numel(already_exist)==1
    if already_exist
        new_list=initial_list;
        return
    else
        if iscell(varargin{1})
            new_files=varargin{1};
        else
            new_files = varargin;
        end
    end
else
    new_files = varargin(~already_exist);
end
if iscell(new_files)
    new_list = {initial_list{:},new_files{:}};
else
    new_list = {initial_list{:},{new_files}};
end

