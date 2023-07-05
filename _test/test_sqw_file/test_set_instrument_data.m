classdef test_set_instrument_data< TestCase
    properties
        data_inst;
        data_inst_ref;
        clob;
        w1;
    end


    methods
        function obj = test_set_instrument_data(varargin)
            if nargin < 1
                name = 'test_set_instrument_data';
            else
                name = varargin{1};
            end
            obj=obj@TestCase(name);
            data_dir = fileparts(which(mfilename));
            obj.clob = set_temporary_warning('off','SQW_FILE:old_version');

            % Data file with 85 spe files, incident energies 100.1,100.2,...108.5 meV:
            % its the file containing old instrument and old sample.
            % only 29 files contribute to the cut, which is reflected in
            % the loaded files
            obj.data_inst_ref = fullfile(data_dir,'w1_inst_ref.sqw');
            obj.data_inst = fullfile(tmp_dir,'test_setup_inst_data_w1_inst.sqw');    % for copying to later

            % Read as an object too:
            obj.w1 = read_sqw(obj.data_inst_ref);

        end
        function setUp(obj)
            if is_file(obj.data_inst)
                delete(obj.data_inst);
            end
            save(obj.w1,obj.data_inst);
        end
        function tearDown(obj)
            if is_file(obj.data_inst)
                delete(obj.data_inst);
            end
        end
        function test_set_moderator_params_on_mix(obj)
            % Set moderator parameters - OK
            ei=300+(1:29);
            pulse_model = 'ikcarp';
            pp=[100./sqrt(ei(:)),zeros(29,2)];  % one row per moderator

            pp = [pp;pp];
            wtmp = set_mod_pulse({obj.w1,obj.data_inst},pulse_model,pp);

            [pulse_model_obj,ppmod,ok,mess,p,present]=get_mod_pulse(wtmp{1});
            assertFalse(ok)

            [pulse_model_file,ppmod_f,ok,mess_f,p_f,pres_f]=get_mod_pulse(obj.data_inst);

            assertFalse(ok)
            assertEqual(ppmod,ppmod_f)
            assertEqual(mess,mess_f)
            assertEqual(p,p_f)
            assertEqual(present,pres_f)
            assertEqual(pulse_model_obj,pulse_model_file);

            [pulse_model_c,pmod_c,ok,mess_c,p_c,present]=get_mod_pulse(wtmp);
            assertFalse(ok)
            assertEqual(pulse_model_obj,pulse_model_c)
            assertEqualToTol(ppmod,pmod_c,1.e-12);
            assertEqual(mess,mess_c)
            % reduce number of contributing runs by half to compare with
            % single dataset
            pp = p_c.pp;
            pp = pp(1:29,:);
            p_c.pp = pp;
            assertEqualToTol(p_f,p_c,1.e-12);

            assertTrue(present);

        end

        function test_set_moderator_params_with_ei(obj)
            % Set moderator parameters - OK
            ei=300+(1:29);
            pulse_model = 'ikcarp';
            pp=[100./sqrt(ei(:)),zeros(29,2)];  % one row per moderator

            wtmp = set_mod_pulse(obj.w1,pulse_model,pp);

            set_mod_pulse(obj.data_inst,pulse_model,pp);

            [pulse_model_obj,ppmod,ok,mess,p,present]=get_mod_pulse(wtmp);
            assertFalse(ok)

            [pulse_model_file,ppmod_f,ok,mess_f,p_f,pres_f]=get_mod_pulse(obj.data_inst);

            assertFalse(ok)
            assertEqual(ppmod,ppmod_f)
            assertEqual(mess,mess_f)
            assertEqual(p,p_f)
            assertEqual(present,pres_f)
            assertEqual(pulse_model_obj,pulse_model_file);
        end
        function test_get_moderator_params_file_vs_memory(obj)

            %% --------------------------------------------------------------------------------------------------
            % New moderator parameters
            % ---------------------------

            % Get moderator parameters - No errors with new insturment

            [pulse_model_obj,ppmod,ok,mess,p,present]=get_mod_pulse(obj.w1);
            assertTrue(ok)

            [pulse_model_file,ppmod_f,ok,mess_f,p_f,pres_f]=get_mod_pulse_horace(obj.data_inst);
            assertTrue(ok)

            assertEqual(ppmod,ppmod_f)
            assertEqual(mess,mess_f)
            pf_m = p_f;              % Only some runs and instrument contribute to
            pf_m.pp = pf_m.pp(1:29,:); % the pixels
            assertEqual(p,pf_m)
            assertEqual(present,pres_f)
            assertEqual(pulse_model_obj,pulse_model_file);
        end


        function test_head_data(obj)
            % Set up names of data files

            % check the conversion of the old sample and instrument stored in file
            hdr = obj.w1.experiment_info;
            sam = hdr.samples{1};
            assertTrue(isa(sam,'IX_sample'));
            assertEqual(sam.shape,'cuboid');
            inst = hdr.instruments{1};
            assertTrue(isa(inst,'IX_inst'));
            assertEqual(inst.name,'');
            %% --------------------------------------------------------------------------------------------------
            % assertThrowsNothing!
        end
        function test_set_ei_on_two(obj)
            % Set incident energies - OK
            ei=1000+(1:29);
            ei = [ei,ei];

            wtmp = set_efix({obj.w1,obj.data_inst},ei); % object

            ei_obj=get_efix(wtmp{1});
            ei_fl=get_efix(wtmp{2});
            ei_all=get_efix(wtmp);

            assertEqual(ei_obj,ei_fl);
            assertEqual(ei_all,ei_obj);
        end

        function test_get_ei(obj)

            %% --------------------------------------------------------------------------------------------------
            % New incident energies
            % ---------------------

            % Get incident energies - OK
            ei_obj=get_efix(obj.w1);
            ei=get_efix_horace(obj.data_inst);
            assertEqual(ei_obj,ei);
        end

        function test_set_ei(obj)
            % Set incident energies - OK
            ei=1000+(1:29);

            wtmp = set_efix(obj.w1,ei); % object
            set_efix(obj.data_inst,ei)  % file

            ei_obj=get_efix(wtmp);
            ei    =get_efix_horace(obj.data_inst);
            assertEqual(ei_obj,ei);
        end

    end
end
