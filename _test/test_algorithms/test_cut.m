classdef test_cut < TestCase & common_state_holder
    % Testing cuts and comparing the results against the reference cuts.
    %
    % This is a non-standard test class, as it compares cut
    % against saved reference, but the reference is not saved as .mat file
    % as in normal TestCaseWithSave classes, but stored as binary sqw file.
    %
    % The interface made similar to TestCaseWithSave classes but is a bit simpler:
    % If the constructor is called with '-save' option, the reference cut
    % is generated afresh.
    % The tests are run and compared against reference cut regardless of
    % '-save' option provided as input to the constructor.
    % Reference cut is generated in the constructor if '-save' option is
    % provided
    properties
        FLOAT_TOL = 1e-5;

        sqw_file = '../test_sym_op/test_cut_sqw_sym.sqw';
        dnd_file = '../common_data/w1d_d1d.sqw';
        ref_cut_file = 'test_cut_ref_sqw.sqw'
        ref_params = { ...
            ortho_proj([1, -1 ,0], [1, 1, 0]/sqrt(2), 'offset', [1, 1, 0], 'type', 'paa'), ...
            [-0.1, 0.025, 0.1], ...
            [-0.1, 0.025, 0.1], ...
            [-0.1, 0.1], ...
            [105, 1, 114], ...
            };
        sqw_4d;
        working_dir;
    end

    methods

        function obj = test_cut(varargin)
            save_reference = false;
            if nargin == 0
                name = 'test_cut';
            else
                if strcmpi(varargin{1},'-save')
                    save_reference = true;
                    name = 'test_cut';
                else
                    name = varargin{1};
                    if nargin>1 && strcmpi(varargin{2},'-save')
                        save_reference = true;
                    end
                end
            end
            obj = obj@TestCase(name);
            obj.sqw_4d = read_sqw(obj.sqw_file);
            obj.working_dir = tmp_dir();

            %
            if save_reference
                fprintf('*** Rebuilding and overwriting reference cut file %s\n',...
                    obj.ref_cut_file);
                sqw_cut = cut(obj.sqw_file, obj.ref_params{:});
                save(sqw_cut,obj.ref_cut_file);
            end
        end
        %
        function test_take_a_cut_from_an_sqw_object(obj)
            %sqw_obj = read_sqw(obj.sqw_file);
            sqw_obj = obj.sqw_4d; % it have just been read in constructor
            ref_par = obj.ref_params;
            sqw_cut = cut(sqw_obj,ref_par{:});
            %
            % offset is currently expressed in hkl
            assertElementsAlmostEqual(sqw_cut.data.offset,obj.ref_params{1}.offset);

            ref_sqw = read_sqw(obj.ref_cut_file);

            assertEqualToTol(sqw_cut, ref_sqw, obj.FLOAT_TOL, ...
                'ignore_str', true,'-ignore_date');

        end

        function test_take_a_cut_with_nopix_argument(obj)
            sqw_cut = cut(obj.sqw_file, obj.ref_params{:}, '-nopix');

            ref_sqw = read_dnd(obj.ref_cut_file);
            assertEqualToTol(sqw_cut, ref_sqw, 1e-5, 'ignore_str', true);
        end

        function test_taking_cut_of_array_of_sqw(obj)
            sqw_obj1 = sqw(obj.sqw_file);
            sqw_obj2 = sqw(obj.sqw_file);

            out_sqw = cut([sqw_obj1, sqw_obj2], obj.ref_params{:});
            assertEqual(out_sqw(1),out_sqw(2))
        end

        function test_take_a_cut_integrating_over_more_than_1_axis(obj)
            proj = ortho_proj([1, -1 ,0], [1, 1, 0], 'offset', [1, 1, 0], 'type', 'paa');

            u_axis_lims = [-0.1, 0.025, 0.1];
            v_axis_lims = [-0.1, 0.1];
            w_axis_lims = [-0.1, 0.1];
            en_axis_lims = [105, 1, 114];

            dnd_cut = cut(...
                obj.sqw_file, proj, u_axis_lims, v_axis_lims, w_axis_lims, ...
                en_axis_lims, '-nopix' ...
                );

            assertEqual(numel(dnd_cut.pax), 2);
        end

        function test_cut_from_an_sqw_file_to_another_sqw_file(obj)
            conf = hor_config();
            old_conf = conf.get_data_to_store();
            conf.mem_chunk_size = 4000;
            cleanup = onCleanup(@() set(hor_config, old_conf));

            outfile = fullfile(obj.working_dir, 'tmp_outfile.sqw');
            ret_sqw = cut(obj.sqw_file, obj.ref_params{:}, outfile);
            cleanup = onCleanup(@() clean_up_file(outfile));

            runid = unique(ret_sqw.pix.run_idx);
            assertEqual(runid,ret_sqw.experiment_info.expdata.get_run_ids());

            loaded_cut = read_sqw(outfile);

            assertEqualToTol(ret_sqw, loaded_cut, obj.FLOAT_TOL, 'ignore_str', true);
        end
        %
        function test_cut_from_an_sqw_file_to_another_sqw_file_combined_mex(obj)
            conf = hor_config();
            old_conf = conf.get_data_to_store();
            conf.mem_chunk_size = 2000;
            clear_fb_cut_buf_settings = onCleanup(@() set(hor_config, old_conf));
            hpc = hpc_config;
            old_hpc = hpc.get_data_to_store();
            hpc_cleanup = onCleanup(@() set(hpc, old_hpc ));
            hpc.combine_sqw_using = 'mex';
            %
            ref_obj= copy(obj.sqw_4d); % it has been read in constructor
            %ref_obj.pix.signal = 1:ref_obj.pix.num_pixels;
            %ref_obj.pix.data = single(ref_obj.pix.data);
            ref_tfile = fullfile(obj.working_dir, 'mex_combine_source_from_file_to_file.sqw');
            rf_cleanup = onCleanup(@()delete(ref_tfile ));
            save(ref_obj,ref_tfile);

            % test filebased cut
            outfile = fullfile(obj.working_dir, 'mex_combine_cut_from_file_to_file.sqw');
            cut(ref_tfile, obj.ref_params{:}, outfile);
            clear clear_fb_cut_buf_settings;
            clear_targ_file = onCleanup(@() clean_up_file(outfile));

            loaded_cut = read_sqw(outfile);

            % reference memory-based cut
            ref_par = obj.ref_params;
            ref_cut = cut(ref_obj,ref_par{:});


            assertEqualToTol(ref_cut, loaded_cut, obj.FLOAT_TOL, 'ignore_str', true);
        end


        function test_cut_from_an_sqw_file_to_another_sqw_file_combined_nomex(obj)
            conf = hor_config();
            old_conf = conf.get_data_to_store();
            conf.mem_chunk_size = 2000;
            cleanup = onCleanup(@() set(hor_config, old_conf));
            hpc = hpc_config;
            old_hpc = hpc.get_data_to_store();
            hpc_cleanup = onCleanup(@() set(hpc, old_hpc ));
            hpc.combine_sqw_using = 'matlab';

            % test filebased cut
            outfile = fullfile(obj.working_dir, 'nomex_combine_cut_from_file_to_file.sqw');
            cut(obj.sqw_file, obj.ref_params{:}, outfile);
            cleanup = onCleanup(@() clean_up_file(outfile));

            loaded_cut = sqw(outfile);

            % reference memory-based cut
            sqw_obj = obj.sqw_4d; % it have just been read in constructor
            ref_par = obj.ref_params;
            ref_cut = cut(sqw_obj,ref_par{:});


            assertEqualToTol(ref_cut, loaded_cut, obj.FLOAT_TOL, 'ignore_str', true);
        end


        function test_cut_from_an_sqw_object_to_an_sqw_file(obj)
            conf = hor_config();
            old_conf = conf.get_data_to_store();
            conf.mem_chunk_size = 4000;
            cleanup = onCleanup(@() set(hor_config, old_conf));

            sqw_obj = read_sqw(obj.sqw_file);

            outfile = fullfile(tmp_dir, 'test_cut_from_obj_to_file.sqw');

            cut(sqw_obj, obj.ref_params{:}, outfile);
            cleanup = onCleanup(@() clean_up_file(outfile));

            loaded_cut = read_sqw(outfile);
            ref_cut = read_sqw(obj.ref_cut_file);

            assertEqualToTol(loaded_cut, ref_cut, obj.FLOAT_TOL, ...
                'ignore_str', true,'-ignore_date');

        end

        function test_you_can_take_a_cut_from_a_dnd_object(obj)
            dnd_obj = read_dnd(obj.sqw_file);

            u_axis_lims = [-0.1, 0.024, 0.1];
            v_axis_lims = [-0.1, 0.024, 0.1];
            w_axis_lims = [-0.1, 0.1];
            en_axis_lims = [105, 1, 114];
            res = cut(dnd_obj, u_axis_lims, v_axis_lims, w_axis_lims, en_axis_lims);
            assertTrue(isa(res, 'd3d'));

            % We expect 3 dimensions since we are integrating over w (u3), as
            % numel(w_axis_lims) = 2.
            % We expect 9 in the u dimension because the range defined in
            % u_axis_lims has 9 steps - you can justify this to yourself by
            % evaluating `numel(u_axis_lims(1):u_axis_lims(2):u_axis_lims(3))`.
            % For similar reasons, v and en have 9 and 10 dims respectively.
            expected_img_size = [11,11, 10];
            assertEqual(size(res.s), expected_img_size);
        end

        function test_you_can_take_multiple_cuts_over_integration_axis(obj)
            proj = ortho_proj([1, -1 ,0], [1, 1, 0], 'offset', [1, 1, 0], 'type', 'paa');

            u_axis_lims = [-0.1, 0.025, 0.1];
            v_axis_lims = [-0.1, 0.025, 0.1];
            w_axis_lims = [-0.1, 0.1];

            % Short-hand for defining multiple integration ranges (as opposed to a loop).
            en_axis_lims = [106, 4, 114, 4];
            % The indices are as follows:
            %   1 - first range center
            %   2 - distance between range centers
            %   3 - final range center
            %   4 - range width
            % Hence the above limits define three cuts, each cut integrating over a
            % different energy range. The first range being 104-108, the second
            % 108-112 and the third 112-116.

            sqw_obj = sqw(obj.sqw_file);
            res = cut(...
                sqw_obj, proj, u_axis_lims, v_axis_lims, w_axis_lims, en_axis_lims ...
                );

            expected_en_int_lims = {[104, 108], [108, 112], [112, 116]};

            assertTrue(isa(res, 'sqw'));
            assertEqual(size(res), [3, 1]);
            for i = 1:numel(res)
                assertEqual(size(res(i).data.s), [9, 9]);
                assertEqual(res(i).data.iint(3:4), expected_en_int_lims{i});
            end
        end

        function test_you_can_take_multiple_cuts_over_int_axis_with_nopix(obj)
            proj = ortho_proj([1, -1 ,0], [1, 1, 0], 'uoffset', [1, 1, 0], 'type', 'paa');

            u_axis_lims = [-0.1, 0.025, 0.1];
            v_axis_lims = [-0.1, 0.025, 0.1];
            w_axis_lims = [-0.1, 0.1];
            en_axis_lims = [106, 4, 114, 4];

            sqw_obj = sqw(obj.sqw_file);
            res = cut(...
                sqw_obj, proj, u_axis_lims, v_axis_lims, w_axis_lims, ...
                en_axis_lims, '-nopix' ...
                );

            expected_en_int_lims = {[104, 108], [108, 112], [112, 116]};

            assertTrue(isa(res, 'd2d'));
            assertEqual(size(res), [3, 1]);
            for i = 1:numel(res)
                assertEqual(size(res(i).s), [9, 9]);
                assertEqual(res(i).iint(3:4), expected_en_int_lims{i});
            end
            % First two cuts are in range of data, final cut is out of range so
            % should have no pixel contributions
            assertFalse(all(res(1).s(:) == 0));
            assertFalse(all(res(2).s(:) == 0));
            assertEqual(res(3).s, zeros(9, 9));
            assertEqual(res(3).e, zeros(9, 9));
        end

        function test_cut_errors_before_cut_taken_if_outfile_cannot_be_created(obj)
            % If the outfile cannot be created, we want to know before we carry out
            % the potentially expensive cut.
            % We check that the error  is raised early by checking the error's ID,
            % which is different if writing fails after the cut is complete.
            outfile = fullfile('P:', 'not', 'a_valid', 'path.sqw');

            f = @() cut(obj.sqw_file, obj.ref_params{:}, outfile);
            assertExceptionThrown(f, 'HORACE:cut:invalid_argument');
        end

        function test_error_raised_if_cut_called_with_multiple_files(obj)
            f = @() cut({obj.sqw_file, obj.sqw_file}, obj.ref_params{:});
            assertExceptionThrown(f, 'HORACE:cut:invalid_argument');
        end

        function test_you_can_take_an_out_of_memory_cut_with_tmp_files_with_mex(obj)
            skipTest('Ticket #896: mex cutting is disabled for the time being')
            mem_chunk_size = 5e5/36;  % this gives two pages of pixels over obj.sqw_file
            outfile = fullfile(tmp_dir, 'tmp_outfile.sqw');
            cleanup_config = set_temporary_config_options( ...
                hor_config, ...
                'mem_chunk_size', mem_chunk_size, ...
                'use_mex', true ...
                );

            cut(obj.sqw_file, obj.ref_params{:}, outfile);
            cleanup_tmp_file = onCleanup(@() clean_up_file(outfile));

            ref_sqw = sqw(obj.ref_cut_file);
            output_sqw = sqw(outfile);
            %HACK: reference stored in binary file and one obtained from
            %cut contains different representation of empty instruments
            % these representations have to be aligned

            ref_sqw.experiment_info.samples = output_sqw.experiment_info.samples;
            ref_sqw.experiment_info.instruments = output_sqw.experiment_info.instruments;
            assertEqualToTol(output_sqw, ref_sqw, obj.FLOAT_TOL, 'ignore_str', true);
            skipTest('SAMPLE COMPARISON and instrument comparison are disabled as some routes ignore empty samples/instruments')
        end

        function test_you_can_take_an_out_of_memory_cut_with_tmp_files_no_mex(obj)
            mem_chunk_size = 5e5/36;  % this gives two pages of pixels over obj.sqw_file
            outfile = fullfile(tmp_dir, 'tmp_outfile.sqw');
            hc = hor_config;
            cleanup_config_handle = set_temporary_config_options( ...
                hc, ...
                'mem_chunk_size', mem_chunk_size, ...
                'use_mex', false ...
                );

            cut(obj.sqw_file, obj.ref_params{:}, outfile);
            cleanup_tmp_file = onCleanup(@() clean_up_file(outfile));

            ref_sqw = sqw(obj.ref_cut_file);
            output_sqw = sqw(outfile);
            %
            contrubuted_keys = output_sqw.runid_map.keys;
            contrib_ind  = [contrubuted_keys{:}];
            real_contr_ind = unique(ref_sqw.pix.run_idx);
            assertTrue(all(ismember(contrib_ind,real_contr_ind)));

            contr_headers = output_sqw.experiment_info.get_subobj(contrib_ind);
            assertEqual(contr_headers,output_sqw.experiment_info);

            assertEqualToTol(output_sqw, ref_sqw, obj.FLOAT_TOL, ...
                'ignore_str', true,'-ignore_date');
            clear cleanup_config_handle;
        end

        function test_calling_cut_with_no_outfile_and_no_nargout_throws_error(obj)
            f = @() cut(obj.sqw_file, obj.ref_params{:});
            assertExceptionThrown(f, 'HORACE:cut:invalid_argument');
        end

        function test_you_can_take_a_cut_with_nopix_arg_and_output_to_file(obj)
            outfile = fullfile(tmp_dir, 'tmp_outfile.sqw');
            cut(obj.sqw_file, obj.ref_params{:}, outfile, '-nopix')
            cleanup = onCleanup(@() clean_up_file(outfile));

            assertTrue(logical(exist(outfile, 'file')));
            ldr = sqw_formats_factory.instance().get_loader(outfile);
            output_obj = ldr.get_dnd();
            ref_object = read_dnd(obj.ref_cut_file);

            assertEqualToTol(output_obj, ref_object, ...
                'ignore_str', true,'abstol',2.e-7);
        end
        %-------------------------------------------------------------------
        function test_cut_dnd_multiple_obj_same_type_cell(obj)
            indata = {dnd_multicut_tester(),dnd_multicut_tester()};
            cuts = cut_dnd(indata,'-cell', obj.ref_params{:});
            assertEqual(numel(cuts),2)
            assertEqual(cuts',indata);
        end

        function test_cut_dnd_multiple_obj_array(obj)
            indata = {dnd_multicut_tester(),dnd_multicut_tester()};
            cuts = cut_dnd(indata, obj.ref_params{:});
            assertEqual(numel(cuts),2)
            assertEqual(cuts(1),indata{1});
            assertEqual(cuts(2),indata{2});
        end

        function test_cut_dnd_multiple_obj(obj)
            indata = {dnd_multicut_tester(),dnd_multicut_tester()};
            [cut1,cut2] = cut_dnd(indata, obj.ref_params{:});
            assertEqual(cut1,indata{1});
            assertEqual(cut2,indata{2});
        end
        function test_cut_dnd_wrapper(obj)
            indata = dnd_multicut_tester();
            cut1 = cut_dnd(indata, obj.ref_params{:});
            assertEqual(cut1,indata);
        end
        %-------------------------------------------------------------------
        function test_cut_hor_multiple_obj_same_type_cell(obj)
            indata = {sqw_multicut_tester(),sqw_multicut_tester()};
            cuts = cut_horace(indata,'-cell', obj.ref_params{:});
            assertEqual(numel(cuts),2)
            assertEqual(cuts',indata);
        end

        function test_cut_hor_multiple_obj_array(obj)
            indata = {sqw_multicut_tester(),sqw_multicut_tester()};
            cuts = cut_horace(indata, obj.ref_params{:});
            assertEqual(numel(cuts),2)
            assertEqual(cuts(1),indata{1});
            assertEqual(cuts(2),indata{2});
        end
        function test_cut_hor_multiple_obj(obj)
            indata = {sqw_multicut_tester(),sqw_multicut_tester()};
            [cut1,cut2] = cut_horace(indata, obj.ref_params{:});
            assertEqual(cut1,indata{1});
            assertEqual(cut2,indata{2});
        end
        function test_cut_hor_wrapper_dnd(obj)
            indata = dnd_multicut_tester();
            cut1 = cut_horace(indata, obj.ref_params{:});
            assertEqual(cut1,indata);
        end
        function test_cut_horace_wrapper_sqw(obj)
            indata = sqw_multicut_tester();
            cut1 = cut_horace(indata, obj.ref_params{:});
            assertEqual(cut1,indata);
        end
        %-------------------------------------------------------------------
        function test_cut_sqw_multiple_obj_same_type_cell(obj)
            indata = {sqw_multicut_tester(),sqw_multicut_tester()};
            cuts = cut_sqw(indata,'-cell', obj.ref_params{:});
            assertEqual(numel(cuts),2)
            assertEqual(cuts',indata);
        end

        function test_cut_sqw_multiple_obj_array(obj)
            indata = {sqw_multicut_tester(),sqw_multicut_tester()};
            cuts = cut_sqw(indata, obj.ref_params{:});
            assertEqual(numel(cuts),2)
            assertEqual(cuts(1),indata{1});
            assertEqual(cuts(2),indata{2});
        end

        function test_cut_sqw_multiple_obj(obj)
            indata = {sqw_multicut_tester(),sqw_multicut_tester()};
            [cut1,cut2] = cut_sqw(indata, obj.ref_params{:});
            assertEqual(cut1,indata{1});
            assertEqual(cut2,indata{2});
        end
        function test_cut_sqw_wrapper(obj)
            indata = sqw_multicut_tester();
            cut1 = cut_sqw(indata, obj.ref_params{:});
            assertEqual(cut1,indata);
        end
        %-------------------------------------------------------------------
        function test_fake_cut_multiple_obj_same_type_cell(obj)
            indata = {sqw_multicut_tester(),sqw_multicut_tester()};
            cuts = cut(indata,'-cell', obj.ref_params{:});
            assertEqual(numel(cuts),2)
            assertEqual(cuts,indata');
        end

        function test_fake_cut_multiple_obj_array(obj)
            indata = {sqw_multicut_tester(),sqw_multicut_tester()};
            cuts = cut(indata, obj.ref_params{:});
            assertEqual(numel(cuts),2)
            assertEqual(cuts(1),indata{1});
            assertEqual(cuts(2),indata{2});
        end

        function test_fake_cut_multiple_obj_cell(obj)
            indata = {sqw_multicut_tester(),dnd_multicut_tester()};
            cuts = cut(indata, obj.ref_params{:});
            assertEqual(cuts{1},indata{1});
            assertEqual(cuts{2},indata{2});
        end
        function test_fake_cut_multiple_obj(obj)
            indata = {sqw_multicut_tester(),dnd_multicut_tester()};
            [cut1,cut2] = cut(indata, obj.ref_params{:});
            assertEqual(cut1,indata{1});
            assertEqual(cut2,indata{2});
        end
        %------------------------------------------------------------------

        function test_take_a_cut_from_multiple_sqw_files(obj)
            conf = hor_config();
            old_conf = conf.get_data_to_store();
            conf.mem_chunk_size = 8000;
            cleanup = onCleanup(@() set(hor_config, old_conf));

            files = {obj.sqw_file,obj.sqw_file};
            [sqw_cut1,sqw_cut2] = cut(files, obj.ref_params{:});
            assertEqualToTol(sqw_cut1,sqw_cut2,'-ignore_date');
        end
        %
        function test_take_a_cut_from_an_sqw_file_single_chunk(obj)
            % Really large file V2 on disk to ensure that ranges are
            % calculated using filebased algorithm rather than all data
            % loaded in memory.
            %v2large_file= 'c:\Users\abuts\Documents\Data\Fe\Data\sqw\Fe_ei1371_base_a.sqw';
            %sqw_cut = cut(v2large_file, obj.ref_params{:});

            conf = hor_config();
            old_conf = conf.get_data_to_store();
            conf.mem_chunk_size = 8000;
            cleanup = onCleanup(@() set(hor_config, old_conf));

            sqw_cut = cut(obj.sqw_file, obj.ref_params{:});

            ref_sqw = read_sqw(obj.ref_cut_file);
            assertEqualToTol(sqw_cut, ref_sqw, 1e-5, ...
                'ignore_str', true,'-ignore_date');
        end
        function test_take_cut_dnd_from_sqw_file_throws(obj)
            ex = assertExceptionThrown(@()cut_dnd(obj.sqw_file, obj.ref_params{:}), ...
                'HORACE:cut:invalid_argument');
        end

        function test_take_cut_sqw_from_dnd_file_throws(obj)
            ex = assertExceptionThrown(@()cut_sqw(obj.dnd_file, obj.ref_params{:}), ...
                'HORACE:cut:invalid_argument');
        end
        function test_cut_no_output_no_file_throw(obj)

            assertExceptionThrown(@()cut(obj.dnd_file,obj.ref_params{:}),...
                'HORACE:cut:invalid_argument');
        end
        function test_cut_2inputs_2files_as_cell(obj)
            files = {'file_name1.sqw','file_name2.sqw'};
            inputs = obj.ref_params;
            inputs{end+1} = files;
            [nin,nout,is_file,files,argi] = ...
                dnd_multicut_tester.cut_inputs_tester(2,0,inputs{:});
            assertEqual(nin,2)
            assertEqual(nout,0)
            assertTrue(is_file)
            assertEqual(numel(files),2)
            assertEqual(files{1},'file_name1.sqw')
            assertEqual(files{2},'file_name2.sqw')
            assertEqual(obj.ref_params,argi);
        end


        function test_cut_2inputs_2files_as_params(obj)
            inputs = [obj.ref_params(:);{'file_name1.sqw';'file_name2.sqw'}]';
            [nin,nout,is_file,files,argi] = ...
                dnd_multicut_tester.cut_inputs_tester(2,0,inputs{:});
            assertEqual(nin,2)
            assertEqual(nout,0)
            assertTrue(is_file)
            assertEqual(numel(files),2)
            assertEqual(files{1},'file_name1.sqw')
            assertEqual(files{2},'file_name2.sqw')
            assertEqual(obj.ref_params,argi);
        end

        function test_cut_2inputs_1file_expanded(obj)
            inputs = [obj.ref_params(:);'some_file_name.sqw']';
            [nin,nout,is_file,files,argi] = ...
                dnd_multicut_tester.cut_inputs_tester(2,0,inputs{:});
            assertEqual(nin,2)
            assertEqual(nout,0)
            assertTrue(is_file)
            assertEqual(numel(files),2)
            assertEqual(files{1},'some_file_name_cutN1.sqw')
            assertEqual(files{2},'some_file_name_cutN2.sqw')
            assertEqual(obj.ref_params,argi);
        end

        function test_cut_inputs_one_file_identified(obj)
            inputs = [obj.ref_params(:);'some_file_name.sqw']';
            [nin,nout,is_file,files,argi] = ...
                dnd_multicut_tester.cut_inputs_tester(1,0,inputs{:});
            assertEqual(nin,1)
            assertEqual(nout,0)
            assertTrue(is_file)
            assertEqual(files{1},'some_file_name.sqw')
            assertEqual(obj.ref_params,argi);
        end
        function test_too_many_inputs_ignored(obj)
            [nin,nout,is_file,files,params]= ...
                dnd_multicut_tester.cut_inputs_tester(4,3,obj.ref_params{:});
            assertEqual(nin,3)
            assertEqual(nout,3)
            assertFalse(is_file);
            assertTrue(isempty(files));
            assertEqual(obj.ref_params,params);
        end
        function test_not_enough_outs_throw(obj)
            err = assertExceptionThrown(@()(dnd_multicut_tester.cut_inputs_tester(2,3,obj.ref_params{:})),...
                'HORACE:cut:invalid_argument');
            assertEqual(err.message,'Number of input cut sources (2) is smaller than the number of requested outputs (3)');
        end
        function test_not_enough_files_throw(obj)
            inputs = [obj.ref_params(:);{'file_name1.sqw';'file_name2.sqw'}]';
            err = assertExceptionThrown(@()(dnd_multicut_tester.cut_inputs_tester(3,0,inputs{:})),...
                'HORACE:cut:invalid_argument');
            assertTrue(strncmp(err.message,'Multiple cuts',12));
        end
        function test_zero_nargout_input_without_file_throw(obj)
            assertExceptionThrown(@()(dnd_multicut_tester.cut_inputs_tester(1,0,obj.ref_params{:})),...
                'HORACE:cut:invalid_argument');
        end
    end
end
