classdef test_set_instr_and_sample < TestCase


    properties
        sam1
        sam2
        sam3
        ds
        source_sqw_2d_file_path = '../common_data/sqw_2d_1.sqw';
        clob_holder
        test_sqw_file
    end

    methods

        function obj = test_set_instr_and_sample(~)
            obj = obj@TestCase('test_set_instr_and_sample');

            rootdir = fileparts(fileparts(mfilename('fullpath')));
            testdata = fullfile(rootdir,'common_data','sqwfile_readwrite_testdata_base_objects.mat');
            obj.ds = load(testdata);


            obj.test_sqw_file = ...
                fullfile(tmp_dir,'sqw_test_file_to_set_sample.sqw');
            copyfile(obj.source_sqw_2d_file_path,obj.test_sqw_file);
            obj.clob_holder = onCleanup(@()delete(obj.test_sqw_file));

            % Create three different samples
            obj.sam1=IX_sample(true,[1,1,0],[0,0,1],'cuboid',[0.04,0.03,0.02]);
            obj.sam1.alatt = [3,4,5];
            obj.sam1.angdeg = [91,89,92];
            obj.sam2=IX_sample(true,[1,1,1],[5,0,1],'cuboid',[0.10,0.33,0.22]);
            obj.sam3=IX_sample(true,[1,1,0],[0,0,1],'point',[]);
            obj.sam2.alatt = [5,4,3];
            obj.sam2.angdeg = [92,89,91];
            obj.sam3.alatt = [6,4,4];
            obj.sam3.angdeg = [90,89,91];

        end
        function delete(obj)
            obj.clob_holder = [];
        end
        function test_set_sample(obj)
            % Really large file V2 on disk to ensure that ranges are
            % calculated using filebased algorithm rather than all data
            % loaded in memory.
            %v2large_file= 'c:\Users\abuts\Documents\Data\Fe\Data\sqw\Fe_ei1371_base_a.sqw';
            %set_sample_horace(v2large_file,obj.sam1);
            file_out = set_sample_horace(obj.test_sqw_file,obj.sam1);
            assertTrue(is_file(file_out));
            sqw_out = sqw(file_out); % this currently should construct filebased sqw
            assertTrue(isa(sqw_out,'sqw'))

            hdr = sqw_out.experiment_info;
            assertEqual(hdr(1).samples{1},obj.sam1)
            %hdr = sqw_out.header;
            %assertEqual(hdr{1}.sample,obj.sam1)
            

            sqw_rec = read_sqw(obj.test_sqw_file);
            assertEqual(sqw_rec,sqw_out)
        end
        function test_change_instr_sampl_in_file(obj)
            f1_1_s1_ref=set_header_fudge(obj.ds.f1_1,'sample',obj.sam1);
            f1_1_s2_ref=set_header_fudge(obj.ds.f1_1,'sample',obj.sam2);
            f1_1_s3_ref=set_header_fudge(obj.ds.f1_1,'sample',obj.sam3);

            % Now change the sample in a file
            % -------------------------------
            tmpsqwfile=fullfile(tmp_dir,'test_sqw_file_read_write_tmp.sqw');
            clob1 = onCleanup(@()delete(tmpsqwfile));

            % Add sam1 to file with f1_1
            save(obj.ds.f1_1,tmpsqwfile);
            set_sample_horace(tmpsqwfile,obj.sam1);
            tmp=read_sqw(tmpsqwfile);
            assertEqualToTol(f1_1_s1_ref,tmp,[5.e-8,5.e-8], ...
                '-ignore_date', 'ignore_str',1);

            % Now add a longer sample - this should be appended to the end
            set_sample_horace(tmpsqwfile,obj.sam2);
            tmp=sqw(tmpsqwfile);
            assertEqualToTol(f1_1_s2_ref,tmp,[5.e-8,5.e-8], ...
                '-ignore_date','ignore_str',1); 

            % Now add a longer sample still - but shorter than the sum of sam1 and sam2: should overwrite
            set_sample_horace(tmpsqwfile,obj.sam3);
            tmp=sqw(tmpsqwfile);
            assertEqualToTol(f1_1_s3_ref,tmp,[5.e-8,5.e-8], ...
                '-ignore_date','ignore_str',1);

            % Dummy sample, empty sample
            set_sample_horace(tmpsqwfile,[]);
            tmp=sqw(tmpsqwfile);
            assertEqualToTol(obj.ds.f1_1,tmp,[5.e-8,5.e-8], ...
                '-ignore_date','ignore_str',1); 

        end

    end
end
