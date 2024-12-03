function out = check_docify(topic)
    persistent isR2023
    if isempty(isR2023)
        isR2023 = isMATLABReleaseOlderThan('R2024a');
    end
    if isR2023
        resolveName = @(topic) matlab.internal.language.introspective.resolveName(topic, '', false, [], false);
    else
        resolveName = @matlab.lang.internal.introspective.resolveName;
    end
    % Checks if a topic contains docify directives and returns mfile name
    out = [];
    % Uses internal Matlab functions to resolve the topic to a file
    resolver = resolveName(topic);
    if isempty(resolver.nameLocation)
        resolver = resolveName(regexprep(topic, '\.', '/'));
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
