function [hdf_name,add]=hdf_group_name(a_name)
% the function checks if hdf-name identifier '/' is present in a symbolic
% name a_name and adds this identifier is it is not present;
%
% $Revision$ ($Date$)
%
if ~iscell(a_name)
    a_name={a_name};
end
if ~isa(a_name{1},'char')
    error('HORACE:hdf_tools','hdf_group_name requested a string or cell array of strings as input argument')    
end


add = ~strncmp(a_name,'/',1);
neded = a_name(add);
neded = strcat('/',neded);
hdf_name={a_name{~add},neded{:}};
