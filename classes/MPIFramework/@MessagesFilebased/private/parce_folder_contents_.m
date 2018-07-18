function [mess_names,mid_from,mid_to,varargout] = parce_folder_contents_(folder_contents)
% Extract message names and messages id-s from the folder contents provided
% as input
% Message name format: 'mess_%s_FromN%d_ToN%d
% Returns
% mess_names the cellarray of messages, present in the system
% mid_from   array of the task_id-s who sent messages
% mid_to     array of the task_id-s where messages are intended.
%

mess_template = 'mess_';
len = numel(mess_template);

is_mess = arrayfun(@(x)(~x.isdir && strncmpi(mess_template,x.name,len)),folder_contents);
mess_files = folder_contents(is_mess);
if numel(mess_files) ==0
    mess_names = {};
    mid_from = [];
    mid_to   = [];
    return;
end
if verLessThan('matlab','8.12')
    mess_fnames = arrayfun(@(x)(regexp(x.name,'_','split')),mess_files,'UniformOutput',false);
else
    mess_fnames = arrayfun(@(x)(strsplit(x.name,'_')),mess_files,'UniformOutput',false);
end

mess_names = arrayfun(@(x)(x{1}{2}),mess_fnames,'UniformOutput',false);
mid_from   = arrayfun(@(x)(sscanf(x{1}{3},'FromN%d')),mess_fnames,'UniformOutput',true);
mid_to     = arrayfun(@(x)(sscanf(x{1}{4},'ToN%d')),mess_fnames,'UniformOutput',true);
if nargout > 3
    varargout{1} = arrayfun(@get_fext,mess_files,'UniformOutput',false);
end
    
function fext = get_fext(file_struct)
    [~,~,fext] = fileparts(file_struct.name);

