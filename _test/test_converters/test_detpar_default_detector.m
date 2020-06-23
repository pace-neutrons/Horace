classdef test_detpar_default_detector < TestCase
    
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
            'group', [26 31 41 59 53], ...
            'phi', [3.1 4.1 5.9 2.6 5.3], ...
            'x2', [1 1 2 3 5], ...
            'azim', [1 2 4 8 16]);
    end
    
    methods
        
        %% Default Detector
        function this = test_default_detector_is_He3Tube(this)
            detector = get_default_detector_from_detpar(this.detpar_single);
            
            assertEqual(numel(detector), 1);
            assertEqual(class(detector), 'IX_det_He3tube');
        end
        
        function this = test_single_detector_returned_from_n_element_detpar(this)
            detector = get_default_detector_from_detpar(this.detpar_multi);
            
            assertEqual(numel(detector), 1);
            assertEqual(class(detector), 'IX_det_He3tube');
        end
        
        function this = test_detector_returned_from_n_element_detpar_is_array_valued(this)
            detector = get_default_detector_from_detpar(this.detpar_multi);
            
            assertEqual(numel(detector.dia), numel(this.detpar_multi.width));
        end
        
        
        function this = test_sets_detector_diameter_to_width(this)
            detector = get_default_detector_from_detpar(this.detpar_single);
            
            assertEqual(detector.dia, this.detpar_single.width);
        end
        
        function this = test_sets_detector_height_to_height(this)
            detector = get_default_detector_from_detpar(this.detpar_single);
            
            assertEqual(detector.height, this.detpar_single.height);
        end
        
        function this = test_sets_detector_pressure_to_expected_value(this)
            expected_pressure = 10; %atmospheres
            
            detector = get_default_detector_from_detpar(this.detpar_single);
            
            assertEqual(detector.atms, expected_pressure);
        end
        
        function this = test_sets_detector_thickness_to_expected_value(this)
            expected_thickness = 6.35e-4; %m
            
            detector = get_default_detector_from_detpar(this.detpar_single);
            
            assertEqual(detector.wall, expected_thickness);
        end
    end
end
