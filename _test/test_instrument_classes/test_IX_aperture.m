classdef test_IX_aperture < TestCaseWithSave
    % Test of IX_aperture
    properties
        home_folder
    end
    methods
        %--------------------------------------------------------------------------
        function self = test_IX_aperture (varargin)
            
            test_files_folder = fileparts(mfilename('fullpath'));
            if nargin> 0
                is = ismember(varargin,'-save');
                if any(is)
                    if numel(is)>2
                        error('HERBERT:test_IX_apperture:invalid_argument',...
                            'the test can be called only with one or two parameters')
                    elseif numel(is)==1
                        filename = 'test_IX_aperture_output.mat';
                    else
                        filename = varargin{~is};
                    end
                    opt = '-save';
                    params={opt,filename};
                else
                    params= varargin(1);
                end
            else
                params= {'test_IX_aperture'};
            end
            self@TestCaseWithSave(params{:});
            self.home_folder = test_files_folder;
            %does nothing unless the constructor called with '-save' key
            self.save()
        end
        
        %--------------------------------------------------------------------------
        function test_1 (self)
            ap = IX_aperture (12,0.1,0.06);
            assertEqualWithSave (self,ap);
        end
        
        %--------------------------------------------------------------------------
        function test_2 (self)
            ap = IX_aperture (12,0.1,0.06,'-name','in-pile');
            assertEqualWithSave (self,ap);
        end
        
        %--------------------------------------------------------------------------
        function test_3 (self)
            ap = IX_aperture ('in-pile',12,0.1,0.06);
            assertEqualWithSave (self,ap);
        end
        
        %--------------------------------------------------------------------------
        function test_cov (~)
            ap = IX_aperture ('in-pile',12,0.1,0.06);
            cov = ap.covariance();
            assertEqualToTol(cov, [0.1^2,0;0,0.06^2]/12, 'tol', 1e-12);
            
        end
        
        %--------------------------------------------------------------------------
        function test_pdf (~)
            ap = IX_aperture ('in-pile',12,0.1,0.06);
            
            npnt = 4e7;
            X = rand (ap, 1, npnt);
            stdev = std(X,1,2);
            assertEqualToTol(stdev.^2, [0.1^2;0.06^2]/12, 'reltol', 1e-3);
        end
        
        function test_apperture_array_prev_versions(obj)
            % 2x2 array example
            ap_arr = [IX_aperture('Ap0', 11, 0.2, 0.25), IX_aperture('Ap1', 121, 0.22, 0.225);...
                IX_aperture('Ap3', 311, 0.23, 0.325), IX_aperture('Ap4', 114, 0.24, 0.245)];
            sample_file_location = obj.home_folder;            
            if obj.save_output % prepare test data for the future.
                % move test data to data folder manually
                % run test_IX_apperture with -save option to obtain reference
                % files when changed to new class version
                
                save_variables=true;
                ver = ap_arr.classVersion();
                verstr = ['ver',num2str(ver)];
                [ok,mess] = check_matfile_IO(verstr, save_variables, sample_file_location ,ap_arr);
                assertTrue(ok,mess)
            else
                save_variables=false;
                verstr = 'ver0';
                [ok,mess] = check_matfile_IO(verstr, save_variables,sample_file_location ,ap_arr);
                assertTrue(ok,mess)
                
                verstr= 'ver1';
                [ok,mess] = check_matfile_IO(verstr, save_variables, sample_file_location ,ap_arr);
                assertTrue(ok,mess)
            end
            
        end
        %
        function test_single_apperture_load_prev_versions(obj)
            % Scalar example
            ap = IX_aperture ('Ap0', 11, 0.2, 0.25);
            sample_files_location = obj.home_folder;
            if obj.save_output
            % run test_IX_apperture with -save option to obtain reference
            % files when changed to new class version                
                save_variables=true;
                ver = ap.classVersion();
                verstr = ['ver',num2str(ver)];
                [ok,mess] = check_matfile_IO(verstr, save_variables, sample_files_location ,ap);
                assertTrue(ok,mess)
                
            else
                save_variables=false;
                verstr = 'ver0';
                [ok,mess] = check_matfile_IO(verstr, save_variables,sample_files_location ,ap);
                assertTrue(ok,mess)
                
                verstr= 'ver1';
                [ok,mess] = check_matfile_IO(verstr, save_variables, sample_files_location ,ap);
                assertTrue(ok,mess)
            end
        end
        
        %--------------------------------------------------------------------------
    end
end

