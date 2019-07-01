classdef test_pdf_table < TestCaseWithSave
    properties
    end
    
    methods
        %--------------------------------------------------------------------------
        function self = test_pdf_table (name)
            self@TestCaseWithSave(name);
            self.save()
        end
        
        %--------------------------------------------------------------------------
        function test_1 (self)
            % triangle function
            x = [10,12,14];
            y = [0,5,0];
            pdf_triangle = pdf_table (x,y);
            
            x_av = mean(pdf_triangle);
            assertEqualToTol (x_av,12,'reltol',1e-12);
            
        end
        
        %--------------------------------------------------------------------------
        function test_2 (self)
            % triangle function
            x = [10,12,14];
            y = [0,5,0];
            pdf_triangle = pdf_table (x,y);
            
            [x_var, x_av] = var(pdf_triangle);
            assertEqualToTol (x_av,12,'reltol',1e-12);
            assertEqualToTol (x_var,(2/3),'reltol',1e-12);
        end
            
        %--------------------------------------------------------------------------
        function test_3 (self)
            % hat function
            x = [20,20,24,24];
            y = [0,15,15,0];
            pdf_hat = pdf_table (x,y);
            
            [x_var, x_av] = var(pdf_hat);
            assertEqualToTol (x_av,22,'reltol',1e-12);
            assertEqualToTol (x_var,(4/3),'reltol',1e-12);
        end
            
        %--------------------------------------------------------------------------
        function test_4 (self)
            % hat function - again, but this time do not have the closing zeros
            x = [30,40];
            y = [15,15];
            pdf_hat = pdf_table (x,y);
            
            [x_var, x_av] = var(pdf_hat);
            assertEqualToTol (x_av,35,'reltol',1e-12);
            assertEqualToTol (x_var,(25/3),'reltol',1e-12);
        end
            
        %--------------------------------------------------------------------------
        function test_5 (self)
            % Two separated triangles with a gap - tests zero range
            x = [10,12,14,19,22,25];
            y = [ 0, 5, 0, 0,10 ,0];
            pdf_twotri = pdf_table (x,y);
            
            [x_var, x_av] = var(pdf_twotri);
            assertEqualToTol (x_av,(39/2),'reltol',1e-12);
            assertEqualToTol (x_var,(481/24),'reltol',1e-12);
        end
            
        %--------------------------------------------------------------------------
    end
    
end
