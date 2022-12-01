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
        function test_set_obj_array_sample_array(obj)
            samp = [IX_sample([1,0,0],[0,1,0],'cuboid',[2,3,4]),...
                    IX_sample([0,1,0],[0,0,1],'cuboid',[12,13,34])];            

            w_mod = [obj.w_fe,obj.w_rb];

            w_mod = w_mod.set_sample(samp);

            ref_samp1 = obj.w_fe.experiment_info.samples(1);
            samp(1).alatt = ref_samp1 .alatt;
            samp(1).angdeg = ref_samp1.angdeg;            
            assertEqual(w_mod(1).experiment_info.samples(3),samp(1));

            ref_samp2 = obj.w_rb.experiment_info.samples(1);            
            samp(2).alatt = ref_samp2.alatt;
            samp(2).angdeg = ref_samp2.angdeg;            
            assertEqual(w_mod(2).experiment_info.samples(10),samp(2));
        end
        
        function test_set_sample_array(obj)
            samp = IX_sample ([1,0,0],[0,1,0],'cuboid',[2,3,4]);
            samp = repmat(samp,1,120);
            samp2 = IX_sample ([0,1,0],[0,0,1],'cuboid',[12,13,34]);
            samp(100) = samp2;
            w_mod = obj.w_fe.set_sample(samp);

            ref_samp = obj.w_fe.experiment_info.samples(1);
            samp(3).alatt = ref_samp.alatt;
            samp(3).angdeg = ref_samp.angdeg;            
            assertEqual(w_mod.experiment_info.samples(3),samp(3));

            samp2.alatt = ref_samp.alatt;
            samp2.angdeg = ref_samp.angdeg;            
            assertEqual(w_mod.experiment_info.samples(100),samp2);
        end
        
        function test_set_sample(obj)
            samp = IX_sample ([1,0,0],[0,1,0],'cuboid',[2,3,4]);
            w_mod = obj.w_fe.set_sample(samp);

            ref_samp = obj.w_fe.experiment_info.samples(1);            
            samp.alatt = ref_samp.alatt;
            samp.angdeg = ref_samp.angdeg;            
            assertEqual(w_mod.experiment_info.samples(100),samp);

        end
        %--------------------------------------------------------------------------
        function test_set_instr_with_array_and_substitution_function(self)
            efix = 201:320;
            omega = (501:620)';
            w_fem = self.w_fe.set_efix(efix);
            wnew_fe = set_instrument(w_fem, @create_test_instrument,'-efix',omega,'s');
            hdr = wnew_fe.experiment_info;
            tis = create_test_instrument(203,503,'s');
            assertEqual(hdr.instruments{3}, tis);

            tis = create_test_instrument(300,600,'s');
            assertEqual(hdr.instruments{100}, tis);
        end

        function test_set_instr_with_func_param_array(self)

            efix = repmat(450,120,1);
            omega = repmat(500,120,1);
            efix(3) = 460;

            wnew_fe = set_instrument(self.w_fe, @create_test_instrument,efix,omega,'s');
            hdr = wnew_fe.experiment_info;
            tis = create_test_instrument(450,500,'s');
            assertEqual(hdr.instruments{100}, tis);

            tis = create_test_instrument(460,500,'s');
            assertEqual(hdr.instruments{3}, tis);
        end
        function test_set_instr_with_substitution_function(self)
            efix = 201:320;
            w_fem = self.w_fe.set_efix(efix);
            wnew_fe = set_instrument(w_fem, @create_test_instrument,'-efix',500,'s');
            hdr = wnew_fe.experiment_info;
            tis = create_test_instrument(203,500,'s');
            assertEqual(hdr.instruments{3}, tis);

            tis = create_test_instrument(300,500,'s');
            assertEqual(hdr.instruments{100}, tis);
        end

        function test_set_instr_with_single_function(self)
            wnew_fe = set_instrument(self.w_fe, @create_test_instrument,400,500,'s');
            hdr = wnew_fe.experiment_info;
            tis = create_test_instrument(400,500,'s');
            assertEqual(hdr.instruments{3}, tis);
        end

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

        function test_set_instrument_updates_all_headers_to_single_value(self)
            % Set all spe file to the same instrument
            wnew_fe = set_instrument(self.w_fe, self.inst_1);
            hdr = wnew_fe.experiment_info;
            assertEqual(hdr.instruments{3}, self.inst_1);
        end
        %--------------------------------------------------------------------------
        %--------------------------------------------------------------------------
        function test_set_efix_updates_data_to_single_value(self)
            % Set efix
            efix_new = 777;
            wnew_fe = set_efix(self.w_fe, efix_new);

            hdr = wnew_fe.experiment_info;
            efix = hdr.expdata(45).efix;
            assertEqual(efix, efix_new)

            [efix,emode,ok,mess,en] = get_efix(wnew_fe);
            assertEqual(efix, 777)
            assertEqual(emode,1);
            assertTrue(ok);
            assertEqual(mess,'')
            assertTrue(isstruct(en));
            assertEqual(en.relerr,0);

        end
        function test_set_efix_updates_array_data_with_array_values(self)
            % Set efix individually, and test enquiry routine
            efix_new = 777 * ones(1, 240);
            efix_new(100) = 777 + 120;  % so the average is 778

            ws = [self.w_fe,self.w_fe];
            wnew_fe = set_efix(ws, efix_new);

            [efix,emode,ok,mess,en] = get_efix(wnew_fe);
            assertEqual(efix, 777.5)
            assertEqual(emode,1);
            assertFalse(ok);
            assertEqual(mess,...
                'Spread of efix lies outside acceptable fraction of average of 0.005');
            assertTrue(isstruct(en));
            assertEqual(en.relerr,(777+120-efix)/efix);
        end

        function test_set_efix_updates_array_data_with_two_array_values(self)
            % Set efix individually, and test enquiry routine
            efix_new = [777,777+120] ;


            ws = [self.w_fe,self.w_fe];
            wnew_fe = set_efix(ws, efix_new);

            [efix,emode,ok,mess,en] = get_efix(wnew_fe);
            assertEqual(efix, 837)
            assertEqual(emode,1);
            assertFalse(ok);
            assertEqual(mess,...
                'Spread of efix lies outside acceptable fraction of average of 0.005');
            assertTrue(isstruct(en));
            assertEqual(en.relerr,(777 + 120-efix)/efix);
        end


        %--------------------------------------------------------------------------
        function test_set_efix_updates_all_data_with_array_values(self)
            % Set efix individually, and test enquiry routine
            efix_new = 777 * ones(1, 120);
            efix_new(100) = 777 + 120;  % so the average is 778

            wnew_fe = set_efix(self.w_fe, efix_new);

            [efix,emode,ok,mess,en] = get_efix(wnew_fe);
            assertEqual(efix, 778)
            assertEqual(emode,1);
            assertFalse(ok);
            assertEqual(mess,...
                'Spread of efix lies outside acceptable fraction of average of 0.005');
            assertTrue(isstruct(en));
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

            [pulse_model, pp,ok,mess,p,present] = get_mod_pulse(wnew_fe);

            assertEqual(pulse_model,'ikcarp')
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

            % data for two unique instruments. (will change if instruments
            % are stored in a service)
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
