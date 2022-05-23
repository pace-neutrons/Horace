classdef test_set_instrument_data_get_head< TestCase
    properties
        data_inst;
        data_inst_ref;
        clenup1
        clenup2
        w1;
    end


    methods
        function obj = test_set_instrument_data_get_head(varargin)
            if nargin < 1
                name = 'test_set_instrument_data_get_head';
            else
                name = varargin{1};
            end
            obj=obj@TestCase(name);
            data_dir = fileparts(which(mfilename));
            wars = warning('off','SQW_FILE:old_version');
            obj.clenup1= onCleanup(@()(warning(wars)));

            % Data file with 85 spe files, incident energies 100.1,100.2,...108.5 meV:
            % its the file containing old instrument and old sample.
            % only 29 files contribute to the cut, which is reflected in
            % the loaded files
            obj.data_inst_ref = fullfile(data_dir,'w1_inst_ref.sqw');
            obj.data_inst = fullfile(tmp_dir,'test_setup_inst_data_w1_inst.sqw');    % for copying to later

            das = obj.data_inst;
            obj.clenup2= onCleanup(@()delete(das));

            % Read as an object too:
            obj.w1 = read_sqw(obj.data_inst_ref);
            if is_file(obj.data_inst)
                delete(obj.data_inst);
            end
            save(obj.w1,obj.data_inst);            

        end
        function test_moderator_params(obj)

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



            % Set moderator parameters - OK
            ei=300+(1:29);
            pulse_model = 'ikcarp';
            pp=[100./sqrt(ei(:)),zeros(29,2)];  % one row per moderator


            wtmp = set_mod_pulse(obj.w1,pulse_model,pp);
            if is_file(obj.data_inst)
                delete(obj.data_inst);
            end
            save(obj.w1,obj.data_inst);


            set_mod_pulse_horace(obj.data_inst,pulse_model,pp);

            [pulse_model_obj,ppmod,ok,mess,p,present]=get_mod_pulse(wtmp);
            assertFalse(ok)

            [pulse_model_file,ppmod_f,ok,mess_f,p_f,pres_f]=get_mod_pulse_horace(obj.data_inst);

            assertFalse(ok)
            assertEqual(ppmod,ppmod_f)
            assertEqual(mess,mess_f)
            assertEqual(p,p_f)
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
            assertEqual(inst.name,'_');
            %% --------------------------------------------------------------------------------------------------
            % Header:
            % ---------
            % First on object:

            % Head without return argument works
            %HACK: should be ivoked without lhs to check disp option
            hh=head(obj.w1);
            hh=head(obj.w1,'-full');
            % assertThrowsNothing!

            h_obj_s=head(obj.w1);
            h_obj=head(obj.w1,'-full');
            assertEqual(h_obj.data,h_obj_s)

        end
        function test_head(obj)
            % Now do the same on file: this time no errors:
            copyfile(obj.data_inst_ref,obj.data_inst,'f')

            %HACK: should be ivoked without lhs to check disp option
            hh=head_horace(obj.data_inst_ref);
            hh=head_horace(obj.data_inst_ref,'-full');

            %TODO: look at this carefully. The stuctures, extracted by different means
            % are a bit different. Do we want this?
            h_file_s=head_horace(obj.data_inst_ref);
            h_file_s = rmfield(h_file_s,{'npixels','nfiles','pix_range'});

            h_file=head_horace(obj.data_inst_ref,'-full');
            data = h_file.data.get_dnd_data('+');
            assertEqual(data,h_file_s)
        end
        function test_get_ei_set_ei(obj)

            %% --------------------------------------------------------------------------------------------------
            % New incident energies
            % ---------------------

            % Get incident energies - OK
            ei_obj=get_efix(obj.w1);

            if is_file(obj.data_inst)
                delete(obj.data_inst);
            end
            save(obj.w1,obj.data_inst);

            ei=get_efix_horace(obj.data_inst);
            assertEqual(ei_obj,ei);



            % Set incident energies - OK
            ei=1000+(1:29);

            wtmp = set_efix(obj.w1,ei);     % object
            set_efix_horace(obj.data_inst,ei)  % file

            ei_obj=get_efix(wtmp);
            ei    =get_efix_horace(obj.data_inst);
            assertEqual(ei_obj,ei);

        end

    end
end
