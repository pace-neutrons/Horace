classdef test_IX_divergence_profile < TestCaseWithSave
    % Test of IX_divergence_profile

    properties
        ang;
        y;
        home_folder;
    end

    methods
        %--------------------------------------------------------------------------
        function obj = test_IX_divergence_profile (name)
            home_folder = fileparts(mfilename('fullpath'));
            if nargin == 0
                name = 'test_IX_divergence_profile';
            end
            file = fullfile(home_folder,'test_IX_divergence_profile_output.mat');
            obj@TestCaseWithSave(name,file);
            obj.home_folder = home_folder;


            obj.ang = -0.5:0.1:0.5;
            obj.y = [0.8662    0.8814    0.0385    0.3429    0.0385    0.1096...
                0.6027    0.7396    0.3152    0.9257    0.5347];

            obj.save()
        end

        %--------------------------------------------------------------------------
        function test_1 (self)
            div = IX_divergence_profile (self.ang, self.y);
            assertEqualWithSave (self,div);
        end

        %--------------------------------------------------------------------------
        function test_2 (self)
            div = IX_divergence_profile (self.ang,'name','in-pile','profile',self.y);
            assertEqualWithSave (self,div);
        end

        %--------------------------------------------------------------------------
        function test_3 (self)
            ws = warning('off','HERBERT:IX_divergence_profile:deprecated');
            clOb = onCleanup(@()warning(ws));
            div = IX_divergence_profile ('in-pile',self.ang, self.y);
            %             [~,mess_id] = lastwarn();
            %             assertEqual(mess_id,'HERBERT:IX_divergence_profile:deprecated');

            div1= IX_divergence_profile (self.ang, self.y,'in-pile');
            assertEqual(div,div1);

            assertEqualWithSave (self,div);
        end

        %--------------------------------------------------------------------------
        function test_4 (self)
            ytmp = self.y;
            ytmp(3) = -0.1;
            assertExceptionThrown(@()IX_divergence_profile (self.ang, ytmp,'in-pile'),...
                'HERBERT:IX_divergence_profile:invalid_argument');
        end
        %--------------------------------------------------------------------------
        function test_prev_versions_array(obj)
            angl = @(x0,n)(x0 + (1:n));
            val = @(n)([0, ones(1,n-2) + 0.02*(1:n-2), 0]);  % version 0 requires end points to be zero


            % 2x2 array example
            div_arr = [IX_divergence_profile(angl(5,25),val(25)), IX_divergence_profile(angl(10,30),val(30));...
                IX_divergence_profile(angl(15,40),val(40)), IX_divergence_profile(angl(20,200),val(200))];


            sample_files_location = obj.home_folder;
            if obj.save_output
                % run test_IX_apperture with -save option to obtain reference
                % files when changed to new class version
                save_variables=true;
                ver = div_arr.classVersion();
                verstr = ['ver',num2str(ver)];
                check_matfile_IO(verstr, save_variables, sample_files_location,div_arr);

            else
                save_variables=false;

                verstr= 'ver1';
                check_matfile_IO(verstr, save_variables, sample_files_location ,div_arr);

                verstr= 'ver0';
                check_matfile_IO(verstr, save_variables, sample_files_location ,div_arr);

            end

        end
        function test_prev_versions(obj)
            %--------------------------------------------------------------------------
            % Divergence
            %---------------
            % Scalar example
            angl = @(x0,n)(x0 + (1:n));
            val = @(n)([0, ones(1,n-2) + 0.02*(1:n-2), 0]);  % version 0 requires end points to be zero
            div = IX_divergence_profile (angl(5,20),val(20));

            % Scalar example
            sample_files_location = obj.home_folder;
            if obj.save_output
                % run test_IX_apperture with -save option to obtain reference
                % files when changed to new class version
                save_variables=true;
                ver = div.classVersion();
                verstr = ['ver',num2str(ver)];
                check_matfile_IO(verstr, save_variables, sample_files_location,div);

            else
                save_variables=false;

                verstr= 'ver1';
                check_matfile_IO(verstr, save_variables, sample_files_location ,div);

                verstr= 'ver0';
                check_matfile_IO(verstr, save_variables, sample_files_location ,div);

            end

        end

    end
end

