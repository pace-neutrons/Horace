classdef myTestWithSave < TestCaseWithSave

    properties
        fh
    end

    methods
       function self = myTestWithSave(name)
           self = self@TestCaseWithSave(name);
%         function self = myTestWithSave(name)
%             self = self@TestCaseWithSave;
            disp('---------------------------')
            disp('Constructor call')
            disp('---------------------------')
        end

        function setUp(self)
            disp('Setup')
            self.fh = figure;
        end

        function tearDown(self)
            disp('Teardown')
            delete(self.fh);
        end

        function testColormapColumns(self)
            disp(['testing: testColormapColumns'])
            assertEqual(size(get(self.fh, 'Colormap'), 2), 3);
        end

        function testPointer(self)
            disp(['testing: testPointer'])
            assertEqual(get(self.fh, 'Pointer'), 'arrow');
        end
    end
end
