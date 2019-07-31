classdef myTestUsingTestCase < TestCase

    properties
        fh
    end

    methods
        function self = myTestUsingTestCase(name)
            disp('*** Constructor ***')
            self = self@TestCase(name);
            disp('Constructor call')
        end

        function setUp(self)
            self.fh = figure;
        end

        function tearDown(self)
            delete(self.fh);
        end

        function testColormapColumns(self)
            disp('*** testColormapColumns')
            assertEqual(size(get(self.fh, 'Colormap'), 2), 3);
        end

        function testPointer(self)
            disp('*** testPointer')
            assertEqual(get(self.fh, 'Pointer'), 'arrow');
        end
    end
end
