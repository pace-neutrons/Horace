classdef test_IX_detector_array_1 < TestCaseWithSave
    % Test the calculation of quantities for IX_detector_array object
    % Detector arrays are made of banks which in turn are made of detectors
    properties
        bank1
        bank2
        bank3
        bank4
    end
    
    methods
        %--------------------------------------------------------------------------
        function obj = test_IX_detector_array_1 (name)
            obj@TestCaseWithSave(name);
            
            % 3He bank
            % --------
            x2_1 = [10,10.1,10.2,10.3];
            phi_1 = [30,35,40,45];
            azim_1 = 45;
            det_1 = IX_det_He3tube(0.0254,0.03,0.002,10);
            
            rotvec1 = [0,0,0; 0,20,0; 0,45,0; 0,60,0]';
            obj.bank1 = IX_detector_bank (1001:1004,x2_1,phi_1,azim_1,det_1,'rotvec',rotvec1);
            
            % 3He bank
            % --------
            x2_2 = 2.5;
            phi_2 = [10,10,15,15,20,20];
            azim_2 = [0,22.5,45,67.5,90,90];
            det_2 = IX_det_He3tube(0.0125,0.015,0.002,6.3);
            
            rotvec2 = [0,10,0; 0,23,0; 0,55,0; 0,60,0; 0,65,0; 0,80,0]';
            obj.bank2 = IX_detector_bank (2001:2006,x2_2,phi_2,azim_2,det_2,'rotvec',rotvec2);
            
            % slab banks
            % ----------
            x2_3 = [2,2.1,2.2];
            phi_3 = [10,21,32];
            azim_3 = [180,180,180];
            det_3 = IX_det_slab (0.01,0.03,0.2,0.005);
            
            rotvec3 = [0,31,0; 0,28,0; 0,41,0]';
            obj.bank3 = IX_detector_bank (3001:3003,x2_3,phi_3,azim_3,det_3,'rotvec',rotvec3);

            % 3He bank
            % --------
            x2_4 = 4;
            phi_4 = [10,20,20];
            azim_4 = [10,122.5,167.5];
            det_4 = IX_det_He3tube(0.0125,0.015,0.002,[6.3,7.3,15.3]);
            
            rotvec4 = [0,3,0; 0,22,0; 0,47,0]';
            obj.bank4 = IX_detector_bank (4001:4003,x2_4,phi_4,azim_4,det_4,'rotvec',rotvec4);
            
            obj.save()
        end
        
        %--------------------------------------------------------------------------
        function test_constructor_1 (obj)
            % Make from a single detector bank
            D = IX_detector_array (obj.bank1);
            assertEqual (D.det_bank, obj.bank1)
        end
        
        %--------------------------------------------------------------------------
        function test_constructor_2 (obj)
            % Make from multiple detector banks, with different detector
            % types
            banks_123 = [obj.bank1, obj.bank2, obj.bank3];
            D = IX_detector_array (banks_123, obj.bank4);
            
            banks_1234 = [obj.bank1 obj.bank2, obj.bank3, obj.bank4];
            assertEqual (D.det_bank, banks_1234(:))
        end
        
        %--------------------------------------------------------------------------
%         function test_constructor_3 (obj)
%             % Check fails if there are non-unique detector id values
%             id1 = obj.bank1.id;
%             id2 = obj.bank2.id;
%             idtmp = id2; idtmp(1) = id1(1);
%             bank_tmp = obj.bank2;
%             bank_tmp.id(1) = ban
%             ***
%             banks_123 = [obj.bank1, obj.bank2, obj.bank3];
%             D = IX_detector_array (banks_123, obj.bank4);
%             
%             banks_1234 = [obj.bank1 obj.bank2, obj.bank3, obj.bank4];
%             assertEqual (D.det_bank, banks_1234(:))
%         end
        
        %--------------------------------------------------------------------------
        function test_effic_1 (obj)
            % Efficiencies for a whole bank
            D = IX_detector_array (obj.bank1);
            
            wvec = 10;
            eff = effic (D, wvec);  % whole bank
            
            eff_ref = effic (obj.bank1, wvec);
            assertEqual (eff, eff_ref)
        end
        
        %--------------------------------------------------------------------------
        function test_effic_2 (obj)
            % Efficiencies for two banks
            D = IX_detector_array (obj.bank1);
            
            wvec = 10;
            eff = effic (D, wvec);  % whole bank
            
            eff_ref = effic (obj.bank1, wvec);
            assertEqual (eff, eff_ref)
        end
        
        %--------------------------------------------------------------------------
        % Test each of the functions once across the detector banks to test
        % scalar, [3,1] and [3,3] outputs correctly resized.
        % Requires that the tests for IX_detector_bank and IX_det_*** have
        % been performed.
        %
        % Test for all combinatioins of scalar and array and number of
        % banks to test parse_ind_wvec_ and repackage_ind_wvec_ for effic.
        % The test above should validate for all the other functions as
        % they share func_eval.
        %
        %--------------------------------------------------------------------------
    end
    
end
