classdef test_sqw_signal < TestCaseWithSave

    properties
        sqw_1d
        sqw_2d
        sqw_file_1d_name = 'sqw_1d_1.sqw';
        sqw_file_2d_name = 'sqw_2d_1.sqw';
    end


    methods
        function obj = test_sqw_signal(varargin)
            this_dir = fileparts(mfilename('fullpath'));
            argi = [varargin,{fullfile(this_dir,'test_sqw_signal.mat')}];
            obj = obj@TestCaseWithSave(argi{:});
            hp = horace_paths;
            test_sqw_1d_fullpath = fullfile(hp.test_common,obj.sqw_file_1d_name);
            test_sqw_2d_fullpath = fullfile(hp.test_common,obj.sqw_file_2d_name);
            obj.sqw_1d = read_sqw(test_sqw_1d_fullpath);
            obj.sqw_2d = read_sqw(test_sqw_2d_fullpath);
            obj.save();
        end
        function test_w2E_option(obj)
            w2modE = signal(obj.sqw_2d,'E');

            assertEqualWithSave(obj,w2modE);
        end

        function test_w2Q_option(obj)
            w2modQ = signal(obj.sqw_2d,'Q');

            assertEqualWithSave(obj,w2modQ);
        end

        function test_w2l_option(obj)
            w2modL = signal(obj.sqw_2d,'l');

            assertEqualWithSave(obj,w2modL);
        end
        function test_w2d2_option(obj)
            w2modD2 = signal(obj.sqw_2d,'d2');

            assertEqualWithSave(obj,w2modD2);
        end

        function test_w1d1_option(obj)
            w1modP1 = signal(obj.sqw_1d,'d1');

            assertEqualWithSave(obj,w1modP1);
        end

    end
end
