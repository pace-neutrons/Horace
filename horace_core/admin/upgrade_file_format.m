function sqw_list = upgrade_file_format(filenames,varargin)
% Helper function to update sqw file(s) into new file format version,
% calculating all necessary averages present in the new file format.
%
% The file format is upgraded from any previous version into current
% version
%
% Input:
% filenames -- filename or cellarray of filenames, describing full path to
%              binary sqw files or mat files to upgrade
%
% '-upgrade_range'
%           -- if the pixel data range is not defined, recalculate
%               and store this range with new file format
% Result:
% The file format of the provided files is updated to version 4
% (currently recent)
% If requested, returns list of processed sqw objects (may be filebacked)

[ok,mess,upgrade_ranges] = parse_char_options(varargin,'-upgrade_range');
if ~ok
    error('HORACE:admin:invalid_argument',mess)
end

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
if nargout > 0
    sqw_list = cell(1,n_inputs);
end
for i=1:n_inputs
    if is_sqw(i)
        ld = sqw_formats_factory.instance().get_loader(filenames{i});
        if isa(ld,'faccess_sqw_v4') && upgrade_ranges %
            if nargout > 1
                sqw_list{i} = finalize_alignment(ld);
            else
                finalize_alignment(ld);   % Will do nothing if the file is not aligned && ranges are valid
            end
        else
            ld_new  = ld.upgrade_file_format();
            if upgrade_ranges
                sqw_tmp = sqw(ld_new,'file_backed',true);
                sqw_tmp = sqw_tmp.finalize_alignment();
            else
                sqw_tmp  = [];
            end
            if nargout > 0
                if isempty(sqw_tmp)
                    sqw_tmp = sqw(ld_new,'file_backed',true);
                end
                sqw_list{i} = sqw_tmp;
            end
            ld_new.delete();
        end
        ld.delete();
    else
        try
            ld = load(filenames{i});
        catch ME
            error('HORACE:upgrade_file_format:invalid_argument',...
                'Can not load file: %s\n Reason: %s',ME.message);
        end
        save(filenames{i},'-struct','ld');
        if nargout>0
            sqw_list{i} = ld;
        end

    end
end

function is = is_sqw_extension(fn)
[~,~,fe] = fileparts(fn);
is = strcmp(fe,'.sqw');
