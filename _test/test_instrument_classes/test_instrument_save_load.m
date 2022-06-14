classdef test_instrument_save_load < TestCaseWithSave
    % Test the saving and loading of instruments as mat files and bytestreams
    properties
        inst_DGdisk
        inst_DGfermi
        matfile
    end
    
    methods
        %--------------------------------------------------------------------------
        function self = test_instrument_save_load (name)
            self@TestCaseWithSave(name);
            
            % Instruments
            self.inst_DGdisk = let_instrument_obj_for_tests(8,240,120,20,1,2);
            self.inst_DGfermi = maps_instrument_obj_for_tests(300,250,'S');
            
            % Temporary output file
            self.matfile = fullfile(tmp_dir,'test_instrument_save_load.mat');
            
            self.save()
        end
        
        %--------------------------------------------------------------------------
        function test_DGdisk_mat (self)
            inst_ref = self.inst_DGdisk;
            save(self.matfile,'inst_ref');
            tmp = load(self.matfile);
            
            assertEqual(inst_ref,tmp.inst_ref)
        end
        
        %--------------------------------------------------------------------------
        function test_DGfermi_mat (self)
            inst_ref = self.inst_DGfermi;
            save(self.matfile,'inst_ref');
            tmp = load(self.matfile);
            
            assertEqual(inst_ref,tmp.inst_ref)
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
