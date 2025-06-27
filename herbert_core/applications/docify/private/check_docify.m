function out = check_docify(topic)
% Check if function contains docify information on the topic, provided as
% input
%
    persistent lessThanR2023
    if isempty(lessThanR2023)
        try
            matlab.internal.language.introspective.resolveName('');
            lessThanR2023 = true;
        catch
            lessThanR2023 = false;
        end
    end
    if lessThanR2023
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
    % in higher Matlab versions resolver return child class name if you call
    % function defined on parent. (e.g. sqw_eval is defined on SQWDnDBase
    % but if you ask help sqw/sqw_eval resolver will correctly return name
    % as the function is defined on sqw from inheritance). 
    % To avoid error about missing file, ignore docify info in such cases
    if fid<1
        return;
    end
    mfiletxt = fread(fid, '*char')';
    fclose(fid);
    % Check for docify tags
    if contains(mfiletxt, '<#doc_')
        out = filepath;
    end
end
