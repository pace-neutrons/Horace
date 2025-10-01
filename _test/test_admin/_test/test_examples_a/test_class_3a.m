classdef test_class_3a < TestCase
    properties
        fh
    end
    methods
        function self = test_class_3a(name)
            self = self@TestCase(name);
        end
        function setUp(self)
            self.fh = figure;
        end
        function tearDown(self)
            delete(self.fh);
        end
        function testColormapColumns_3a(self)
            assertEqual(size(get(self.fh, 'Colormap'), 2), 3);
        end
        function testPointer_3a(self)
            assertEqual(get(self.fh, 'Pointer'), 'arrow');
        end
    end
end
