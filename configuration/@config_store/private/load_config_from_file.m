function [config_data,result,mess] = load_config_from_file(file_name,class_field_names)
% Load configuration from file, if it exists and suitabnle.
% Otherwise, return empty structure.
%
%   >> [config_data,ok,mess] = load_config (file_name,class_field_names)
%
% Input:
% ------
%   file_name       Name of file that contains configuration. Assumed to be a
%                  .mat file with the configuration saved as a variable
%                  called config_data.
%  class_field_names -- the names of the fields which has to be present in
%                   the file for it to be correct
%
% Output:
% -------
%   config_data     class containing configuration data. Empty if file does
%                   not exist or there is a problem
%   result          1 if file succesfully read, 0 if file contains data which
%                   are not consistent with the current configuration or -1
%                   if file is wrong or some IO error occurs.
%   mess            Message. Empty if result==1

% $Revision$ ($Date$)

config_data=[];
if exist(file_name,'file')
    try
        S=load(file_name,'-mat');
    catch
        result=-1;
        mess=['Problem reading configuration file ',file_name];
        return
    end
    if isfield(S,'config_data') && isstruct(S.config_data)
        stored_fields = fieldnames(S.config_data);
        if numel(stored_fields) == numel(class_field_names)
            if ~all(ismember(class_field_names,stored_fields))
                result=0;
                mess = ['Contents of configuration file ',file_name,' is outdated '];
                return;
            end
            config_data=S.config_data;
        else
            result=0;
            mess = ['Contents of configuration file ',file_name,' is outdated '];
            return;
        end       
    else
        result=-1;
        mess=['Contents of file ',file_name,' are not configuration data'];
        return
    end
else
    result=-1;
    mess = ['Configuration file ',file_name,' does not exist'];
    return
end
result = 1;
mess = '';

