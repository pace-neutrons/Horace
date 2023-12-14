function wout = save(w, varargin)
% Save a sqw or dnd object or array of sqw/dnd objects to a binary sqw file
% of recommended file-format version.
%
%   >> save (w)              % prompt for file
%   >> save (w, file)        % save to file with the name provided
%   >> save (w, file,varargin)
% provide additional save options. See below.
%  >> wout = save(___)      % return filebacked sqw object if you are
%                             saving sqw object
% Input:
%   w       sqw object
%   file    [optional] File for output. if none given, then prompted for a file
% Optional:
%  loader   -- instance of registerted faccess loader (see sqw_formats_factory)
%              to use to save data.
%              May be used to save data in old file formats. Be careful, as
%              this options
%
% Optional output:
% wout -- filebacked sqw object with new filename if filename was provided
%

%   NOTE:
% % if w is an array of sqw objects then file must be a cell
%   array of filenames of the same size.
%

% Original author: T.G.Perring
%
[ok,mess,upgrade,update,argi] = parse_char_options(varargin,{'-update','-upgrade'});
if ~ok
    error('HORACE:sqw:invalid_argument',mess);
end
return_result = nargout>0;
num_to_save = numel(w);

[filenames,ldw]  = parse_additional_args(num_to_save,w,argi{:});

if num_to_save > 1
    if return_result
        wout = repmat(w(1),size(w));
    else
        wout = zeros(size(w));
    end
    for i=1:num_to_save
        wout(i) = save_one(w(i),filenames{i},return_result,ldw{i});
    end
else
    wout = save_one(w,filenames{1},return_result,ldw{1});
end
%==========================================================================
function wout = save_one(w,filename,return_result,ldw,varargin)
wout = []; % parallel cluster used to combine and save. Not tested, not used


hor_log_level = get(hor_config,'log_level');

% Write data to file   x
if hor_log_level>0
    disp(['*** Writing to: ',filename,'...'])
end

if isfile(filename) && ( ...
        ~w.is_filebacked || (w.is_filebacked && w.pix.full_filename ~= filename) ...
        )
    delete(filename);
end
%

ldw = ldw.init(w,filename);
if w.is_filebacked
else
    w.full_filename = filename;
end

ldw = ldw.put_sqw();
ldw.delete();
%
if return_result
    if isa(w,'sqw')
        wout = sqw(filename,'file_backed',true);
    else
        wout = w;
    end
end
%==========================================================================
function [filenames,ldw] = parse_additional_args(num_to_save,w,varargin)
% parse inputsd for filenames and loaders provided as input of save method.
% fill default or ask user if some

% Get file name - prompting if necessary
if numel(varargin) == 0
    if num_to_save > 1
        error('HORACE:sqw:invalid_argument', ...
            ['No target filenames provided to save method.\n' ...
            'Storing %d files requests %d filenames provided. '], ...
            num_to_save,num_to_save);
    else
        [filenames,mess]=putfile_horace('');
        if ~isempty(mess)
            error('HORACE:sqw:invalid_argument',mess)
        end
        argi = {};
    end
else
    if num_to_save == 1
        is_fn = cellfun(@istext,varargin);
    else
        is_fn = cellfun(@(x)iscell(x)&&istext(x{1}),varargin);
    end
    n_found = sum(is_fn);
    if n_found > 1
        fn_like = varargin(is_fn);
        error('HORACE:sqw:invalid_argument', ...
            'More then one input (%s) can be interpreted as filename', ...
            disp2str(fn_like));
    end
    if n_found == 0
        if num_to_save > 1
            error('HORACE:sqw:invalid_argument', ...
                ['No target filenames provided to save method.\n' ...
                'Storing %d files requests %d filenames provided. '], ...
                num_to_save,num_to_save);
        else
            [filenames,mess]=putfile_horace('');
            if ~isempty(mess)
                error('HORACE:sqw:invalid_argument',mess)
            end
            argi = varargin;
        end
    else
        filenames = varargin(is_fn);
        if iscell(filenames)
            if numel(filenames) ~= num_to_save
                error('HORACE:sqw:invalid_argument', ...
                    ['Saving %d object requests providing cellarray of %d filenamse.\n' ...
                    ' Actually provided: %d filenames'],...
                    num_to_save,num_to_save,numel(filenames));
            end
            all_text = cellfun(@istext,filenames);
            if ~all_text
                n_filename_arg = find(is_fn);
                error('HORACE:sqw:invalid_argument', ...
                    'Not all members of filenames cellarray (Argument N%d ) are the text strings. This is not supported',...
                    n_filename_arg)
            end
        end
        argi      = varargin(~is_fn);
    end
end
if isempty(argi)
    ldw = cell(1,num_to_save);
    for i=1:num_to_save
        ldw{i} = sqw_formats_factory.instance().get_pref_access(w(i));
    end
    return
end
ldw = argi{1};
if isa(ldw,'horace_binfile_interface') % specific loader provided
    if numel(ldw) ~= num_to_save
        error('HORACE:sqw:invalid_argument', ...
            'Saving %d sqw objects requests the same number of loaders. Proived %d',...
            num_to_save,numel(ldw));
    end
    ldw = num2cell(ldw);
elseif iscell(ldw)
    is_faccesor = cellfun(@(x)isa(x,'horace_binfile_interface'),ldw);
    if ~all(is_faccesor)
        error('HORACE:sqw:invalid_argument', ...
            'Not every file-accessor provided as input is child of horace_binfile_interface. This is not supported')
    end
    if numel(ldw) ~= num_to_save
        error('HORACE:sqw:invalid_argument', ...
            'Saving %d sqw objects requests the same number of loaders. Proived %d',...
            num_to_save,numel(ldw));
    end
else
    error('HORACE:sqw:invalid_argument', ...
        'Unable to use class %s as faccess-or for sqw data',...
        class(ldw))
end
