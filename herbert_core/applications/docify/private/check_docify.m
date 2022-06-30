function out = check_docify(topic)
    % Checks if a topic contains docify directives and returns mfile name
    out = [];
    % Uses internal Matlab functions to resolve the topic to a file
    resolver = matlab.internal.language.introspective.resolveName( ...
        topic, '', false, [], false);
    if isempty(resolver.nameLocation)
        resolver = matlab.internal.language.introspective.resolveName( ...
            regexprep(topic, '\.', '/'), '', false, [], false);
        if isempty(resolver.nameLocation) || ~exist(resolver.nameLocation, 'file')
            return
        end
    end
    filepath = resolver.nameLocation;
    % Skip if 'Herbert' or 'Horace' not in the full file name to save lots of reading
    if ~contains(lower(filepath), 'herbert') && ...
       ~contains(lower(filepath), 'horace'), return; end
    fid = fopen(filepath);
    mfiletxt = fread(fid, '*char')';
    fclose(fid);
    % Check for docify tags
    if contains(mfiletxt, '<#doc_')
        out = filepath;
    end
end
