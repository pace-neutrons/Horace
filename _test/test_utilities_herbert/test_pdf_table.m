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
        function test_3a (self)
            % hat function - again, but this time do not have the closing zeros
            x = [30,40];
            y = [15,15];
            pdf_hat = pdf_table (x,y);
            
            [x_var, x_av] = var(pdf_hat);
            assertEqualToTol (x_av,35,'reltol',1e-12);
            assertEqualToTol (x_var,(25/3),'reltol',1e-12);
        end
            
        %--------------------------------------------------------------------------
        function test_4 (self)
            % delta function
            pdf_delta = pdf_table (23,Inf);
            
            x_av = mean(pdf_delta);
            assertEqualToTol (x_av,23);
            
            [x_var, x_av] = var(pdf_delta);
            assertEqualToTol (x_av,23);
            assertEqualToTol (x_var,0);
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
        function test_6 (self)
            % Gaussian - to test moments function
            x = 1:100;
            y = gauss(x,[10,50,10]);
            gau = pdf_table(x,y);
            
            x_av = mean (gau);
            assertEqualToTol (x_av,50.000009708130889,'reltol',1e-12);
            
            [x_var, x_av] = var(gau);
            assertEqualToTol (x_av,50.000009708130889,'reltol',1e-12);
            assertEqualToTol (x_var,100.1646872989924,'reltol',1e-12);
        end
            
        %--------------------------------------------------------------------------
        function test_7 (self)
            % Gaussian - to test width function
            x = 1:100;
            y = gauss(x,[10,50,10]);
            gau = pdf_table(x,y);
            
            [w,xmax,xlo,xhi] = width (gau);
            
            % Half-heights are at sigma * sqrt(log(4)), but as a linear
            % approximation tpo pdf, the width will not be exactly this
            hwhh = 11.776681401097939;
            assertEqualToTol (w,2*hwhh,'reltol',1e-12);
            assertEqualToTol (xmax,50,'reltol',1e-12);
            assertEqualToTol (xlo,xmax-hwhh,'reltol',1e-12);
            assertEqualToTol (xhi,xmax+hwhh,'reltol',1e-12);
        end
            
        %--------------------------------------------------------------------------
        function test_8 (self)
            % Gaussian - to test width function Part-II
            x = 1:100;
            y = gauss(x,[10,50,10]);
            gau = pdf_table(x,y);
            
            [w,xmax,xlo,xhi] = width (gau, 0.25);   % quarter height
            
            % Quarter-heights are at sigma * sqrt(log(16)), but as a linear
            % approximation tpo pdf, the width will not be exactly this
            hwqh = 16.662957887462881;
            assertEqualToTol (w,2*hwqh,'reltol',1e-12);
            assertEqualToTol (xmax,50,'reltol',1e-12);
            assertEqualToTol (xlo,xmax-hwqh,'reltol',1e-12);
            assertEqualToTol (xhi,xmax+hwqh,'reltol',1e-12);
        end
            
        %--------------------------------------------------------------------------
        function test_9 (~)
            % Gaussian - to test random number selection
            % Something more complex than a hat or triangle
            x = linspace(31,69,381);
            y = gauss(x,[10,50,10]);
            
            gau = pdf_table(x,y);
            
            S = rng();  % store rng configuration
            rng(0);
            sz = [1e2,1e3,5e2];
            X = gau.rand(1e2,1e3,5e2);
            rng(S);

            xb = (31:2:69);
            N = histcounts(X, xb);
            
            % Check that we have the correct number of counts in the histogram
            assertTrue(sum(N)==prod(sz)) 
            Nnorm = N / sum(N);
            
            % Check relative number of counts in the bins
            centre = 50; sigma = 10;
            tb = (xb-centre) / (sigma*sqrt(2));   % into unit of measure for erf function
            A = zeros(1, numel(tb)-1);
            for i=1:numel(A)
                A(i) = erf(tb(i+1)) - erf(tb(i));   % ok as diff(tb) = 0.1414
            end
            Anorm = A / sum(A);
            
            assertTrue(all(abs(Nnorm-Anorm)./Anorm < 1e-3)) % account for random noise
            
        end
        function test_function_handle_vs_values(~)
            x = linspace(31,69,381);
            
            pdf_fh = pdf_table(x,@gauss,[10,50,10]);

            y = gauss(x,[10,50,10]);
            pdf_val = pdf_table(x,y);            

            assertEqual(pdf_val,pdf_fh);

            fh = @(x)gauss(x,[10,40,10]);
            pdf_fh.f = fh;
            
            y_prime = fh(x);
            pdf_val.f = y_prime;            
            assertEqual(pdf_val,pdf_fh);            
        end
            
        %--------------------------------------------------------------------------
        function test_10 (~)
            % delta function random selection
            pdf_delta = pdf_table (23,Inf);
            
            sz = [3,2,5];
            X = pdf_delta.rand(sz);
            assertEqualToTol (X,23*ones(sz));
        end
            
        %--------------------------------------------------------------------------
    end
    
end
