classdef test_horace_binfile_interface < TestCase
    properties
        basic_det
    end

    methods
        % Construction and helpers
        function obj = test_horace_binfile_interface(varargin)
            if nargin == 0
                name = varargin{1};
            else
                name = 'test_horace_binfile_interface ';
            end
            obj = obj@TestCase(name);
            hp = horace_paths;
            test_file = fullfile(hp.test_common,'96dets.par');
            apr = asciipar_loader(test_file);
            obj.basic_det = apr.load_par();
        end
        %------------------------------------------------------------------
        function test_convert_det_obj_container(obj)
            det_arr = IX_detector_array(obj.basic_det);
            det_ct  = unique_objects_container('baseclass','IX_detector_array');
            det_ct  = det_ct.add(det_arr);
            det_ct  = det_ct.replicate_runs(3);
            det = horace_binfile_interface.convert_old_det_forms(det_ct,3);

            assertTrue(isa(det,'unique_objects_container'));
            assertEqual(det.n_objects,3)
            assertEqual(det.n_unique,1)
            uob = det.unique_objects();
            assertTrue(isa(uob{1},'IX_detector_array'));
            assertEqual(uob{1}.ndet,96);
        end

        function test_convert_det_array(obj)
            det_arr = IX_detector_array(obj.basic_det);
            det = horace_binfile_interface.convert_old_det_forms(det_arr,3);

            assertTrue(isa(det,'unique_objects_container'));
            assertEqual(det.n_objects,3)
            assertEqual(det.n_unique,1)
            uob = det.unique_objects();
            assertTrue(isa(uob{1},'IX_detector_array'));
            assertEqual(uob{1}.ndet,96);
        end

        function test_convert_det_structure(obj)
            det = horace_binfile_interface.convert_old_det_forms(obj.basic_det);

            assertTrue(isa(det,'unique_objects_container'));
            assertEqual(det.n_objects,1)
            assertEqual(det.n_unique,1)
            uob = det.unique_objects();
            assertTrue(isa(uob{1},'IX_detector_array'));
            assertEqual(uob{1}.ndet,96);
        end
    end
end
