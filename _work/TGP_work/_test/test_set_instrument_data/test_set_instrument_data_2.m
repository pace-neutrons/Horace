% Set up names of data files
data_dir = pwd;

% Data file with 85 spe files, incident energies 100.1,100.2,...108.5 meV:
data_inst_ref = fullfile(data_dir,'w1_inst_ref.sqw');
data_inst = fullfile(tmp_dir,'w1_inst.sqw');    % for copying to later

% Read as an object too:
w1 = read_sqw(data_inst_ref);



%% --------------------------------------------------------------------------------------------------
% Header:
% ---------
% First on object:

% Head without return argument works
head(w1)

head(w1,'-full')

% *** ERROR *** if have a return argument *********************************
h_obj=head(w1)

% *** ERROR *** if have a return argument *********************************
h_obj=head(w1,'-full')



% Now do the same on file: this time no errors:
copyfile(data_inst_ref,data_inst,'f')

head_horace(data_inst_ref)

head_horace(data_inst_ref,'-full')

h_file=head_horace(data_inst_ref)

h_file=head_horace(data_inst_ref,'-full')



%% --------------------------------------------------------------------------------------------------
% New incident energies
% ---------------------

% Get incident energies - OK
ei=get_efix(w1)

copyfile(data_inst_ref,data_inst,'f')
ei=get_efix_horace(data_inst)



% Set incident energies - OK
ei=1000+(1:85);

wtmp = set_efix(w1,ei);     % object

copyfile(data_inst_ref,data_inst,'f')
set_efix_horace(data_inst,ei)  % file




%% --------------------------------------------------------------------------------------------------
% New moderator parameters
% ---------------------------

% Get moderator parameters - errors

% *** ERROR *******************************************************************
[pulse_model,ppmod,ok]=get_mod_pulse(w1);

% *** ERROR *******************************************************************
[pulse_model,ppmod,ok]=get_mod_pulse_horace(data_inst);



% Set moderator parameters - OK
ei=300+(1:85);
pulse_model = 'ikcarp';
pp=[100./sqrt(ei(:)),zeros(85,2)];  % one row per moderator


wtmp = set_mod_pulse(w1,pulse_model,pp);


copyfile(data_inst_ref,data_inst,'f')
set_mod_pulse_horace(data_inst,pulse_model,pp);

