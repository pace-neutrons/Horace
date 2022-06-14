function valid_version = is_valid_version(version_string)
% Returns true if the function argument is a valid version string
%
valid_version = false;
if ~ischar(version_string)
    return;
end
version_string = split(version_string);
version_string = version_string{1};
version_regex = '^[0-9]+\.[0-9]+\.[0-9]+(\.[0-9a-z]+|)$';
if regexp(version_string, version_regex)
    valid_version = true;
end
