function test_set_instrument_data_1
% Test setting of instrument parameters in header
% Created 13 December 2016 T.G.Perring

% Set up names of data files
data_dir = fileparts(which('test_set_instrument_data_1'));

% Data file with 85 spe files, incident energies 100.1,100.2,...108.5 meV:
data_noinst_ref = fullfile(data_dir,'w1_noinst_ref.sqw');
data_inst_ref = fullfile(data_dir,'w1_inst_ref.sqw');

% File names for copying to later on
data_noinst = fullfile(tempdir,'w1_noinst.sqw');
data_inst = fullfile(tempdir,'w1_inst.sqw');


%% --------------------------------------------------------------------------------------------------
% New incident energies
% ---------------------
wtmp=read_sqw(data_noinst_ref);

% Set the incident energies in the object 
ei=1000+(1:85);
wtmp_new = set_efix(wtmp,ei);

if ~isequal([wtmp.header{10}.efix,wtmp_new.header{10}.efix],[101,1010])
    error('Oh dear!')
end

% Set the incident energies in the file 
copyfile(data_noinst_ref,data_noinst,'f')

ei=500+(1:85);
set_efix_horace (data_noinst,ei)

wtmp_new1=read_sqw(data_noinst);
if ~isequal([wtmp.header{10}.efix,wtmp_new1.header{10}.efix],[101,510])
    error('Oh dear!')
end


%% --------------------------------------------------------------------------------------------------
% New moderator parameters
% ---------------------------

ei=300+(1:85);
pulse_model = 'ikcarp';
pp=[100./sqrt(ei(:)),zeros(85,2)];  % one row per moderator

% Set the moderator pulse model in the object
wtmp=read_sqw(data_inst_ref);
wtmp_new = set_mod_pulse(wtmp,pulse_model,pp);

if ~isequal(wtmp_new.header{10}.instrument.moderator.pp(1),100/sqrt(ei(10)))
    error('Oh dear!')
end

% Set the incident energies in the file - produces an error
copyfile(data_inst_ref,data_inst,'f')
set_mod_pulse_horace(data_inst,pulse_model,pp);

wtmp_new2 = read_sqw(data_inst);
if ~isequal(wtmp_new2.header{10}.instrument.moderator.pp(1),100/sqrt(ei(10)))
    error('Oh dear!')
end



%% --------------------------------------------------------------------------------------------------
% New instrument parameters
% ---------------------------

% Set the parameters in an object
wtmp = read_sqw(data_noinst_ref);
wtmp_new3 = set_instrument (wtmp, @maps_instrument_for_tests, '-efix', 300, 'S');
if ~isequal(wtmp_new3.header{10}.instrument.moderator.pp(1),70/sqrt(101))
    error('Oh dear!')
end

% Set parameters in a file - error:
copyfile(data_noinst_ref,data_noinst,'f')
set_instrument_horace (data_noinst, @maps_instrument_for_tests, '-efix', 300, 'S');

wtmp_new4=read_sqw(data_noinst);
if ~isequal(wtmp_new4.header{10}.instrument.moderator.pp(1),70/sqrt(101))
    error('Oh dear!')
end


