classdef test_IX_inst < TestCaseWithSave
    % Test of instrumnet dfinition objects
    properties
        % DGfermi instrument:
        mod_DGfermi
        ap_DGfermi
        chop_DGfermi
        
        % DGdisk instrument:
        mod_DGdisk
        shape_DGdisk
        mono_DGdisk
        hdiv_DGdisk
        vdiv_DGdisk
    end
    
    methods
        %--------------------------------------------------------------------------
        function self = test_IX_inst (name)
            self@TestCaseWithSave(name);
            
            % Create components needed for an IX_inst_DGfermi
            % Use an old-ish maps function for convenience
            instru = maps_instrument_struct_for_tests(500,600,'S');
            
            self.mod_DGfermi = instru.moderator;
            self.ap_DGfermi = instru.aperture;
            self.chop_DGfermi = instru.fermi_chopper;
            
            % Create components needed for an IX_inst_DGdisk
            % Use an old-ish LET function for convenience
            efix = 8.04;
            instru = let_instrument_struct_for_tests (efix, 280, 140, 20, 2, 2);
            instru.chop_shape.frequency=171;
            
            self.mod_DGdisk = instru.moderator;
            self.shape_DGdisk = instru.chop_shape;
            self.mono_DGdisk = instru.chop_mono;
            self.hdiv_DGdisk = instru.horiz_div;
            self.vdiv_DGdisk = instru.vert_div;
            
            %             xx = IX_inst_DGdisk (mod_DGdisk, shape_DGdisk, mono_DGdisk,...
            %                 hdiv_DGdisk, vdiv_DGdisk);
            
            self.save()
        end
        
        %--------------------------------------------------------------------------
        function test_create_DGfermi (self)
            % Test creation of Fermi instrument
            instru = IX_inst_DGfermi (self.mod_DGfermi, self.ap_DGfermi, self.chop_DGfermi);
            assertEqualWithSave (self,instru,'',[1.e-12,1.e-9]);
        end
        
        %--------------------------------------------------------------------------
        function test_query_DGfermi (self)
            % Test querying moderator parameters
            instru = IX_inst_DGfermi (self.mod_DGfermi, self.ap_DGfermi, self.chop_DGfermi);
            mod_dist = instru.moderator.distance;
            assertEqualWithSave (self,mod_dist);
        end
        
        %--------------------------------------------------------------------------
        function test_modify_DGfermi (self)
            % Test changing moderator parameters
            instru = IX_inst_DGfermi (self.mod_DGfermi, self.ap_DGfermi, self.chop_DGfermi);
            
            mod_new = self.mod_DGfermi;
            mod_new.distance = 199;
            mod_new.pp(1) = 42;
            
            instru.moderator = mod_new;     % change moderator
            
            mod_dist = instru.moderator.distance;
            pp1 = instru.moderator.pp(1);
            assertEqual (199,mod_dist);
            assertEqual (42,pp1)
        end
        
        %--------------------------------------------------------------------------
        function test_modify_DGfermi_energy (self)
            % Test changing instrument energy - should progagate in several places
            instru = IX_inst_DGfermi (self.mod_DGfermi, self.ap_DGfermi, self.chop_DGfermi);
            instru.energy = 254;
            
            mod_energy = instru.moderator.energy;
            chop_energy = instru.fermi_chopper.energy;
            assertEqual (254,mod_energy)
            assertEqual (254,chop_energy)
        end
        
        %--------------------------------------------------------------------------
        function test_create_DGdisk (self)
            % Test creation of disk chopper instrument
            instru = IX_inst_DGdisk (self.mod_DGdisk, self.shape_DGdisk, self.mono_DGdisk,...
                self.hdiv_DGdisk, self.vdiv_DGdisk);
            assertEqualWithSave (self,instru,'',[0,1.e-9]);
        end
        
        %--------------------------------------------------------------------------
        function test_modify_DGdisk_energy (self)
            % Test changing instrument energy - should progagate in several places
            instru = IX_inst_DGdisk (self.mod_DGdisk, self.shape_DGdisk, self.mono_DGdisk,...
                self.hdiv_DGdisk, self.vdiv_DGdisk);
            instru.energy = 9.5;
            
            mod_energy = instru.moderator.energy;
            assertEqual (9.5,mod_energy)
        end
        
        %--------------------------------------------------------------------------
    end
end
