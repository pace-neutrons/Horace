classdef test_cut_multicut < TestCase
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
        ref_params = { ...
            line_proj([1, -1 ,0], [1, 1, 0]/sqrt(2), 'offset', [1, 1, 0], 'type', 'paa'), ...
            [-0.1, 0.025, 0.1], ...
            [-0.1, 0.025, 0.1], ...
            [-0.1, 0.1], ...
            [105, 1, 114], ...
            };
        sqw_4d;
        working_dir;
        old_ws;
    end

    methods

        function obj = test_cut_multicut(varargin)
            if nargin == 0
                name = 'test_cut_multicut';
            else
                name = varargin{1};
            end
            obj = obj@TestCase(name);
            obj.sqw_4d = read_sqw(obj.sqw_file);
            obj.working_dir = tmp_dir();
            obj.old_ws = warning('off','HORACE:old_file_format');
        end


        function test_multiple_cuts_integration_axis(obj)
            proj = line_proj([1, -1 ,0], [1, 1, 0], 'offset', [1, 1, 0], 'type', 'paa');

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

        function test_multiple_cuts_int_axis_nopix(obj)
            proj = line_proj([1, -1 ,0], [1, 1, 0], 'offset', [1, 1, 0], 'type', 'paa');

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

        function test_cut_fail_multiple_files(obj)
            f = @() cut({obj.sqw_file, obj.sqw_file}, obj.ref_params{:});
            assertExceptionThrown(f, 'HORACE:cut:invalid_argument');
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

        function test_multicut_1(obj)
            % Test multicut capability for cuts that are adjacent
            % Note that the last cut has no pixels retained - a good test too!

            range = [0,0.2];    % range of cut
            step = 0.01;        % Q step
            bin = [range(1)+step/2,step,range(2)-step/2];
            width = [-0.15,0.15];  % Width in Ang^-1 of cuts
            args = {obj.ref_params{1}, bin, width, width};

            % Must use '-pix' to properly handle pixel double counting in general
            w1 = cut(obj.sqw_4d, args{:}, [106,4,114,4], '-pix');
            w2 = repmat(sqw,[3,1]);

            for i=1:3
                tmp = cut(obj.sqw_4d, args{:}, 102+4*i+[-2,2], '-pix');
                w2(i) = tmp;
            end
            assertEqualToTol(w1, w2, obj.FLOAT_TOL,'ignore_str',1)

        end

        function test_multicut_2(obj)
            % Test multicut capability for cuts that are adjacent
            % Last couple of cuts have no pixels read or are even outside the range
            % of the input data

            range = [0,0.2];    % range of cut
            step = 0.01;        % Q step
            bin = [range(1)+step/2,step,range(2)-step/2];
            width = [-0.15,0.15];  % Width in Ang^-1 of cuts
            args = {obj.ref_params{1}, bin, width, width};

            % Must use '-pix' to properly handle pixel double counting in general
            w1 = cut(obj.sqw_4d, args{:}, [110,2,118,2], '-pix');
            w2 = repmat(sqw,[5,1]);
            for i=1:5
                w2(i) = cut(obj.sqw_4d, args{:}, 108+2*i+[-1,1], '-pix');
            end
            assertEqualToTol(w1, w2, obj.FLOAT_TOL,'ignore_str',1)

        end

        function test_multicut_3(obj)
            % Test multicut capability for cuts that overlap adjacent cuts

            range = [0,0.2];    % range of cut
            step = 0.01;        % Q step
            bin = [range(1)+step/2,step,range(2)-step/2];
            width = [-0.15,0.15];  % Width in Ang^-1 of cuts
            args = {obj.ref_params{1}, bin, width, width};

            % Must use '-pix' to properly handle pixel double counting in general
            w1 = cut(obj.sqw_4d, args{:}, [106,4,114,8], '-pix');
            w2 = repmat(sqw,[3,1]);
            for i=1:3
                w2(i) = cut(obj.sqw_4d, args{:}, 102+4*i+[-4,4], '-pix');
            end
            assertEqualToTol(w1, w2, obj.FLOAT_TOL,'ignore_str',1)

        end

        %------------------------------------------------------------------

        function test_cut_multiple_sqw_files(obj)
            mem_chunk_size = 8000;
            cleanup_config_handle = set_temporary_config_options( ...
                hor_config, ...
                'mem_chunk_size', mem_chunk_size ...
                );

            files = {obj.sqw_file,obj.sqw_file};
            [sqw_cut1,sqw_cut2] = cut(files, obj.ref_params{:});
            assertEqualToTol(sqw_cut1,sqw_cut2,'-ignore_date');
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
    end
end
