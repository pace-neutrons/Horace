classdef test_upgrade_file_format< TestCase

    properties
        source_mat  = 'testsqw_w3_small_v1.mat'
        source_sqw1 = 'sqw_2d_2.sqw'
        source_sqV4 = 'faccess_sqw_v4_sample.sqw'
        ff_source_mat;
        ff_source_sqw;
        ff_source_sqwV4;
        working_dir
        test_common;
    end
    methods
        %
        function obj=test_upgrade_file_format(name)
            if nargin<1
                name = 'test_upgrade_file_format';
            end
            obj = obj@TestCase(name);
            hc = horace_paths;
            obj.test_common = hc.test_common;
            obj.ff_source_mat  = fullfile(obj.test_common,obj.source_mat);
            obj.ff_source_sqw  = fullfile(obj.test_common,obj.source_sqw1);
            obj.ff_source_sqwV4= fullfile(obj.test_common,obj.source_sqV4);
            obj.working_dir = tmp_dir();
        end
        %
        function test_upgrade_instr_sample_no_hash_to_hash(obj)
            % this file contains old V4 version which do not have hashes
            source = obj.ff_source_sqwV4;
            [clFile,test_fl] = obj.copy_my_file(source);



            facc = sqw_formats_factory.instance().get_loader(test_fl);
            facc = facc{1};
            %
            sam  = facc.get_sample('-all');
            obj.check_container(sam,109)

            ins  = facc.get_instrument('-all');
            obj.check_container(ins,109)

            det  = facc.get_detpar();
            assertTrue(isstruct(det));

            facc.delete();
            clWarn = set_temporary_warning('off','HORACE:test_upgrade_instr_sample');
            warning('HORACE:test_upgrade_instr_sample','test warning issued to ensure other warning do not polute workspace')

            % upgrade instrument, sample and detectors in file to hashable
            % version
            upgrade_file_format(test_fl);
            % no warning about old file format and any other
            [~,wcl] = lastwarn;
            assertEqual(wcl,'HORACE:test_upgrade_instr_sample')

            facc = sqw_formats_factory.instance().get_loader(test_fl);
            facc = facc{1};

            sam  = facc.get_sample('-all');
            obj.check_container(sam,109)

            ins  = facc.get_instrument('-all');
            obj.check_container(ins,109)

            det  = facc.get_detpar();
            obj.check_container(det,109)
        end
        %------------------------------------------------------------------
        function test_upgrade_for_legacy_alignment(obj)
            %
            source = fullfile(obj.test_common,'sqw_4d.sqw');
            [clFile,test_fl] = obj.copy_my_file(source);

            clWarn = set_temporary_warning('off', 'HORACE:old_file_format','HORACE:test_warning');
            warning('HORACE:test_warning','test warning issued to ensure other warning do not polute workspace')
            fl = upgrade_file_format(test_fl);
            [~,wcl] = lastwarn;

            assertEqual(wcl,'SQW_FILE:old_version')
            assertTrue(isa(fl{1},'sqw'));
            assertTrue(fl{1}.is_filebacked);

            obj.check_container(fl{1}.experiment_info.instruments,23);
            obj.check_container(fl{1}.experiment_info.samples,23);            
            obj.check_container(fl{1}.experiment_info.detector_arrays,23);                        
        end
        function test_upgrade_single_sqw_filebacked_noupgrade_range_warning(obj)
            [clFile,targ_f] = obj.copy_my_file(obj.ff_source_sqw);
            clConf = set_temporary_config_options(hor_config, ...
                'mem_chunk_size',10000,'fb_scale_factor',3); % should give 3 pages
            clWarn = set_temporary_warning('off', 'TESTS:my_warning','HORACE:invalid_data_range');
            warning('TESTS:my_warning','This should become the last warning as no other waning were issued on the way');

            upgrade_file_format(targ_f);
            w2  = sqw(targ_f{1});

            [~,e] = lastwarn;
            assertEqual(e,'TESTS:my_warning');
            assertFalse(w2.pix.is_range_valid())

            obj.check_container(w2.experiment_info.instruments,186);
            obj.check_container(w2.experiment_info.samples,186);            
            obj.check_container(w2.experiment_info.detector_arrays,186);                        

        end

        function test_upgrade_single_sqw_filebacked_upgrade_range_no_warning(obj)
            [clFile,targ_f] = obj.copy_my_file(obj.ff_source_sqw);
            clConf = set_temporary_config_options(hor_config, ...
                'mem_chunk_size',10000,'fb_scale_factor',3); % should give 3 pages
            clWarn = set_temporary_warning('off', 'TESTS:my_warning');
            warning('TESTS:my_warning','This should become the last warning as no other waning were issued on the way');

            upgrade_file_format(targ_f,'-upgrade_range');
            w2  = sqw(targ_f{1});

            [~,e] = lastwarn;
            % second warning comes on windows as memmapfile is locked
            % despite being freed by MATLAB. Deletion message is issued but file get deleted through OS
            assertTrue(isequal(e,'TESTS:my_warning')||isequal(e,'MATLAB:DELETE:Permission'));
            assertTrue(w2.pix.is_range_valid())
        end


        function test_upgrade_single_sqw_membased(obj)
            [clOb,targ_f] = obj.copy_my_file(obj.ff_source_sqw);
            upgrade_file_format(targ_f{1});
            w2  = read_sqw(targ_f{1});
            assertTrue(any(w2.pix.data_range(:) ~= PixelData.EMPTY_RANGE(:)) )
        end

        function test_upgrade_single_mat(obj)

            [clOb,targ_f] = obj.copy_my_file(obj.ff_source_mat);
            clWarn = set_temporary_warning('off', ...
                'MATLAB:load:classNotFound','TESTS:my_warning');
            upgrade_file_format(targ_f);
            [~,e] = lastwarn;
            assertEqual(e,'MATLAB:load:classNotFound'); % old file format
            % contains reference to the missing class, so we can identify
            % that this is old file format

            warning('TESTS:my_warning','This should become the last warning');
            ld = load(targ_f{1});
            [~,e] = lastwarn;
            assertEqual(e,'TESTS:my_warning');
            w3  = ld.w3_small_v1;
            assertTrue(any(w3.pix.data_range(:) ~= PixelData.EMPTY_RANGE(:)) )
        end
    end
    methods(Access=private)
        function check_container(~,uob_present,n_runs)
            assertTrue(isa(uob_present,'unique_references_container'));
            assertEqual(uob_present.n_objects,n_runs);
            assertEqual(uob_present.n_unique_objects,1);
            uob_here= uob_present.unique_objects.unique_objects{1};
            % hash has been calculated while putting into urc
            assertTrue(uob_here.hash_defined)
        end

        function [clOb,targ_f] = copy_my_file(obj,flilelist)
            if istext(flilelist)
                filelist = cellstr(flilelist);
            end
            targ_f = cell(numel(filelist),1);
            for i=1:numel(filelist)
                source = filelist{i};
                [~,fn,fe] = fileparts(source);
                target = fullfile(obj.working_dir,[fn,fe]);
                copyfile(source,target,"f");
                targ_f{i} = target;
            end
            clOb = onCleanup(@()del_memmapfile_files(targ_f));
        end
    end
end

