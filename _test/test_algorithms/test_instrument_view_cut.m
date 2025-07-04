classdef test_instrument_view_cut < TestCaseWithSave

    properties (Constant)
        FLOAT_TOL = 4*eps('single');
    end

    properties
        sqw_2d_obj;
        sqw_2d_file = 'sqw_2d_2.sqw';
        dnd_file    = 'w3d_d3d.sqw';
    end

    methods

        function obj = test_instrument_view_cut(varargin)
            if nargin<1
                opt = 'test_instrument_view_cut';
            else
                opt = varargin{1};
            end
            % 
            this_folder = fileparts(mfilename("fullpath"));
            obj = obj@TestCaseWithSave(opt,fullfile(this_folder,'test_test_instrument_view_ref_data.mat'));


            hps = horace_paths;
            obj.sqw_2d_file= fullfile(hps.test_common,obj.sqw_2d_file);
            obj.sqw_2d_obj = read_sqw(obj.sqw_2d_file);
            obj.dnd_file   = fullfile(hps.test_common,obj.dnd_file);
            %
            obj.save();
        end
        %------------------------------------------------------------------
        % SQW object tests
        function test_instrument_view_works_gives_kf_de_plot(obj)
            %
            out_dnd_obj = instrument_view_cut(obj.sqw_2d_obj,[0,0.2,20],[150,2,200],'-check_correspondence');

            assertEqualToTolWithSave(obj,out_dnd_obj,...
                obj.FLOAT_TOL, '-ignore_str','-ignore_date');

        end
        %
        function test_instrument_view_works_with_sqw_obj_or_file(obj)

            out_dnd_obj = instrument_view_cut(obj.sqw_2d_obj,[0,0.2,20],[]);
            % in addition, also check correct default energy binning ranges
            % calculation
            out_dnd_file = instrument_view_cut(obj.sqw_2d_file,[0,0.2,20],5);

            assertEqualToTol(out_dnd_obj,out_dnd_file,'tol', obj.FLOAT_TOL)

            assertEqualToTolWithSave(obj,out_dnd_obj, ...
                'tol', obj.FLOAT_TOL, '-ignore_date');
        end
        %------------------------------------------------------------------
        function test_instrument_view_on_dnd_fails(~)
            fake_dnd = d4d();
            assertExceptionThrown(@()instrument_view_cut(fake_dnd,[],[]),...
                'HORACE:instrument_view:invalid_argument');
        end
        function test_instrument_view_on_dnd_file_fails(obj)
            assertExceptionThrown(@()instrument_view_cut(obj.dnd_file,[],[]),...
                'HORACE:instrument_view:invalid_argument');
        end

        function test_instrument_view_something_unknown_file_fails(~)
            assertExceptionThrown(@()instrument_view_cut(10,[],[]),...
                'HORACE:instrument_view:invalid_argument');
        end
    end

end
