function  obj = set_file_name_(obj,new_name)
% Set input file name for a loader verifying
% if the file with appropriate name exist.
%
if ~(ischar(new_name) || isstring(new_name))
    error('HERBERT:a_loader:invalid_argument', ...
        'file name have to be a character array or string. It is: %s', ...
        evalc('disp(new_name)'));
end
if isempty(new_name)
    % disconnect detector information in memory from a par file
    obj.file_name_ = '';
    if isempty(obj.S_)
        obj.en_ = [];
        obj.n_detindata_=[];
    end
    f_name = '';
else
    [ok,mess,f_name] = check_file_exist(obj,new_name);
    if ~ok
        obj.isvalid_ = false;
        obj.reason_for_invalid_ = mess;
        obj.file_name_ = new_name;
        return;
    end
end
if strcmp(obj.file_name_,f_name)
    return;
end
if ~isempty(obj.file_name_)
    obj= obj.delete();
end
obj=obj.set_data_info(f_name);
