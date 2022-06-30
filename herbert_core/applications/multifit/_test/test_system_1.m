classdef test_with_structures < TestCaseWithSave
    properties
        data
    end
    
    methods
        %----------------------------------------------------------------------
        % Constructor
        %----------------------------------------------------------------------
        function self = myTestWithSave2(name)
            % Create test class instance (note that as it is a handle object
            % we dont need to return the class instance on the LHS)
            self@TestCaseWithSave(name);
            
            % Read input data for testing
            test_dir = fileparts(mfilename('fullpath'));
            self.data = load(fullfile(test_dir,'/data/testdata_multifit_1.mat'));
        end
        
        %----------------------------------------------------------------------
        % Test methods
        %----------------------------------------------------------------------
        function testColormapColumns(self)
            % Ensure fit control parameters are the same for old and new multifit
            fcp = [0.0001 30 0.0001];


            disp('testing: testColormapColumns')
            sz1 = size(get(self.fh, 'Colormap'), 2);
            assertEqual(sz1, 3);
            %sz1=2*sz1;
            assertEqualToTolWithSave(self,sz1)
            if ~self.save_output
                disp('=============================')
                disp('=============================')
                disp('=============================')
                disp('=============================')
            end
        end
        
        function testPointer(self)
            disp('testing: testPointer')
            pointer_type=get(self.fh, 'Pointer');
            assertEqual(pointer_type, 'arrow');
            assertEqualToTolWithSave(self,pointer_type)
        end
    end
end
