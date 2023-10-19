classdef test_sqw_activate_deactivate< TestCase
    % Series of tests to check work of mex files against Matlab files

    properties
        out_dir = tmp_dir();
        sqw_obj;
        sqw_file;
    end

    methods
        function obj = test_sqw_activate_deactivate(varargin)
            if nargin == 0
                name = 'test_sqw_main';
            else
                name = varargin{1};
            end
            obj = obj@TestCase(name);
            sqww = sqw.generate_cube_sqw(10);
            obj.sqw_obj = sqww;
            obj.sqw_file = build_tmp_file_name('test_sqw_activation');
            save(sqww,obj.sqw_file);
        end
        function delete(obj)
            if is_file(obj.sqw_file)
                del_memmapfile_files(obj.sqw_file);
            end
        end

        function test_deactivated_copied_tmp_file_deleted(obj)
            new_file = fullfile(tmp_dir(),'test_deact_copied_tmp_deleted.tmp_xxxx');
            copyfile(obj.sqw_file,new_file,'f');


            sq_obj = sqw(new_file,'file_backed',true);
            sq_obj = sq_obj.set_as_tmp_obj();
            sq2_obj= copy(sq_obj);
            sq_obj = sq_obj.deactivate();
            assertTrue(is_file(new_file ))
            clear sq_obj;
            assertTrue(is_file(new_file ))
            clear sq2_obj;

            assertFalse(is_file(new_file ))
        end
        function test_copied_tmp_file_deleted(obj)
            new_file = fullfile(tmp_dir(),'test_deact_copied_tmp_deleted.tmp_xxxx');
            copyfile(obj.sqw_file,new_file,'f');

            sq_obj = sqw(new_file,'file_backed',true);
            sq_obj = sq_obj.set_as_tmp_obj();
            sq2_obj= copy(sq_obj);
            assertTrue(is_file(new_file ))
            clear sq_obj;
            assertTrue(is_file(new_file ))
            clear sq2_obj;

            assertFalse(is_file(new_file ))
        end

        function test_deactivated_activated_tmp_file_deleted(obj)
            new_file = fullfile(tmp_dir(),'test_deact_act_tmp_deleted.tmp_xxxx');
            copyfile(obj.sqw_file,new_file,'f');

            sq_obj = sqw(new_file,'file_backed',true);
            sq_obj = sq_obj.set_as_tmp_obj();
            sq_obj = sq_obj.deactivate();
            assertTrue(is_file(new_file ))
            sq_obj = sq_obj.activate();
            clear sq_obj;

            assertFalse(is_file(new_file ))
        end

        function test_deactivated_activated_non_tmp_file_kept(obj)
            new_file = fullfile(tmp_dir(),'test_deactivated_act_nontmp_kept.sqw');
            copyfile(obj.sqw_file,new_file,'f');

            clOb = onCleanup(@()del_memmapfile_files(new_file ));

            sq_obj = sqw(new_file,'file_backed',true);
            sq_obj = sq_obj.set_as_tmp_obj();
            sq_obj = sq_obj.deactivate();
            assertTrue(is_file(new_file ))
            sq_obj = sq_obj.activate();
            clear sq_obj;

            assertTrue(is_file(new_file ))
        end

        function test_deactivated_file_kept(obj)
            new_file = fullfile(tmp_dir(),'test_deactivated_tmp_kept.sqw');
            copyfile(obj.sqw_file,new_file,'f');

            clOb = onCleanup(@()del_memmapfile_files(new_file ));

            sq_obj = sqw(new_file,'file_backed',true);
            sq_obj = sq_obj.set_as_tmp_obj();
            sq_obj = sq_obj.deactivate();
            assertTrue(is_file(new_file ))
            clear sq_obj;

            assertTrue(is_file(new_file ))
        end

        function test_based_file_deleted(obj)
            new_file = fullfile(tmp_dir(),'test_activation_tmp_deleted.sqw');
            copyfile(obj.sqw_file,new_file,'f');

            sq_obj = sqw(new_file,'file_backed',true);
            sq_obj = sq_obj.set_as_tmp_obj();
            assertTrue(is_file(new_file ))
            clear sq_obj;

            assertFalse(is_file(new_file ))
        end

        function test_sqw_activate_deactivate_does_nothing_in_mem(obj)
            sdec = obj.sqw_obj.deactivate();
            sdec = sdec.activate();
            assertEqual(sdec,obj.sqw_obj);
        end
    end
end
