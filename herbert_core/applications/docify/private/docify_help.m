function process = docify_help(topic, filepath, n_out, n_in)
    % Uses docify to generate help text in a temporary file.
    % If the help refers to a class, for the property linking to work 
    % we need it to be in an "@" folder with the correct name.
    [~, tmp_dir] = strtok(filepath, '@');
    [~, mfile] = fileparts(filepath);
    if ~isempty(tmp_dir)
        mfile = tmp_dir;
        tmp_dir = join([tempdir fileparts(tmp_dir)], '');
        mkdir(tmp_dir);
    else
        mfile = join([mfile '.m']);
    end
    output_file = join([tempdir mfile], '');
    % Next line ensures the temp file/folder is deleted on return
    rmtmp = onCleanup(@()remove_tempfile(output_file, tmp_dir));
    % Calls docify on the file
    [ok, mess, ~, has_changes, outfile] = docify_single(filepath, output_file, false);
    assert(ok, 'HERBERT:Docify:runtime_error', mess);
    if ~isempty(mess), warning(mess); end
    % Only use the docified output if there has been changes
    if has_changes
        % Uses built-in Matlab documentation functions to pretty-print docify text
        process = helpUtils.helpProcess(n_out, n_in, {outfile});
        process.getHelpText;
        process.topic = topic;
    else
        process = [];
    end
end

function remove_tempfile(filename, folder)
    if exist(filename, 'file')
        try  %#ok<TRYNC>
            delete(filename);
        end
    end
    if exist('folder', 'var') && exist(folder, 'dir')
        try  %#ok<TRYNC>
            rmdir(folder)
        end
    end
end

