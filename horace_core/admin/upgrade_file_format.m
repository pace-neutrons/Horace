function msln_files_list = upgrade_file_format(filenames,varargin)
% Helper function to update sqw file(s) into new file format version,
% calculating all necessary averages present in the new file format.
%
% The file format is upgraded from any previous version into current
% version
%
% Input:
% filenames -- filename or cellarray of filenames, describing full path to
%              binary sqw files or mat files to upgrade
% Optional:
% alatt     -- 3-component vector of original lattice parameters, originaly
%              present in legacy aligned file and modified later or
%              cellarray of such vectors with vector for each file
% angdeg    -- 3-component vector of original lattice angles, originaly
%              present in legacy aligned file and modified later or
%              cellarray of such vectors with vector for each file
%
% Result:
% The file format of the provided files is updated to version 4
% (currently recent)
% Returns:
% msln_files_list -- cellarray of files, which are legacy aligned and
%                    should be realigned first

msln_files_list = {};

if istext(filenames)
    filenames = cellstr(filenames);
end
if nargin>1
    [alatt,angdeg] = prepare_lattice(varargin{1},varargin{2},numel(filenames));
else
    alatt = {};
    angdeg = {};
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
        ld = sqw_formats_factory.instance().get_loader(filenames{i});
        if isa(ld,'faccess_sqw_v4') %
            apply_alignment(ld);   % Will do nothing if the file is not aligned
        else
            exp = ld.get_exp_info(1);
            hav = exp.header_average;
            if isfield(hav,'u_to_rlu') % legacy aligned file
                if ~isempty(alatt)
                    ld = ld.upgrade_file_format();
                    ld = upgrade_legacy_alignment(ld,alatt{i},angdeg{i});
                    ld = ld{1};
                    apply_alignment(ld);
                    continue
                else
                    msln_files_list{end+1} = filenames{i};
                    warning('HORACE:legacy_alignment', ...
                        ['file %s contains legacy-aligned data.\n' ...
                        ' Realign them using "upgrade_legacy_alignment" routine first\n' ...
                        ' or provide original lattice to this function for realigning during pugrade'], ...
                        filenames{i});
                    ld.delete();
                    continue;
                end
            end
            ld_new = ld.upgrade_file_format();
            ld_new.delete();
        end
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

function  [alatt,angdeg] = prepare_lattice(alatt,angdeg,nfiles)
if iscell(alatt)
    if numel(alatt) == nfiles &&  iscell(angdeg)&& numel(angdeg) == nfiles
        return;
    else
        error('HORACE:admin:upgrade_file_format', ...
            'if you provide lattice parameters in the form of cellarray, the number of elements in this celarray have to be equal to the number of files to upgrade')
    end
end
if ~(isnumeric(alatt) && isvector(alatt)&&numel(alatt)==3) ...
        || ~(isnumeric(angdeg) && isvector(angdeg)&&numel(angdeg)==3)
    error('HORACE:admin:upgrade_file_format', ...
        'single alatt and angdeg have to be 3-element vectors');
end
ii = 1:nfiles;
alatt = arrayfun(@(x)(alatt),ii,'UniformOutput',false);
angdeg = arrayfun(@(x)(angdeg),ii,'UniformOutput',false);

function is = is_sqw_extension(fn)
[~,~,fe] = fileparts(fn);
is = strcmp(fe,'.sqw');
