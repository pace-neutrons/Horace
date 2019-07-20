classdef test_IX_doubledisk_chopper < TestCaseWithSave
    % Test of IX_divergence_profile
    
    methods
        %--------------------------------------------------------------------------
        function self = test_IX_doubledisk_chopper (name)
            self@TestCaseWithSave(name);
            
            self.save()
        end
        
        %--------------------------------------------------------------------------
        function test_1 (self)
            chop = IX_doubledisk_chopper (12,120,0.7,0.02);
            assertEqualWithSave (self,chop);            
        end
        
        %--------------------------------------------------------------------------
        function test_1a (self)
            try
                chop = IX_doubledisk_chopper (12,120,0.7);
                failed = false;
            catch
                failed = true;
            end
            assertTrue(failed);            
        end
        
        %--------------------------------------------------------------------------
        function test_2 (self)
            chop = IX_doubledisk_chopper (12,120,0.7,0.02,0.05);
            assertEqualWithSave (self,chop);            
        end
        
        %--------------------------------------------------------------------------
        function test_3 (self)
            chop = IX_doubledisk_chopper ('Chopper_1',12,120,0.7,0.02,0.05);
            assertEqualWithSave (self,chop);            
        end
        
        %--------------------------------------------------------------------------
        function test_4 (self)
            chop = IX_doubledisk_chopper (12,120,0.7,0.02,0.05,...
                '-name','Chopper_1','-aperture_h',0.2);
            assertEqualWithSave (self,chop);            
        end
        
        %--------------------------------------------------------------------------
    end
end

