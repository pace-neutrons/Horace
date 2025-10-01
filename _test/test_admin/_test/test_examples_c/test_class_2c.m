classdef test_class_2c < TestCase
    properties
        fh
    end
    methods
        function self = test_class_2c(name)
            self = self@TestCase(name);
        end
        function setUp(self)
            self.fh = figure;
        end
        function tearDown(self)
            delete(self.fh);
        end
        function testColormapColumns_2c(self)
            assertEqual(size(get(self.fh, 'Colormap'), 2), 3);
        end
        function testPointer_2c(self)
            assertEqual(get(self.fh, 'Pointer'), 'arrow');
        end
    end
end
