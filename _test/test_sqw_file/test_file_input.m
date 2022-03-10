classdef  test_file_input < TestCase & common_sqw_file_state_holder
    % Tests functionality of methods that can take object or file input
    %
    % Author: T.G.Perring

    %banner_to_screen(mfilename)
    properties
        sqw1d_arr
        sqw2d_arr
        d1d_arr
        d2d_arr
        sqw1d_name
        sqw2d_name
        d1d_name
        d2d_name

        refcount_;
        clob_obj_
    end

    methods
        function obj = test_file_input(varargin)
            if nargin > 0
                name = varargin{1};
            else
                name= mfilename('class');
            end
            obj=obj@TestCase(name);
            persistent t_sqw1d_arr;
            persistent t_sqw2d_arr;
            persistent t_d1d_arr;
            persistent t_d2d_arr;
            global test_file_input_refcount;

            % =================================================================================================
            % Read in test data sets
            % =================================================================================================
            % Note: this function assumes that read(sqw,sqwfilename) works correctly

            [~,~,~,~,t_sqw1d_name,t_sqw2d_name,t_d1d_name,t_d2d_name]=create_testdata('get f-names');
            if isempty(t_sqw1d_arr) || ~(exist(t_sqw1d_name{1},'file')==2)
                [t_sqw1d_arr,t_sqw2d_arr,t_d1d_arr,t_d2d_arr]=create_testdata();
                test_file_input_refcount = 1;
            else
                test_file_input_refcount = test_file_input_refcount + 1;
            end
            obj.sqw1d_arr = t_sqw1d_arr;
            obj.sqw2d_arr = t_sqw2d_arr;
            obj.d1d_arr   = t_d1d_arr;
            obj.d2d_arr   = t_d2d_arr;
            obj.sqw1d_name= t_sqw1d_name;
            obj.sqw2d_name= t_sqw2d_name;
            obj.d1d_name  = t_d1d_name;
            obj.d2d_name = t_d2d_name;

            obj.clob_obj_ = onCleanup(@()clearer());
            %
            function clearer()
                if exist('test_file_input','file')==2
                    tearDown(obj);
                end
            end

        end
        %
        function obj=setUp(obj)
            % =================================================================================================
            % Read in test data sets
            % =================================================================================================
            % Note: this function assumes that read(sqw,sqwfilename) works correctly
            global test_file_input_refcount;


            [~,~,~,~,t_sqw1d_name,t_sqw2d_name,t_d1d_name,t_d2d_name]=create_testdata('get f-names');
            if isempty(obj.sqw1d_arr) || ~(exist(t_sqw1d_name{1},'file')==2)
                [t_sqw1d_arr,t_sqw2d_arr,t_d1d_arr,t_d2d_arr]=create_testdata();
                test_file_input_refcount = 1;
                obj.sqw1d_arr = t_sqw1d_arr;
                obj.sqw2d_arr = t_sqw2d_arr;
                obj.d1d_arr   = t_d1d_arr;
                obj.d2d_arr   = t_d2d_arr;
                obj.sqw1d_name= t_sqw1d_name;
                obj.sqw2d_name= t_sqw2d_name;
                obj.d1d_name  = t_d1d_name;
                obj.d2d_name = t_d2d_name;
            end
            %
            obj.refcount_ = test_file_input_refcount;

        end
        %
        function obj=tearDown(obj)
            clearUp(obj);
        end
        %
        function clearUp(obj)
            global test_file_input_refcount;
            test_file_input_refcount = test_file_input_refcount -1;
            if test_file_input_refcount  <= 0
                try
                    for i=1:numel(obj.sqw1d_name), delete(obj.sqw1d_name{i}); end
                    for i=1:numel(obj.sqw2d_name), delete(obj.sqw2d_name{i}); end
                    for i=1:numel(obj.d1d_name), delete(obj.d1d_name{i}); end
                    for i=1:numel(obj.d2d_name), delete(obj.d2d_name{i}); end
                catch
                    %disp('TEST_FILE_INPUT: Unable to delete temporary file(s)');
                end
            end
            %delete@handle(obj);
        end

        % =================================================================================================
        % Perform tests
        % =================================================================================================
        function obj = test_normal_buf(obj)
            obj=obj.input_operations();
        end

        function obj = test_crossbuf_io(obj)
            hc = hor_config;
            mem_chunk_size = hc.mem_chunk_size;
            clob = onCleanup(@()set(hor_config,'mem_chunk_size',mem_chunk_size));

            hc.mem_chunk_size = 2000;

            obj=obj.input_operations();
        end
        %
        function obj = test_normal_file_cut(obj)
            obj=obj.input_operations();
        end
        %
        function obj = test_crossbuf_file_cut(obj)
            hc = hor_config;
            mem_chunk_size = hc.mem_chunk_size;
            clob = onCleanup(@()set(hor_config,'mem_chunk_size',mem_chunk_size));

            hc.mem_chunk_size = 2000;

            obj=obj.input_operations();
        end


        function obj = file_cut_array_vs_file(obj)
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

        function obj = input_operations(obj)
            % =================================================================================================
            % Cuts
            % =================================================================================================

            % Cut of sqw objects or files
            % ---------------------------
            proj2.u=[-1,1,0];
            proj2.v=[1,1,0];

            s1_s=cut(obj.sqw2d_arr(2),proj2,[0.5,0.02,1],[0.9,1.1],[-0.1,0.1],[170,180]);
            s1_f_h=cut(obj.sqw2d_name{2},proj2,[0.5,0.02,1],[0.9,1.1],[-0.1,0.1],[170,180]);
            [ok,mess] = equal_to_tol(s1_s,s1_f_h,'ignore_str',1);
            assertTrue(ok,['Memory based and file based cuts are different: ',mess])

            s1_s_h=cut(obj.sqw2d_arr(2),proj2,[0.5,0.02,1],[0.9,1.1],[-0.1,0.1],[170,180]);
            s1_s_s=cut_sqw(obj.sqw2d_arr(2),proj2,[0.5,0.02,1],[0.9,1.1],[-0.1,0.1],[170,180]);
            s1_f_s=cut_sqw(obj.sqw2d_name{2},proj2,[0.5,0.02,1],[0.9,1.1],[-0.1,0.1],[170,180]);
            try
                s1_s_d=cut_dnd(obj.sqw2d_arr(2),proj2,[0.5,0.02,1],[0.9,1.1],[-0.1,0.1],[170,180]);
                failed=false;
            catch
                failed=true;
            end
            assertTrue(failed,'Should have failed!');

            try
                s1_f_d=cut_dnd(obj.sqw2d_name{2},proj2,[0.5,0.02,1],[0.9,1.1],[-0.1,0.1],[170,180]);
                failed=false;
            catch
                failed=true;
            end
            assertTrue(failed,'Should have failed!');

            [ok,mess] = equal_to_tol(s1_s,s1_s_h);
            assertTrue(ok,['Error in functionality: ',mess])

            [ok,mess] = equal_to_tol(s1_s,s1_s_s);
            assertTrue(ok,['Error in functionality: ',mess])

            [ok,mess] = equal_to_tol(s1_s,s1_f_s,'ignore_str',1);
            assertTrue(ok,['Error in functionality: ',mess])



            % Cut of dnd objects or files
            % ---------------------------
            d1_d=cut(obj.d2d_arr(2),[0.5,0,1.2],[170,180]);
            d1_d_h=cut(obj.d2d_arr(2),[0.5,0,1.2],[170,180]);
            d1_f_h=cut(obj.d2d_name{2},[0.5,0,1.2],[170,180]);

            d1_d_d=cut_dnd(obj.d2d_arr(2),[0.5,0,1.2],[170,180]);
            d1_f_d=cut_dnd(obj.d2d_name{2},[0.5,0,1.2],[170,180]);

            function call_cut_sqw(w)
                % We want to call cut_sqw with an output arg, so no lambda
                d1_d_s=cut_sqw(w,[0.5,0,1.2],[170,180]);
            end

            assertExceptionThrown(@() call_cut_sqw(obj.d2d_arr(2)), 'HORACE:cut_sqw');
            assertExceptionThrown(@() call_cut_sqw(obj.d2d_name{2}), 'HORACE:cut_sqw');

            [ok,mess] = equal_to_tol(d1_d,d1_d_h);
            assertTrue(ok,['Error in functionality: ',mess])

            [ok,mess] = equal_to_tol(d1_d,d1_d_d);
            assertTrue(ok,['Error in functionality: ',mess])

            [ok,mess] = equal_to_tol(d1_d,d1_f_h,'ignore_str',1);
            assertTrue(ok,['Error in functionality: ',mess])

            [ok,mess] = equal_to_tol(d1_d,d1_f_d,'ignore_str',1);
            assertTrue(ok,['Error in functionality: ',mess])

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

            % TODO: disabled - read does not work for dnd objects, an SQW is returned
            %tmp=read(d2d, obj.sqw2d_name{2});
            % COMMENT FOR REVIEWERS - I have replaced read with d2d. Same
            % reasons as above for sqw. Again checking if there is a need
            % for read that I have missed. The result is that this test is
            % now identical to the test two further on from this one.
            tmp=d2d(obj.sqw2d_name{2});
            [ok,mess] = equal_to_tol(obj.d2d_arr(2),tmp,'ignore_str',1);
            assertTrue(ok,['Error in functionality: ',mess])

            tmp=read_dnd(obj.sqw2d_name{2});
            tmp.data.img_db_range = PixelData.EMPTY_RANGE_; % TODO fix this
            [ok,mess] = equal_to_tol(obj.d2d_arr(2),tmp,'ignore_str',1);
            assertTrue(ok,['Error in functionality: ',mess])

            % TODO: disabled - read does not work for dnd objects, an SQW is returned
            %tmp=read(d2d, obj.d2d_name{2});
            tmp=d2d(obj.d2d_name{2});
            [ok,mess] = equal_to_tol(obj.d2d_arr(2),tmp,'ignore_str',1);
            assertTrue(ok,['Error in functionality: ',mess])

            try
                tmp=sqw(obj.d2d_name{2});
                failed=false;
            catch
                failed=true;
            end
            assertTrue(failed,'Should have failed!');

            tmp=read_horace(obj.d2d_name{2});
            [ok,mess] = equal_to_tol(obj.d2d_arr(2),tmp,'ignore_str',1);
            assertTrue(ok,['Error in functionality: ',mess])

            % Read array of files
            tmp=read_horace(obj.sqw2d_name);
            [ok,mess] = equal_to_tol(obj.sqw2d_arr,tmp,'ignore_str',1);
            assertTrue(ok,['Error in functionality: ',mess])

            tmp=read_dnd(obj.sqw2d_name);

            tmp(1).data.img_db_range = PixelData.EMPTY_RANGE_; % TODO:
            tmp(2).data.img_db_range = PixelData.EMPTY_RANGE_; % This should go with refactoring

            [ok,mess] = equal_to_tol(obj.d2d_arr,tmp,'ignore_str',1);
            assertTrue(ok,['Error in functionality: ',mess])

            tmp = repmat(sqw(),1,numel(obj.sqw2d_name));
            for i=1:numel(obj.sqw2d_name)
                name = obj.sqw2d_name(i);
                tmp(i)=sqw(name{1});
            end
            [ok,mess] = equal_to_tol(obj.sqw2d_arr,tmp,'ignore_str',1);
            assertTrue(ok,['Error in functionality: ',mess])
            skipTest('TODO: img_db_range assigned here should not be present on dnd objects')
        end
    end
    %banner_to_screen([mfilename,': Test(s) passed'],'bot')
end
