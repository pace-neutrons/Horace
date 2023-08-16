function msln_files_list = upgrade_file_format(filenames,varargin)
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
% Returns:
% msln_files_list -- cellarray of files, which are legacy aligned and
%                    should be realigned first

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
msln_files_list = {};
for i=1:n_inputs
    if is_sqw(i)
        ld = sqw_formats_factory.instance().get_loader(filenames{i});
        [exp,ld] = ld.get_exp_info();
        hav = exp.header_average;
        if isfield(hav,'u_to_rlu') % legacy aligned file
            msln_files_list{end+1} = filenames{i};
            warning('HORACE:legacy_alignment', ...
                ['file %s contains legacy-aligned data.\n' ...
                ' Realign them using "upgrade_legacy_alignment" routine first'], ...
                filenames{i});
            ld.delete();
            continue;
        end
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
