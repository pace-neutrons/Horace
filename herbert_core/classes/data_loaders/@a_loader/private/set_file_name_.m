function  obj = set_file_name_(obj,new_name)
% Set input file name for a loader verifying 
% if the file with appropriate name exist.
%
if isempty(new_name)
    % disconnect detector information in memory from a par file
    obj.file_name_ = '';
    if isempty(obj.S_)
        obj.en_ = [];
        obj.n_detindata_=[];
    end
    f_name = '';
else
    [ok,~,f_name] = check_file_exist(obj,new_name);
    if ok
        obj.isvalid_ = true;        
    else
        % Should we leave this check throwing? Removed to allow the file to
        % appear later, but different policy may request to implement it as
        % exception.
        %error('HERBERT:a_loader:invalid_argument',mess);
        obj.isvalid_ = false;
    end
end
if strcmp(obj.file_name_,f_name)
    return;
end
if ~isempty(obj.file_name_)
    obj= obj.delete();
end
obj=obj.set_data_info(f_name);
