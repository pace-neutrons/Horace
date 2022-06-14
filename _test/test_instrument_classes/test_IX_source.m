classdef test_IX_source < TestCaseWithSave
    % Test of IX_source -- very similar to aperture
    properties
        home_folder
    end
    methods
        %--------------------------------------------------------------------------
        function self = test_IX_source(varargin)
            
            self@TestCaseWithSave(varargin{:});
            test_files_folder = fileparts(mfilename('fullpath'));
            self.home_folder = test_files_folder;
            %does nothing unless the constructor called with '-save' key
            self.save()
        end
        
        %--------------------------------------------------------------------------
        function test_simple_source(self)
            ap = IX_source('ISIS','-freq',50);
            assertEqualWithSave (self,ap);
        end
        function test_empty_source(self)
            ap = IX_source();
            %assertTrue(isempty(ap));
            assertEqualWithSave (self,ap);
        end                
        %--------------------------------------------------------------------------
        
        function test_source_array_prev_versions(obj)
            % 3x1 array example
            srs_arr = [IX_source('ISIS','TS2',40), IX_source('-name','SNS',...
                '-target_name','TS1','-frequency',50),...
                IX_source()];
            sample_file_location = obj.home_folder;
            if obj.save_output % prepare test data for the future.
                % move test data to data folder manually
                % run test_IX_source with -save option to obtain reference
                % files when changed to new class version
                
                save_variables=true;
                ver = srs_arr.classVersion();
                %ver = 1;
                verstr = ['ver',num2str(ver)];
                [ok,mess] = check_matfile_IO(verstr, save_variables, sample_file_location ,srs_arr);
                assertTrue(ok,mess)
            else
                save_variables=false;
                
                verstr= 'ver1';
                [ok,mess] = check_matfile_IO(verstr, save_variables, sample_file_location ,srs_arr);
                assertTrue(ok,mess)
            end
            
        end
        %
        function test_single_source_load_prev_versions(obj)
            % Scalar example
            srs = IX_source(30);
            sample_files_location = obj.home_folder;
            if obj.save_output
                % run test_IX_apperture with -save option to obtain reference
                % files when changed to new class version
                save_variables=true;
                ver = srs.classVersion();
                %ver = 1;
                verstr = ['ver',num2str(ver)];
                [ok,mess] = check_matfile_IO(verstr, save_variables, sample_files_location ,srs);
                assertTrue(ok,mess)
                
            else
                save_variables=false;
                
                verstr= 'ver1';
                [ok,mess] = check_matfile_IO(verstr, save_variables, sample_files_location ,srs);
                assertTrue(ok,mess)
            end
        end
        
        %--------------------------------------------------------------------------
    end
end

