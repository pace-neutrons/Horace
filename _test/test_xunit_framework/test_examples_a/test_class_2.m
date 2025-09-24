classdef test_class_2 < TestCase
    properties
        fh
    end
    methods
        function self = test_class_2(name)
            self = self@TestCase(name);
        end
        function setUp(self)
            self.fh = figure;
        end
        function tearDown(self)
            delete(self.fh);
        end
        function testColormapColumns_2(self)
            assertEqual(size(get(self.fh, 'Colormap'), 2), 3);
        end
        function testPointer_2(self)
            assertEqual(get(self.fh, 'Pointer'), 'arrow');
        end
    end
end
