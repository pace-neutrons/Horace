classdef test_rebin < TestCase
    % Collection of placeholder tests to simple run the migrated API functions: these MUST be replaced
    % with more comprehensive tests as soon as possible

    properties
        sqw_file_1d_name = 'sqw_1d_1.sqw';
        sqw_file_2d_name = 'sqw_2d_1.sqw';
        sqw_file_4d_name = 'sqw_4d.sqw';


        test_sqw_1d_fullpath = '';
        test_sqw_2d_fullpath = '';
        test_sqw_4d_fullpath = '';
    end



    methods
        function obj = test_rebin(varargin)
            if nargin == 0
                name = 'test_rebin';
            else
                name = varargin{1};
            end
            obj = obj@TestCase(name);
            hc = horace_paths();

            obj.test_sqw_1d_fullpath = fullfile(hc.test_common, obj.sqw_file_1d_name);
            obj.test_sqw_2d_fullpath = fullfile(hc.test_common, obj.sqw_file_2d_name);
            obj.test_sqw_4d_fullpath = fullfile(hc.test_common, obj.sqw_file_4d_name);
            %obj.save();
        end
        function test_rebin1d0d_keep_contents(obj)
            d1d_obj = read_dnd(obj.test_sqw_1d_fullpath);
            d_base = d0d();

            dsum = d_base.rebin(d1d_obj,'-keep_contents');

            assertEqual(dsum.npix,sum(d1d_obj.npix(:))+1);
        end
        

        function test_rebin1d0d(obj)
            d1d_obj = read_dnd(obj.test_sqw_1d_fullpath);
            d_base = d0d();
            dsum = d_base.rebin(d1d_obj);

            assertEqual(dsum.npix,sum(d1d_obj.npix(:)));
        end
    end

end
