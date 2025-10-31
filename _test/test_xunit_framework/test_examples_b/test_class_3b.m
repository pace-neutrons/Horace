classdef test_class_3b < TestCase
    % TestCase subclass used to provide example tests for tests of the
    % matlab_xunit function runtests.
    % It is only the name of the test class and methods that are needed, hence
    % the essentially) dummy functions.
    % See test_runtests_extensions.m for where this is used.
    properties
        fh
    end
    methods
        function self = test_class_3b(name)
            self = self@TestCase(name);
        end
        function setUp(self)
            self.fh = figure;
        end
        function tearDown(self)
            delete(self.fh);
        end
        function testColormapColumns_3b(self)
            assertEqual(size(get(self.fh, 'Colormap'), 2), 3);
        end
        function testPointer_3b(self)
            assertEqual(get(self.fh, 'Pointer'), 'arrow');
        end
    end
end
