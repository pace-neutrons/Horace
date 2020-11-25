classdef test_dnd_constructor < TestCase

properties
end

methods

    function obj = test_dnd_constructor(~)
        obj = obj@TestCase('test_dnd_constructor');
    end

    function test_d2d_class_follows_expected_class_heirarchy(obj)
        dnd_obj = d2d();

        assertTrue(isa(dnd_obj, 'd2d'));
        assertTrue(isa(dnd_obj, 'DnDBase'));;
        assertTrue(isa(dnd_obj, 'SQWDnDBase'));
    end

    function test_default_constructor_returns_empty_instance(obj)
        dnd_obj = d2d();

        assertTrue(isa(dnd_obj, 'd2d'));
        assertEqual(numel(dnd_obj.pax), 2);
    end

    function test_d2d_contains_expected_properties(obj)
        expected_props = { ...
            'filename', 'filepath', 'title', 'alatt', 'angdeg', ...
            'uoffset', 'u_to_rlu', 'ulen', 'ulabel', 'iax', ...
             'iint', 'pax', 'p', 'dax', 's', 'e', 'npix'};

        dnd_obj = d2d();
        actual_props = fieldnames(dnd_obj);

        assertEqual(numel(actual_props), numel(expected_props));
        for idx = 1:numel(actual_props)
            assertTrue( ...
                any(strcmp(expected_props, actual_props(idx))), ...
                sprintf('Unrecognised DnD property "%s"', actual_props{idx}));
        end
    end

    function test_d2d_get_returns_set_properties(obj)
        dnd_obj = d2d();
        class_props = fieldnames(dnd_obj);

        % properties are mapped to an internal data structure; verify the getters and
        % setters are correctly wired
        for idx = 1:numel(class_props)
            test_value = rand(10);
            prop_name = class_props{idx};
            dnd_obj.(prop_name) = test_value;
            assertEqual(dnd_obj.(prop_name), test_value, ...
                sprintf('Value set to "%s" not returned', prop_name));
        end
    end
end
end
