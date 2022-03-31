classdef test_IX_detectors_3 < TestCaseWithSave
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
        function self = test_IX_detectors_3 (name)
            self@TestCaseWithSave(name);
            
            % Arrays for construction of detectors
            dia(1) = 0.0254;  height(1) = 0.015; thick(1) = 6.35e-4; atms(1) = 10; th(1) = pi/2;
            dia(2) = 0.0300;  height(2) = 0.025; thick(2) = 10.0e-4; atms(2) = 6;  th(2) = 0.9;
            dia(3) = 0.0400;  height(3) = 0.035; thick(3) = 15.0e-4; atms(3) = 4;  th(3) = 0.775;
            dia(4) = 0.0400;  height(4) = 0.035; thick(4) = 15.0e-4; atms(4) = 7;  th(4) = 0.775;
            dia(5) = 0.0400;  height(5) = 0.035; thick(5) = 15.0e-4; atms(5) = 9;  th(5) = 0.775;
            
            self.dia = dia;
            self.height = height;self;
            self.thick = thick;
            self.atms = atms;
            self.path = [sin(th); zeros(size(th)); cos(th)];
            
            self.save()
        end
        
        %--------------------------------------------------------------------------
        function test_det_bank_construction (self)
            [dets, det_array] = construct_detectors(self);
            det = dets(1);
            id = (1:99)';
            x2 = (0.0001:0.0001:0.0099)';
            phi = (1.8:1.8:179.999)';
            azim = (1.8:1.8:179.999)';
            bank = IX_detector_bank(id,x2,phi,azim,det);
            assertEqual(bank.id, id);
            assertEqual(bank.x2, x2);
            assertEqual(bank.phi, phi);
            assertEqual(bank.azim, azim);
            assertEqual(bank.det, det);
        end
        
        %--------------------------------------------------------------------------
        function test_det_bank_saveload (self)
            [dets, det_array] = construct_detectors(self);
            det = dets(1);
            id = (1:99)';
            x2 = (0.0001:0.0001:0.0099)';
            phi = (1.8:1.8:179.999)';
            azim = (1.8:1.8:179.999)';
            bank = IX_detector_bank(id,x2,phi,azim,det);
            save('detbank.mat','bank');
            clob = onCleanup(@()(delete('detbank.mat')));
            data = load('detbank.mat');
            assertEqual(data.bank, bank);
        end
        
        %--------------------------------------------------------------------------
        function test_det_array_construction_from_data_items (self)
            [dets, det_array] = construct_detectors(self);
            det = dets(1);
            id = (1:99)';
            x2 = (0.0001:0.0001:0.0099)';
            phi = (1.8:1.8:179.999)';
            azim = (1.8:1.8:179.999)';
            array = IX_detector_array(id,x2,phi,azim,det);
            save('detarray.mat','array');
            clob = onCleanup(@()(delete('detarray.mat')));
            data = load('detarray.mat');
            assertEqual(data.array, array);
        end
        
        %--------------------------------------------------------------------------
        function test_det_array_construction_from_detpar_struct (self)
            [dets, det_array] = construct_detectors(self);
            det = dets(1);
            id = (1:99)';
            x2 = (0.0001:0.0001:0.0099)';
            phi = (1.8:1.8:179.999)';
            azim = (1.8:1.8:179.999)';
            filename = '';
            filepath = '';
            width = repmat(0.01,99,1);
            height = repmat(0.01,99,1);
            detpar.group = id;
            detpar.x2 = x2;
            detpar.phi = phi;
            detpar.azim = azim;
            detpar.det = det;
            detpar.filename = filename;
            detpar.filepath = filepath;
            detpar.width = width;
            detpar.height = height;
            array = IX_detector_array(detpar);
            save('detarray2.mat','array');
            clob = onCleanup(@()(delete('detarray2.mat')));
            data = load('detarray2.mat');
            assertEqual(data.array, array);
        end
        
         
        %--------------------------------------------------------------------------
        % Utility methods
        %--------------------------------------------------------------------------
        function [dets,det_arr] = construct_detectors (self)
            for i=1:5
                dets(i) = IX_det_He3tube (self.dia(i), self.height(i), self.thick(i), self.atms(i));
            end
            det_arr = IX_det_He3tube (self.dia, self.height, self.thick, self.atms);
            
        end
        
        %--------------------------------------------------------------------------
    end
    
    
end
