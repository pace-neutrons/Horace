function moderator_save_to_mat_all
% Save all the baseline moderator simulations as mat files
% This function is design for developer use only. The .mat files it creates
% in the Matlab temporary area should be copied to the public ISIS_moderator
% data store.

% Data are the baseline models before the TS-1 upgrade

% Target Station 1:
% -----------------
name_TS1 = {...
    'North01_Sandals' ...
    'North02_Prisma' ...
    'North03_Surf' ...
    'North04_Crisp' ...
    'North05_Loq' ...
    'North06_Iris' ...
    'North07_Polaris' ...
    'North08_Tosca' ...
    'North09_Het' ...
    'South01_Maps' ...
    'South01_Maps_2foilsInWatMod' ...
    'South02_Vesuvio' ...
    'South03_Sxd' ...
    'South04_Merlin' ...
    'South06_Mari' ...
    'South07_Gem' ...
    'South08_Hrpd' ...
    'South09_Pearl' ...
    };

file_stub_TS1 = '.\ISIS_TS1_mcstas\TS1verBase2016_LH8020_newVM-var_';

for i=1:numel(name_TS1)
    moderator_save_to_mat([file_stub_TS1,name_TS1{i},'.mcstas']);
end


% Target Station 2
% ----------------
name_TS2 = {...
    'Larmor_Base' ...
    'Let_Base' ...
    'NimrodFull_Base' ...
    'NimrodRed_Base' ...
    };

file_stub_TS2 = '.\ISIS_TS2_mcstas\';

for i=1:numel(name_TS2)
    moderator_save_to_mat([file_stub_TS2,name_TS2{i},'.mcstas']);
end
