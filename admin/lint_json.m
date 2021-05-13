function lint_json(varargin)
% Use mlint, and convert to a json for easy parsing by WNG
%
% Input:
% ------
% filesin              cell array of char arrays listing filepaths/globs to parse
%                          if filesin is empty will recurse from current working directory
% outputfile           char array of filename to write output to (will overwrite)
%                          if outputfile is empty will write to stdout
%
% Keyword arguments:
% exclude              cell array of char arrays listing filepaths/globs to exclude from parsing
%

    p = inputParser;
    addOptional(p, 'filesin', {['**', filesep, '*.m']}, @iscellstr);
    addOptional(p, 'outputfile', '_screen', @ischar);
    addParameter(p, 'exclude', {}, @iscellstr);
    parse(p, varargin{:});

    filesin = p.Results.filesin;
    outputfile = p.Results.outputfile;
    exclude = p.Results.exclude;

    if strcmp(outputfile, '_screen')
        fh = 1;
    else % Open file
        fh = fopen(outputfile,'w');
        if fh == -1
            error("MATLAB:FileOpenError", "Failed to open file %s", outputfile);
        end
        cleanup = onCleanup(@()(fclose(fh)));
    end

    % Expand globbing to file objects
    flist = cellfun(@(x)(dir(x)), filesin, 'UniformOutput', false);
    % Flatten array
    flist = vertcat(flist{:});
    % Filter doc files
    flist = filter_list(flist, @(x)(startsWith(x.name,'doc_')));
    % Convert to filepaths
    flist = arrayfun(@(file)(fullfile(file.folder, file.name)), flist, 'UniformOutput', false);

    % Same for exclusion (no filter step)
    excl = cellfun(@(x)(dir(x)), exclude, 'UniformOutput', false);
    excl = arrayfun(@(file)(fullfile(file.folder, file.name)), [excl{:}], 'UniformOutput', false);

    % Exclude
    files = setdiff(flist, excl);

    issuesList = struct('issues', {{}}, 'size', 0);
    raw = checkcode(files, '-id');
    for i = 1:numel(raw)
        for j = 1:numel(raw{i})
            curr = wng_compat(raw{i}(j), files{i});
            issuesList.issues = {issuesList.issues{:}, curr};
        end
    end

    issuesList.size = numel(issuesList.issues);
    fprintf(fh, "%s", jsonencode(issuesList));
end

function struc = wng_compat(struc, filename)
% Parse an mlint error struct into a Jenkins Warnings Next Gen compatible form
    struc = rename(struc, 'line', 'lineStart');
    struc = rename(struc, 'id', 'type');
    struc.fileName = filename;
    struc.columnStart = struc.column(1);
    struc.columnEnd = struc.column(2);
    struc = rmfield(struc,'column');
    struc = rmfield(struc,'fix');
    struc.severity = 'NORMAL';
end

function struc = rename(struc, old, new)
% Rename a structure's field 'old' to 'new'
% From: https://stackoverflow.com/questions/2733582/how-do-i-rename-a-field-in-a-structure-array-in-matlab
    [struc.(new)] = struc.(old);
    struc = rmfield(struc,old);
end

function to_filt = filter_list(to_filt, match)
% Filter a list based on match function handle
    filter = arrayfun(match, to_filt);
    if any(filter)
        filtered = to_filt(filter);
        fprintf("Skipping: %s\n", filtered.name);
        to_filt = to_filt(~filter);
    end
end
