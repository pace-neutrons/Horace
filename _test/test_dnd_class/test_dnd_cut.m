classdef test_dnd_cut< TestCaseWithSave
    %
    % Check various dnd cuts comparing them with the reference cuts stored
    % earlier
    %

    properties
        sqw_file_2d_name = 'w2d_qe_sqw.sqw';
        d2d_obj;
        sqw_ref_obj;
    end

    methods

        %The above can now be read into the test routine directly.
        function obj=test_dnd_cut(varargin)
            name = 'test_dnd_cut';
            if nargin>0 && strncmp(varargin{1},'-save',max(strlength(varargin{1}),2))
                if nargin == 2
                    name = varargin{2};
                else
                    name = fullfile(fileparts(mfilename("fullpath")),'test_dnd_cut_output.mat');
                end
                argi = {'-save',name};
            else
                argi = {name};
            end

            obj = obj@TestCaseWithSave(argi{:});
            hp = horace_paths();
            sqw_2d_fullpath = fullfile(hp.test_common,obj.sqw_file_2d_name);

            obj.sqw_ref_obj = read_sqw(sqw_2d_fullpath);
            obj.d2d_obj     = obj.sqw_ref_obj.data;

            obj.save();
        end
        %------------------------------------------------------------------
        % tests
        function test_2D_to2D_cut_with_cylinder_proj_23(obj)
            clOb = set_temporary_warning('off','HORACE:runtime_error','HORACE:developers_option');

            proj = cylinder_proj([1,1,0],[0,0,1],'type','aad');
            cut_range = obj.d2d_obj.get_targ_range(proj);
            bin_range = {[0,4],[-2,0.1,2],[cut_range(1,3),2,cut_range(2,3)],[0,10]};
            w2 = cut(obj.d2d_obj,proj,bin_range{:});
            % this is reference image which should be compared with w2 manually
            %w2f = cut(obj.sqw_ref_obj,proj,bin_range{:});

            % interpolation on edges in different versions of Matlab
            % differs.
            % To be able to compare datasets produced by different Matlab
            % versions, nullify these values
            w2.s(:,1) = 0;
            w2.s(:,end) = 0;
            w2.s(1,:) = 0;
            w2.s(end,:) = 0;
            assertEqualToTolWithSave(obj,w2,'ignore_str',true,'tol',[1.e-3,2.e-3]);
        end

        function test_2D_to2D_cut_with_cylinder_proj_24(obj)
            clOb = set_temporary_warning('off','HORACE:runtime_error','HORACE:developers_option');

            proj = cylinder_proj([1,1,0],[0,0,1],'type','aad');
            cut_range = obj.d2d_obj.get_targ_range(proj);
            bin_range = {[0,4],[-2,0.1,2],[cut_range(1,3),cut_range(2,3)],[]};
            w2 = cut(obj.d2d_obj,proj,bin_range{:});
            % this is reference image which should be compared with w2 manually
            %w2f = cut(obj.sqw_ref_obj,proj,bin_range{:});

            % interpolation on edges in different versions of Matlab
            % differs.
            % To be able to compare datasets produced by different Matlab
            % versions, nullify these values
            w2.s(:,1) = 0;
            w2.s(:,end) = 0;
            w2.s(1,:) = 0;
            w2.s(end,:) = 0;

            assertEqualToTolWithSave(obj,w2,'ignore_str',true,'tol',[1.e-9,1.e-9]);
        end

        function test_2D_to2D_cut_with_spher_proj(obj)
            clOb = set_temporary_warning('off','HORACE:runtime_error','HORACE:developers_option');

            proj = sphere_proj('type','add');
            %cut_range = obj.d2d_obj.get_targ_range(proj);
            w2 = cut(obj.d2d_obj,proj,[0,0.1,5], ...
                [0,2,180],[-180,180],[20,50]);
            % this is reference image which should be compared with w2 manually
            %w2ref = cut(obj.sqw_ref_obj,proj,[0,0.1,5], ...
            %    [0,2,180],[-180,180],[20,50]);


            assertEqualToTolWithSave(obj,w2,'ignore_str',true,'tol',[1.e-9,1.e-9]);
        end

        function test_2D_to2D_cut_with_proj(obj)
            clOb = set_temporary_warning('off','HORACE:runtime_error','HORACE:developers_option');

            proj = line_proj([1,1,1],[0,0,1]);
            w2 = cut(obj.d2d_obj,proj,[0,0.02,0.9], ...
                [-0.3,0.02,0.9],[-0.1,0.1],[20,50]);

            % this is reference image which should be compared with w2 manually
            %w2ref = cut(obj.sqw_ref_obj,proj,[0,0.02,0.9], ...
            %    [-0.3,0.02,0.9],[-0.1,0.1],[20,50]);

            assertEqualToTolWithSave(obj,w2,'ignore_str',true,'tol',[1.e-9,1.e-9]);
        end

        function test_2D_to2D_cut(obj)
            w2 = cut(obj.d2d_obj,[-0.9,0.04,0.9],[0,4,100]);
            % this is reference image which should be compared with w1 manually
            % w2ref = cut(obj.sqw_ref_obj,[-0.9,0.04,0.9],[0,4,100]);
            assertEqualToTolWithSave(obj,w2,'ignore_str',true,'tol',[1.e-9,1.e-9]);
        end

        function test_2D_to1D_cut(obj)
            w1 = cut(obj.d2d_obj,[-0.9,0.04,0.9],[20,50]);
            % this is reference image which should be compared with w1 manually
            % w1ref = cut(obj.sqw_ref_obj,[-0.9,0.04,0.9],[20,50]);
            assertEqualToTolWithSave(obj,w1,'ignore_str',true,'tol',[1.e-9,1.e-9]);
        end

    end
end
