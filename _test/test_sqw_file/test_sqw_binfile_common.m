classdef test_sqw_binfile_common <  TestCase
    %Testing common part of the code used to access binary sqw files
    % and various auxliary methods, availble on this class
    %
    properties
        test_folder
        root_tests_folder
    end

    methods
        function obj = test_sqw_binfile_common(varargin)
            if nargin > 0
                name = varargin{1};
            else
                name= mfilename('class');
            end
            %obj = obj@TestCaseWithSave(name,sample_file);
            obj = obj@TestCase(name);
            obj.test_folder=fileparts(mfilename('fullpath'));
            obj.root_tests_folder = fullfile(fileparts(fileparts(mfilename('fullpath'))));
        end
        function test_header_no_mangling_no_mangle_update_v3file(obj)
            %
            sample_V3_file = fullfile(obj.root_tests_folder, ...
                'test_sqw_file','test_sqw_file_read_write_v3_1.sqw');
            out_file = fullfile(obj.test_folder,'test_no_mangling_update_v3.sqw');
            clOb = onCleanup(@()delete(out_file));
            copyfile(sample_V3_file,out_file,'f');

            v3reader = faccess_sqw_v3(out_file);

            v3r_tester = sqw_binfile_common_tester();
            v3r_tester = v3r_tester.init(v3reader);
            assertFalse(v3r_tester.is_mangled);

            vMreader = v3reader.upgrade_file_format();
            v3r_tester = v3r_tester.init(vMreader);
            assertFalse(v3r_tester.is_mangled);
            vMreader.delete();
            v3reader.delete();
        end


        function test_header_no_mangling_mangle_on_write_v3file(obj)
            sample_V3_file = fullfile(obj.root_tests_folder, ...
                'test_sqw_file','test_sqw_file_read_write_v3_1.sqw');
            v3reader = faccess_sqw_v3(sample_V3_file);

            v3_tester = sqw_binfile_common_tester();
            v3_tester = v3_tester.init(v3reader);
            assertFalse(v3_tester.is_mangled);

            sq_obj = v3reader.get_sqw();
            assertEqual(sq_obj.experiment_info.expdata(1).run_id,1)
            v3_tester.delete();


            out_file = fullfile(obj.test_folder,'test_mangling_v3.sqw');
            clOb = onCleanup(@()delete(out_file));

            v3wr = faccess_sqw_v3(sq_obj,out_file);
            v3r_tester = v3_tester.init(v3wr);
            assertTrue(v3r_tester.is_mangled);

            v3wr = v3wr.put_sqw();
            v3wr.delete();

            v3reader = faccess_sqw_v3(out_file);
            v3r_tester = v3r_tester.init(v3reader);
            assertTrue(v3r_tester.is_mangled);
            v3reader.delete();

        end

        function test_header_no_mangling_no_mangle_update_v2file(obj)
            %
            sample_V2_file = fullfile(obj.root_tests_folder, ...
                'test_symmetrisation','w3d_sqw.sqw');
            out_file = fullfile(obj.test_folder,'test_no_mangling_updata_v2.sqw');
            clOb = onCleanup(@()delete(out_file));
            copyfile(sample_V2_file,out_file,'f');

            v2reader = faccess_sqw_v2(out_file);

            v2r_tester = sqw_binfile_common_tester();
            v2r_tester = v2r_tester.init(v2reader);
            assertFalse(v2r_tester.is_mangled);

            vMreader = v2reader.upgrade_file_format();
            v2r_tester = v2r_tester.init(vMreader);
            assertFalse(v2r_tester.is_mangled);
            vMreader.delete();
            v2reader.delete();
        end

        function test_header_no_mangling_mangle_on_write_v2file(obj)
            sample_V2_file = fullfile(obj.root_tests_folder, ...
                'test_symmetrisation','w3d_sqw.sqw');
            v2reader = faccess_sqw_v2(sample_V2_file);

            v2r_tester = sqw_binfile_common_tester();
            v2r_tester = v2r_tester.init(v2reader);
            assertFalse(v2r_tester.is_mangled);

            sq_obj = v2reader.get_sqw();
            assertEqual(sq_obj.experiment_info.expdata(1).run_id,1)
            v2reader.delete();


            out_file = fullfile(obj.test_folder,'test_mangling_v2.sqw');
            clOb = onCleanup(@()delete(out_file));

            v2wr = faccess_sqw_v2(sq_obj,out_file);
            v2r_tester = v2r_tester.init(v2wr);
            assertTrue(v2r_tester.is_mangled);

            v2wr = v2wr.put_sqw();
            v2wr.delete();

            v2reader = faccess_sqw_v2(out_file);
            v2r_tester = v2r_tester.init(v2reader);
            assertTrue(v2r_tester.is_mangled);
            v2reader.delete();

        end

        %-----------------------------------------------------------------
        function obj = test_get_main_header_form(obj)
            tob = sqw_binfile_common_tester();
            mh = tob.get_main_header_form();

            fn = fieldnames(mh);
            memb = ismember(fn,{'filename_with_cdate','filepath','title','nfiles'});
            assertTrue(all(memb));

            mh = tob.get_main_header_form('-const');
            fn = fieldnames(mh);
            memb = ismember(fn,{'nfiles'});
            assertTrue(all(memb));
        end
        function obj = test_get_header_form(obj)
            tob = sqw_binfile_common_tester();

            mh = tob.get_header_form();

            sample_const = {'efix','emode','alatt','angdeg',...
                'cu','cv','psi','omega','dpsi','gl','gs','en',...
                'uoffset','u_to_rlu','ulen','ulabel'};
            sample_var =  {'filename','filepath'};
            tot = [sample_var(:);sample_const(:)];

            fn = fieldnames(mh);
            memb = ismember(fn,tot);
            assertTrue(all(memb));

            mh = tob.get_header_form('-const');
            fn = fieldnames(mh);
            memb = ismember(fn,sample_const);
            assertTrue(all(memb));
        end
        function obj = test_get_detpar_form(obj)
            tob = sqw_binfile_common_tester();

            mh = tob.get_detpar_form();

            sample_const = {'ndet','group','x2','phi','azim','width','height'};
            sample_var =  {'filename','filepath'};
            tot = [sample_var(:);sample_const(:)];

            fn = fieldnames(mh);
            memb = ismember(fn,tot);
            assertTrue(all(memb));

            mh = tob.get_detpar_form('-const');
            fn = fieldnames(mh);
            memb = ismember(fn,sample_const);
            assertTrue(all(memb));

        end
        %
        function obj = test_get_data_form(obj)
            tob = sqw_binfile_common_tester();

            mh = tob.get_dnd_form();

            var_fields = {'filename','filepath','title'};
            const_fields={'alatt','angdeg','offset','u_to_rlu',...
                'ulen','label','npax','iax','iint','pax','p_size','p',...
                'dax','s','e','npix'};
            tot = [var_fields(:);const_fields(:)];

            fn = fieldnames(mh);
            memb = ismember(fn,tot);
            assertTrue(all(memb));

            mh = tob.get_dnd_form('-const');
            fn = fieldnames(mh);
            memb = ismember(fn,const_fields);
            assertTrue(all(memb));

            tob = sqw_binfile_common_tester();

            mh = tob.get_dnd_form('-const','-head');
            fn = fieldnames(mh);
            ch ={'alatt','angdeg','offset','u_to_rlu',...
                'ulen','label','npax','iax','iint','pax','p_size','p',...
                'dax'};
            memb = ismember(fn,ch);
            assertTrue(all(memb));


            mh = tob.get_dnd_form('-head');
            fn = fieldnames(mh);

            var_fields = {'filename','filepath','title'};
            tot_head =[var_fields(:);ch(:)];
            memb = ismember(fn,tot_head);
            assertTrue(all(memb));

            tob = tob.set_data_type('a');
            mh = tob.get_dnd_form();
            fn = fieldnames(mh);
            memb = ismember(fn,tot);
            assertTrue(all(memb));
        end
        %
    end
end

