classdef myTestWithSave2 < TestCaseWithSave

    properties
        fh
    end

    methods
       function self = myTestWithSave2(name)
            self@TestCaseWithSave(name);
%            self = self@TestCaseWithSave(name);
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
            disp('testing: testColormapColumns')
            sz1 = size(get(self.fh, 'Colormap'), 2);
            assertEqual(sz1, 3);
            sz1=2*sz1;
            assertEqualToTolWithSave(self,sz1)
            if ~self.save_output
                disp('=============================')
                disp('=============================')
                disp('=============================')
                disp('=============================')
            end
        end

        function testPointer(self)
            disp('testing: testPointer')
            pointer_type=get(self.fh, 'Pointer');
            assertEqual(pointer_type, 'arrow');
            assertEqualToTolWithSave(self,pointer_type)
        end
    end
end
