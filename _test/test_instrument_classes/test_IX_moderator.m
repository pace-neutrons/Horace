classdef test_IX_moderator < TestCaseWithSave
    % Test of IX_moderator
    properties
        mik
        mikp
        mtable
        mdelta
    end
    
    methods
        %--------------------------------------------------------------------------
        function self = test_IX_moderator (name)
            self@TestCaseWithSave(name);
            
            % Make some moderators
            self.mik = IX_moderator(15,30,'ikcarp',[5,25,0.13]);
            self.mikp = IX_moderator(12,23,'ikcarp_param',[0.05,25,200],'-energy',120);
            tri = pdf_table ([0,10,20], [0,1,0]);  % triangular distribution
            self.mtable = IX_moderator(115,300,'table',tri);
            self.mdelta = IX_moderator(125,10,'delta_function',[]);

            self.save()
        end
        
        %--------------------------------------------------------------------------
        function test_pulse_shape_default (self)
            mdefault = IX_moderator();
            mdelta_zero_distAndAngle = IX_moderator(0,0,'delta_function',[]);
            assertEqual (mdefault, mdelta_zero_distAndAngle);
        end
        
        %--------------------------------------------------------------------------
        function test_pulse_shape_mik (self)
            t = -10:0.01:200;
            [y, t] = pulse_shape (self.mik, t); w_mik = IX_dataset_1d (t, y);
            assertEqualWithSave (self, w_mik);
        end
        
        %--------------------------------------------------------------------------
        function test_pulse_shape_mikp (self)
            t = -10:0.01:200;
            [y, t] = pulse_shape (self.mikp, t); w_mikp = IX_dataset_1d (t, y);
            assertEqualWithSave (self, w_mikp);
        end
        
        %--------------------------------------------------------------------------
        function test_pulse_shape_mtable (self)
            t = -10:0.01:200;
            [y, t] = pulse_shape (self.mtable, t); w_mtable = IX_dataset_1d (t, y);
            assertEqualWithSave (self, w_mtable);
        end
        
        %--------------------------------------------------------------------------
        function test_pulse_shape_mdelta (self)
            t = -10:0.01:200;
            [y, t] = pulse_shape (self.mdelta, t); w_mdelta = IX_dataset_1d (t, y);
            assertEqualWithSave (self, w_mdelta);
        end
        
        %--------------------------------------------------------------------------
        function test_pdf_mik (self)
            npnt = 1e7;
            
            % Pulse shape
            tbin = 0:0.1:50;
            t = (tbin(2:end) + tbin(1:end-1)) / 2;
            y = pulse_shape (self.mik, t); w = IX_dataset_1d (t, y);
            area = integrate(w);
            w = w/area.val;
            
            % Random sampling (deterministic; return rng state afterwards)
            S = rng(); rng(0);
            wsamp = vals2distr (self.mik.rand(1,npnt), tbin, 'norm', 'poisson');
            rng(S)
            
            % Check random sampling and 
            [ok,mess,wdiff,chisqr] = IX_dataset_1d_same (wsamp,w,3,'rebin','chi'); 
            assert(ok);
        end
        
        %--------------------------------------------------------------------------
        function test_pdf_mikp (self)
            npnt = 1e7;
            
            % Pulse shape
            tbin = 0:0.1:50;
            t = (tbin(2:end) + tbin(1:end-1)) / 2;
            y = pulse_shape (self.mikp, t); w = IX_dataset_1d (t, y);
            area = integrate(w);
            w = w/area.val;
            
            % Random sampling (deterministic; return rng state afterwards)
            S = rng(); rng(0);
            wsamp = vals2distr (self.mikp.rand(1,npnt), tbin, 'norm', 'poisson');
            rng(S)
            
            % Check random sampling and 
            [ok,mess,wdiff,chisqr] = IX_dataset_1d_same (wsamp,w,3,'rebin','chi'); 
            assert(ok);
        end
        
        %--------------------------------------------------------------------------
        function test_pdf_mtable (self)
            npnt = 1e7;
            
            % Pulse shape
            tbin = 0:0.1:50;
            t = (tbin(2:end) + tbin(1:end-1)) / 2;
            y = pulse_shape (self.mtable, t); w = IX_dataset_1d (t, y);
            area = integrate(w);
            w = w/area.val;
            
            % Random sampling (deterministic; return rng state afterwards)
            S = rng(); rng(0);
            wsamp = vals2distr (self.mtable.rand(1,npnt), tbin, 'norm', 'poisson');
            rng(S)
            
            % Check random sampling and 
            [ok,mess,wdiff,chisqr] = IX_dataset_1d_same (wsamp,w,3,'rebin','chi'); 
            assert(ok);
        end
        
        %--------------------------------------------------------------------------
        function test_pdf_mdelta (self)
            tsamp = self.mdelta.rand(1,10); 
            assert(all(tsamp==0));
        end
        
        %--------------------------------------------------------------------------
        function test_pulse_width_mik (self)
            [dt, t_av, fwhh] = pulse_width (self.mik);
            assertEqualToTol (dt, 15.064444895182829, 1e-14)
            assertEqualToTol (t_av, 18.25, 1e-14)
            assertEqualToTol (fwhh, 17.796795013023157, 1e-14)
        end
        
        %--------------------------------------------------------------------------
        function test_pulse_width_mikp (self)
            [dt, t_av, fwhh] = pulse_width (self.mikp);
            assertEqualToTol (dt, 24.141435934481127, 1e-14)
            assertEqualToTol (t_av, 29.692839193676942, 1e-14)
            assertEqualToTol (fwhh, 26.406900251721297, 1e-14)
        end
        
        %--------------------------------------------------------------------------
        function test_pulse_width_mtable (self)
            [dt, t_av, fwhh] = pulse_width (self.mtable);
            assertEqualToTol (dt, 10/sqrt(6), 1e-14)
            assertEqualToTol (t_av, 10, 1e-14)
            assertEqualToTol (fwhh, 10, 1e-14)
        end
        
        %--------------------------------------------------------------------------
        function test_pulse_width_mdelta (self)
            [dt, t_av, fwhh] = pulse_width (self.mdelta);
            assertEqual (dt, 0)
            assertEqual (t_av, 0)
            assertEqual (fwhh, 0)
        end
        
        %--------------------------------------------------------------------------
        function test_pulse_width2_mik (self)
            [width, tmax, tlo, thi] = pulse_width2 (self.mik, 0.25);
            assertEqualToTol (width, 26.151479900731516, 1e-14)
            assertEqualToTol (tmax, 10.239533277555076, 1e-14)
            assertEqualToTol (tlo, 2.359637371190054, 1e-14)
            assertEqualToTol (thi, 28.511117271921570, 1e-14)
        end
        
        %--------------------------------------------------------------------------
        function test_pulse_width2_mikp (self)
            [width, tmax, tlo, thi] = pulse_width2 (self.mikp, 0.25);
            assertEqualToTol (width, 42.980743939855834, 1e-14)
            assertEqualToTol (tmax, 12.997016317476614, 1e-14)
            assertEqualToTol (tlo, 2.860652447599696, 1e-14)
            assertEqualToTol (thi, 45.841396387455532, 1e-14)

        end
        
        %--------------------------------------------------------------------------
        function test_pulse_width2_mtable (self)
            [width, tmax, tlo, thi] = pulse_width2 (self.mtable, 0.25);
            assertEqualToTol (width, 15, 1e-14)
            assertEqualToTol (tmax, 10, 1e-14)
            assertEqualToTol (tlo, 2.5, 1e-14)
            assertEqualToTol (thi, 17.5, 1e-14)

        end
        
        %--------------------------------------------------------------------------
        function test_pulse_width2_mdelta (self)
            [width, tmax, tlo, thi] = pulse_width2 (self.mdelta, 0.25);
            assertEqual (width, 0)
            assertEqual (tmax, 0)
            assertEqual (tlo, 0)
            assertEqual (thi, 0)
        end
        
        %--------------------------------------------------------------------------
    end
end

