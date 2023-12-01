classdef PageOp_split_sqw_tester < PageOp_split_sqw
    % Helper class to test some PageOp_split_sqw methods

    properties(Dependent)
        % expose couple of internal properties for testing

        results_are_tmp_files % If restulting files are tmp files or permanent files
        targ_files_list;     % list of the names of the target files
        runid_map            % map connecting run_id-s and numbers of experiments in
        % Experiment of sqw object.
        img_filebacked       % true if one works with filebacked image and false
        % if with memory based
    end


    methods
        function obj = PageOp_split_sqw_tester()
            obj = obj@PageOp_split_sqw();
            obj.runid_map_ = containers.Map({101,102,103}, ...
                {1,2,3});
            obj.img_filebacked = false;
        end

        function obj  = gen_target_filenames_public(obj,file_in,pix_filebacked)
            obj  = gen_target_filenames(obj,file_in,pix_filebacked);
        end
        function obj = prepare_split_sqw_public(obj,in_sqw,pix_filebacked,img_filebacked)
            obj.img_filebacked = img_filebacked;
            obj = prepare_split_sqw(obj,in_sqw,pix_filebacked,img_filebacked);
        end
        %------------------------------------------------------------------
        function are = get.results_are_tmp_files(obj)
            are = obj.results_are_tmp_files_;
        end
        function fll = get.targ_files_list(obj)
            fll = obj.targ_files_map_;
        end
        function rdm = get.runid_map(obj)
            rdm = obj.runid_map_;
        end
        function obj = set.runid_map(obj,val)
            obj.runid_map_ = val;
        end
        function obj = set.img_filebacked(obj,val)
            obj.img_filebacked_ = logical(val);
        end
        function is = get.img_filebacked(obj)
            is = obj.img_filebacked_;
        end
    end
end