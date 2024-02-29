function wout = save(w, varargin)
% Save a sqw or dnd object or array of sqw/dnd objects to a binary sqw file
% of recommended file-format version.
%
%  >> save (w)              % prompt for file
%  >> save (w, filename)    % save to file with the name provided
%  >> save (w, filename,varargin)
%  >> wout = save(___)      % returns sqw object backed by file "filename"
%                             if you are saving any sqw object.
% provide additional save options. See below.
% Input:
%   w        -- sqw or dnd object or array of such objects.
% Optional:
%  filename  -- Filename for output. If none given, then prompted for
%               a filename to save. If w is an array you should provide:
%    either:    single string with "filename.sqw" (.sqw must be present)
%               Then numel(w) files will be wirtten with the names
%               filename_1.sqw,filename_2.sqw ... filename_n.sqw where
%               n==numel(w)
%        or:    n arguments with filenames, one filename per each object 
%               in array.
%  loader    -- instance of registered faccess loader (see
%               sqw_formats_factory) to use to save data.
%               if w is an array, array or cellarray of loaders have to be
%               provided, one per each element of w.
%               May be used to save data in old file formats. Be careful,
%               as this options does not support many features of new file
%               formats.
%
% Modifiers: RELATED TO FILEBACKED OBJECTS, no much use for memory-based
% objects. Incompatible with old file format loader provided as input.
% '-assume_updated'  -- Affects only filebacked sqw objects. Ignored for any
%                       other type of input object. Requests new file name
%                       being defined.
%                       If provided, assumes that the information in memory
%                       is the same as the information in file and the
%                       backing file just needs to be moved to a new location
%                       if any is provided. Source filebacked object becomes
%                       invalidated.
% '-update'          -- Opposite '-assume_updated' and intended mainly for
%                       filebacked objects but would also work
%                       for memory based object with filename defined in
%                       PixelData. Ignores input "filename" property if one
%                       is provided. Saves the contents of the memory-part
%                       of the filebacked object into the file which backs
%                       the object. Pixel part remains untouched for
%                       filebacked object. If used with memory-based object
%                       writes whole object contents into the file with
%                       name defined for PixelData.
% '-make_temporary'  -- Affects only sqw objects and works in situations where
%  OR                   output object is returned. Normally, if you save sqw
%  '-make_tmp'          object with extension '.tmpXXXX' save returns
%                       temporary sqw object, i.e. the object with the file,
%                       get deleted when object goes out of scope. With
%                       this option, any saved sqw object becomes temporary
%                       regardless of its extension.
% '-clear_source'    -- Used with filebacked object together with target
%                       filename, different from the name of the file,
%                       currently backing filebacked object. Moves
%                       filebacked object to new file and destroys previous
%                       filebacked object if output object is not provided
%                       for save operation, i.e.:
%                       >>save(in_obj,target_filename,'-clear') saves contents
%                       of in_obj in file target_filename and invalidates
%                       in_obj.
%                       If output object is provided, this key is ignored and
%                       is equivalent to calling:
%                       >>in_obj = save(in_obj,target_filename) operation.
%                       If operation is invoked in the form:
%                       >>out_obj = save(in_obj,target_filename), in_obj
%                       gets invalidated.
% Optional output:
% wout -- filebacked sqw object built from input sqw object based on new
%         filename if filename was provided
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
options = {'-assume_updated','-make_temporary','-make_tmp','-update','-clear_source'};
[ok,mess,assume_updated,make_tmp,make_temp,update,clear_source,argi] = ...
    parse_char_options(varargin,options);
if ~ok
    error('HORACE:sqw:invalid_argument',mess);
end
make_tmp = make_tmp || make_temp;
return_result = nargout>0;
%
if make_tmp && ~return_result && isa(w,'sqw')
    error('HORACE:sqw:invalid_argument', ...
        ['If you use "-make_temporary" option, you need to return output object(s).\n' ...
        ' The file saved with this option gets deleted immediately after its object goes out of scope']);
end
if assume_updated && update
    error('HORACE:sqw:invalid_argument', ...
        '"-assume_updated" and "-update" options can not be used together.');
end
num_to_save = numel(w);

[filenames,ldw]  = parse_additional_args(w,num_to_save,update,argi{:});


if return_result
    wout = cell(size(w));
    for i=1:num_to_save
        wout{i} = save_one(w(i),filenames{i},assume_updated,return_result,clear_source,make_tmp,ldw{i});
    end
    wout = reshape([wout{:}],size(w));
else
    for i=1:num_to_save
        save_one(w(i),filenames{i},assume_updated,return_result,clear_source,make_tmp,ldw{i});
    end
end
%==========================================================================
function wout = save_one(w,filename,assume_updated,return_result,clear_source,make_tmp,ldw,varargin)
% save single sqw object
%
wout = []; % Target sqw object
if return_result
    if make_tmp
        target_is_tmp  = true;
    else
        [~,~,fe] = fileparts(filename);
        target_is_tmp = strncmp(fe,'.tmp',4);
    end
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
            if ~assume_updated
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
if w.is_filebacked && (assume_updated || ...
        (w.is_tmp_obj && (return_result || clear_source)))
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
    if assume_updated
        % store only blocks which contain changed file name.
        ldw = ldw.put_new_blocks_values(w,'update', ...
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
% parse inputs for filenames and loaders provided as input of save method.
% fill default or ask user if some are missing.
%
% varargin here may either be empty or else contain either single filename
% for a single file or filename template for array of files or list of
% filenames one per file to save.

if numel(varargin) == 0
    if update %
        filenames = extract_filenames_for_update(w,num_to_save);
    else
        % Get file name - prompting if necessary
        filenames = ask_for_filename_if_possible(num_to_save);
    end
    argi = {};
else % numel(varargin) > 0
    [filenames,n_found,is_fname] = extract_filenames_from_inputs(num_to_save,varargin{:});
    if n_found == 0
        if update %
            filenames = extract_filenames_for_update(w,num_to_save);
        else
            filenames = ask_for_filename_if_possible(num_to_save);
        end
        argi = varargin;
    else % found some
        n_filename_arg = find(is_fname);
        filenames = check_filenames_provided(num_to_save,n_filename_arg,filenames);
        if update
            filenames = extract_filenames_for_update(w,num_to_save,filenames);
        end
        argi      = varargin(~is_fname);
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
        n_arg = find(~is_fname);
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
% The routine returns filenames to save data in case if '-update' option is
% provided as input.
%
% If update option is provided changed data should be saved within the
% existing files. For filebacked objects these files are the files backing
% the object, but for memory based objects these files may or may not exist.
%
% The routine extracts necessary filenames to save object from the filebakced
% objects themselves (the names of the backing files) using
% optional_filenames in case of non-filebacked objects.
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
            if isfile(filenames{i}) %
                % if you have memory-based object, have not provided the
                % filename to save it and use '-update' option this may be
                % a mistake. As target file will be destroyed in this case,
                % better not to allow this action at all.
                error('HORACE:sqw:invalid_argument', ...
                    ['Attempt to implicitly save non_filebacked object N%d using "-update" option to file: %s which exist.\n' ...
                    'Give this filename explicitly as input of "save" method if you want to overwrite existing file.'],...
                    i,filenames{i});
            else % let's just save memory-based object in guessed file ignoring '-update'
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

function [filenames,n_found,is_fname] = extract_filenames_from_inputs(num_to_save,varargin)
% analyse varargin which should contain one or more filenames and
% build/extract filename information from this input.
%
% Inputs:
% num_to_save  -- number of objects to save which defines the number of
%                 filenames to extract
% varargin     -- arguments to process as filenames requested. The filenames
%                 are either text, with number of components equal to number
%                 of objects to save or else a single text value ending with
%                 substring ".sqw", which will be used by suffixing numbers
%                 to make up the required number of filenames.
% Outputs:
% filenames    -- cellarray of names of files to save
% n_found      -- how many arguments have been identified as filenames
% is_fname     -- logical array of size numel(varargin) containing true in
%                 places where a filename argument has been
%                 identified.

is_fname = cellfun(@istext,varargin);
n_found  = sum(is_fname);
if n_found == 0 % may be filenames are provided as cellarray
    may_be_fnames = cellfun(@iscell,varargin);
    if any(may_be_fnames)
        fnames = varargin(may_be_fnames);
        if numel(fnames) > 1
            error('HORACE:sqw:invalid_argument', ...
                'Can not interpret any input as filename %s', ...
                disp2str(varargin));
        end
        prov_filenames = fnames{1};
        [filenames,n_found] = extract_filenames_from_inputs(num_to_save,prov_filenames{:});
        is_fname = may_be_fnames;
        return;
    end
end
if num_to_save ==  n_found
    filenames = varargin(is_fname);
else
    if n_found>1 && num_to_save == 1
        is_fname = cellfun(@(x)~isempty(regexp(x,'.sqw$','once')),varargin(is_fname));
        n_found = sum(is_fname);
    end
    if n_found == 0
        error('HORACE:sqw:invalid_argument', ...
            ['Single parameter provided for saving array of files have' ...
            ' to have form "filename.sqw".\nIt is: %s '], ...
            disp2str(varargin{1}));
    end
    if n_found == 1 && num_to_save>1
        % generate multiple filenames from filename template
        [fp,fb] = fileparts(varargin{is_fname});
        file_id = 1:num_to_save;
        filenames = arrayfun(@(nf)(fullfile(fp,sprintf('%s_%d.sqw',fb,nf))), ...
            file_id,'UniformOutput',false);
        n_found = num_to_save;
    else
        filenames = varargin(is_fname);
    end
end
if n_found ~= num_to_save
    error('HORACE:sqw:invalid_argument', ...
        'More then one input (%s) can be interpreted as filename', ...
        disp2str(filenames));
end
