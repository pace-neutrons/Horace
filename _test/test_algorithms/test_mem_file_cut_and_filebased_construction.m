classdef  test_mem_file_cut_and_filebased_construction < TestCase & common_sqw_file_state_holder
    % Tests functionality of methods that can take object or file input
    %
    % Author: T.G.Perring

    properties
        sqw1d_arr
        sqw2d_arr
        d1d_arr
        d2d_arr
        sqw1d_name
        sqw2d_name
        d1d_name
        d2d_name

        clob_obj_;
    end

    methods
        function obj = test_mem_file_cut_and_filebased_construction(varargin)
            if nargin > 0
                name = varargin{1};
            else
                name= mfilename('class');
            end
            obj=obj@TestCase(name);

            % =================================================================================================
            % Read in test data sets
            % =================================================================================================
            % Note: this function assumes that read(sqw,sqwfilename) works correctly
            obj = prepare_testdata(obj);

            obj.clob_obj_ = onCleanup(@()clearUp(obj));
            %

        end
        function delete(obj)
            obj.clob_obj_ = [];
        end
        function obj = prepare_testdata(obj)
            % Function to return sqw and dnd test data and also save the same objects in the temporary folder
            %
            %  >>obj = read_testdata(obj)
            % where obj defiles the following fields
            %   [sqw1d_arr,sqw2d_arr,d1d_arr,d2d_arr,...
            %    sqw1d_name,sqw2d_name,d1d_name,d2d_name]
            %
            %   sqw1d_arr   sqw object array: two 1D cuts
            %   sqw2d_arr   sqw object array: two 2D cuts
            %
            %   d1d_arr     d1d object array: two 1D cuts
            %   d2d_arr     d2d object array: two 2D cuts
            %
            %   sqw1d_name  cell array of the names of the two files with 1D sqw data
            %   sqw2d_name  cell array of the names of the two files with 1D sqw data
            %
            %   d1d_name  cell array of the names of the two files with 1D sqw data
            %   d2d_name  cell array of the names of the two files with 1D sqw data
            %
            % Author: T.G.Perring

            obj.sqw1d_name = cell(2,1);
            obj.sqw1d_name{1}=fullfile(tmp_dir,'test_file_input_sqw_1d_1.sqw');
            obj.sqw1d_name{2}=fullfile(tmp_dir,'test_file_input_sqw_1d_2.sqw');

            obj.sqw2d_name = cell(2,1);
            obj.sqw2d_name{1}=fullfile(tmp_dir,'test_file_input_sqw_2d_1.sqw');
            obj.sqw2d_name{2}=fullfile(tmp_dir,'test_file_input_sqw_2d_2.sqw');

            obj.d1d_name = cell(2,1);
            obj.d1d_name{1}=fullfile(tmp_dir,'test_file_input_d1d_1.d1d');
            obj.d1d_name{2}=fullfile(tmp_dir,'test_file_input_d1d_2.d1d');

            obj.d2d_name = cell(2,1);
            obj.d2d_name{1}=fullfile(tmp_dir,'test_file_input_d2d_1.d2d');
            obj.d2d_name{2}=fullfile(tmp_dir,'test_file_input_d2d_2.d2d');

            % now prepare source data objects
            % now prepare source data objects
            test_root=fileparts(fileparts(which(mfilename)));
            source = fullfile(test_root,'common_data');
            %
            sqw_1d_source = {fullfile(source,'sqw_1d_1.sqw'),...
                fullfile(source,'sqw_1d_2.sqw')};

            obj.sqw1d_arr = repmat(sqw(),1,2);
            obj.sqw1d_arr(1)=read_sqw(sqw_1d_source{1});
            obj.sqw1d_arr(2)=read_sqw(sqw_1d_source{2});

            sqw_2d_source = {fullfile(source,'sqw_2d_1.sqw'),...
                fullfile(source,'sqw_2d_2.sqw')};

            obj.sqw2d_arr = repmat(sqw(),1,2);
            obj.sqw2d_arr(1)=read_sqw(sqw_2d_source{1});
            obj.sqw2d_arr(2)=read_sqw(sqw_2d_source{2});

            obj.d1d_arr=dnd(obj.sqw1d_arr);
            obj.d2d_arr=dnd(obj.sqw2d_arr);
            % prepare source data files
            copyfile(sqw_1d_source{1},obj.sqw1d_name{1},'f');
            copyfile(sqw_1d_source{2},obj.sqw1d_name{2},'f');

            copyfile(sqw_2d_source{1},obj.sqw2d_name{1},'f');
            copyfile(sqw_2d_source{2},obj.sqw2d_name{2},'f');

            save(obj.d1d_arr(1),obj.d1d_name{1});
            save(obj.d1d_arr(2),obj.d1d_name{2});

            save(obj.d2d_arr(1),obj.d2d_name{1});
            save(obj.d2d_arr(2),obj.d2d_name{2});
        end

        function clearUp(obj)
            for i=1:numel(obj.sqw1d_name), delete(obj.sqw1d_name{i}); end
            for i=1:numel(obj.sqw2d_name), delete(obj.sqw2d_name{i}); end
            for i=1:numel(obj.d1d_name), delete(obj.d1d_name{i}); end
            for i=1:numel(obj.d2d_name), delete(obj.d2d_name{i}); end
        end

        % =================================================================================================
        % Perform tests
        % =================================================================================================
        function obj = file_cut_array_vs_file_normal_buf(obj)
            %
            tmp_file=fullfile(tmp_dir,'test_file_input_tmp.sqw');
            tmp0_file=fullfile(tmp_dir,'test_file_input_tmp0.sqw');
            clob1 = onCleanup(@()delete(tmp0_file,tmp_file));


            cut(obj.sqw2d_arr(2),proj2,[0.5,0.02,1],[0.9,1.1],[-0.1,0.1],[170,180],tmp0_file);

            tmp0=sqw(tmp0_file);

            cut_horace(obj.sqw2d_arr(2),proj2,[0.5,0.02,1],[0.9,1.1],[-0.1,0.1],[170,180],tmp_file);
            tmp=sqw(tmp_file); if ~equal_to_tol(tmp0,tmp,'ignore_str',1), assertTrue(false,'Error in functionality'), end

            cut_sqw(obj.sqw2d_arr(2),proj2,[0.5,0.02,1],[0.9,1.1],[-0.1,0.1],[170,180],tmp_file);
            tmp=sqw(tmp_file); if ~equal_to_tol(tmp0,tmp,'ignore_str',1), assertTrue(false,'Error in functionality'), end

            cut_horace(obj.sqw2d_name{2},proj2,[0.5,0.02,1],[0.9,1.1],[-0.1,0.1],[170,180],tmp_file);
            tmp=sqw(tmp_file);
            [ok,mess]=equal_to_tol(tmp0,tmp,'ignore_str',1); assertTrue(ok,['test_file_input: Error in functionality',mess]);

            % looks like waste of time?
            %cut_sqw(obj.sqw2d_name{2},proj2,[0.5,0.02,1],[0.9,1.1],[-0.1,0.1],[170,180],tmp_file);
            %tmp=read(sqw,tmp_file); if ~equal_to_tol(tmp0,tmp,'ignore_str',1), assertTrue(false,'Error in functionality'), end
        end
        function obj = file_cut_array_vs_file_small_buf(obj)
            hc = hor_config;
            mem_chunk_size = hc.mem_chunk_size;
            clob = onCleanup(@()set(hor_config,'mem_chunk_size',mem_chunk_size));

            hc.mem_chunk_size = 2000;

            %
            tmp_file=fullfile(tmp_dir,'test_file_input_tmp.sqw');
            tmp0_file=fullfile(tmp_dir,'test_file_input_tmp0.sqw');
            clob1 = onCleanup(@()delete(tmp0_file,tmp_file));


            cut(obj.sqw2d_arr(2),proj2,[0.5,0.02,1],[0.9,1.1],[-0.1,0.1],[170,180],tmp0_file);

            tmp0=sqw(tmp0_file);

            cut_horace(obj.sqw2d_arr(2),proj2,[0.5,0.02,1],[0.9,1.1],[-0.1,0.1],[170,180],tmp_file);
            tmp=sqw(tmp_file); if ~equal_to_tol(tmp0,tmp,'ignore_str',1), assertTrue(false,'Error in functionality'), end

            cut_sqw(obj.sqw2d_arr(2),proj2,[0.5,0.02,1],[0.9,1.1],[-0.1,0.1],[170,180],tmp_file);
            tmp=sqw(tmp_file); if ~equal_to_tol(tmp0,tmp,'ignore_str',1), assertTrue(false,'Error in functionality'), end

            cut_horace(obj.sqw2d_name{2},proj2,[0.5,0.02,1],[0.9,1.1],[-0.1,0.1],[170,180],tmp_file);
            tmp=sqw(tmp_file);
            [ok,mess]=equal_to_tol(tmp0,tmp,'ignore_str',1); assertTrue(ok,['test_file_input: Error in functionality',mess]);

            % looks like waste of time?
            %cut_sqw(obj.sqw2d_name{2},proj2,[0.5,0.02,1],[0.9,1.1],[-0.1,0.1],[170,180],tmp_file);
            %tmp=read(sqw,tmp_file); if ~equal_to_tol(tmp0,tmp,'ignore_str',1), assertTrue(false,'Error in functionality'), end

        end
        function test_cut_file_singlechunk_vs_memory(obj)
            % ---------------------------
            proj2.u=[-1,1,0];
            proj2.v=[1,1,0];

            s1_s=cut(obj.sqw2d_arr(2),proj2,[0.5,0.02,1],[0.9,1.1],[-0.1,0.1],[170,180]);
            s1_f_h=cut(obj.sqw2d_name{2},proj2,[0.5,0.02,1],[0.9,1.1],[-0.1,0.1],[170,180]);
            [ok,mess] = equal_to_tol(s1_s,s1_f_h,[1.e-7,1.e-7],'ignore_str',1);
            assertTrue(ok,['Memory based and file based cuts are different: ',mess])

        end

        function test_cut_file_multichunk_vs_memory(obj)
            hc = hor_config;
            mem_chunk_size = hc.mem_chunk_size;
            clob = onCleanup(@()set(hor_config,'mem_chunk_size',mem_chunk_size));

            hc.mem_chunk_size = 2000;

            % ---------------------------
            proj2.u=[-1,1,0];
            proj2.v=[1,1,0];

            s1_s=cut(obj.sqw2d_arr(2),proj2,[0.5,0.02,1],[0.9,1.1],[-0.1,0.1],[170,180]);
            s1_f_h=cut(obj.sqw2d_name{2},proj2,[0.5,0.02,1],[0.9,1.1],[-0.1,0.1],[170,180]);
            [ok,mess] = equal_to_tol(s1_s,s1_f_h,[1.e-7,1.e-7],'ignore_str',1);
            assertTrue(ok,['Memory based and file based cuts are different: ',mess])

        end
        function test_cut_dnd_with_proj_fails_on_file_and_memory(obj)

            proj2.u=[-1,1,0];
            proj2.v=[1,1,0];

            assertExceptionThrown(@()cut_dnd(obj.sqw2d_arr(2),proj2,[0.5,0.02,1],[0.9,1.1],[-0.1,0.1],[170,180]), ...
                'HORACE:cut_dnd:invalid_argument');

            skipTest('Does not work and fixe needs cut_dnd to be refactored as proper method similar to cut_sqw.  Ticket #796')
            assertExceptionThrown(@()cut_dnd(obj.sqw2d_name{2},proj2,[0.5,0.02,1],[0.9,1.1],[-0.1,0.1],[170,180]), ...
                'HORACE:cut_dnd:invalid_argument');
        end
        %
        function test_cut_sqw_and_cut_from_sqw_file_and_memory_based(obj)
            hc = hor_config;
            mem_chunk_size = hc.mem_chunk_size;
            clob = onCleanup(@()set(hor_config,'mem_chunk_size',mem_chunk_size));

            hc.mem_chunk_size = 2000;

            % Cut of sqw objects or files
            % ---------------------------
            proj2.u=[-1,1,0];
            proj2.v=[1,1,0];

            s1_s_h=cut(obj.sqw2d_arr(2),proj2,[0.5,0.02,1],[0.9,1.1],[-0.1,0.1],[170,180]);
            s1_s_s=cut_sqw(obj.sqw2d_arr(2),proj2,[0.5,0.02,1],[0.9,1.1],[-0.1,0.1],[170,180]);
            s1_f_s=cut_sqw(obj.sqw2d_name{2},proj2,[0.5,0.02,1],[0.9,1.1],[-0.1,0.1],[170,180]);

            [ok,mess] = equal_to_tol(s1_s_s,s1_s_h);
            assertTrue(ok,['Error in functionality: ',mess])

            [ok,mess] = equal_to_tol(s1_s_h,s1_s_s);
            assertTrue(ok,['Error in functionality: ',mess])

            [ok,mess] = equal_to_tol(s1_s_h,s1_f_s,[1.e-7,1.e-7],'ignore_str',1);
            assertTrue(ok,['Error in functionality: ',mess])
        end

        function test_cut_sqw_fais_on_dnd(obj)

            function d1_d_s=call_cut_sqw(w)
                % We want to call cut_sqw with an output arg, so no lambda
                d1_d_s=cut_sqw(w,[0.5,0,1.2],[170,180]);
            end

            assertExceptionThrown(@() call_cut_sqw(obj.d2d_arr(2)), ...
                'HORACE:cut_sqw:invalid_argument');
            assertExceptionThrown(@() call_cut_sqw(obj.d2d_name{2}), ...
                'HORACE:cut_sqw:invalid_argument');
        end
        %
        function test_cut_dnd_file_and_memory_based(obj)
            % Cut of dnd objects or files
            % ---------------------------
            skipTest("Cut dnd is broken. Ticket #796")
            d1_d=cut(obj.d2d_arr(2),[0.5,0,1.2],[170,180]);
            d1_d_h=cut(obj.d2d_arr(2),[0.5,0,1.2],[170,180]);
            d1_f_h=cut(obj.d2d_name{2},[0.5,0,1.2],[170,180]);

            d1_d_d=cut_dnd(obj.d2d_arr(2),[0.5,0,1.2],[170,180]);
            d1_f_d=cut_dnd(obj.d2d_name{2},[0.5,0,1.2],[170,180]);


            [ok,mess] = equal_to_tol(d1_d,d1_d_h);
            assertTrue(ok,['Error in functionality: ',mess])

            [ok,mess] = equal_to_tol(d1_d,d1_d_d);
            assertTrue(ok,['Error in functionality: ',mess])

            [ok,mess] = equal_to_tol(d1_d,d1_f_h,'ignore_str',1);
            assertTrue(ok,['Error in functionality: ',mess])

            [ok,mess] = equal_to_tol(d1_d,d1_f_d,'ignore_str',1);
            assertTrue(ok,['Error in functionality: ',mess])

        end
        %
        function test_sqw_constructor_throws_on_dnd_file(obj)
            assertExceptionThrown(@()sqw(obj.d2d_name{2}), ...
                'HORACE:sqw:invalid_argument');
        end
        %
        function test_sqw_constructor_equal_to_read_sqw(obj)
            % =================================================================================================
            % Reading data
            % =================================================================================================

            % TODO: disabled - read does not work for dnd objects, an SQW is returned
            %tmp=read(sqw,obj.sqw2d_name{2});
            % COMMENT FOR REVIEWERS - I have replaced read with sqw. In the
            % master branch, read is seen to pass execution directly to
            % sqw(filename), with the first argument just acting as an OO
            % scope. As a result, this test is identical to the next one.
            % Checking there isn't something here I've missed which makes
            % read a necessity, or whether it can be removed.
            tmp=sqw(obj.sqw2d_name{2});
            [ok,mess] = equal_to_tol(obj.sqw2d_arr(2),tmp,'ignore_str',1);
            assertTrue(ok,['Error in functionality: ',mess])

            tmp=sqw(obj.sqw2d_name{2});
            [ok,mess] = equal_to_tol(obj.sqw2d_arr(2),tmp,'ignore_str',1);
            assertTrue(ok,['Error in functionality: ',mess])


            tmp=read_horace(obj.sqw2d_name{2});
            [ok,mess] = equal_to_tol(obj.sqw2d_arr(2),tmp,'ignore_str',1);
            assertTrue(ok,['Error in functionality: ',mess])
        end

        function test_dnd_constructor_equal_to_read_dnd(obj)
            % TODO: disabled - read does not work for dnd objects, an SQW is returned
            %tmp=read(d2d, obj.sqw2d_name{2});
            % COMMENT FOR REVIEWERS - I have replaced read with d2d. Same
            % reasons as above for sqw. Again checking if there is a need
            % for read that I have missed. The result is that this test is
            % now identical to the test two further on from this one.

            tmp=read_dnd(obj.sqw2d_name{2});
            [ok,mess] = equal_to_tol(obj.d2d_arr(2),tmp,'ignore_str',1);
            assertTrue(ok,['Error in functionality: ',mess])

            % TODO: disabled - read does not work for dnd objects, an SQW is returned
            %tmp=read(d2d, obj.d2d_name{2});
            tmp=d2d(obj.d2d_name{2});
            [ok,mess] = equal_to_tol(obj.d2d_arr(2),tmp,'ignore_str',1);
            assertTrue(ok,['Error in functionality: ',mess])


            tmp=read_horace(obj.d2d_name{2});
            [ok,mess] = equal_to_tol(obj.d2d_arr(2),tmp,'ignore_str',1);
            assertTrue(ok,['Error in functionality: ',mess])
        end
        %
        function obj = test_read_horace_multifiled_reads_array_of_sqw(obj)

            % Read array of files
            tmp=read_horace(obj.sqw2d_name);
            [ok,mess] = equal_to_tol(obj.sqw2d_arr,tmp,'ignore_str',1);
            assertTrue(ok,['Error in functionality: ',mess])

        end
        %
        function obj = test_read_dnd_multifiled_reads_array_of_dnd(obj)
            tmp=read_dnd(obj.sqw2d_name);

            [ok,mess] = equal_to_tol(obj.d2d_arr,tmp,'ignore_str',1);
            assertTrue(ok,['Error in functionality: ',mess])

        end
    end
end
