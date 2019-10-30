classdef test_IX_fermi_chopper < TestCaseWithSave
    % Test of IX_fermi_chopper
    properties
        f500
        f200
        f163
        f162
        f100
        f50
    end
    
    methods
        %--------------------------------------------------------------------------
        function self = test_IX_fermi_chopper (name)
            self@TestCaseWithSave(name);
            
            % Make some Fermi choppers
            f=IX_fermi_chopper(10,600,0.049,1.3,0.0028);
            
            f500 = f; f500.energy = 500; % gamma = eps
            f200 = f; f200.energy = 200; % gamma < 1
            f163 = f; f163.energy = 163; % gamma = 1-eps
            f162 = f; f162.energy = 162; % gamma = 1+eps
            f100 = f; f100.energy = 100; % gamma = 1.64
            f50 = f;  f50.energy = 50;   % gamma = 2.86
            
            % A chopper
            self.f500 = f500;
            self.f200 = f200;
            self.f163 = f163;
            self.f162 = f162;
            self.f100 = f100;
            self.f50  = f50;
            
            self.save()
        end
        
        %--------------------------------------------------------------------------
        function test_pulse_shape (self)
            t = -20:0.001:20;
            y = pulse_shape (self.f500,t); w500=IX_dataset_1d(t,y);
            y = pulse_shape (self.f200,t); w200=IX_dataset_1d(t,y);
            y = pulse_shape (self.f163,t); w163=IX_dataset_1d(t,y);
            y = pulse_shape (self.f162,t); w162=IX_dataset_1d(t,y);
            y = pulse_shape (self.f100,t); w100=IX_dataset_1d(t,y);
            y = pulse_shape (self.f50,t);  w50=IX_dataset_1d(t,y);
            
            warr = [w500,w200,w163,w162,w100,w50];
            assertEqualWithSave (self,warr);
        end
        
        %--------------------------------------------------------------------------
        function test_auto_pulse_shape (self)
            [y,t] = pulse_shape (self.f163); w163=IX_dataset_1d(t,y);
            assertEqualWithSave (self,w163,'',[0,1.e-9]);
        end
        
        %--------------------------------------------------------------------------
        function test_pdf (self)
            npnt = 1e7;
            
            % Pulse shape
            tbin = -20:0.05:20;
            t = tbin(1:end-1) + 0.025;
            y = pulse_shape (self.f200,t); w200=IX_dataset_1d(t,y);
            area = integrate(w200);
            w200 = w200/area.val;
            
            % From sampling
            wsamp = vals2distr (self.f200.rand(1,npnt), tbin, 'norm', 'poisson');
            
            [ok,mess,wdiff,chisqr] = IX_dataset_1d_same (wsamp,w200,3,'rebin','chi');
            
            assert(ok);
        end
        
        %--------------------------------------------------------------------------
    end
end

