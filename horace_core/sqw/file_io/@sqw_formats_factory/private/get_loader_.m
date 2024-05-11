function  loader = get_loader_(obj,sqw_file_name,varargin)
% Returns initiated loader which can load the data from the specified data file.
%
%Usage:
%>>loader=loaders_factory.instance().get_loader(sqw_file_name);
%>>loader=loaders_factory.instance().get_loader(sqw_file_name,'-update');
%
% where:
%>>data_file_name  -- the name of the file, which is the source of the data
%                     or the cellarray of such names.
%                     If cellarray of the names provided, the method returns
%                     cellarray of loaders.
% Optional:
% '-update'        -- if provided, open file for read/write/update
%                     operations, unlike default opening file
%                     for read access only
%
%
% On error:      throws
% HORACE:file_io:runtime_error exception with
%                message, explaining the reason for error.
%                The errors are usually caused by missing or
%                not-recognized (non-sqw) input files.
if iscell(sqw_file_name) % process range of files
    loader = cellfun(@(x)(obj.get_loader(x)),sqw_file_name,...
        'UniformOutput',false);
    return;
end
if ~isnumeric(sqw_file_name)
    [ok,mess,full_data_name] = check_file_exist(sqw_file_name,'*');
else
    error('HORACE:file_io:runtime_error', 'filename was not numeric');
end
if ~ok
    mess = regexprep(mess,'[\\]','/');
    error('HORACE:file_io:runtime_error','get_loader: %s',mess);
end
% read initial bytes of binary file and interpret them as Horace headers to identify file format.
% Returns header block and open file handle not to open file again
[head_struc,fh] = horace_binfile_interface.get_file_header(full_data_name,varargin{:});

for i=1:numel(obj.supported_accessors_)
    loader = obj.supported_accessors_{i};
    % check if loader should load the file. Initiate loaders
    % with open file handle if loader recognizes the file format
    % as its own.
    [ok,objinit] = loader.should_load_stream(head_struc,fh);
    if ok
        % if loader can load, initialize loader to be able
        % to read the file.
        try
            loader=loader.init(objinit,varargin{:});
            return
        catch ME
            if fh>0
                try
                    fclose(fh);
                catch
                end
            end
            err = MException('HORACE:file_io:runtime_error',...
                ['get_loader: Error initializing selected loader: %s : %s\n',...
                'invalid file format or damaged file?'],...
                class(loader),ME.message);
            err = addCause(ME,err);
            rethrow(err);
        end
    end
end
% no appropriate loader found.
fclose(fh);
if strcmp(head_struc.name,'horace')
    error('HORACE:file_io:runtime_error',...
        ['get_loader: this Horace package does not support the sqw',...
        ' file version %d found in file: %s\n',...
        ' Update your Horace installation.'],...
        head_struc.version,full_data_name);
else
    error('HORACE:file_io:runtime_error',...
        ['get_loader: Existing readers can not understand format of file: %s\n',...
        ' Is it a sqw file at all?'],...
        full_data_name);
end

