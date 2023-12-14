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
upgrade = upgrade||update;

if numel(argi) == 0
    filenames = '';
else
    filenames = argi{1};
    argi      = argi(2:end);
end

if numel(w)>1 % We do not want to manually provide filename for every file to save
    % cellarray of filenames have to be provided to save multiple files
    if isempty(filenames)
        error('HORACE:sqw:invalid_argument',...
            'If you want to save array of sqw files, you need to provide cellarray of filenames to save');
    end
    if numel(filenames) ~= numel(w)
        error('HORACE:sqw:invalid_argument',...
            'Number of data objects in array to save does not match number of file names')
    end
    for i=1:numel(w)
        cl = save_one(w(i),filenames{i},upgrade,argi{:});
    end
else
    cl = save_one(w,filenames,upgrade,argi{:});
end


function cl = save_one(w,filename,upgrade,varargin)
cl = []; % parallel cluster used to combine and save. Not tested, not used

% Get file name - prompting if necessary
[file_internal,mess]=putfile_horace(filename);
if ~isempty(mess)
    error('HORACE:sqw:invalid_argument',mess)
end

if ~isempty(varargin)
    if isa(varargin{1},'horace_binfile_interface') % specific loader provided
        ldw  = varargin{1};
        argi = varargin(2:end);
        if upgrade % we do not want to support upgrade to previous faccess versions
            error('HORACE:sqw:invalid_argument',...
                'specific loader and option "-upgrade" can not be used together');
        end
    else
        ldw = [];
        argi = varargin;
    end
else
    ldw = [];
    argi = {};
end


hor_log_level = get(hor_config,'log_level');
sqw_type = isa(w,'sqw');

% Write data to file   x
if hor_log_level>0
    disp(['*** Writing to: ',file_internal,'...'])
end

if upgrade
    if isfile(file_internal)
        error('HORACE:sqw:not_implemented',...
            'Update mode has not been yet implemented. See Re #1186');

        ldw = sqw_formats_factory.instance().get_loader(file_internal);
        if sqw_type && ldw.sqw_type
            if ldw.npixels ~= w.npixels
                error('HORACE:sqw:invalid_argument',[...
                    ' Upgrade makes sence only for the files with identical pixels .\n' ...
                    ' file: "%s" contains: %d pixels and upgrade object has: %d\n'
                    ' Its your responsibility to ensure the pixels for source and upgrade are the same'], ...
                    file_internal,ldw.num_pixels,w.npixels);
            end
        end
        ldw = ldw.upgrade_file_format();
        ldw = ldw.put_sqw(w,'-update','-nopix');
        ldw.delete();
        return;
    else
        wargning('HORACE:missing_file',[...
            'Upgrade for file: %s requested but the file does not exist.\n' ...
            ' Saving provided sqw object into the file'])
        ldw = sqw_formats_factory.instance().get_pref_access(w);
    end
else
    if isfile(file_internal)
        delete(file_internal);
    end
    if isempty(ldw)
        ldw = sqw_formats_factory.instance().get_pref_access(w);
    end
    % pixels should always have actual filename
    if w.has_pixels
        w.pix.full_filename = file_internal;
    end
    ldw = ldw.init(w,file_internal);
end

if sqw_type  % Actually, can be removed, as put_sqw for dnd does put dnd for faccess_dnd
    % only the possible issue that is currently put_dnd and put_sqw do not
    % accept the same key set. Should it be reconciled?
    ldw = ldw.put_sqw(argi{:});
else
    ldw = ldw.put_dnd();
end

ldw.delete();

