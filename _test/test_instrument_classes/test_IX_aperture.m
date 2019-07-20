classdef test_IX_aperture < TestCaseWithSave
    % Test of IX_aperture
    
    methods
        %--------------------------------------------------------------------------
        function self = test_IX_aperture (name)
            self@TestCaseWithSave(name);
            
            self.save()
        end
        
        %--------------------------------------------------------------------------
        function test_1 (self)
            ap = IX_aperture (12,0.1,0.06);
            assertEqualWithSave (self,ap);            
        end
        
        %--------------------------------------------------------------------------
        function test_2 (self)
            ap = IX_aperture (12,0.1,0.06,'-name','in-pile');
            assertEqualWithSave (self,ap);            
        end
        
        %--------------------------------------------------------------------------
        function test_3 (self)
            ap = IX_aperture ('in-pile',12,0.1,0.06);
            assertEqualWithSave (self,ap);            
        end
        
        %--------------------------------------------------------------------------
        function test_cov (self)
            ap = IX_aperture ('in-pile',12,0.1,0.06);
            cov = ap.covariance();
            assertEqualToTol(cov, [0.1^2,0;0,0.06^2]/12, 'tol', 1e-12);
            
        end
        
        %--------------------------------------------------------------------------
        function test_pdf (self)
            ap = IX_aperture ('in-pile',12,0.1,0.06);
            
            npnt = 4e7;
            X = rand (ap, 1, npnt);
            stdev = std(X,1,2);
            assertEqualToTol(stdev.^2, [0.1^2;0.06^2]/12, 'reltol', 1e-3);
        end
        
        %--------------------------------------------------------------------------
    end
end

