classdef test_IX_divergence_profile < TestCaseWithSave
    % Test of IX_divergence_profile
    
    properties
        ang
        y
    end
    
    methods
        %--------------------------------------------------------------------------
        function self = test_IX_divergence_profile (name)
            self@TestCaseWithSave(name);
            
            self.ang = -0.5:0.1:0.5;
            self.y = [0.8662    0.8814    0.0385    0.3429    0.0385    0.1096...
                0.6027    0.7396    0.3152    0.9257    0.5347];
            
            self.save()
        end
        
        %--------------------------------------------------------------------------
        function test_1 (self)
            div = IX_divergence_profile (self.ang, self.y);
            assertEqualWithSave (self,div);            
        end
        
        %--------------------------------------------------------------------------
        function test_2 (self)
            div = IX_divergence_profile (self.ang,'-name','in-pile','-profile',self.y);
            assertEqualWithSave (self,div);            
        end
        
        %--------------------------------------------------------------------------
        function test_3 (self)
            div = IX_divergence_profile ('in-pile',self.ang, self.y);
            assertEqualWithSave (self,div);            
        end
        
        %--------------------------------------------------------------------------
        function test_4 (self)
            ytmp = self.y;
            ytmp(3) = -0.1;
            try
                div = IX_divergence_profile ('in-pile',self.ang, ytmp);
                failed = false;
            catch
                failed = true;
            end
            assertTrue (failed);            
        end
        
        %--------------------------------------------------------------------------
    end
end

