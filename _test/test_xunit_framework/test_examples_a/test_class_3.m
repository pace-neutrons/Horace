classdef test_class_3 < TestCase
    properties
        fh
    end
    methods
        function self = test_class_3(name)
            self = self@TestCase(name);
        end
        function setUp(self)
            self.fh = figure;
        end
        function tearDown(self)
            delete(self.fh);
        end
        function testColormapColumns_3(self)
            assertEqual(size(get(self.fh, 'Colormap'), 2), 3);
        end
        function testPointer_3(self)
            assertEqual(get(self.fh, 'Pointer'), 'arrow');
        end
    end
end
