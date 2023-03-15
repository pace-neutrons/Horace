classdef test_dnd_cut< TestCaseWithSave
    %
    % Check various dnd cuts comparing them with the reference cuts stored
    % earlier
    %

    properties
        dnd_file_2d_name = 'dnd_2d.sqw';
        d2d_obj;
    end

    methods

        %The above can now be read into the test routine directly.
        function obj=test_dnd_cut(varargin)
            test_ref_data = fullfile(fileparts(mfilename('fullpath')),'test_dnd_cut.mat');

            argi = [varargin,test_ref_data];

            obj = obj@TestCaseWithSave(argi{:});
            hp = horace_paths();
            dnd_2d_fullpath = fullfile(hp.test_common,obj.dnd_file_2d_name);
            %hor_root = horace_root();            %
            %dnd_2d_fullpath = fullfile(hor_root,'_test/common_data',...
            %    obj.dnd_file_2d_name);

            obj.d2d_obj = read_dnd(dnd_2d_fullpath);
            obj.save();
        end        
        % tests
        function test_2D_to2D_cut_with_spher_proj(obj)
            proj = spher_proj();
            w2 = cut(obj.d2d_obj,proj,[0,0.01,0.8], ...
                [0,1,180],[-180,180],[-0.25,0.25]);
            % formally this works but needs scientific validation
            assertEqualToTolWithSave(obj,w2,'ignore_str',true,'tol',[1.e-9,1.e-9]);
        end
        
        function test_2D_to2D_cut_with_proj(obj)
            proj = ortho_proj([1,1,1],[0,0,1]);
            w2 = cut(obj.d2d_obj,proj,[-0.6,0.01,-0.4], ...
                [-0.3,0.02,0.2],[-0.05,0.05],[-0.25,0.25]);
            % formally this works but needs scientific validation
            assertEqualToTolWithSave(obj,w2,'ignore_str',true,'tol',[1.e-9,1.e-9]);
        end

        function test_2D_to2D_cut(obj)
            w2 = cut(obj.d2d_obj,[-0.6+1.9222e-08+4.9794e-13,0.02,-0.4], ...
                [-0.59,0.02,-0.47]);
            assertEqualToTolWithSave(obj,w2,'ignore_str',true,'tol',[1.e-9,1.e-9]);
        end

        function test_2D_to1D_cut(obj)
            w1 = cut(obj.d2d_obj,[-0.60+1.9222e-08+4.9794e-13,0.02,-0.4],[-0.54,-0.44]);
            assertEqualToTolWithSave(obj,w1,'ignore_str',true,'tol',[1.e-9,1.e-9]);
        end

    end
end


