classdef test_instrument_methods < TestCaseWithSave
    % Test of setting instrument and moderator parameters
    properties
        w_fe
        w_rb
        inst_1
        inst_2
    end
    
    methods
        %--------------------------------------------------------------------------
        function self = test_instrument_methods (name)
            self@TestCaseWithSave(name);
            
            % load data
            load('test_instrument_methods_data.mat','w_fe','w_rb')
            self.w_fe = w_fe;     % iron dataset
            self.w_rb = w_rb;     % RbMnF3 dataset
            
            % Make an instrument(distance,frequency,radius,curvature,slit_width
            mod_1 = IX_moderator(10,11,'ikcarp',[11,111,0.1]);
            mod_2 = IX_moderator(20,22,'ikcarp',[20,222,0.2]);
            ap_1 = IX_aperture(-10,0.1,0.11);
            ap_2 = IX_aperture(-20,0.2,0.22);
            chopper_1 = IX_fermi_chopper(1,100,0.1,1,0.01);
            chopper_2 = IX_fermi_chopper(2,200,0.2,2,0.02);
            inst_1 = IX_inst_DGfermi (mod_1, ap_1, chopper_1, 100);
            inst_2 = IX_inst_DGfermi (mod_2, ap_2, chopper_2, 200);
            
            self.inst_1 = inst_1;
            self.inst_2 = inst_2;
            
            self.save()
        end
        
        %--------------------------------------------------------------------------
        function test_1 (self)
            % Set all spe file to the same instrument
            wnew_fe = set_instrument(self.w_fe,self.inst_1);
            assertEqual(wnew_fe.header{3}.instrument, self.inst_1);
        end
        
        %--------------------------------------------------------------------------
        function test_2 (self)
            % Set instruments individually
            inst_arr = repmat(self.inst_1,186,1);
            inst_arr(100) = self.inst_2;
            
            wnew_fe = set_instrument(self.w_fe,inst_arr);
            assertEqual(wnew_fe.header{99}.instrument, self.inst_1);
            assertEqual(wnew_fe.header{100}.instrument, self.inst_2);
            assertEqual(wnew_fe.header{101}.instrument, self.inst_1);
        end
        
        %--------------------------------------------------------------------------
        function test_3 (self)
            % Set efix
            efix_new = 777;
            wnew_fe = set_efix(self.w_fe,efix_new);
            
            efix = wnew_fe.header{45}.efix;
            assertEqual(efix,efix_new)
        end

        %--------------------------------------------------------------------------
        function test_4 (self)
            % Set efix individually, and test enquiry routine
            efix_new = 777*ones(1,186);
            efix_new(100) = 777 + 186;  % so the average is 778
            
            wnew_fe = set_efix(self.w_fe,efix_new);
            
            efix = get_efix(wnew_fe);
            assertEqual(efix,778)

        end
        
        %--------------------------------------------------------------------------
        function test_5 (self)
            % Set all mod pars to the same
            wnew_fe = set_instrument(self.w_fe,self.inst_1);
            
            pp = [100,200,0.7];
            wnew_fe = set_mod_pulse(wnew_fe, 'ikcarp', pp);
            
            [~,pp] = get_mod_pulse(wnew_fe);
            
            mod3 = wnew_fe.header{3}.instrument.moderator;
            assertEqualToTol(mod3.pp, pp, 'reltol', 1e-13);
        end
        
        %--------------------------------------------------------------------------
        function test_6 (self)
            % Set mod pars individually and test enquiry
            wnew_fe = set_instrument(self.w_fe,self.inst_1);
            
            pp = [100,200,0.7];
            pp = repmat(pp,186,1);
            pp(100,:) = [100,386,0.7];  % so pp(2) average is 201
            wnew_fe = set_mod_pulse(wnew_fe, 'ikcarp', pp);
            
            mod3 = wnew_fe.header{3}.instrument.moderator;
            assertEqual(mod3.pp, [100, 200, 0.7]);

            mod100 = wnew_fe.header{100}.instrument.moderator;
            assertEqual(mod100.pp, [100,386, 0.7]);

            [~,pp_av] = get_mod_pulse(wnew_fe);
            assertEqualToTol(pp_av, [100,201,0.7], 'reltol', 1e-13);
        end
        
        %--------------------------------------------------------------------------
    end
end
