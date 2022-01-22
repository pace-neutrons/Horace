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
        function test_9 (self)
            % Gaussian - to test random number selection
            % Something more complex than a hat or triangle
            x = linspace(-20,120,1201);
            y = gauss(x,[10,50,10]);
            
            gau = pdf_table(x,y);
            
            S = rng();  % store rng configuration
            rng(0);
            tic
            X = gau.rand(1e2,1e3,5e2);
            rng(S);
            toc
            
            N = histcounts(X, 20:2:80);
            x = (21:2:79);
            sigma = 10; nsig = 3; bin = 2;
            
            y = (N/bin)/(sum(N)/erf(nsig/sqrt(2))) / (sigma*sqrt(2*pi));
            
            
            H = sum(N)/(sigma*sqrt(2*pi)*erf(nsig/sqrt(2)));
            y = N/H;
            yref = gauss(x,[1,50,10]);

            w = IX_dataset_1d(x,y);
            wref = IX_dataset_1d(x,yref);
            dd(w-wref)

        end
            
        %--------------------------------------------------------------------------
    end
    
end
