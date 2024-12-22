classdef test_read_spe < TestCase
    properties
        test_data_path;
        EXPECTED_DET_NUM = 28160
    end

    methods

        function obj=test_read_spe(name)
            if nargin<1
                name = 'test_read_spe';
            end
            obj = obj@TestCase(name);
            pths = horace_paths;
            obj.test_data_path = pths.test_common;
        end
        %------------------------------------------------------------------
        function test_spe_file_empty(~)
            assertExceptionThrown(@()read_spe(""), ...
                'HERBERT:read_spe:invalid_argument');
        end

        function test_spe_file_not_there(obj)
            spe_file = fullfile(obj.test_data_path,'missing_spe_file.spe');
            assertExceptionThrown(@()read_spe(spe_file), ...
                'HERBERT:read_spe:invalid_argument');
        end

        function test_read_data_nonstandard_format(obj)
            spe_file = fullfile(obj.test_data_path,'Fe4_2K_reduced_11l.spe');

            [S,ERR,en]  = read_spe(spe_file);

            assertEqual(size(S),[16,16]);
            assertEqual(size(ERR),[16,16]);
            assertEqual(size(en),[17,1]);
        end

        function test_read_data_legacy_vs_smart(obj)
            spe_file = fullfile(obj.test_data_path,'MAP10001.spe');

            [S,ERR,en]  = read_spe(spe_file);
            [Sl,ERRl,enl] = read_spe(spe_file,'-legacy');

            assertEqual(Sl,S,'-nan_equal');
            assertEqual(ERRl,ERR);
            assertEqual(enl,en);
        end

        function test_read_info_legacy_vs_smart(obj)
            spe_file = fullfile(obj.test_data_path,'MAP10001.spe');
            ne = 30;
            ndet = 28160;
            [nen,ndetn,en]  = read_spe(spe_file,'-info');
            [nel,ndetl,enl] = read_spe(spe_file,'-info','-legacy');

            assertEqual(ne,nen);
            assertEqual(ndet,ndetn);
            assertEqual(nel,nen);
            assertEqual(ndetl,ndetn);
            assertEqual(en,enl);
        end

        function test_read_legacy_eq_smart(obj)
            spe_file = fullfile(obj.test_data_path,'MAP10001.spe');
            [ne,ndet,en] = read_spe(spe_file,'-info');

            [S,ERR,enl] = read_spe(spe_file,'-legacy');

            assertEqual(size(S),[ne,ndet])
            assertEqual(size(ERR),[ne,ndet])
            assertElementsAlmostEqual(en,enl);
            assertEqual(numel(en),ne+1);
        end

        function test_read_legacy(obj)
            spe_file = fullfile(obj.test_data_path,'MAP10001.spe');
            [ne,ndet,en] = read_spe(spe_file,'-info');

            [S,ERR,enl] = read_spe(spe_file,'-legacy');

            assertEqual(size(S),[ne,ndet])
            assertEqual(size(ERR),[ne,ndet])
            assertElementsAlmostEqual(en,enl);
            assertEqual(numel(en),ne+1);
        end
    end
end
