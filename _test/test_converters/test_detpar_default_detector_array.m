classdef test_detpar_default_detector_array < TestCase
    
    properties
        detpar_single = struct( ...
            'width', 54, ...
            'height', 32, ...
            'group', 11, ...
            'phi', 9.8, ...
            'x2', 7.6, ...
            'azim', 5.4);
        
        detpar_multi = struct( ...
            'width', 123.45, ...
            'height', 987.65, ...
            'group', [26 31 41 53 59], ...
            'phi', [3.1 4.1 5.9 2.6 5.3], ...
            'x2', [1 1 2 3 5], ...
            'azim', [1 2 4 8 16]);
    end
    
    methods
        
        %% Default DetectorArray : single-valued detpar
        function this = test_returns_single_detector_array(this)
            detector_array = get_default_detector_array_from_detpar(this.detpar_single);
            
            assertEqual(numel(detector_array), 1);
            assertEqual(class(detector_array), 'IX_detector_array');
        end
        
        function this = test_detector_array_contains_a_single_detector(this)
            detector_array_single = get_default_detector_array_from_detpar(this.detpar_single);
            
            assertEqual(detector_array_single.ndet, 1);
        end
        
        function this = test_detector_array_contains_a_single_detector_bank(this)
            detector_array_single = get_default_detector_array_from_detpar(this.detpar_single);
            
            assertEqual(numel(detector_array_single.det_bank), 1);
            assertEqual(class(detector_array_single.det_bank), 'IX_detector_bank');
        end
        
        function this = test_detector_array_phi_eq_detpar_phi(this)
            detector_array_single = get_default_detector_array_from_detpar(this.detpar_single);
            
            assertEqual(detector_array_single.phi, this.detpar_single.phi);
        end
        
        function this = test_detector_array_x2_eq_detpar_x2(this)
            detector_array_single = get_default_detector_array_from_detpar(this.detpar_single);
            
            assertEqual(detector_array_single.x2, this.detpar_single.x2);
        end
        
        function this = test_detector_array_azim_eq_detpar_azim(this)
            detector_array_single = get_default_detector_array_from_detpar(this.detpar_single);
            
            assertEqual(detector_array_single.azim, this.detpar_single.azim);
        end
        
        function this = test_detector_array_id_eq_detpar_group(this)
            detector_array_single = get_default_detector_array_from_detpar(this.detpar_single);
            
            assertEqual(detector_array_single.id, this.detpar_single.group);
        end
        
        function this = test_detector_array_dmat_is_unit_diagonal_3matrix(this)
            detector_array_single = get_default_detector_array_from_detpar(this.detpar_single);
            
            assertEqual(detector_array_single.dmat, diag([1,1,1]));
        end
        
        function this = test_detector_bank_contains_default_dettector(this)
            expected_detector = get_default_detector_from_detpar(this.detpar_single);
            
            detector_array_single = get_default_detector_array_from_detpar(this.detpar_single);
            
            assertEqual(numel(detector_array_single.det_bank.det), 1);
            assertEqual(detector_array_single.det_bank.det, expected_detector);
        end
        
        
        %% Default DetectorArray : array-valued detpar
        function this = test_returns_single_detector_array_from_n_element_detpar(this)
            detector_array = get_default_detector_array_from_detpar(this.detpar_multi);
            
            assertEqual(numel(detector_array), 1);
            assertEqual(class(detector_array), 'IX_detector_array');
        end
        
        function this = test_detector_array_contains_n_detector_from_n_element_detpar(this)
            detector_array = get_default_detector_array_from_detpar(this.detpar_multi);
            
            assertEqual(detector_array.ndet, numel(this.detpar_multi.x2'));
        end
        
        function this = test_detector_array_phi_eq_detpar_phi_from_n_element_detpar(this)
            detector_array = get_default_detector_array_from_detpar(this.detpar_multi);
            
            assertEqual(detector_array.phi, this.detpar_multi.phi');
        end
        
        function this = test_detector_array_x2_eq_detpar_x2_from_n_element_detpar(this)
            detector_array = get_default_detector_array_from_detpar(this.detpar_multi);
            
            assertEqual(detector_array.x2, this.detpar_multi.x2');
        end
        
        function this = test_detector_array_azim_eq_detpar_azim_from_n_element_detpar(this)
            detector_array = get_default_detector_array_from_detpar(this.detpar_multi);
            
            assertEqual(detector_array.azim, this.detpar_multi.azim');
        end
        
        function this = test_detector_array_id_eq_detpar_group_from_n_element_detpar(this)
            detector_array = get_default_detector_array_from_detpar(this.detpar_multi);
            
            assertEqual(detector_array.id, this.detpar_multi.group');
        end
        
        function this = test_detector_array_dmat_is_unit_diagonal_3matrix_by_n(this)
            expected_matrix = repmat(diag([1,1,1]),1,1,5);
            
            detector_array = get_default_detector_array_from_detpar(this.detpar_multi);
            
            assertEqual(detector_array.dmat, expected_matrix);
        end
    end
end