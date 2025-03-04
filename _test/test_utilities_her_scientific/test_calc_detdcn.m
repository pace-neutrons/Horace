classdef test_calc_detdcn< TestCaseWithSave
    %
    %

    properties
        small_nxspe_file_path
    end
    methods
        %
        function obj=test_calc_detdcn(varargin)
            ref_data = fullfile(fileparts(mfilename('fullpath')),'test_calc_detdcn_output');
            if nargin == 0
                name = 'test_calc_detdcn';
            else
                name = varargin{1};
            end
            obj = obj@TestCaseWithSave(name,ref_data);
            
            hp = horace_paths;
            obj.small_nxspe_file_path = fullfile(hp.test_common,'MAR11001_test.nxspe');
            obj.save();
        end
        % tests themself
        function test_get_par_nxspe(obj)
            par = get_par(obj.small_nxspe_file_path);
            dc = calc_detdcn(par.phi,par.azim);
            assertEqualWithSave(obj,dc);
        end
    end
end
