classdef test_pix_combine_info < TestCase & common_sqw_file_state_holder
    % Test checks some components of pix_combine_info
    %
    %---------------------------------------------------------------------
    properties
        % properties to use as input for data
        data_path;
        test_souce_files
        ref_data_range
        cleanup_ob1
    end

    methods
        function obj=test_pix_combine_info(test_class_name)
            %
            if ~exist('test_class_name','var')
                test_class_name = 'test_pix_combine_info';
            end
            obj = obj@TestCase(test_class_name);
            data_path= fullfile(fileparts(mfilename('fullpath')),'TestData');

            obj.data_path = data_path;
            pths = horace_paths;
            source_test_dir = pths.test_common;
            source_file = fullfile(source_test_dir,'MAP11014.nxspe');
            target_file = fullfile(tmp_dir,'TPC11014.nxspe');
            copyfile(source_file,target_file,'f');

            psi = [0,2,20]; %-- test settings;
            %psi = 0:1:200;  %-- evaluate_performance settings;
            source_test_file  = cell(1,numel(psi));
            for i=1:numel(psi)
                source_test_file{i}  = target_file;
            end

            wk_dir = tmp_dir;
            targ_file =fullfile(wk_dir,'never_created_sqw.sqw');

            hc = hor_config;
            hc.saveable = false;
            del_tmp_state = hc.delete_tmp;
            hc.delete_tmp = false;
            in = hc.ignore_nan;
            hc.ignore_nan = false;
            clob1 = onCleanup(@()set(hc,'delete_tmp',del_tmp_state,...
                'ignore_nan',in));
            hpc = hpc_config;
            hpc.saveable = false;
            [comb_state,combine_sqw_using] = get(hpc,...
                'build_sqw_in_parallel','combine_sqw_using');
            hpc.build_sqw_in_parallel = false;
            hpc.combine_sqw_using  = 'matlab';
            clob2 = onCleanup(@()set(hpc,'build_sqw_in_parallel',comb_state,...
                'combine_sqw_using',combine_sqw_using));


            [temp_files,~,obj.ref_data_range]=gen_sqw(source_test_file,'',targ_file,...
                787.,1,[2.87,2.87,2.87],[90,90,90],...
                [1,0,0],[0,1,0],psi,0,0,0,0,'replicate','tmp_only');
            obj.test_souce_files = temp_files;
            obj.cleanup_ob1 = onCleanup(@()delete(temp_files{:}));
            delete(target_file);
        end
        %
        function test_pix_range(obj)
            tester = pix_combine_info(obj.test_souce_files);

            assertEqual(tester.data_range,PixelDataBase.EMPTY_RANGE);

            tester = tester.recalc_data_range();

            assertElementsAlmostEqual(tester.data_range,obj.ref_data_range,'relative',1.e-6);
            is_undef = tester.data_range == PixelDataBase.EMPTY_RANGE;
            assertFalse(any(is_undef(:)));
        end
        %

        %
    end
end
