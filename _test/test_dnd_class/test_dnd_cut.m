classdef test_dnd_cut< TestCaseWithSave
    %
    % Validate fast sqw reader used in combining sqw
    
    
    properties
        dnd_file_2d_name = 'dnd_2d.sqw';
        d2d_obj;
    end
    
    methods
        
        %The above can now be read into the test routine directly.
        function obj=test_dnd_cut(varargin)
            test_ref_data = fullfile(fileparts(mfilename('fullpath')),'test_dnd_cut.mat');
            if nargin == 0
                argi = {test_ref_data};
            else
                argi = {varargin{1},test_ref_data};
            end

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
        function test_2D_to2D_cut(obj)
            w2 = cut(obj.d2d_obj,[-0.6+1.9222e-08+4.9794e-13,0.02,-0.4], ...
                [-0.59,0.02,-0.47]);
            assertEqualToTolWithSave(obj,w2,'ignore_str',true);
        end
        
        function test_2D_to1D_cut(obj)
            w1 = cut(obj.d2d_obj,[-0.60+1.9222e-08+4.9794e-13,0.02,-0.4],[-0.54,-0.44]);
            assertEqualToTolWithSave(obj,w1,'ignore_str',true,'tol',[1.e-6,1.e-6]);
        end
        
    end
end


