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
        % assertTrue( ... properties ...);
    end

end
end
