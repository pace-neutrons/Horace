function test_set_instrument_data_2()

% Set up names of data files
data_dir = fileparts(which(mfilename));
wars = warning('off','SQW_FILE:old_version');
clob0 = onCleanup(@()(warning(wars)));

% Data file with 85 spe files, incident energies 100.1,100.2,...108.5 meV:
% its the file containing old instrument and old sample
data_inst_ref = fullfile(data_dir,'w1_inst_ref.sqw');
data_inst = fullfile(tempdir,'test_setup_inst_data_w1_inst.sqw');    % for copying to later

clob = onCleanup(@()delete(data_inst));

% Read as an object too:
w1 = read_sqw(data_inst_ref);

% check the conversion of the old sample and instrument stored in file
sam = w1.header{1}.sample;
assertTrue(isa(sam,'IX_sample'));
assertEqual(sam.shape,'cuboid');
inst = w1.header{1}.instrument;
assertTrue(isa(inst,'IX_inst'));
assertEqual(inst.name,'MAPS');
%% --------------------------------------------------------------------------------------------------
% Header:
% ---------
% First on object:

% Head without return argument works
%HACK: should be ivoked without lhs to check disp option
hh=head(w1); 
hh=head(w1,'-full');
% assertThrowsNothing!

h_obj_s=head(w1);
h_obj=head(w1,'-full');
assertEqual(h_obj.data,h_obj_s)


% Now do the same on file: this time no errors:
copyfile(data_inst_ref,data_inst,'f')

%HACK: should be ivoked without lhs to check disp option
hh=head_horace(data_inst_ref);
hh=head_horace(data_inst_ref,'-full');

%TODO: look at this carefully. The stuctures, extracted by different means 
% are a bit different. Do we want this?
h_file_s=head_horace(data_inst_ref);
h_file_s = rmfield(h_file_s,{'npixels','nfiles'});

h_file=head_horace(data_inst_ref,'-full');
data = h_file.data.to_struct();
data = rmfield(data,{'pix','axis_caption'});
assertEqual(data,h_file_s)



%% --------------------------------------------------------------------------------------------------
% New incident energies
% ---------------------

% Get incident energies - OK
ei_obj=get_efix(w1);

copyfile(data_inst_ref,data_inst,'f')


ei=get_efix_horace(data_inst);
assertEqual(ei_obj,ei);



% Set incident energies - OK
ei=1000+(1:85);

wtmp = set_efix(w1,ei);     % object

copyfile(data_inst_ref,data_inst,'f')
set_efix_horace(data_inst,ei)  % file




%% --------------------------------------------------------------------------------------------------
% New moderator parameters
% ---------------------------

% Get moderator parameters - No errors with new insturment

[pulse_model_obj,ppmod,ok,mess,p,present]=get_mod_pulse(w1);
assertTrue(ok)

[pulse_model_file,ppmod_f,ok,mess_f,p_f,pres_f]=get_mod_pulse_horace(data_inst);
assertTrue(ok)

assertEqual(ppmod,ppmod_f)
assertEqual(mess,mess_f)
assertEqual(p,p_f)
assertEqual(present,pres_f)
assertEqual(pulse_model_obj,pulse_model_file);



% Set moderator parameters - OK
ei=300+(1:85);
pulse_model = 'ikcarp';
pp=[100./sqrt(ei(:)),zeros(85,2)];  % one row per moderator


wtmp = set_mod_pulse(w1,pulse_model,pp);


copyfile(data_inst_ref,data_inst,'f')
set_mod_pulse_horace(data_inst,pulse_model,pp);

clear clob;
