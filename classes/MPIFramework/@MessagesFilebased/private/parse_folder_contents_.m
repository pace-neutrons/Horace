function [mess_names,mid_from,mid_to,varargout] = parse_folder_contents_(folder_contents,varargin)
% Extract message names and messages id-s from the folder contents provided
% as input
%
% if nolocked option is provided do not return names of messages which are locked
% if nothing is provided, locked messages names and id-s are also returned.
%
% Routine defineds:
% Message name format : 'mess_%s_FromN%d_ToN%d.ext
%
% where ext is either '.mat', '.lock[r|w]] or number or a message in a queue.
% messages with extension .lock are treated as locks to the message names,
%      never returned as output and, on request may suppress correspondent 
%      message names.
% 
%
% Returns:
%
% mess_names the cellarray of messages, present in the system
% mid_from   array of the task_id-s who sent messages
% mid_to     array of the task_id-s where messages are intended.
%Optional:
% ext       -- message extensions (except locks), used to organize the messages
%              queue.
%
%
% $Revision:: 830 ($Date:: 2019-04-09 10:03:50 +0100 (Tue, 9 Apr 2019) $)
%
%

if nargin > 1
    nolocked = true;
else
    nolocked = false;
end

mess_template = 'mess_';
len = numel(mess_template);



% extract only messages
[is_mess,is_lock] = arrayfun(@(x)is_message(x,mess_template,len),folder_contents);

% remove locked files from further consideration
if any(is_lock)
    if nolocked % remove locked files from the list
        mess_files = folder_contents(is_mess);
        lock_files = folder_contents(is_lock);
        mess_names = arrayfun(@get_mat_fname,mess_files,'UniformOutput',false);
        lock_names = arrayfun(@get_fname,lock_files,'UniformOutput',false);
        are_locked = ismember(mess_names,lock_names);
        if any(are_locked)
            mess_files  = mess_files(~are_locked);
        end
    else % remove only locks from the list.
        is_mess = is_mess&~is_lock;
        mess_files = folder_contents(is_mess);
    end
else
    mess_files = folder_contents(is_mess);
end

if numel(mess_files) ==0
    mess_names = {};
    mid_from = [];
    mid_to   = [];
    if nargout > 3
        varargout{1}  = {};
    end
    return;
end

% identify messages sources and destinations
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
end

function fext = get_fext(file_struct)
[~,~,fext] = fileparts(file_struct.name);
end
function name = get_fname(file_struct)
[~,name] = fileparts(file_struct.name);
end

function name = get_mat_fname(file_struct)
% only mat files can be locked. To avoid locking data queue file, change
% their name.
[~,name,fext] = fileparts(file_struct.name);
if strcmpi(fext,'.mat') || strncmpi(fext,'.lock',5)
    return
else
    name = [name,fext];
end
end


function [is_mess,is_lock] = is_message(file_struc,mess_template,len)
% the functon verifies if the file structure produced by dir
% and received as input is actually the file, with filebased
% message or is a lock file.
if file_struc.isdir
    is_mess = false;
    is_lock = false;
    return;
end
[~,fn,fext] = fileparts(file_struc.name);
is_mess = strncmpi(mess_template,fn,len);
if is_mess
    if strncmpi(fext,'.lock',5)
        is_lock = true;
    else
        is_lock = false;
    end
else
    is_lock = false;
end
end
