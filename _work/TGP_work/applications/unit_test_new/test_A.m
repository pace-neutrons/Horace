classdef test_A < TestCaseWithSave
    % Test of basic properties of a test suite with save
    
    properties
        fh
    end
    
    methods
        function self = test_A(name)
            self@TestCaseWithSave(name);
            disp('-----------------------------------------------------')
            disp('Constructor call')
            disp('-----------------------------------------------------')
            self.save()
        end
        
        function setUp(self)
            disp('-----------------------------------------------------')
            disp('Setup')
            self.fh = figure;
        end
        
        function tearDown(self)
            disp('Teardown')
            delete(self.fh);
            disp('-----------------------------------------------------')
        end
        
        function testColormapColumns(self)
            disp(['testing: testColormapColumns'])
            sz = size(get(self.fh, 'Colormap'), 2);
            assertEqualToTolWithSave(self,sz)
        end
        
        function testPointer(self)
            disp(['testing: testPointer'])
            pointer_type=get(self.fh, 'Pointer');
            assertEqualToTolWithSave(self,pointer_type)
        end
        
        function testToolbar(self)
            disp(['testing: testPointer'])
            type = get(self.fh, 'Type');
            toolbar_type=get(self.fh, 'ToolBar');
            assertEqual(type,'figure')
            assertEqualToTolWithSave(self,toolbar_type)
        end
        
    end
end
