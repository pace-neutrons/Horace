classdef test_split< TestCase
    %
    % Validate sqw object splitting
    %

    properties
        this_dir;
        sqw_source = 'sqw_4d.sqw'

        source_sqw4D;
    end

    methods
        function obj=test_split(name)
            if ~exist('name','var')
                name = 'test_split';
            end
            obj=obj@TestCase(name);
            hpc = horace_paths;
            obj.this_dir = fileparts(mfilename('fullpath'));
            source_data = fullfile(hpc.test_common,obj.sqw_source);
            obj.sqw_source   = source_data;
            obj.source_sqw4D = read_sqw(source_data);

        end
        function delete_subfiles(~,filelist)
            for i=1:numel(filelist)
                if isfile(filelist{i})
                    del_memmapfile_files(filelist{i})
                end
            end
        end
        function test_split_all_filebacked_eq_membased(obj)
            w_spl_mem = split(obj.source_sqw4D);

            n_pix = obj.source_sqw4D.npixels;
            %clConf = set_temporary_config_options(hor_config,'mem_chunk_size',n_pix/3);
            source = sqw(obj.sqw_source,'file_backed',true);
            assertTrue(source.is_filebacked);

            targ_folder = fullfile(tmp_dir,'split_fb_targ');
            clFiles     = onCleanup(@()rmdir(targ_folder,'s'));

            w_splf = split(source,'-files',targ_folder);

            assertEqual(numel(w_splf),23);

            % check that resulting object exist and always available
            for i=1:numel(w_splf)
                assertTrue(isfile(w_splf{i}));
                spl_obj = read_sqw(w_splf{i});
                assertEqualToTol(w_spl_mem(i),spl_obj,'ignore_str',true, ...
                    '-ignore_date','tol',[8*eps('single'),8*eps('single')]);
            end
        end

        function test_split_all_filebacked_generates_files(obj)
            n_pix = obj.source_sqw4D.npixels;
            clConf = set_temporary_config_options(hor_config,'mem_chunk_size',n_pix/3);
            source = sqw(obj.sqw_source,'file_backed',true);
            assertTrue(source.is_filebacked);

            hc = hor_config;
            wkdir = hc.working_directory;
            tf = cell(1,23);
            for i=1:23
                tf{i} = fullfile(wkdir,sprintf('sqw_4d_runID%07d.sqw',91+i));
            end
            clOuF = onCleanup(@()delete_subfiles(obj,tf));

            w_splf = split(source,'-files');

            assertEqual(numel(w_splf),23);

            % check that resulting object exist and always available
            for i=1:numel(w_splf)
                assertTrue(isfile(w_splf{i}));
                assertEqual(tf{i},w_splf{i});
            end

            clear clOuF;

            for i=1:numel(w_splf)
                assertFalse(isfile(w_splf{i}));
            end
        end

        function test_split_pix_filebacked_permanent_res(obj)
            n_pix = obj.source_sqw4D.npixels;

            targ_folder = fullfile(tmp_dir,'split_fb_targ');
            clFiles = onCleanup(@()rmdir(targ_folder,'s'));
            w_spl = split(obj.source_sqw4D,'-filebacked',targ_folder);

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

            assertTrue(isfolder(targ_folder));

            % check that filebacked objects are temporary objects in this
            % case
            files = cell(1,numel(w_spl));
            for i=1:numel(files)
                files{i} = w_spl(i).full_filename;

                assertTrue(isfile(files{i}));
                [~,~,fe] = fileparts(files{i});
                assertEqual(fe,'.sqw');
            end
            clear('w_spl');
            for i=1:numel(files)
                assertTrue(isfile(files{i}));
            end
        end


        function test_split_filebacked_eq_split_membased(obj)

            w_spl_mem = split(obj.source_sqw4D);

            n_pix = obj.source_sqw4D.npixels;

            clConf = set_temporary_config_options(hor_config,'mem_chunk_size',n_pix/3);
            source = sqw(obj.sqw_source,'file_backed',true);
            assertTrue(source.is_filebacked);

            w_spl_fb = split(source,'-filebacked');

            assertEqual(numel(w_spl_mem),23);
            clear clConf


            for i=1:numel(w_spl_mem)
                assertEqualToTol(w_spl_mem(i),w_spl_fb(i),'ignore_str',true, ...
                    'tol',[8*eps('single'),8*eps('single')]);
            end
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

            % check that filebacked objects are temporary objects in this
            % case
            files = cell(1,numel(w_spl));
            for i=1:numel(files)
                files{i} = w_spl(i).pix.full_filename;
                assertTrue(isfile(files{i}));
            end
            clear('w_spl');
            for i=1:numel(files)
                assertFalse(isfile(files{i}));
            end
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

        function test_prepare_split_sqw_in_mem(obj)
            page_op = PageOp_split_sqw();

            page_op = page_op.prepare_split_sqw(obj.source_sqw4D,false,false);
            n_runs  = obj.source_sqw4D.main_header.nfiles;

            assertEqual(numel(page_op.out_img),n_runs )
            assertEqual(numel(page_op.out_pix),n_runs )
            assertEqual(numel(page_op.write_handles),n_runs )
            % all memory-based objects
            is_mb  = cellfun(@isempty,page_op.write_handles);
            assertTrue(all(is_mb))
        end
    end
end
