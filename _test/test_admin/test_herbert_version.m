classdef test_herbert_version < TestCase

properties
    VERSION_REGEX = '[0-9]\.[0-9]\.[0-9](\.[0-9a-z]+|)';
end

methods 
    function obj = test_herbert_version(varargin)
        if nargin == 0
            name = 'test_herbert_version';            
        else
            name = varargin{1};            
        end
        obj = obj@TestCase(name);
    end
    function obj = test_full_version_string_returned_if_nargout_is_1(obj)
        version_string = herbert_version();
        match_start = regexp(version_string, obj.VERSION_REGEX, 'ONCE');
        assertFalse(isempty(match_start));
    end
    
    function obj = test_major_minor_and_patch_returned_if_nargout_is_3(obj)
        version_string = herbert_version();
        numbers = split(version_string, '.');
        [major, minor, vpatch] = herbert_version();
        assertEqual(major, numbers{1});
        assertEqual(minor, numbers{2});
        assertEqual(vpatch, numbers{3});
    end
end

end
