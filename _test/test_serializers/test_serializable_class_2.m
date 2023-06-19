classdef test_serializable_class_2 < TestCaseWithSave
    % Additional tests of serializable class
    properties
        dia
        height
        wall
        atms
        path
    end
    
    methods
        %--------------------------------------------------------------------------
        function obj = test_serializable_class_2 (name)
            obj@TestCaseWithSave(name);
            
            % Arrays for construction of detectors
            % Note: have varying paths w.r.t. detector coordinate frame
            dia(1) = 0.0254;  height(1) = 0.015; wall(1) = 6.35e-4; atms(1) = 10; th(1) = pi/2;
            dia(2) = 0.0300;  height(2) = 0.025; wall(2) = 10.0e-4; atms(2) = 6;  th(2) = 0.9;
            dia(3) = 0.0400;  height(3) = 0.035; wall(3) = 15.0e-4; atms(3) = 4;  th(3) = 0.775;
            dia(4) = 0.0400;  height(4) = 0.035; wall(4) = 15.0e-4; atms(4) = 7;  th(4) = 0.775;
            dia(5) = 0.0400;  height(5) = 0.035; wall(5) = 15.0e-4; atms(5) = 9;  th(5) = 0.775;
            
            obj.dia = dia;
            obj.height = height;
            obj.wall = wall;
            obj.atms = atms;
            obj.path = [sin(th); zeros(size(th)); cos(th)];
            
            obj.save()
        end

        function obj = setUp(obj)
            % Set version number
            serializableTester3.version_holder(2);
        end

        %--------------------------------------------------------------------------
        function test_to_bare_struct_1 (obj)
            % Test alternastive ways of calling from_bare_struct
            % for a single detector
            dets_ref = construct_detectors (obj);
            
            % Structures from single detector
            S = to_struct (dets_ref(1));
            Sbare = to_bare_struct (dets_ref(1));
            
            % Recover detector
            det_1 = serializable.from_struct (S);
            det_1_bare = from_bare_struct (serializableTester3, Sbare);
            myobj = serializableTester3();
            det_1_bare_alternate = myobj.from_bare_struct (Sbare);
            
            assertEqual (dets_ref(1), det_1)
            assertEqual (dets_ref(1), det_1_bare)
            assertEqual (dets_ref(1), det_1_bare_alternate)
        end       

        %--------------------------------------------------------------------------
        function test_to_bare_struct_2 (obj)
            % Test alternastive ways of calling from_bare_struct
            % for a multiple detectors
            dets_ref = construct_detectors (obj);
            
            % Structures from array of detectors
            S = to_struct (dets_ref);
            Sbare = to_bare_struct (dets_ref);
            
            % Recover array of detectors
            dets = serializable.from_struct (S);
            dets_bare = from_bare_struct (serializableTester3, Sbare);
            myobj = serializableTester3();
            dets_bare_alternate = myobj.from_bare_struct (Sbare);

            assertEqual (dets_ref, dets)
            assertEqual (dets_ref, dets_bare)
            assertEqual (dets_ref, dets_bare_alternate)
        end
                
        %--------------------------------------------------------------------------
        function test_saveobj_1 (obj)
            % Test save and load for a single detector
            dets_ref = construct_detectors (obj);
            
            % Save single detector
            det_1_ref = dets_ref(1);

            test_file = fullfile (tmp_dir(), 'test_serializable_saveobj_1.mat');
            cleanup = onCleanup(@()delete(test_file));
            save (test_file, 'det_1_ref');
            
            % Recover detector
            tmp = load (test_file);
            
            assertEqual (det_1_ref, tmp.det_1_ref)
        end
                
        %--------------------------------------------------------------------------
        function test_saveobj_2 (obj)
            % Test save and load for multiple detectors
            dets_ref = construct_detectors (obj);
            
            % Save detector array
            test_file = fullfile (tmp_dir(), 'test_serializable_saveobj_2.mat');
            cleanup = onCleanup(@()delete(test_file));
            save (test_file, 'dets_ref');
            
            % Recover detector array
            tmp = load (test_file);
            
            assertEqual (dets_ref, tmp.dets_ref)
        end
                
        %--------------------------------------------------------------------------
        % Test reading old class versions
        %--------------------------------------------------------------------------

        function test_ver1_save_load (obj)
            % Test save and load for multiple detectors
            % save/load will treat each detector in the array individually i.e
            % internally it loops over each detector and so tests the scalaar
            % object functionality
            % serialize/deserialize treats the array as a whole, so exercises
            % the .array_dat field in to_struct/from_struct
            dets_ref = construct_detectors (obj);

            % Save detector array - ver1
            serializableTester3.version_holder(1);
            dets_ver1 = construct_detectors (obj);

            % -side test: Check that only the fields we expect will be saved
            %             This is a check that ver1 has been chosen
            S = rmfield(to_struct(dets_ver1(1)), {'serial_name','version'});
            assertEqual(fieldnames(S), {'dia';'height';'atms'})

            test_file = fullfile (tmp_dir(), 'test_serializableTester3_ver1.mat');
            cleanup = onCleanup(@()delete(test_file));
            save (test_file, 'dets_ver1');

            serializableTester3.version_holder(2);  % return to version 2

            % Recover detector array as ver2 objects
            tmp = load (test_file);

            % Confirm that reading version 1 .mat file results in version 2
            % classes, with value for property 'wall' from convert_old_struct
            for i=1:numel(dets_ver1)
                dets_ref(i).wall = 1e-6;
            end
            assertEqual (dets_ref, tmp.dets_ver1)
        end
                
        function test_ver1_reserialize (obj)
            % Test save and load for multiple detectors
            % save/load will treat each detector in the array individually i.e
            % internally it loops over each detector and so tests the scalaar
            % object functionality
            % serialize/deserialize treats the array as a whole, so exercises
            % the .array_dat field in to_struct/from_struct
            dets_ref = construct_detectors (obj);

            % Serialize detector array - ver1
            serializableTester3.version_holder(1);
            dets_ver1 = construct_detectors (obj);

            byte_array = serialize(dets_ver1);

            serializableTester3.version_holder(2);  % return to version 2

            % Deserialize detector array as ver2 objects
            dets_ver1_reserialized = serializableTester3.deserialize (byte_array);

            % Confirm that reserialisation of ver1 detectors results in version 2
            % classes, with value for property 'wall' from convert_old_struct            
            for i=1:numel(dets_ver1)
                dets_ref(i).wall = 1e-6;
            end
            assertEqual (dets_ref, dets_ver1_reserialized)
        end
                
        function test_verNaN_from_struct (obj)
            % Cannot test save and load for multiple detectors directly as
            % serializable does not have a mechanism to save pre-serializable
            % class versions.
            % The nearest we can do is create a bare structure with the verNaN 
            % form (which mimics te structure of our notional pre-serializable 
            % bare structure) and use from_struct to generate the latest version
            dets_ref = construct_detectors (obj);

            % Save detector array - ver==NaN
            for i=1:numel(dets_ref)
                S(i).dia = dets_ref(i).dia;
                S(i).height = dets_ref(i).height;
            end

            % Recover detector array as ver2 objects
            tmp = serializable.from_struct (S, serializableTester3());

            % Confirm that reading version NaN structure results in version 2
            % classes, with value for properties 'wall' and 'atms' from
            % convert_old_struct
            for i=1:numel(dets_ref)
                dets_ref(i).wall = 1e-7;
                dets_ref(i).atms = 27;
            end
            assertEqual (dets_ref, tmp)
        end
                
        %--------------------------------------------------------------------------
        % Utility methods
        %--------------------------------------------------------------------------
        function dets = construct_detectors (obj)
            % Create array of single IX_det_He3tube objects, and the 
            % equivalent IX_det_He3tube object containing an array of
            % detectors.
            dets = repmat(serializableTester3, [1,5]);
            for i=1:5
                dets(i) = serializableTester3 (obj.dia(i), obj.height(i), obj.wall(i), obj.atms(i));
            end
        end
        
        %--------------------------------------------------------------------------
    end
    
    
end
