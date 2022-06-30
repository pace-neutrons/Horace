function [mess_names,mess_id] = parce_folder_contents_(folder_contents)
% Extract message names and messages id-s from the folder contents provided
% as input
% Return%
% mess_names the cellarray of messages, present in the system
% mess_id    array of task_id-s
%

mess_template = 'mess_';
len = numel(mess_template);

is_mess = arrayfun(@(x)(~x.isdir && strncmpi(mess_template,x.name,len)),folder_contents);
mess_files = folder_contents(is_mess);
if numel(mess_files) ==0
    mess_names = {};
    mess_id = [];
    return;
end
if verLessThan('matlab','8.12')
    mess_fnames = arrayfun(@(x)(regexp(x.name,'_','split')),mess_files,'UniformOutput',false);
else
    mess_fnames = arrayfun(@(x)(strsplit(x.name,'_')),mess_files,'UniformOutput',false);
end

mess_names = arrayfun(@(x)(x{1}{2}),mess_fnames,'UniformOutput',false);
mess_id    = arrayfun(@(x)(sscanf(x{1}{3},'TaskN%d.mat')),mess_fnames,'UniformOutput',true);
