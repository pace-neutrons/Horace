classdef myTestWithSave2_2 < TestCaseWithSave2

    properties
        fh
    end

    methods
       function self = myTestWithSave2_2(name)
            self@TestCaseWithSave2(name);
            %self = self@TestCaseWithSave2;
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
            disp('--------------------------------------------')
            disp('testing: testColormapColumns')
            nog.sz1 = size(get(self.fh, 'Colormap'), 2);
            assertEqual(nog.sz1, 3);
            nog.sz1=2*nog.sz1;
            assertEqualToTolWithSave(self,nog)
%             if ~self.save_output
%                 disp('=============================')
%                 disp('=============================')
%                 disp('=============================')
%                 disp('=============================')
%             end
            disp('--------------------------------------------')
        end

        function testPointer(self)
            disp('--------------------------------------------')
            disp('testing: testPointer')
            pointer_type=get(self.fh, 'Pointer');
            pointer_type='Barf';
            assertEqual(pointer_type, 'arrow');
            %assertEqualToTolWithSave(self,pointer_type)
            disp('--------------------------------------------')
        end
        
        function testPointer2(self)
            disp('--------------------------------------------')
            disp('testing: testPointer2')
            pointer_type=get(self.fh, 'Pointer');
            pointer_type='HaHa!';
            assertEqualWithSave(self,pointer_type)
            disp('--------------------------------------------')
        end
        
        function testPointer3(self)
            disp('--------------------------------------------')
            disp('testing: testPointer3')
            boggle(self)
            disp('--------------------------------------------')
        end
        
        function boggle(self)
            pointer_type=get(self.fh, 'Pointer');
            assertEqualWithSave(self,pointer_type)
        end
        
    end
end
