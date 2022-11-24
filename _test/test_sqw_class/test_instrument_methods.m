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
            load('data/test_instrument_methods_data.mat','w_fe','w_rb')

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
        function test_set_instrument_updates_all_headers_to_single_value(self)
            % Set all spe file to the same instrument
            wnew_fe = set_instrument(self.w_fe, self.inst_1);
            hdr = wnew_fe.experiment_info;
            assertEqual(hdr.instruments{3}, self.inst_1);
        end

        %--------------------------------------------------------------------------
        function test_set_instrument_updates_headers_with_array_values(self)
            % Set instruments individually
            inst_arr = repmat(self.inst_1, 120, 1);
            inst_arr(100) = self.inst_2;

            wnew_fe = set_instrument(self.w_fe, inst_arr);

            hdr = wnew_fe.experiment_info;
            assertEqual(hdr.instruments{99}, self.inst_1);
            assertEqual(hdr.instruments{100}, self.inst_2);
            assertEqual(hdr.instruments{101}, self.inst_1);
        end

        %--------------------------------------------------------------------------
        function test_set_efix_updates_data_to_single_value(self)
            % Set efix
            efix_new = 777;
            wnew_fe = set_efix(self.w_fe, efix_new);

            hdr = wnew_fe.experiment_info;
            efix = hdr.expdata(45).efix;
            assertEqual(efix, efix_new)
        end

        %--------------------------------------------------------------------------
        function test_set_efix_updates_all_data_with_array_values(self)
            % Set efix individually, and test enquiry routine
            efix_new = 777 * ones(1, 120);
            efix_new(100) = 777 + 120;  % so the average is 778

            wnew_fe = set_efix(self.w_fe, efix_new);

            efix = get_efix(wnew_fe);
            assertEqual(efix, 778)
        end

        %--------------------------------------------------------------------------
        function test_set_mod_pulse_on_array_udates_data_to_single_value(self)
            % Set all mod pars to the same
            wnew_fe = set_instrument(self.w_fe, self.inst_1);
            wnew_fe  = [wnew_fe,wnew_fe];

            pp = [100, 200, 0.7];
            wnew_fe = set_mod_pulse(wnew_fe, 'ikcarp', pp);

            [~, pp] = get_mod_pulse(wnew_fe);

            hdr = wnew_fe(1).experiment_info;
            instr = hdr.instruments{3};
            mod3 = instr.moderator;
            assertEqualToTol(mod3.pp, pp, 'reltol', 1e-13);

            hdr = wnew_fe(2).experiment_info;
            instr = hdr.instruments{3};
            mod3 = instr.moderator;
            assertEqualToTol(mod3.pp, pp, 'reltol', 1e-13);

            assertTrue(ok)
            assertEqual(mess,'')
            assertTrue(isstruct(p));
            assertTrue(present);

        end

        function test_set_mod_pulse_udates_data_to_single_value(self)
            % Set all mod pars to the same
            wnew_fe = set_instrument(self.w_fe, self.inst_1);

            pp = [100, 200, 0.7];
            wnew_fe = set_mod_pulse(wnew_fe, 'ikcarp', pp);

            [pulse_model, pp,ok,mess,p,present] = get_mod_pulse(wnew_fe);
            assertEqual(pulse_model,'ikcarp')

            hdr = wnew_fe.experiment_info;
            instr = hdr.instruments{3};
            mod3 = instr.moderator;
            assertEqualToTol(mod3.pp, pp, 'reltol', 1e-13);

            assertTrue(ok)
            assertEqual(mess,'')
            assertTrue(isstruct(p));
            assertTrue(present);

        end

        function test_set_mod_pulse_on_unique_inst_udates_all_data_array_values (self)
            % Set mod pars individually and test enquiry
            wnew_fe = set_instrument(self.w_fe,self.inst_1);

            w_tot = [wnew_fe,wnew_fe];

            pp = [100, 200, 0.7;100,300,0.7];

            w_tot = set_mod_pulse(w_tot, 'ikcarp', pp);

            hdr = w_tot(2).experiment_info;
            instr = hdr.instruments{3};
            mod3 = instr.moderator;

            assertEqual(mod3.pp, [100,300,0.7]);
            instr = hdr.instruments{100};
            mod100 = instr.moderator;
            assertEqual(mod100.pp, [100,300,0.7]);


            hdr = w_tot(1).experiment_info;
            instr = hdr.instruments{100};
            mod100 = instr.moderator;
            assertEqual(mod100.pp, [100, 200, 0.7]);

            [pulse_model,pp_av,ok,mess,p,present] = get_mod_pulse(w_tot,0.05);
            assertEqualToTol(pp_av, [100,250,0.7], 'reltol', 1e-13);

            assertEqual(pulse_model,'ikcarp')
            assertFalse(ok)
            assertEqual(mess, ...
                'Spread of one or more pulse parameters lies outside acceptable fraction of average of 0.05')
            assertTrue(isstruct(p));
            assertTrue(present);
        end

        function test_set_mod_pulse_on_array_udates_all_data_array_values (self)
            % Set mod pars individually and test enquiry
            wnew_fe = set_instrument(self.w_fe,self.inst_1);

            w_tot = [wnew_fe,wnew_fe];

            pp = [100, 200, 0.7];
            pp = repmat(pp, 240, 1);
            pp(100, :) = [100, 209, 0.7];  % so pp(2) average is 200.0375
            w_tot = set_mod_pulse(w_tot, 'ikcarp', pp);

            hdr = w_tot(2).experiment_info;
            instr = hdr.instruments{3};
            mod3 = instr.moderator;

            assertEqual(mod3.pp, [100, 200, 0.7]);
            instr = hdr.instruments{100};
            mod100 = instr.moderator;
            assertEqual(mod100.pp, [100,200, 0.7]);


            hdr = w_tot(1).experiment_info;
            instr = hdr.instruments{100};
            mod100 = instr.moderator;
            assertEqual(mod100.pp, [100,209, 0.7]);

            [pulse_model,pp_av,ok,mess,p,present] = get_mod_pulse(w_tot,0.05);
            assertEqualToTol(pp_av, [100,200.0375,0.7], 'reltol', 1e-13);

            assertEqual(pulse_model,'ikcarp')
            assertTrue(ok)
            assertEqual(mess,'')
            assertTrue(isstruct(p));
            assertTrue(present);
        end

        function test_set_mod_pulse_udates_all_data_array_values (self)
            % Set mod pars individually and test enquiry
            wnew_fe = set_instrument(self.w_fe,self.inst_1);


            pp = [100, 200, 0.7];
            pp = repmat(pp, 120, 1);
            pp(100, :) = [100, 386, 0.7];  % so pp(2) average is 201.55
            wnew_fe = set_mod_pulse(wnew_fe, 'ikcarp', pp);

            hdr = wnew_fe.experiment_info;
            instr = hdr.instruments{3};
            mod3 = instr.moderator;
            assertEqual(mod3.pp, [100, 200, 0.7]);

            instr = hdr.instruments{100};
            mod100 = instr.moderator;
            assertEqual(mod100.pp, [100,386, 0.7]);

            [pulse_model,pp_av,ok,mess,p,present] = get_mod_pulse(wnew_fe);
            assertEqualToTol(pp_av, [100,201.55,0.7], 'reltol', 1e-13);

            assertEqual(pulse_model,'ikcarp')
            assertFalse(ok)
            assertEqual(mess, ...
                'Spread of one or more pulse parameters lies outside acceptable fraction of average of 0.005')
            assertTrue(isstruct(p));
            assertTrue(present);
        end

        %--------------------------------------------------------------------------
    end
end
