function obj = init_sqw_from_file_(obj, in_struc)
% Initialize SQW from file or file loader
%

if ~isempty(in_struc.file)
    if istext(in_struc.file)
        ldr = sqw_formats_factory.instance().get_loader(in_struc.file);
    elseif isa(in_struc.file,'horace_binfile_interface')
        ldr = in_struc.file;
    else
        error('HORACE:sqw:invalid_argument',...
            ['Field "file" of init_from_file_ routine can ' ...
            'contain only filename or initialized instance of loader class.\n' ...
            ' Provided: %s'],disp2str(in_struc.file))
    end
else
    error('HORACE:sqw:invalid_argument',...
        ['init_from_file_ accepts only structure with field "file"' ...
        ' containing filename or initialized data loader class.\n Provided: %s'], ...
        disp2str(in_struc))
end

% An error is raised if the data file is identified not a SQW object
if ~ldr.sqw_type % not a valid sqw-type structure
    if ischar(in_struc.file)
        filename = in_struc.file;
    else
        filename  = ldr.full_filename;
    end
    error('HORACE:sqw:invalid_argument',...
        'Data file: %s does not contain valid sqw-type object',...
        filename);
end

in_struc.sqw_struc = true;
in_struc.legacy = true;
[sqw_struc,ldr] = ldr.get_sqw(in_struc);
sqw_struc.pix.full_filename = ldr.full_filename;
%
obj = init_from_loader_struct_(obj, sqw_struc);
ldr.delete();
end
