classdef test_IX_sample < TestCaseWithSave
    % Test of obj2struct
    properties
        sam1
        sam2
        sam3
        s1
        s2
        s3
        slookup
        home_folder;
    end

    methods
        %--------------------------------------------------------------------------
        function obj = test_IX_sample (name)
            home_folder = fileparts(mfilename('fullpath'));
            if nargin == 0
                name = 'test_IX_sample';
            end
            file = fullfile(home_folder,'test_IX_sample_output.mat');
            obj@TestCaseWithSave(name,file);

            % Make some samples and sample arrays
            obj.sam1 = IX_sample ([1,0,0],[0,1,0],'cuboid',[2,3,4]);
            obj.sam2 = IX_sample ([0,1,0],[0,0,1],'cuboid',[12,13,34]);
            obj.sam3 = IX_sample ([1,1,0],[0,0,1],'cuboid',[22,23,24]);

            obj.s1 = [obj.sam1, obj.sam1, obj.sam2, obj.sam2, obj.sam2];
            obj.s2 = [obj.sam3, obj.sam1, obj.sam2, obj.sam3, obj.sam1];
            obj.s3 = [obj.sam2, obj.sam3, obj.sam1, obj.sam2, obj.sam3];

            obj.slookup = object_lookup({obj.s1, obj.s2, obj.s3});

            obj.save()
        end
        function test_to_from_struct(~)
            sample = IX_sample([1,0,0], [0,1,0], 'cuboid', [2,3,4],...
                'hall_symbol', 'hsymbol');
            sample.alatt = [1,2,3];
            sample.angdeg = [91,89,91];
            str = sample.to_struct();

            samp_rec = serializable.from_struct(str);

            assertEqual(sample,samp_rec);
        end

        %--------------------------------------------------------------------------
        function test_IX_sample_constructor_error_if_required_args_missing(~)
            f = @()IX_sample([1,0,0],[0,1,0],'cuboid');
            assertExceptionThrown(f, 'HERBERT:IX_sample:invalid_argument');
        end

        %--------------------------------------------------------------------------
        function test_IX_sample_constructor_error_if_invalid_shape(~)
            f = @()IX_sample([1,0,0],[0,1,0],'banana',[2,3,4]);
            assertExceptionThrown(f, 'HERBERT:IX_sample:invalid_argument');
        end

        %--------------------------------------------------------------------------
        function test_IX_sample_constructor_accepts_and_sets_hall_symbol(~)
            sample = IX_sample([1,0,0], [0,1,0], 'cuboid', [2,3,4], 'hall_symbol', 'hsymbol');
            assertEqual(sample.hall_symbol, 'hsymbol');
        end

        %--------------------------------------------------------------------------
        function test_IX_sample_constructor_accepts_and_sets_temperature(~)
            sample = IX_sample([1,0,0], [0,1,0], 'cuboid', [2,3,4], 'temperature', 1234.5);
            assertEqual(sample.temperature, 1234.5);
        end
        function test_IX_sample_constructor_errors_for_non_numeric_temperature(~)
            f = @()IX_sample([1,0,0], [0,1,0], 'cuboid', [2,3,4], 'temperature', 'string');
            assertExceptionThrown(f, 'HERBERT:IX_sample:invalid_argument');
        end

        %--------------------------------------------------------------------------
        function test_IX_sample_constructor_accepts_and_sets_name(~)
            sample = IX_sample([1,0,0], [0,1,0], 'cuboid', [2,3,4], 'name', 'test name');
            assertEqual(sample.name, 'test name');
        end

        %--------------------------------------------------------------------------
        function test_IX_sample_constructor_accepts_and_sets_mosaic_eta(~)
            eta = IX_mosaic(1234);
            sample = IX_sample([1,0,0], [0,1,0], 'cuboid', [2,3,4], 'eta', eta);
            assertEqual(sample.eta, eta);
        end
        function test_IX_sample_constructorsets_sets_numeric_eta_as_mosaic(~)
            sample = IX_sample([1,0,0], [0,1,0], 'cuboid', [2,3,4], 'eta', 4134);
            assertEqual(sample.eta, IX_mosaic(4134));
        end

        %--------------------------------------------------------------------------
        function test_covariance (self)
            s = self.slookup;
            cov = s.func_eval_ind(2,[2,2,1,4,3],@covariance);
            assertEqualWithSave (self,cov);
        end

        %--------------------------------------------------------------------------
        function test_identical_samples_are_equal(~)
            samp1 = IX_sample([1,0,0], [0,1,0], 'cuboid', [2,3,4]);
            samp2 = IX_sample([1,0,0], [0,1,0], 'cuboid', [2,3,4]);

            assertTrue(samp1 == samp2);
            assertFalse(samp1 ~= samp2)
        end

        function test_different_samples_are_not_equal(~)
            samp1 = IX_sample ([1,0,0],[0,1,0],'cuboid',[2,3,4]);
            samp2 = IX_sample ([1,1,0],[0,0,1],'cuboid',[22,23,24]);

            assertFalse(samp1 == samp2);
            assertTrue(samp1 ~= samp2)
        end

        function test_identical_samples_with_matching_hall_symbol_are_equal(~)
            samp1 = IX_sample([1,0,0], [0,1,0], 'cuboid', [2,3,4], 'hall_symbol', 'hsymbol');
            samp2 = IX_sample([1,0,0], [0,1,0], 'cuboid', [2,3,4], 'hall_symbol', 'hsymbol');

            assertTrue(samp1 == samp2);
            assertFalse(samp1 ~= samp2)
        end

        function test_matching_samples_with_missing_hall_symbol_are_not_equal(~)
            samp1 = IX_sample([1,0,0], [0,1,0], 'cuboid', [2,3,4]);
            samp2 = IX_sample([1,0,0], [0,1,0], 'cuboid', [2,3,4], 'hall_symbol', 'hsymbol');

            assertFalse(samp1 == samp2);
            assertTrue(samp1 ~= samp2)
        end

        function test_matching_samples_with_different_hall_symbols_are_not_equal(~)
            samp1 = IX_sample([1,0,0], [0,1,0], 'cuboid', [2,3,4], 'hall_symbol', 'other');
            samp2 = IX_sample([1,0,0], [0,1,0], 'cuboid', [2,3,4], 'hall_symbol', 'hsymbol');

            assertFalse(samp1 == samp2);
            assertTrue(samp1 ~= samp2)
        end

        %--------------------------------------------------------------------------
        function test_pdf (self)
            nsamp = 1e7;
            ind = randselection([2,3],[ceil(nsamp/10),10]);     % random indicies from 2 and 3
            samp = rand_ind(self.slookup,2,ind,@rand);
            samp2 = samp(:,ind==2);
            samp3 = samp(:,ind==3);

            mean2 = mean(samp2,2);
            mean3 = mean(samp3,2);
            std2 = std(samp2,1,2);
            std3 = std(samp3,1,2);

            assertEqualToTol(mean2, [0;0;0], 'tol', 0.003);
            assertEqualToTol(mean3, [0;0;0], 'tol', 0.02);

            assertEqualToTol(std2, self.sam1.ps'/sqrt(12), 'reltol', 0.001);
            assertEqualToTol(std3, self.sam2.ps'/sqrt(12), 'tol', 0.01);
        end
        %--------------------------------------------------------------------------
        function test_prev_versions_array(obj)
            % 1x2 array example
            sample_arr = [IX_sample('',false,[1,1,1],[0,1,1],'cuboid',[0.005,0.005,0.0005]),...
                IX_sample('FeSi',true,[1,1,0],[0,1,3],'cuboid',[0.020,0.024,0.028],0.5,120)];

            sample_files_location = obj.home_folder;
            if obj.save_output
                % run test_IX_apperture with -save option to obtain reference
                % files when changed to new class version
                save_variables=true;
                ver = sample_arr(1).classVersion();
                verstr = ['ver',num2str(ver)];
                check_matfile_IO(verstr, save_variables, sample_files_location,sample_arr);

            else
                save_variables=false;
                verstr= 'ver0';
                check_matfile_IO(verstr, save_variables, sample_files_location ,sample_arr);


                verstr= 'ver1';
                check_matfile_IO(verstr, save_variables, sample_files_location ,sample_arr);
            end
        end

        function test_prev_versions(obj)
            % Scalar example
            sample = IX_sample('Fe',true,[1,1,0],[0,1,3],'cuboid',[0.020,0.024,0.028]);

            sample_files_location = obj.home_folder;
            if obj.save_output
                % run test_IX_apperture with -save option to obtain reference
                % files when changed to new class version
                save_variables=true;
                ver = sample.classVersion();
                verstr = ['ver',num2str(ver)];
                check_matfile_IO(verstr, save_variables, sample_files_location,sample);

            else
                save_variables=false;
                verstr= 'ver0';
                check_matfile_IO(verstr, save_variables, sample_files_location ,sample);

                verstr= 'ver1';
                check_matfile_IO(verstr, save_variables, sample_files_location ,sample);
            end
        end

    end
end

