% script prepares and packs all flavours of recent Horace distributives 
% for further placement on Horace distribution server.
%
% Update herbert code version:
update_svn_revision_info('herbert') 
% Update horace code version:
update_svn_revision_info('horace') 

% create Horace distribution
make_horace_distribution_kit
% create Horace distribution without demo and tests
make_horace_distribution_kit -compact
movefile('Horace_nodemo.zip','Horace&Herbert_NoDemoNoTests.zip','f')
% create Herbert distribution only
make_herbert_distribution_kit
movefile('herbert_distribution_kit.zip','Herbert_NoHorace_distribution_kit.zip','f')
% create Horace distribution only without demo and tests
make_horace_distribution_kit -compact -noherbert
movefile('Horace_only_nodemo.zip','Horace_NoHerbert_NoDemo.zip','f')
% create Horace without Herbert
make_horace_distribution_kit -noherbert
movefile('horace_only_distribution_kit.zip','Horace_NoHerbert_distribution_kit.zip','f')

disp('--------------------------------------------------------------------')
disp('------- COPY HORACE KITS TO TARGET DESTINATIONS MANUALY ------------')
disp('--------------------------------------------------------------------')
