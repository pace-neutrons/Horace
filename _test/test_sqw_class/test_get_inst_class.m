classdef test_get_inst_class < TestCase

    properties
        sqw_file_2d_name = 'sqw_2d_1.sqw';
        test_sqw_fullpath;
    end


    methods
        function obj = test_get_inst_class(varargin)
            if nargin == 0
                name = 'test_get_inst_class';
            else
                name = varargin{1};
            end

            obj = obj@TestCase(name);
            pths = horace_paths;

            obj.test_sqw_fullpath = fullfile(pths.test_common, obj.sqw_file_2d_name);
        end

        function test_get_inst_class_with_missing_instrument_from_cell(obj)
            % s is initially created without instruments
            % all instruments in s are initially a base-class IX_inst
            % with name ''. Previously they were structs with this name
            s = sqw(obj.test_sqw_fullpath);

            inst1 =  IX_inst_DGfermi();
            s1 = s.set_instrument(inst1 );
            s2 = test_get_inst_class.build_object_with_partially_empty_instrument( ...
                s,IX_null_inst());
            s = {s1,s2};

            [inst,all_inst] = get_inst_class(s{:});

            % Now get the instrument classes from s.
            % Some are DGfermi, some are '', all IX_inst.
            assertFalse(all_inst);
            assertEqual(inst,inst1);
        end

        function test_different_instruments_from_cell_array_throw(obj)
            s = sqw(obj.test_sqw_fullpath);

            inst1 =  IX_inst_DGfermi();
            updated1 = s.set_instrument(inst1 );
            inst2 = IX_inst_DGdisk();
            updated2 = s.set_instrument(inst2);
            s = {updated1,updated2};

            assertExceptionThrown(@()get_inst_class(s{:}), ...
                'HORACE:tobyfit:not_implemented');
        end

        function test_get_inst_class_with_same_instrument_from_cell_array(obj)
            s = sqw(obj.test_sqw_fullpath);

            expected_inst =  IX_inst_DGfermi ();
            updated = s.set_instrument(expected_inst);
            s = {updated,updated};

            [retrieved_instrument, all_inst] = get_inst_class(s{:});

            assertTrue(all_inst);
            assertTrue(equal_to_tol(retrieved_instrument, expected_inst));
        end

        function test_different_instruments_from_array_throw(obj)
            s = sqw(obj.test_sqw_fullpath);

            inst1 =  IX_inst_DGfermi();
            updated1 = s.set_instrument(inst1 );
            inst2 = IX_inst_DGdisk();
            updated2 = s.set_instrument(inst2);
            s = [updated1,updated2];

            assertExceptionThrown(@()get_inst_class(s), ...
                'HORACE:tobyfit:not_implemented');
        end

        function test_get_inst_class_with_same_instrument_from_array(obj)
            s = sqw(obj.test_sqw_fullpath);

            expected_inst =  IX_inst_DGfermi ();
            updated = s.set_instrument(expected_inst);
            s = [updated,updated];

            [retrieved_instrument, all_inst] = s.get_inst_class();

            assertTrue(all_inst);
            assertTrue(equal_to_tol(retrieved_instrument, expected_inst));
        end

        function test_get_inst_class_with_same_instrument(obj)
            s = sqw(obj.test_sqw_fullpath);

            expected_inst =  IX_inst_DGfermi ();

            updated = s.set_instrument(expected_inst);
            [retrieved_instrument, all_inst] = updated.get_inst_class();

            assertTrue(all_inst);
            assertTrue(equal_to_tol(retrieved_instrument, expected_inst));
        end

        function test_get_inst_class_with_different_instrument_throw(obj)
            % s is initially created without instruments
            % all instruments in s are initially a base-class IX_inst
            % with name ''. Previously they were structs with this name
            s = sqw(obj.test_sqw_fullpath);


            s = test_get_inst_class.build_object_with_partially_empty_instrument(...
                s,IX_inst_DGdisk);

            assertExceptionThrown(@()get_inst_class(s), ...
                'HORACE:tobyfit:not_implemented');
        end

        function test_get_inst_class_with_missing_instrument(obj)
            % s is initially created without instruments
            % all instruments in s are initially a base-class IX_inst
            % with name ''. Previously they were structs with this name
            s = sqw(obj.test_sqw_fullpath);

            [s,expected_inst] = test_get_inst_class.build_object_with_partially_empty_instrument( ...
                s,IX_null_inst());

            [inst,all_inst] = get_inst_class(s);

            % Now get the instrument classes from s.
            % Some are DGfermi, some are '', all IX_inst.
            assertFalse(all_inst);
            assertEqual(inst,expected_inst);
        end
    end
    methods(Static)
        function [source,expected_inst] = build_object_with_partially_empty_instrument(source,other_inst)
            % Create a DGfermi instrument with a view to slotting it in
            % to s. This is sample of the code to create valid instrument
            %
            mod_1 = IX_moderator(10,11,'ikcarp',[11,111,0.1]);
            ap_1 = IX_aperture(-10,0.1,0.11);
            chopper_1 = IX_fermi_chopper(1,100,0.1,1,0.01);
            expected_inst =  IX_inst_DGfermi (mod_1, ap_1, chopper_1, 100);

            % there are 24 runs. Change the header so that the first 20
            % runs are now the DGfermi, the rest are still ''. But they
            % are all IX_inst because that is how the new header is set up.
            % Previously the unset ones were just structs.
            hdr = source.experiment_info;
            n_runs = hdr.n_runs;
            for idx=1:n_runs-2
                hdr.instruments{idx} = expected_inst;
            end
            for idx=n_runs-1:n_runs
                hdr.instruments{idx} = other_inst;
            end
            source.experiment_info = hdr;
        end
    end
end
