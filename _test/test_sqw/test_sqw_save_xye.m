classdef test_sqw_save_xye < TestCase
    % Series of tests to check work of mex files against Matlab files

    properties
        out_dir = tmp_dir();
        tests_dir = fileparts(fileparts(mfilename('fullpath')));
    end

    methods
        function obj = test_sqw_save_xye(varargin)
            if nargin>0
                name = varargin{1};
            else
                name = 'test_sqw_save_xye';
            end
            obj = obj@TestCase(name);
        end
        
    end
end
