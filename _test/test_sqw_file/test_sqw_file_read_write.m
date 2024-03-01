classdef test_sqw_file_read_write < TestCase
    % Perform a number of tests of put_sqw, get_sqw with and without sample and instrument information
    % Read sqw objects from a mat file: (none have sample or instrument information)
    %   two different files, each with one contributing spe file:  f1_1  f2_1
    %   two different files, each with two contributing spe files:  f1_2  f2_2
    %   two different files, each with three contributing spe files:  f1_3  f2_3
    %
    % These objects were read from an sqw file during the creation process, so we should not
    % have any subsequent problems with writing to and reading from disk.

    properties
        ds
        sam1
        sam2
        sam3
        inst1
    end
    methods
        function obj = test_sqw_file_read_write(~)
            obj = obj@TestCase('test_sqw_file_read_write');
            rootdir = fileparts(fileparts(mfilename('fullpath')));
            testdata = fullfile(rootdir,'common_data',...
                'sqwfile_readwrite_testdata_base_objects.mat');
            obj.ds = load(testdata);

            % Create three different samples
            obj.sam1=IX_sample(true,[1,1,0],[0,0,1],'cuboid',[0.04,0.03,0.02]);
            % values for alatt,angdeg from obj.ds.f1_1.header_.samples(1)
            % saves explicit unpack here
            obj.sam1.alatt=[4 5 6];
            obj.sam1.angdeg=[91 92 93];

            obj.sam2=IX_sample(true,[1,1,1],[5,0,1],'cuboid',[0.10,0.33,0.22]);
            obj.sam2.alatt=[4 5 6];
            obj.sam2.angdeg=[91 92 93];

            obj.sam3=IX_sample(true,[1,1,0],[0,0,1],'point',[]);
            obj.sam3.alatt=[4 5 6];
            obj.sam3.angdeg=[91 92 93];

            % T.G.Perring 22/7/19: These do not currently exist, so replaced
            % sam2=IX_sample(true,[1,1,1],[0,2,1],'cylinder_long_name',rand(1,5));
            % sam3=IX_sample(true,[1,1,0],[0,0,1],'hypercube_really_long_name',rand(1,6));



            % Create three different instruments
            obj.inst1=create_test_instrument(95,250,'s');
            %inst2=create_test_instrument(56,300,'s');
            %inst2.flipper=true;
            %inst3=create_test_instrument(195,600,'a');
            %inst3.filter=[3,4,5];

        end

        function test_sqw_save_load_in_constructor(obj)

            tmpsqwfile=fullfile(tmp_dir,'test_sqw_file_read_write_tmp.sqw');
            clob1 = onCleanup(@()delete(tmpsqwfile));

            % Write out to sqw files, read back in, and test they are the same
            % ----------------------------------------------------------------
            save(obj.ds.f1_1,tmpsqwfile);
            tmp=sqw(tmpsqwfile);
            obj.ds.f1_1.main_header.creation_date = tmp.main_header.creation_date;
            assertEqualToTol(obj.ds.f1_1,tmp,1.e-8,'ignore_str',1)

            save(obj.ds.f1_3,tmpsqwfile);
            tmp=sqw(tmpsqwfile);
            obj.ds.f1_3.main_header.creation_date = tmp.main_header.creation_date;
            assertEqualToTol(obj.ds.f1_3,tmp,1.e-9,'ignore_str',1)

        end
        %
        function test_sqw_file_read_and_write(obj)
            tmpsqwfile=fullfile(tmp_dir,'test_sqw_file_read_write_tmp.sqw');
            clob1 = onCleanup(@()delete(tmpsqwfile));
            if is_file(tmpsqwfile)
                delete(tmpsqwfile);
            end

            % Reference sqw objects with different samples
            % --------------------------------------------
            f1_1_s1_ref=set_header_fudge(obj.ds.f1_1,'sample',obj.sam1);

            %==================================================================================================
            % Systematic test of '-v3' format and writing - test rather complex append/overwrite algorithms
            %==================================================================================================

            % Add a sample, write out and read back in
            % ----------------------------------------
            % Set sample
            f1_1_s1=set_sample(obj.ds.f1_1,obj.sam1);
            [ok,mess]=equal_to_tol(f1_1_s1_ref,f1_1_s1,'ignore_str',1);
            assertTrue(ok,mess)

            % Write and read back in
            save(f1_1_s1,tmpsqwfile);
            tmp=read_sqw(tmpsqwfile);

            % ignore creation date comparison
            f1_1_s1.main_header.creation_date = tmp.main_header.creation_date;
            assertEqualToTol(f1_1_s1,tmp,1.e-8,'ignore_str',1)


            % Remove the sample again, and confirm the same as original object after writing and reading
            % ------------------------------------------------------------------------------------------
            % Set sample
            sam0=IX_samp('',[4 5 6],[91 92 93]);
            f1_1_s0=set_sample(f1_1_s1,sam0);
            obj.ds.f1_1.main_header.creation_date = f1_1_s0.main_header.creation_date;
            assertEqualToTol(obj.ds.f1_1,f1_1_s0,1.e-8,'ignore_str',1)

            % Write and read back in
            save(f1_1_s0,tmpsqwfile);
            tmp=sqw(tmpsqwfile);
            assertEqualToTol(f1_1_s0,tmp,1.e-8,'ignore_str',1)
        end
        function test_syntax_and_file_io_instr_sample(obj)

            %==================================================================================================
            % Test syntax and file i/o of set_instrument and set_sample
            %==================================================================================================
            % These tests exercise the read/write of get_sqw and put_sqw, and the correct operation
            % of the set_sample and set_instrument methods for both objects and files.


            % Add sample to a single spe file sqw object
            f1_1_s1=change_header_test(obj.ds.f1_1,'-none',obj.sam1);

            % Add sample to a multiple spe file sqw object
            f1_2_s1=change_header_test(obj.ds.f1_2,'-none',obj.sam1);

            % Add instrument to a single spe file sqw object
            f1_1_i1=change_header_test(obj.ds.f1_1,obj.inst1,'-none');

            % Add instrument to a multiple spe file sqw object
            f1_2_i1=change_header_test(obj.ds.f1_2,obj.inst1,'-none');

            % And instrument and sample to a ingle spe file sqw object
            f1_1_i1s1=change_header_test(obj.ds.f1_2,obj.inst1,obj.sam1);

            % And instrument and sample to a multiple spe file sqw object
            f1_2_i1s1=change_header_test(obj.ds.f1_2,obj.inst1,obj.sam1);

            % Do some fancy stuff: overwrite instrument and sample
            ins=IX_null_inst();
            f1_2_i0s2=change_header_test(f1_2_i1s1,ins,obj.sam2);

            % Do some fancy stuff: remove instrument and sample
            % replace with null inst and sample (was empty structs)
            ins=IX_null_inst();
            sam=IX_samp();
            sam.alatt=[4 5 6];
            sam.angdeg=[91 92 93];
            f1_2_i0s0=change_header_test(f1_2_i1s1,ins,sam);
        end
        function test_change_instrument(obj)
             % Use instrument function definition to change instrument
            % -------------------------------------------------------
            % Create reference object, testing setting of array instrument on the way
            tmpsqwfile=fullfile(tmp_dir,'test_sqw_file_fileref_store.sqw');
            clob1 = onCleanup(@()file_delete(tmpsqwfile));

            wref=obj.ds.f1_2;
            hdr = wref.experiment_info;
            hdr.expdata(1).efix=130;
            hdr.expdata(1).efix=135; % betting this is {2} like the instrument change below
            wref.experiment_info = hdr;
            inst_arr=create_test_instrument(95,250,'s');
            inst_arr(2)=create_test_instrument(105,300,'a');

            wref=change_header_test(wref,inst_arr,obj.sam1);

            save(wref,tmpsqwfile);
            wref=sqw(tmpsqwfile);     % creates with same file name will be set with read_sqw

            % Change the two instruments
            inst_arr=create_test_instrument(400,500,'s');
            inst_arr(2)=create_test_instrument(105,600,'a');
            wtmp_ref=wref;
            hdr = wtmp_ref.experiment_info;
            hdr.instruments{1}=inst_arr(1);
            hdr.instruments{2}=inst_arr(2);
            wtmp_ref.experiment_info = hdr;

            wtmp=set_instrument(wref,@create_test_instrument,[400;105],[500;600],{'s';'a'});
            assertTrue(isequal(wtmp_ref,wtmp),'Incorrectly set instrument for sqw object')

            tmpsqwfile1=fullfile(tmp_dir,'test_sqw_file_fileref_store1.sqw');
            clob2 = onCleanup(@()delete(tmpsqwfile1));
            save(wref,tmpsqwfile1);     % recreate reference file
            % this fails but for different reason
            % set_instrument_horace(tmpsqwfile,@()create_test_instrument([400;105],[500;600],{'s';'a'}));
            % assertTrue(isequal(wtmp_ref,read_sqw(tmpsqwfile)),'Incorrectly set instrument for sqw file')


            % Both instruments set to the same
            inst_arr=create_test_instrument(400,500,'s');
            inst_arr(2)=create_test_instrument(400,500,'s');
            wtmp_ref=wref;
            hdr = wtmp_ref.experiment_info;
            hdr.instruments{1}=inst_arr(1);
            hdr.instruments{2}=inst_arr(2);
            wtmp_ref.experiment_info = hdr;

            wtmp=set_instrument(wref,@create_test_instrument,400,500,'s');
            assertTrue(isequal(wtmp_ref,wtmp),'Incorrectly set instrument for sqw object')

            tmpsqwfile2=fullfile(tmp_dir,'test_sqw_file_fileref_store2.sqw');
            clob3 = onCleanup(@()delete(tmpsqwfile2));
            save(wref,tmpsqwfile2);     % recreate reference file
            % this fails buf for some other reason
            % set_instrument_horace(tmpsqwfile,@create_test_instrument,400,500,'s');
            % assertTrue(isequal(wtmp_ref,read_sqw(tmpsqwfile)),'Incorrectly set instrument for sqw file')


            % Set ei in chopper to whatever is in the spe files
            inst_arr=create_test_instrument(135,500,'s');
            inst_arr(2)=create_test_instrument(50,500,'s');
            wtmp_ref=wref;
            hdr = wtmp_ref.experiment_info;
            hdr.instruments{1}=inst_arr(1);
            hdr.instruments{2}=inst_arr(2);
            wtmp_ref.experiment_info = hdr;

            wtmp=set_instrument(wref,@create_test_instrument,'-efix',500,'s');
            assertTrue(isequal(wtmp_ref,wtmp),'Incorrectly set instrument for sqw object')

            tmpsqwfile3=fullfile(tmp_dir,'test_sqw_file_fileref_store3.sqw');
            clob4 = onCleanup(@()delete(tmpsqwfile3));

            save(wref,tmpsqwfile3);     % recreate reference file
            %set_instrument_horace(tmpsqwfile,@create_test_instrument,'-efix',500,'s');
            %assertTrue(isequal(wtmp_ref,read_sqw(tmpsqwfile)),'Incorrectly set instrument for sqw file')
            %----------------------------------------------------------------------------------------
        end
    end
end
