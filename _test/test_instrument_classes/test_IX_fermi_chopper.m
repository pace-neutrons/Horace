classdef test_IX_fermi_chopper < TestCaseWithSave
    % Test of IX_fermi_chopper
    properties
        f500
        f200
        f163
        f162
        f100
        f50
        home_folder
    end

    methods
        %--------------------------------------------------------------------------
        function obj = test_IX_fermi_chopper (name)
            home_folder = fileparts(mfilename('fullpath'));
            if nargin == 0
                name = 'test_IX_fermi_chopper';
            end
            file = fullfile(home_folder,'test_IX_fermi_chopper_output.mat');
            obj@TestCaseWithSave(name,file);
            obj.home_folder = home_folder;

            % Make some Fermi choppers
            f=IX_fermi_chopper(10,600,0.049,1.3,0.0028);

            f500 = f; f500.energy = 500; % gamma = eps
            f200 = f; f200.energy = 200; % gamma < 1
            f163 = f; f163.energy = 163; % gamma = 1-eps
            f162 = f; f162.energy = 162; % gamma = 1+eps
            f100 = f; f100.energy = 100; % gamma = 1.64
            f50 = f;  f50.energy = 50;   % gamma = 2.86

            % A chopper
            obj.f500 = f500;
            obj.f200 = f200;
            obj.f163 = f163;
            obj.f162 = f162;
            obj.f100 = f100;
            obj.f50  = f50;

            obj.save()
        end

        %--------------------------------------------------------------------------
        function test_pulse_shape (self)
            t = -20:0.001:20;
            y = pulse_shape (self.f500,t); w500=IX_dataset_1d(t,y);
            y = pulse_shape (self.f200,t); w200=IX_dataset_1d(t,y);
            y = pulse_shape (self.f163,t); w163=IX_dataset_1d(t,y);
            y = pulse_shape (self.f162,t); w162=IX_dataset_1d(t,y);
            y = pulse_shape (self.f100,t); w100=IX_dataset_1d(t,y);
            y = pulse_shape (self.f50,t);  w50=IX_dataset_1d(t,y);

            warr = [w500,w200,w163,w162,w100,w50];
            assertEqualWithSave (self,warr);
        end

        %--------------------------------------------------------------------------
        function test_auto_pulse_shape (self)
            [y,t] = pulse_shape (self.f163); w163=IX_dataset_1d(t,y);
            assertEqualWithSave (self,w163,'',[0,1.e-9]);
        end

        %--------------------------------------------------------------------------
        function test_pdf (self)
            npnt = 1e7;

            % Pulse shape
            tbin = -20:0.05:20;
            t = tbin(1:end-1) + 0.025;
            y = pulse_shape (self.f200,t); w200=IX_dataset_1d(t,y);
            area = integrate(w200);
            w200 = w200/area.val;

            % From sampling
            wsamp = vals2distr (self.f200.rand(1,npnt), tbin, 'norm', 'poisson');

            [ok,mess,wdiff,chisqr] = IX_dataset_1d_same (wsamp,w200,3,'rebin','chi');

            assert(ok,mess);
        end

        %--------------------------------------------------------------------------
        % Test of the default object
        %--------------------------------------------------------------------------
        function test_default_pulse_shape (~)
            % Delta function pulse, even though energy = 0
            f = IX_fermi_chopper ();
            [y,t] = pulse_shape(f);
            assertEqual (t, 0)
            assertEqual (y, Inf)
        end

        function test_default_pulse_range (~)
            % Delta function pulse, even though energy = 0
            f = IX_fermi_chopper ();
            [tlo, thi] = pulse_range(f);
            assertEqual (tlo, 0)
            assertEqual (thi, 0)
        end

        function test_default_partial_transmission (~)
            % Delta function pulse, even though energy = 0
            f = IX_fermi_chopper ();
            T = partial_transmission (f, [-eps,0,eps]);
            assertEqual (T, [0,0,1])
        end

        function test_prev_versions_array(obj)

            % 2x2 array example
            fermi_arr = [IX_fermi_chopper(12,610,0.049,1.3,0.0228),...
                IX_fermi_chopper(12,620,0.049,1.3,0.0228);...
                IX_fermi_chopper(12,630,0.049,1.3,0.0228),...
                IX_fermi_chopper(12,640,0.049,1.3,0.0228)];


            sample_files_location = obj.home_folder;
            if obj.save_output
                % run test_IX_apperture with -save option to obtain reference
                % files when changed to new class version
                save_variables=true;
                ver = fermi_arr.classVersion();
                verstr = ['ver',num2str(ver)];
                check_matfile_IO(verstr, save_variables, sample_files_location,fermi_arr);
            else
                save_variables=false;
                verstr= 'ver0';
                check_matfile_IO(verstr, save_variables, sample_files_location ,fermi_arr);


                verstr= 'ver1';
                check_matfile_IO(verstr, save_variables, sample_files_location ,fermi_arr);
            end

        end        
        function test_prev_versions(obj)
           % Scalar example
            fermi = IX_fermi_chopper(12,600,0.049,1.3,0.0228);

            sample_files_location = obj.home_folder;
            if obj.save_output
                % run test_IX_apperture with -save option to obtain reference
                % files when changed to new class version
                save_variables=true;
                ver = fermi.classVersion();
                verstr = ['ver',num2str(ver)];
                check_matfile_IO(verstr, save_variables, sample_files_location,fermi);

            else
                save_variables=false;

                verstr= 'ver1';
                check_matfile_IO(verstr, save_variables, sample_files_location ,fermi);
            end

        end

        %--------------------------------------------------------------------------
    end
end
