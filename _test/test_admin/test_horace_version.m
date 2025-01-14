classdef test_horace_version < TestCase

properties
    VERSION_REGEX = '[0-9]\.[0-9]\.[0-9](\.[0-9a-z]+|)';
end

methods

    function obj = test_full_version_string_returned_if_nargout_is_1(obj)
        version_string = horace_version();
        match_start = regexp(version_string, obj.VERSION_REGEX, 'ONCE');
        assertFalse(isempty(match_start));
    end

    function obj = test_major_minor_and_patch_returned_if_nargout_is_3(obj)
        version_string = horace_version();
        numbers = split(version_string, '.');
        [major, minor, vpatch] = horace_version();
        assertEqual(major, numbers{1});
        assertEqual(minor, numbers{2});
        assertEqual(vpatch, numbers{3});
    end

end

end
