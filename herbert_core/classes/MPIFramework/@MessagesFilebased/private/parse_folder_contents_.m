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


if nargin > 1
    nolocked_only = varargin{1};
else
    nolocked_only = true;
end

mess_template = 'mess_';
len = numel(mess_template);




if ~isstruct(folder_contents)
    % the code to deal with strange situation on Linux, where sometimes,
    % very rarely, dir returns something strange. Interesting to know what
    % it is actually.
    warning('HERBERT:MessagesFilebased:runtime_error',...
        '*** dir have returned unusual output:\n ***%s\n',...
        evalc('disp(folder_contents)'))
    mess_names = {};
    mid_from = [];
    mid_to   = [];
    if nargout > 3
        varargout{1}  = {};
    end
    return;
end
% extract only messages
[is_mess,is_lock] = arrayfun(@(x)is_message_(x,mess_template,len,nolocked_only),folder_contents);

% remove locked files from further consideration
if any(is_lock)
    if nolocked_only % remove locked files from the list
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
% Sort messages according to their access date, the most recent come first
if isfield(mess_files,'datenum')
    mess_date = arrayfun(@extract_datenum,mess_files,'UniformOutput',true);
    %[~,ind] = sort(mess_date,'descend');
    [~,ind] = sort(mess_date);
    mess_files = mess_files(ind);
else %  dos command sorts files with oldest coming last
    %
    % mess_files = fliplr(mess_files);
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
function dn = extract_datenum(f_info)
dn = f_info.datenum;
if ~isnumeric(dn) || numel(dn) > 1
    warning(' Non-numeric or non-scalar datenum for file %s in folder %s; Contains: %s',...
        evalc('disp(f_info.name)'),evalc('disp(f_info.folder)'),evalc('disp(f_info.datenum)'));
    dn = NaN;
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


function [is_mess,is_lock] = is_message_(file_struc,mess_template,len,nolocked_only)
% the functon verifies if the file structure produced by dir
% and received as input is actually the file, with filebased
% message or is a lock file.
%
if ~isfield(file_struc,'isdir') || ~isfield(file_struc,'name')
    % some odd input may be provided by dir on some OS
    is_mess = false;
    is_lock = false;
    return;    
end


if file_struc.isdir
    is_mess = false;
    is_lock = false;
    return;
end
[~,fn,fext] = fileparts(file_struc.name);
is_mess = strncmpi(mess_template,fn,len);
%
if is_mess && strncmpi(fext,'.tmp_',5) % the message in process of
    % writing to disk. Its a locked message, whatewer lock state is
    if nolocked_only
        is_mess  = false;
    else
        is_mess = true;
    end
end
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

