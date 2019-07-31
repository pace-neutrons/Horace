classdef test_instrument_methods <  TestCase %WithSave
    %Testing various methods to change instrument/sample in a file
    %
    
    
    properties
        test_folder
        sample_file
        test_file_
        
    end
    
    methods
        function obj = test_instrument_methods(varargin)
            if nargin > 0
                name = varargin{1};
            else
                name= mfilename('class');
            end
            %obj = obj@TestCaseWithSave(name,sample_file);
            obj = obj@TestCase(name);
            obj.test_folder=fileparts(mfilename('fullpath'));
            obj.sample_file  = 'w2_small_v1.sqw';
        end
        %
        function obj=setUp(obj)
            tmp_dir = tempdir;
            obj.test_file_ = fullfile(tmp_dir,obj.sample_file);
            copyfile(fullfile(obj.test_folder,obj.sample_file),obj.test_file_,'f')
        end
        function tearDown(obj)
            if ~isempty(obj.test_file_) && exist(obj.test_file_,'file')==2
                delete(obj.test_file_);
            end
        end
        %
        function test_set_ei(obj)
            ei=1000+(1:186);
            
            % Set the incident energies in the object - no problem
            wtmp=read_sqw(obj.test_file_);
            wtmp_new = set_efix(wtmp,ei);
            assertEqual([wtmp.header{10}.efix,wtmp_new.header{10}.efix],[787,1010])
            
            % old format file implicitly converted into new format
            set_efix_horace (obj.test_file_,ei)
            
            ldr = sqw_formats_factory.instance().get_loader(obj.test_file_);
            header = ldr.get_header(10);
            ldr.delete(); % clear existing loader not to hold test file in case of further modifications
            
            assertEqual([header.efix,wtmp_new.header{10}.efix],[1010,1010])
            
            % file is in the new format, see how update goes in this case
            ei=100+(1:186);
            set_efix_horace (obj.test_file_,ei)
            
            % ASSIGNMENT IN MATLAB 2015b is broken. if I assign to the previous
            % (deleted) loader ldr, the file will close!!!
            ldr1 = sqw_formats_factory.instance().get_loader(obj.test_file_);
            header = ldr1.get_header(10);
            ldr1.delete(); % clear existing loader not to hold test file in case of further modifications
            
            assertEqual([header.efix,wtmp_new.header{10}.efix],[110,1010])
        end
        %
        function test_set_instrument(obj)
            ei=100+(1:186);
            set_efix_horace (obj.test_file_,ei)
            
            % Set the incident energies in the object - no problem
            wref=read_sqw(obj.test_file_);
            
            %---------------------------------------------------------------------
            wtmp=set_instrument(wref,@create_test_instrument,400,500,'s');
            set_instrument_horace(obj.test_file_,@create_test_instrument,400,500,'s');
            
            ldr = sqw_formats_factory.instance().get_loader(obj.test_file_);
            inst = ldr.get_instrument();
            ldr.delete(); % clear existing loader not to hold test file in case of further modifications
            
            assertEqual(wtmp.header{1}.instrument,inst);
            
            %---------------------------------------------------------------------
            wtmp=set_instrument(wref,@create_test_instrument,'-efix',500,'s');
            set_instrument_horace(obj.test_file_,@create_test_instrument,'-efix',500,'s');
            
            ldr1 = sqw_formats_factory.instance().get_loader(obj.test_file_);
            inst = ldr1.get_instrument(10);
            assertEqual(wtmp.header{10}.instrument,inst);
            
            inst = ldr1.get_instrument('-all');
            ldr1.delete(); % clear existing loader not to hold test file in case of further modifications
            
            assertEqual(numel(inst),186) % all instruments for this file are the same
            assertEqual(wtmp.header{186}.instrument,inst(186));
            
            %---------------------------------------------------------------------
            % NOT IMPLEMENTED or implemented wrongly. Does not accept array
            % of parameters
            %             omg  = 400 + (1:186);
            %             %
            %             wtmp=set_instrument(wref,@create_test_instrument,'-efix',omg ,'s');
            %             set_instrument_horace(obj.test_file_,@create_test_instrument,'-efix',omg,'s');
            %
            %             inst = ldr1.get_instrument('-all');
            %             assertEqual(numel(inst),186) % all instruments for this file are the same
            %             assertEqual(wtmp.header{186}.instrument,inst(186));
            %             assertEqual(wtmp.header{1}.instrument,inst(1));
            %             assertEqual(wtmp.header{10}.instrument,inst(10));
            
        end
        %
        function test_update_instrument_set_pulse(obj)
            %TODO decide on and return instrument either as array or
            %cellarray
            ei=1000+(1:186);
            pulse_model = 'ikcarp';
            pp=[100./sqrt(ei(:)),zeros(186,2)];  % one row per moderator
            
            % file contains empty instrument and sample.
            wtmp=read_sqw(obj.test_file_);
            f = @()set_mod_pulse(wtmp,pulse_model,pp);
            assertExceptionThrown(f,'SQW:invalid_instrument');
            % set up proper instrument:
            inst = maps_instrument(100,400,'S');
            wtmp= set_instrument(wtmp,inst);
            
            wtmp_new = set_mod_pulse(wtmp,pulse_model,pp);
            
            assertEqual(wtmp_new.header{10}.instrument.moderator.pp(1),100/sqrt(ei(10)))
            
            % Set the incident energies in the file - produces an error as
            % the instrument is empty
            f = @()set_mod_pulse_horace(obj.test_file_,pulse_model,pp);
            assertExceptionThrown(f,'SQW:invalid_instrument');
            n_files = wtmp.main_header.nfiles;
            inst_arr = repmat(inst,n_files,1);
            % set up multiple instrument on file
            set_instrument_horace(obj.test_file_,inst_arr);
            % as we have proper instrument, setting moderator pulse should work
            set_mod_pulse_horace(obj.test_file_,pulse_model,pp);            

            ldr1 = sqw_formats_factory.instance().get_loader(obj.test_file_);
            
            inst = ldr1.get_instrument('-all');
            ldr1.delete(); % clear existing loader not to hold test file in case of further modifications
            
            assertEqual(numel(inst),186) % all instruments for this file are the same
            assertEqual(wtmp_new.header{186}.instrument,inst(186));
            assertEqual(wtmp_new.header{10}.instrument,inst(10));
            assertEqual(wtmp_new.header{1}.instrument,inst(1));
            
            
        end
        
    end
    
end

