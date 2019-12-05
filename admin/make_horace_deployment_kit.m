function make_horace_deployment_kit(varargin)
% script prepares and packs all flavors of recent Horace distributive
% for further placement on Horace distribution server.
%
%
opt = {'-update_version'};
[ok,mess,update_version] = parse_char_options(varargin,opt);
if ~ok
    error('MAKE_HORACE_DEPLOYMENT_KIT:invalid_argument',mess);
end
if update_version
    % Update Herbert code version:
    update_svn_revision_info('herbert')
    % Update Horace code version:
    update_svn_revision_info('horace')
end
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
