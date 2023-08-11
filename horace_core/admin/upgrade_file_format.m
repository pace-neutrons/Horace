function upgrade_file_format(filenames,varargin)
% Helper function to update sqw file(s) into new file format version,
% calculating all necessary averages present in the new file format.
%
% The file format is upgraded from any previous version into current
% version
%
% Input:
% filenames -- filename or list of filenames, describing full path to
%              binary sqw files or mat files to upgrade
%
%
% Result:
% The file format of the provided files is updated to version 4
% (currently recent)
if istext(filenames)
    filenames = cellstr(filenames);
end
n_inputs = numel(filenames);
is_file = cellfun(@isfile,filenames);
if ~all(is_file)
    non_files = filenames(~is_file);
    error('HORACE:upgrade_file_format:invalid_argument', ...
        'Can not find or identify files: %s', ...
        disp2str(non_files))
end
is_sqw = cellfun(@is_sqw_extension,filenames);
%
for i=1:n_inputs
    if is_sqw(i)
        ld = sqw_format_factory.instance().get_loader(filenames{i});
        ld_new = ld.upgrade_file_format();
        ld_new.delete();
    else
        try
            ld = load(filenames{i});
        catch ME
            error('HORACE:upgrade_file_format:invalid_argument',...
                'Can not load file: %s\n Reason: %s',ME.message);
        end
        save(filenames{i},'-struct','ld');
    end
end

function is = is_sqw_extension(fn)
[~,~,fe] = fileparts(fn);
is = strcmp(fe,'.sqw');
