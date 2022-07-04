function [set_vars_map,contents,set_ind_map] = extract_bash_exports(filename)
% function reads bash file and parses it extracting part responsible for
% enviromental variables exports.
%
% The purpose of parsing is simple change to enviromental variables and
% possibility to write absolutely the same file with different enviromental
% variable values
% Input:
% filename -- name with full path to the bash file to process
% Output:
%
%


fh = fopen(filename,'rb');
if fh<1
    error('HERBERT:extract_bash_exports:invalid_argument',...
        ' Can not open input file: %s',filename)
end
clob = onCleanup(@()fclose(fh));

data = fread(fh);
data = char(data)';
clear clob;
% introduced in Matlab 2013b, use regexp before this.
contents = strsplit(data,{'\n','\r'},'CollapseDelimiters',true);
sets_vars = cellfun(@(str)strncmp(str,'export',6),contents,'UniformOutput',true);

if ~any(sets_vars)
    set_vars_map = containers.Map();
    return;
end
env_var_set_str = contents(sets_vars);
[key,val] = cellfun(@(str)parse_env_export(str),env_var_set_str,'UniformOutput',false);
% exclude variables, set up somewhere else
nonempty_val = cellfun(@(v)(~isempty(v)),val,'UniformOutput',true);
key = key(nonempty_val);
val = val(nonempty_val);
set_vars_map =  containers.Map(key,val);
if nargout>2
    ind_map = find(sets_vars);
    ind_map = ind_map(nonempty_val);
    val = num2cell(ind_map);
    set_ind_map = containers.Map(key,val);
end

function [key,val] = parse_env_export(str)
cont = strsplit(str,{' ','='},'CollapseDelimiters',true);
key = cont{2};
if numel(cont) > 2
    val = cont{3};
else
    val = '';
end
