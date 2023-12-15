function wout = save(w, varargin)
% Save a sqw or dnd object or array of sqw/dnd objects to a binary sqw file
% of recommended file-format version.
%
%   >> save (w)              % prompt for file
%   >> save (w, file)        % save to file with the name provided
%   >> save (w, file,varargin)
%  >> wout = save(___)      % return filebacked sqw object if you are
%                             saving sqw object
% provide additional save options. See below.
% Input:
%   w       sqw or dnd object or array of such objects.
%   file    [optional] File for output. if none given, then prompted for a file
%           if w is array, cellarray of file names must be provided here,
%           one filename per each input object.
% Optional:
%  loader   -- instance of registerted faccess loader (see sqw_formats_factory)
%              to use to save data.
%              if w is an array, array or cellarray of loaders have to be
%              provided, one per each element of w.
%              May be used to save data in old file formats. Be careful, as
%              this options doe not support many features of new file
%              formats.

% Modifiers:
% '-assume_written'  -- Affects only filebacked sqw objects. Ignored for any
%                       other type of input object. Requests new file name
%                       being defined.
%                       If provided, assumes that the information in memory
%                       is the same as the information in file and the
%                       backing file needs to be moved to new location.
% '-make_temporary'  -- Affects only sqw objects and works in situations where
%                       output object is returned. Normally, if you save sqw
%                       object with extension '.tmp' save returns
%                       temporary sqw object, i.e. the object with the file,
%                       get deleted when object goes out of scope. With
%                       this option, any saved sqw object becomes temporary
%                       regardless of its extension.
%
%
% Optional output:
% wout -- filebacked sqw object with new filename if filename was provided
%
%
%  NOTE:
% 1) if w is an array of sqw objects then file must be a cell
%    array of filenames of the same size.
% 2) If save is used for filebacked sqw objects backed by tmp files it is
%    equivalent to moving the backing file to a file with new name.
%

% Original author: T.G.Perring
%
options = {'-assume_written','-make_temporary'};
[ok,mess,assume_written,make_tmp,argi] = parse_char_options(varargin,options);
if ~ok
    error('HORACE:sqw:invalid_argument',mess);
end
return_result = nargout>0;
if make_tmp && ~return_result && isa(w,'sqw')
    error('HORACE:sqw:invalid_argument', ...
        ['If you use "-make_temporary" option, you need to return output object(s).\n' ...
        ' The file saved with this option gets deleted immediately after its object goes out of scope']);
end
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

if isfile(filename)
    if ~w.is_filebacked || ~(w.is_filebacked && strcmp(w.pix.full_filename,filename))
        % target file present and not the file I use for this object
        delete(filename);
        ldw = ldw.init(w,filename);
    else % source filebacked and the target file is filebacked same file.
        lde = sqw_formats_factory.instance().get_loader(filename);
        if lde.faccess_version == ldw.faccess_version
            ldw = lde.reopen_to_write();
        else
            ldw = lde.upgrade_file_format();
        end
        w.full_filename = filename;
    end
else
    if ~w.is_filebacked
        ldw = ldw.init(w,filename);
    end
end
%
if w.is_filebacked
    w.pix = w.pix.deactivate();
    movefile(w.pix.full_filename,filename,'f');
    ldw = ldw.init(filename);
    w.full_filename = filename;
    ldw = ldw.put_new_blocks_values(w,'-exclude',{'pix_data'});
else
    ldw = ldw.put_sqw();
end
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
        filenames = {filenames};
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
            filenames = {filenames};
            argi = varargin;
        end
    else % found one
        filenames = varargin{is_fn};
        if iscell(filenames)
            if numel(filenames) ~= num_to_save
                error('HORACE:sqw:invalid_argument', ...
                    ['Saving %d object requests providing cellarray of %d filenamse.\n' ...
                    ' Actually provided: %d filenames'],...
                    num_to_save,num_to_save,numel(filenames));
            end
            is_text = cellfun(@istext,filenames);
            if ~all(is_text)
                n_filename_arg = find(is_fn);
                error('HORACE:sqw:invalid_argument', ...
                    'Not all members of filenames cellarray (Argument N%d ) are the text strings. This is not supported',...
                    n_filename_arg)
            end
        else
            filenames = {filenames};
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
        n_arg = find(~is_fn);
        error('HORACE:sqw:invalid_argument', ...
            ['Not every file-accessor provided as input (Argument N%d) is ' ...
            'child of horace_binfile_interface (faccess loader).' ...
            ' This is not supported'], ...
            n_arg)
    end
    if numel(ldw) ~= num_to_save
        error('HORACE:sqw:invalid_argument', ...
            'Saving %d sqw objects requests the same number of loaders. Proived %d',...
            num_to_save,numel(ldw));
    end
else
    error('HORACE:sqw:invalid_argument', ...
        'Unable to use class "%s" as faccess-or for sqw data',...
        class(ldw))
end
