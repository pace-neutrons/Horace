function wout = save(w, varargin)
% Save a sqw or dnd object or array of sqw/dnd objects to a binary sqw file
% of recommended file-format version.
%
%  >> save (w)              % prompt for file
%  >> save (w, file)        % save to file with the name provided
%  >> save (w, file,varargin)
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
% '-assume_updated'  -- Affects only filebacked sqw objects. Ignored for any
%                       other type of input object. Requests new file name
%                       being defined.
%                       If provided, assumes that the information in memory
%                       is the same as the information in file and the
%                       backing file just needs to be moved to a new location.
% '-make_temporary'  -- Affects only sqw objects and works in situations where
%                       output object is returned. Normally, if you save sqw
%                       object with extension '.tmpXXXX' save returns
%                       temporary sqw object, i.e. the object with the file,
%                       get deleted when object goes out of scope. With
%                       this option, any saved sqw object becomes temporary
%                       regardless of its extension.
% '-update'          -- Opposite '-assume_updated' and intended mainly for
%                       filebacked objects but would also work
%                       for memory based object with filename defined for
%                       PixelData. Ignores input "file" property if one is
%                       provided. Drops the contents of the memory-part of
%                       the filebacked object into the file which backs the
%                       object. Pixel part remains untouched for filebacked
%                       object. If used with memory-based object writes
%                       whole object contents into the file with name
%                       defined for PixelData.
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
% Fully rewritten on 31/12/2023 for PACE project.
%
options = {'-assume_updated','-make_temporary','-update'};
[ok,mess,assume_updated,make_tmp,update,argi] = parse_char_options(varargin,options);
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

[filenames,ldw]  = parse_additional_args(w,num_to_save,update,argi{:});


if num_to_save > 1
    if return_result
        wout = repmat(w(1),size(w));
    else
        wout = zeros(size(w));
    end
    for i=1:num_to_save
        wout(i) = save_one(w(i),filenames{i},assume_updated,return_result,ldw{i});
    end
else
    wout = save_one(w,filenames{1},assume_updated,return_result,ldw{1});
end
%==========================================================================
function wout = save_one(w,filename,assume_written,return_result,ldw,varargin)
% save single sqw object
%
wout = []; % Target sqw object
if return_result
    [~,~,fe] = fileparts(filename);
    target_is_tmp = strncmp(fe,'.tmp',4);
else
    target_is_tmp = false;
end

ll = get(hor_config,'log_level');

% Write data to file   x
if ll>0
    disp(['*** Writing to: ',filename,'...'])
end

if isfile(filename)
    if w.is_filebacked && strcmp(w.pix.full_filename,filename)
        % we are writing in the same file as the backing file
        if w.pix.old_file_format
            wout = upgrade_file_calc_ranges(w,return_result,ll,filename);
            return;
        else
            if ~assume_written
                ldw = ldw.init(filename);
                % store everything except pixels data.
                ldw = ldw.put_new_blocks_values(w);
                ldw.delete();
            end
            wout = w;
            return;
        end
    else % writing to different file
        delete(filename);
    end
end
%
if w.is_filebacked && w.is_tmp_obj && return_result
    if w.pix.old_file_format
        wout = upgrade_file_calc_ranges(w,return_result,ll,filename);
        return;
    end
    w = w.deactivate();
    del_memmapfile_files(filename);
    movefile(w.pix.full_filename,filename,'f');
    ldw = ldw.init(filename);
    if target_is_tmp
        w.pix.full_filename = filename;
    else
        w.full_filename = filename;
    end
    if assume_written
        % store only blocks which contain changed file name.
        ldw.put_new_blocks_values(w,'update', ...
            {'bl__main_header','bl_data_metadata','bl_pix_metadata'});
    else
        % update all blocks except pixels
        ldw = ldw.put_new_blocks_values(w);
    end
else
    ldw = ldw.init(w,filename);
    ldw = ldw.put_sqw();
end
%
if return_result
    if isa(w,'sqw')
        wout = sqw(ldw,'file_backed',true);
        if target_is_tmp
            wout = wout.set_as_tmp_obj();
        end
    else % dnd object never filebacked so just return it.
        wout = w;
    end
end
ldw.delete();
%==========================================================================
function w = upgrade_file_calc_ranges(w,return_result,log_level,filename)
% upgrade file format to new and recalculate averages and
% ranges. Save result in temporary file.
if log_level > 0
    fprintf(2,[ '\n', ...
        '*** Upgrading source SQW file %s into new file format\n', ...
        '    and storing result of the operation in file %s\n',...
        '    This is one-off upgrade operation which calculates all averages,\n'...
        '    requested for new-format sqw files.\n'
        ], ...
        w.pix.full_filename,filename);
end
pix_op = PageOp_recompute_bins();
pix_op.outfile =filename;
pix_op = pix_op.init(w);
pix_op.init_filebacked_output = return_result;
w    = sqw.apply_op(w,pix_op);

%
function [filenames,ldw] = parse_additional_args(w,num_to_save,update,varargin)
% parse inputsd for filenames and loaders provided as input of save method.
% fill default or ask user if some are missing.
%

if numel(varargin) == 0
    if update %
        filenames = extract_filenames_for_update(w,num_to_save);
    else
        % Get file name - prompting if necessary
        filenames = ask_for_filename_if_possible(num_to_save);
    end
    argi = {};
else % numel(varargin) > 0
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
        if update %
            filenames = extract_filenames_for_update(w,num_to_save);
        else
            filenames = ask_for_filename_if_possible(num_to_save);
        end
        argi = varargin;
    else % found one
        filenames      = varargin{is_fn};
        n_filename_arg = find(is_fn);
        filenames = check_filenames_provided(num_to_save,n_filename_arg,filenames);
        if update
            filenames = extract_filenames_for_update(w,num_to_save,filenames);
        end
        argi      = varargin(~is_fn);
    end
end
%=== find loaders/savers for filenames:
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

function filenames = check_filenames_provided(num_to_save,n_filename_arg,filenames)
% if input parameter is identified as filename or list of filenames check
% if it indeed can be treated as filename of list of filenames
% Return cellarray of string which may be used as filenames.
%
if iscell(filenames)
    if numel(filenames) ~= num_to_save
        error('HORACE:sqw:invalid_argument', ...
            ['Saving %d object requests providing cellarray of %d filenamse.\n' ...
            ' Actually provided: %d filenames'],...
            num_to_save,num_to_save,numel(filenames));
    end
    is_text = cellfun(@istext,filenames);
    if ~all(is_text)
        error('HORACE:sqw:invalid_argument', ...
            'Not all members of filenames cellarray (Argument N%d ) are the text strings. This is not supported',...
            n_filename_arg)
    end
else
    filenames = {filenames};
end

%
function filenames = ask_for_filename_if_possible(num_to_save)
% if possible, ask user for filename to save the result.
%
% Throw 'HORACE:sqw:invalid_argument' if more then one object intended for
% saving and no filenames was provided for all of them.
%
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
end
%
function filenames = extract_filenames_for_update(w,num_to_save,optional_filenames)
% If update option is provided extract necessary filename to save object
% from the objects themselves using optional_filenames in case of
% non-filebacked objects.
%
if nargin <3
    optional_filenames = [];
end

filenames = cell(1,num_to_save);
for i=1:numel(w)
    if w(i).is_filebacked
        if isempty(optional_filenames)
            filenames{i} = w(i).pix.full_filename;
        else
            filenames{i} = optional_filenames{i};
        end
    else
        if isempty(optional_filenames)
            filenames{i} = w(i).full_filename;
            if isfile(filenames{i})
                error('HORACE:sqw:invalid_argument', ...
                    ['Attempt to implicitly save non_filebacked object N%d using "-update" option to file: %s which exist.\n' ...
                    'Give this filename explicitly as input of "save" method if you want to overwrite existing file.'],...
                    i,filenames{i});
            else
                [tgdir,fp,fe] = fileparts(filenames{i});
                if isempty(tgdir)
                    hc = hor_config;
                    tgdir = hc.working_directory;
                else
                    if ~isfolder(tgdir)
                        error('HORACE:sqw:invalid_argument', ...
                            'Default folder: "%s" for saving memory-based object with "-update" key does not exist',...
                            tgdir);
                    end
                    test_dir = fullfile(tgdir,'write_test_folder');
                    clOb = onCleanup(@()rmdir(test_dir));
                    ok = mkdir(test_dir);
                    if ~ok
                        error('HORACE:sqw:invalid_argument', ...
                            'Default folder: "%s" for saving memory-based object with "-update" key is write-protected',...
                            tgdir)
                    end
                end
                filenames{i} = fullfile(tgdir,[fp,fe]);
            end
        else
            filenames{i} = optional_filenames{i};
        end
    end
end
