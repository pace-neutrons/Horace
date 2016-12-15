% Set up names of data files
data_dir = pwd;


% Data file with 85 spe files, incident energies 100.1,100.2,...108.5 meV:
data_inst_ref = fullfile(data_dir,'w1_inst_ref.sqw');
data_inst = fullfile(tempdir,'test_setup_inst_data_w1_inst.sqw');    % for copying to later
if exist(data_inst,'file')==2
    clear clob;
end
clob = onCleanup(@()delete(data_inst));

% Read as an object too:
w1 = read_sqw(data_inst_ref);



%% --------------------------------------------------------------------------------------------------
% Header:
% ---------
% First on object:

% Head without return argument works
head(w1); 
head(w1,'-full');
% assertThrowsNothing!

h_obj_s=head(w1);
h_obj=head(w1,'-full');
assertEqual(h_obj.data,h_obj_s)


% Now do the same on file: this time no errors:
copyfile(data_inst_ref,data_inst,'f')

head_horace(data_inst_ref);
head_horace(data_inst_ref,'-full');

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

% Get moderator parameters - errors

[pulse_model_obj,ppmod,ok,mess,p,present]=get_mod_pulse(w1);
assertFalse(ok)

[pulse_model_file,ppmod_f,ok,mess_f,p_f,pres_f]=get_mod_pulse_horace(data_inst);
assertFalse(ok)

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