classdef test_IX_doubledisk_chopper < TestCaseWithSave
    % Test of IX_doubledis_chopper
    properties
        home_folder
    end

    methods
        %--------------------------------------------------------------------------
        function obj = test_IX_doubledisk_chopper (name)
            home_folder = fileparts(mfilename('fullpath'));
            if nargin == 0
                name = 'test_IX_doubledisk_chopper';
            end
            file = fullfile(home_folder,'test_IX_doubledisk_chopper_output.mat');
            obj@TestCaseWithSave(name,file);
            obj.home_folder = home_folder;


            obj.save()
        end

        %--------------------------------------------------------------------------
        function test_aperture_undefined_slot_width_used(self)
            chop = IX_doubledisk_chopper (12,120,0.7,0.02);
            assertEqualWithSave (self,chop,'',[0,1.e-9]);

            assertEqual(chop.slot_width,chop.aperture_width)
        end

        %--------------------------------------------------------------------------
        function test_insufficient_arguments_throw (~)
            assertExceptionThrown(@()IX_doubledisk_chopper (12,120,0.7),...
                'HERBERT:IX_doubledisk_chopper:invalid_argument');
        end

        %--------------------------------------------------------------------------
        function test_aperture_defined (self)
            chop = IX_doubledisk_chopper (12,120,0.7,0.02,0.05);
            assertEqualWithSave (self,chop,[0,1.e-9]);
            assertEqual(chop.slot_width,0.02);
            assertEqual(chop.aperture_width,0.05);
        end

        %--------------------------------------------------------------------------
        function test_constructor_with_positional_names (self)
            ws = warning('off','HERBERT:IX_doubledisk_chopper:deprecated');
            clOb = onCleanup(@()warning(ws));
            chop = IX_doubledisk_chopper ('Chopper_1',12,120,0.7,0.02,0.05);
            %
            %             [~,mess_id] = lastwarn();
            %             assertEqual(mess_id,'HERBERT:IX_doubledisk_chopper:deprecated');

            chop1 = IX_doubledisk_chopper (12,120,0.7,0.02,0.05,0,0,'Chopper_1');
            assertEqual(chop,chop1)

            assertEqualWithSave (self,chop,'',[0,1.e-9]);
        end

        %--------------------------------------------------------------------------
        function test_constructor_with_key_val (self)
            ws = warning('off','HORACE:serializable:deprecated');
            clOb = onCleanup(@()warning(ws));

            chop = IX_doubledisk_chopper (12,120,0.7,0.02,0.05,...
                '-name','Chopper_1','-aperture_h',0.2);
            [~,mess_id] = lastwarn();
            assertEqual(mess_id,'HORACE:serializable:deprecated');

            chop1 = IX_doubledisk_chopper (12,120,0.7,0.02,0.05,...
                'name','Chopper_1','aperture_h',0.2);
            assertEqual(chop,chop1)

            assertEqualWithSave (self,chop,'',[0,1.e-9]);

        end
        %--------------------------------------------------------------------------
        function test_prev_versions_array(obj)

            % 2x2 array example
            disk_arr = [IX_doubledisk_chopper(12,120,0.5,0.01,0.02),...
                IX_doubledisk_chopper(12,120,0.5,0.01,0.04,3);...
                IX_doubledisk_chopper(15,120,0.5,0.01),...
                IX_doubledisk_chopper(122,120,0.5,0.01,0.03)];


            sample_files_location = obj.home_folder;
            if obj.save_output
                % run test_IX_apperture with -save option to obtain reference
                % files when changed to new class version
                save_variables=true;
                ver = disk_arr.classVersion();
                verstr = ['ver',num2str(ver)];
                check_matfile_IO(verstr, save_variables, sample_files_location,disk_arr);

            else
                save_variables=false;
                verstr= 'ver0';
                check_matfile_IO(verstr, save_variables, sample_files_location ,disk_arr);


                verstr= 'ver1';
                check_matfile_IO(verstr, save_variables, sample_files_location ,disk_arr);
            end
        end

        function test_prev_versions(obj)
            % Scalar example
            disk = IX_doubledisk_chopper(12,120,0.5,0.01);
            %dd_chop = IX_doubledisk_chopper (12,120,0.7,0.02,0.05);
            sample_files_location = obj.home_folder;
            if obj.save_output
                % run test_IX_apperture with -save option to obtain reference
                % files when changed to new class version
                save_variables=true;
                ver = disk.classVersion();
                verstr = ['ver',num2str(ver)];
                check_matfile_IO(verstr, save_variables, sample_files_location,disk);

            else
                save_variables=false;
                verstr= 'ver0';
                check_matfile_IO(verstr, save_variables, sample_files_location ,disk);

                verstr= 'ver1';
                check_matfile_IO(verstr, save_variables, sample_files_location ,disk);
            end
        end

    end
end

