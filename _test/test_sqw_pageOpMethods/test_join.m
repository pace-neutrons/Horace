classdef test_join < TestCase
    properties
        test_dir;
        wk_dir;
        sample_obj;
        sqw_to_join;
        files_to_join;
    end

    methods
        function obj = test_join(~)
            obj = obj@TestCase('test_join');
            hc = horace_paths;
            obj.test_dir = hc.test_common;
            obj.sample_obj = read_sqw(fullfile(obj.test_dir,'sqw_2d_1.sqw'));
            obj.sqw_to_join = obj.sample_obj.split();
            n_parts = numel(obj.sqw_to_join);
            obj.files_to_join = cell(n_parts,1);
            obj.wk_dir   = fullfile(tmp_dir,'test_join_data');
            if ~isfolder(obj.wk_dir)
                mkdir(obj.wk_dir);
            end
            for i = 1:n_parts
                id = obj.sqw_to_join(i).runid_map.keys;
                [~,fn] = fileparts(obj.sqw_to_join(i).main_header.filename);
                fn = sprintf('%s_runID%d',fn,id{1});
                fn = fullfile(obj.wk_dir,fn);
                obj.files_to_join{i} = fn;
                if isfile(fn)
                    continue;
                end
                save(obj.sqw_to_join(i),fn);

            end
        end
        function delete(obj)
            if ~isempty(obj.wk_dir) && isfolder(obj.wk_dir)
                rmdir(obj.wk_dir,'s');
            end
        end

        function test_split_cube_1_run(~)
            sqw_obj = sqw.generate_cube_sqw(10);

            split_obj = split(sqw_obj);
            reformed_obj = join(sqw_obj);

            assertEqualToTol(split_obj, reformed_obj)
            assertEqualToTol(sqw_obj, reformed_obj)
        end

        function test_split_cube_2_run(~)
            sqw_obj = sqw.generate_cube_sqw(10);

            sqw_obj.pix.run_idx(8:end) = 2;

            sqw_obj.experiment_info.expdata(2) = struct( ...
                "filename", 'fake', ...
                "filepath", '/fake', ...
                "efix", 1, ...
                "emode", 1, ...
                "cu", [1,0,0], ...
                "cv", [0,1,0], ...
                "psi", 1, ...
                "omega", 1, ...
                "dpsi", 1, ...
                "gl", 1, ...
                "gs", 1, ...
                "en", 10, ...
                "run_id", 1);
            sqw_obj.main_header.nfiles = 2;

            sqw_obj.experiment_info.runid_map(2) = 2;

            split_obj = sqw_obj.split();

            assertEqual(numel(split_obj), 2)

            reformed_obj = join(sqw_obj);

            assertEqualToTol(sqw_obj, reformed_obj)
        end

        function test_split_and_join_returns_same_object_including_pixels(obj)

            fpath = fullfile(obj.test_dir, 'sqw_2d_1.sqw');
            sqw_obj = sqw(fpath);
            split_obj = split(sqw_obj);

            assertTrue(all(arrayfun(@(x) x.main_header.nfiles == 1, split_obj)));

            reformed_obj = join(split_obj);

            %TODO: Re #1320 -- this should not happen. Split reindexes from
            % 1 -- split should not touch indexes.
            reformed_obj.pix.run_idx = reformed_obj.pix.run_idx + min(sqw_obj.pix.run_idx) - 1;

            assertEqualToTol(sqw_obj, reformed_obj, [1e-6, 1e-4], 'ignore_str', true);
        end
        function test_collect_metadata_works_on_membased(obj)
            sqw_t = collect_sqw_metadata(obj.sqw_to_join);
            assertEqual(sqw_t.main_header.nfiles,24)

            assertEqualToTol(sqw_t.data,obj.sample_obj.data, ...
                'ignore_str',true,'tol',[1.e-7,1.e-7])
            assertTrue(isa(sqw_t.pix,'pix_combine_info'))
        end


        function test_collect_metadata_works_on_files(obj)
            sqw_t = collect_sqw_metadata(obj.files_to_join);
            assertEqual(sqw_t.main_header.nfiles,24)

            assertEqualToTol(sqw_t.data,obj.sample_obj.data, ...
                'ignore_str',true,'tol',[1.e-7,1.e-7])
            assertTrue(isa(sqw_t.pix,'pix_combine_info'))
        end


    end
end
