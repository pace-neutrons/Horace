classdef test_IX_detectors_2 < TestCaseWithSave
    % Test the calculation of quantities for a detector object
    properties
        dia
        height
        thick
        atms
        path
    end
    
    methods
        %--------------------------------------------------------------------------
        function self = test_IX_detectors_2 (name)
            self@TestCaseWithSave(name);
            
            % Arrays for construction of detectors
            dia(1) = 0.0254;  height(1) = 0.015; thick(1) = 6.35e-4; atms(1) = 10; th(1) = pi/2;
            dia(2) = 0.0300;  height(2) = 0.025; thick(2) = 10.0e-4; atms(2) = 6;  th(2) = 0.9;
            dia(3) = 0.0400;  height(3) = 0.035; thick(3) = 15.0e-4; atms(3) = 4;  th(3) = 0.775;
            dia(4) = 0.0400;  height(4) = 0.035; thick(4) = 15.0e-4; atms(4) = 7;  th(4) = 0.775;
            dia(5) = 0.0400;  height(5) = 0.035; thick(5) = 15.0e-4; atms(5) = 9;  th(5) = 0.775;
            
            self.dia = dia;
            self.height = height;
            self.thick = thick;
            self.atms = atms;
            self.path = [sin(th); zeros(size(th)); cos(th)];
            
            self.save()
        end
        
        %--------------------------------------------------------------------------
        function test_det_constructor (self)
            [ndet,ndet_arr] = construct_detectors (self);
            assertEqualWithSave(self,ndet)
            assertEqualWithSave(self,ndet_arr)
        end
        
        %--------------------------------------------------------------------------
        function test_effic (self)
            [ndet,ndet_arr] = construct_detectors (self);
            wvec = 10;
            
            neff_arr = ndet_arr.effic (self.path, wvec);
            for i=1:5
                neff(i)   = ndet(i).effic(self.path(:,i), wvec);
            end
            
            assertEqualToTol(neff,neff_arr,'tol',[1e-13,1e-13])
            assertEqualToTolWithSave(self,neff_arr,'tol',[1e-13,1e-13])
        end
        
        %--------------------------------------------------------------------------
        function test_mean (self)
            [ndet,ndet_arr] = construct_detectors (self);
            wvec = 10;
            
            nmean_d_arr = ndet_arr.mean_d (self.path, wvec);
            for i=1:5
                nmean_d(i)= ndet(i).mean_d(self.path(:,i), wvec);
            end
            
            assertEqualToTol(nmean_d,nmean_d_arr,'tol',[1e-13,1e-13])
            assertEqualToTolWithSave(self,nmean_d_arr,'tol',[1e-13,1e-13])
        end
        
        %--------------------------------------------------------------------------
        function test_var_d (self)
            [ndet,ndet_arr] = construct_detectors (self);
            wvec = 10;
            
            nvar_d_arr = ndet_arr.var_d (self.path, wvec);
            for i=1:5
                nvar_d(i)   = ndet(i).var_d(self.path(:,i), wvec);
            end
            
            assertEqualToTol(nvar_d,nvar_d_arr,'tol',[1e-13,1e-13])
            assertEqualToTolWithSave(self,nvar_d_arr,'tol',[1e-13,1e-13])
        end
        
        %--------------------------------------------------------------------------
        function test_var_w (self)
            [ndet,ndet_arr] = construct_detectors (self);
            wvec = 10;
            
            nvar_y_arr = ndet_arr.var_y (self.path, wvec);
            for i=1:5
                nvar_y(i)   = ndet(i).var_y(self.path(:,i), wvec);
            end
            
            assertEqualToTol(nvar_y,nvar_y_arr,'tol',[1e-13,1e-13])
            assertEqualToTolWithSave(self,nvar_y_arr,'tol',[1e-13,1e-13])
        end
        
        %--------------------------------------------------------------------------
        % Utility methods
        %--------------------------------------------------------------------------
        function [ndet,ndet_arr] = construct_detectors (self)
            for i=1:5
                ndet(i) = IX_det_He3tube (self.dia(i), self.height(i), self.thick(i), self.atms(i));
            end
            ndet_arr = IX_det_He3tube (self.dia, self.height, self.thick, self.atms);
            
        end
        
        %--------------------------------------------------------------------------
    end
    
    
end
