classdef test_calc_qspec< TestCaseWithSave
    %
    %

    properties
        small_det
        good_det
        timing = struct();
        n_rep = 100;
        ll
    end
    methods
        %
        function obj=test_calc_qspec(varargin)
            ref_data = fullfile(fileparts(mfilename('fullpath')),'test_calc_qspec_output');
            if nargin == 0
                name = 'test_calc_qspec';
            else
                name = varargin{1};
            end
            obj = obj@TestCaseWithSave(name,ref_data);

            hp = horace_paths;
            small_nxspe_file_path = fullfile(hp.test_common,'MAR11001_test.nxspe');
            good_nxspe_file_path  = fullfile(hp.test_common,'MAP11014v3.nxspe');
            obj.small_det   = get_par(small_nxspe_file_path);
            obj.good_det    = get_par(good_nxspe_file_path );
            hc = hor_config;
            obj.ll = hc.log_level;
            obj.save();
        end
        %------------------------------------------------------------------
        function test_calc_qspec_large_mode0(obj)
            par = obj.good_det;
            dc = calc_detdcn(par.phi,par.azim);
            efix = -1;
            eps = -1:0.1:1 + efix;
            emode = 0;
            tb = tic();
            for i=1:obj.n_rep
                [qs,en] = calc_qspec(dc, efix, eps, emode);
            end
            te = toc(tb);
            assertEqualWithSave(obj,qs);
            assertEqualWithSave(obj,en);
            if obj.ll>1; fprintf('calc_qspec, Emode 0  takes %gsec\n',te);end
            check_timing(obj,'elastic',te)
        end
        function test_calc_qspec_large_mode2(obj)
            par = obj.good_det;
            dc = calc_detdcn(par.phi,par.azim);
            efix = 100;
            eps = -10:99;
            emode = 2;
            tb = tic();
            for i=1:obj.n_rep
                [qs,en] = calc_qspec(dc, efix, eps, emode);
            end
            te = toc(tb);
            assertEqualWithSave(obj,qs);
            assertEqualWithSave(obj,en);
            if obj.ll>1; fprintf('calc_qspec, Emode 2  takes %gsec\n',te); end

            check_timing(obj,'indirect',te)
        end
        function test_calc_qspec_large_mode1(obj)
            par = obj.small_det;
            dc = calc_detdcn(par.phi,par.azim);
            efix = 100;
            eps = -10:99;
            emode = 1;
            tb = tic();
            for i=1:obj.n_rep
                [qs,en] = calc_qspec(dc, efix, eps, emode);
            end
            te = toc(tb);
            assertEqualWithSave(obj,qs);
            assertEqualWithSave(obj,en);
            if obj.ll>1; fprintf('calc_qspec, Emode 1  takes %gsec\n',te); end
            check_timing(obj,'direct',te)
        end
        %------------------------------------------------------------------
        function test_calc_qspec_small_mode0(obj)
            par = obj.small_det;
            dc = calc_detdcn(par.phi,par.azim);
            efix = -1;
            eps = -1:0.1:1 + efix;
            emode = 0;
            [qs,en] = calc_qspec(dc, efix, eps, emode);
            assertEqualWithSave(obj,qs);
            assertEqualWithSave(obj,en);
        end

        function test_calc_qspec_small_mode2(obj)
            par = obj.small_det;
            dc = calc_detdcn(par.phi,par.azim);
            efix = 100;
            eps = -10:99;
            emode = 2;
            [qs,en] = calc_qspec(dc, efix, eps, emode);
            assertEqualWithSave(obj,qs);
            assertEqualWithSave(obj,en);
        end

        function test_calc_qspec_small_mode1(obj)
            par = obj.small_det;
            dc = calc_detdcn(par.phi,par.azim);
            efix = 100;
            eps = -10:99;
            emode = 1;
            [qs,en] = calc_qspec(dc, efix, eps, emode);
            assertEqualWithSave(obj,qs);
            assertEqualWithSave(obj,en);
        end
    end
    methods(Access=protected)
        function check_timing(obj,timing_field,value)
            if ~isfield(obj.ref_data_,'timing')
                obj.ref_data_.timing = struct();
            end
            if isfield(obj.ref_data_.timing,timing_field)
                prev_value = obj.ref_data_.timing.(timing_field);
            else
                prev_value = value;
            end
            obj.ref_data_.timing.(timing_field) = value;
            if obj.ll>2
                difr = 0.5*(value-prev_value)/(value+prev_value);
                if abs(difr) > 0.05
                    fprintf([ ...
                        '*** calc_qspec: mode %s Execution time changed more then 5%\n' ...
                        '*** Times: Previous : %dsec Current: %dsec\n'], ...
                        timing_field,prev_value,value);
                end
            end
        end
    end
end
