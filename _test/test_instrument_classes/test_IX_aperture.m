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
                        filename = 'test_IX_aperture_data.mat';
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
        
        %--------------------------------------------------------------------------
    end
end

