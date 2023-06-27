classdef test_instrument_save_load < TestCaseWithSave
    % Test the saving and loading of instruments as mat files and bytestreams
    properties
        inst_DGdisk
        inst_DGfermi
    end

    methods
        %--------------------------------------------------------------------------
        function obj = test_instrument_save_load (name)
            home_folder = fileparts(mfilename('fullpath'));
            if nargin == 0
                name = 'test_instrument_save_load';
            end
            file = fullfile(home_folder,'test_instrument_save_load_output.mat');
            obj@TestCaseWithSave(name,file);


            % Instruments
            obj.inst_DGdisk = let_instrument_obj_for_tests(8,240,120,20,1,2);
            obj.inst_DGfermi = maps_instrument_obj_for_tests(300,250,'S');


            obj.save()
        end

        %--------------------------------------------------------------------------
        function test_DGdisk_mat (self)
            disk_inst_ref = self.inst_DGdisk;

            assertEqualWithSave(self,disk_inst_ref)
        end

        %--------------------------------------------------------------------------
        function test_DGfermi_mat (self)
            fermi_inst_ref = self.inst_DGfermi;

            assertEqualWithSave(self,fermi_inst_ref)
        end

        %--------------------------------------------------------------------------
        function test_DGdisk_bytestream (self)
            inst_ref = self.inst_DGdisk;
            bytes = hlp_serialize(inst_ref);
            inst = hlp_deserialize(bytes);

            assertEqual(inst_ref,inst)
        end

        %--------------------------------------------------------------------------
        function test_DGfermi_bytestream (self)
            inst_ref = self.inst_DGfermi;
            bytes = hlp_serialize(inst_ref);
            inst = hlp_deserialize(bytes);

            assertEqual(inst_ref,inst)
        end

        %--------------------------------------------------------------------------
    end

end
