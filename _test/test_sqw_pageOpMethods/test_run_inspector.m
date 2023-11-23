classdef test_run_inspector< TestCase
    %
    % Validate sqw object replication
    %

    properties
        this_dir;
        sqw_source = 'common_data/sqw_4d.sqw'

        source_sqw4D;
        source_sqw2D;
        source_sqw1D;
    end

    methods
        function obj=test_run_inspector(name)
            if ~exist('name','var')
                name = 'test_run_inspector';
            end
            obj=obj@TestCase(name);
            obj.this_dir = fileparts(mfilename('fullpath'));
            [fp,fn,fe] = fileparts(obj.sqw_source);
            source_data = fullfile(fileparts(obj.this_dir),fp,[fn,fe]);
            obj.sqw_source   = source_data;
            obj.source_sqw4D = read_sqw(source_data);
            obj.source_sqw2D = cut(obj.source_sqw4D,[-0.2,0.2],[-0.2,0.2],[],[]);
            obj.source_sqw1D = cut(obj.source_sqw4D,[-0.2,0.2],[-0.2,0.2],[-0.2,0.2],[]);

        end
        % tests
        function test_run_inspector_2D(obj)
            [~,nd,split_data] = run_inspector(obj.source_sqw2D,...
                'test_videofig',true);

            assertEqual(nd,2)
            assertEqual(numel(split_data),21);
        end

        function test_run_inspector_1D(obj)
            [~,nd,split_data] = run_inspector(obj.source_sqw1D,...
                'test_videofig',true);

            assertEqual(nd,1)
            assertEqual(numel(split_data),21);
        end
        function test_invalid_param_throw(obj)
            assertExceptionThrown(@()run_inspector(obj.source_sqw4D),...
                'HORACE:run_inspector:invalid_argument');

            assertExceptionThrown(@()run_inspector([obj.source_sqw1D,obj.source_sqw1D]),...
                'HORACE:run_inspector:invalid_argument');

            assertExceptionThrown(@()run_inspector(obj.source_sqw1D,'ax'),...
                'HORACE:run_inspector:invalid_argument');

            assertExceptionThrown(@()run_inspector(obj.source_sqw1D,'col',[1,-1]),...
                'HORACE:run_inspector:invalid_argument');

            assertExceptionThrown(@()run_inspector(obj.source_sqw1D,'ax',[1,-1]),...
                'HORACE:run_inspector:invalid_argument');

            assertExceptionThrown(@()run_inspector(obj.source_sqw1D,'ax',[-1,1,-2,-2]),...
                'HORACE:run_inspector:invalid_argument');


            assertExceptionThrown(@()run_inspector(obj.source_sqw1D,'ax',[1,-1,-2,2]),...
                'HORACE:run_inspector:invalid_argument');

        end
        function test_parse_col(obj)
            [pr,nd] = run_inspector(obj.source_sqw1D,'colour',[-1,1],...
                'test_parser',true);
            assertEqual(nd,1)
            assertTrue(isempty(pr.ax))
            assertEqual(pr.col,[-1,1]);

        end

        function test_parse_ax(obj)
            [pr,nd] = run_inspector(obj.source_sqw2D,'axis',[-1,1,-2,2],...
                'test_parser',true);
            assertEqual(nd,2)
            assertFalse(isempty(pr.ax));
            assertEqual(pr.ax,[-1,1,-2,2]);
            assertTrue(isempty(pr.col));
        end

        function test_parse_default_par(obj)
            [pr,nd] = run_inspector(obj.source_sqw2D,'test_parser',true);
            assertEqual(nd,2)
            assertTrue(isempty(pr.ax))
            assertTrue(isempty(pr.col))
        end

        function test_split_pix_filebacked(obj)
            n_pix = obj.source_sqw4D.npixels;
            clConf = set_temporary_config_options(hor_config,'mem_chunk_size',n_pix/3);
            source = sqw(obj.sqw_source,'file_backed',true);
            assertTrue(source.is_filebacked);

            w_spl = split(source,'-filebacked');

            assertEqual(numel(w_spl),23);

            n_split_pix = 0;
            for i=1:numel(w_spl)
                assertTrue(w_spl(i).is_filebacked);
                keys = w_spl(i).runid_map.keys;
                assertEqual(numel(keys),1);
                id = unique(w_spl(i).pix.run_idx);
                assertEqual(keys{1},id);
                assertEqual(w_spl(i).experiment_info.expdata.run_id,id);
                n_split_pix  = n_split_pix +w_spl(i).npixels;
            end
            assertEqual(n_pix,n_split_pix);
        end

        function test_split_all_in_memory(obj)
            n_pix = obj.source_sqw4D.npixels;
            
            w_spl = split(obj.source_sqw4D);

            assertEqual(numel(w_spl),23);

            n_split_pix = 0;
            for i=1:numel(w_spl)
                keys = w_spl(i).runid_map.keys;
                assertEqual(numel(keys),1);
                id = unique(w_spl(i).pix.run_idx);
                assertEqual(keys{1},id);
                assertEqual(w_spl(i).experiment_info.expdata.run_id,id);
                n_split_pix  = n_split_pix +w_spl(i).npixels;
            end
            assertEqual(n_pix,n_split_pix);
        end

        function test_prepare_split_sqw(obj)
            page_op = PageOp_split_sqw();

            page_op = page_op.prepare_split_sqw(obj.source_sqw4D);
            n_runds = obj.source_sqw4D.main_header.nfiles;

            assertEqual(numel(page_op.out_img),n_runds )
            assertEqual(numel(page_op.out_pix),n_runds )
            assertEqual(numel(page_op.write_handles),n_runds )
            % all memory-based objects
            is_mb  = cellfun(@isempty,page_op.write_handles);
            assertTrue(all(is_mb))
        end
    end
end
