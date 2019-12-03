function test_load_instrument_classes (varargin)
% Test that earlier versions of classes can be read in by the latest class
% definitions
%
%   >> test_instrument_class_load_save                  % perform tests for 'ver0'
%   >> test_instrument_class_load_save (ver)            % perform tests for named version
%   >> test_instrument_class_load_save (ver, '-save')   % save results with version name
%
% The version name is just a character string for cinstruction of file names,
% but by convention they should be chosen to be:
%   - ver0  Class definitions prior to July 2019 (old-style pre-R2008a matlab
%           classes
%   - ver1  First version of new-style classes (i.e. using classdef construction)
%
% E.G. for unversioned classes, first save from a Herbert version with the
% original class definitions as:
%
%   >> test_instrument_class_load_save ('ver0','-save')
%
% Then move to a version of Herbert with the new class definitions, and run
%   >> test_instrument_class_load_save ('ver0')


if numel(varargin)==2 && strcmpi(varargin{2},'-save')
    save_variables = true;
    ver_str = varargin{1};
elseif numel(varargin)==1
    save_variables = false;
    ver_str = varargin{1};
elseif numel(varargin)==0
    save_variables = false;
    ver_str = 'ver0';
else
    error('Check input arguments')
end


%--------------------------------------------------------------------------
% Fermi chopper
%---------------
% Scalar example
fermi = IX_fermi_chopper(12,600,0.049,1.3,0.0228);

% 2x2 array example
fermi_arr = [IX_fermi_chopper(12,610,0.049,1.3,0.0228),IX_fermi_chopper(12,620,0.049,1.3,0.0228);...
    IX_fermi_chopper(12,630,0.049,1.3,0.0228),IX_fermi_chopper(12,640,0.049,1.3,0.0228)];

% Test/save:
ok = matfile_IO (ver_str, save_variables, fermi, fermi_arr);
assertTrue(ok,'Problems saving/reading fermi chopper(s)')


%--------------------------------------------------------------------------
% Aperture
%---------------
% Scalar example
ap = IX_aperture ('Ap0', 11, 0.2, 0.25);

% 2x2 array example
ap_arr = [IX_aperture('Ap0', 11, 0.2, 0.25), IX_aperture('Ap1', 121, 0.22, 0.225);...
    IX_aperture('Ap3', 311, 0.23, 0.325), IX_aperture('Ap4', 114, 0.24, 0.245)];

% Test/save:
ok = matfile_IO (ver_str, save_variables, ap, ap_arr);
assertTrue(ok,'Problems saving/reading aperture(s)')


%--------------------------------------------------------------------------
% Divergence
%---------------
% Scalar example
ang = @(x0,n)(x0 + (1:n));
val = @(n)([0, ones(1,n-2) + 0.02*(1:n-2), 0]);  % version 0 requires end points to be zero
div = IX_divergence_profile (ang(5,20),val(20));

% 2x2 array example
div_arr = [IX_divergence_profile(ang(5,25),val(25)), IX_divergence_profile(ang(10,30),val(30));...
    IX_divergence_profile(ang(15,40),val(40)), IX_divergence_profile(ang(20,200),val(200))];

% Test/save:
ok = matfile_IO (ver_str, save_variables, div, div_arr);
assertTrue(ok,'Problems saving/reading divergence(s)')


%--------------------------------------------------------------------------
% Double disk chopper
%--------------------
% Scalar example
disk = IX_doubledisk_chopper(12,120,0.5,0.01);

% 2x2 array example
disk_arr = [IX_doubledisk_chopper(12,120,0.5,0.01,0.02), IX_doubledisk_chopper(12,120,0.5,0.01,0.04,3);...
    IX_doubledisk_chopper(15,120,0.5,0.01), IX_doubledisk_chopper(122,120,0.5,0.01,0.03)];

% Test/save:
ok = matfile_IO (ver_str, save_variables, disk, disk_arr);
assertTrue(ok,'Problems saving/reading disk chopper(s)')


%--------------------------------------------------------------------------
% Moderator
%--------------------
% Scalar example
moderator = IX_moderator(12,23,'ikcarp',[5,25,0.13]);

% 2x2 array example
moderator_arr = [IX_moderator(15,30,'ikcarp',[5,25,0.13]), IX_moderator(12,23,'ikcarp',[5,25,0.13]);...
    IX_moderator(115,300,'ikcarp',[15,25,0.13]), IX_moderator(125,10,'ikcarp',[5,25,0.13])];

% Test/save:
ok = matfile_IO (ver_str, save_variables, moderator, moderator_arr);
assertTrue(ok,'Problems saving/reading moderator(s)')


%--------------------------------------------------------------------------
% Sample
%--------------------
% Scalar example
sample = IX_sample('Fe',true,[1,1,0],[0,1,3],'cuboid',[0.020,0.024,0.028]);

% 1x2 array example
sample_arr = [IX_sample(false,[1,1,1],[0,1,1],'cuboid',[0.005,0.005,0.0005]),...
    IX_sample('FeSi',true,[1,1,0],[0,1,3],'cuboid',[0.020,0.024,0.028],0.5,120)];

% Test/save:
ok = matfile_IO (ver_str, save_variables, sample, sample_arr);
assertTrue(ok,'Problems saving/reading sample(s)')





%==========================================================================
function ok = matfile_IO (ver_str, save_variables, varargin)
% Save to or read from mat file

for i=1:numel(varargin)
    class_name = class(varargin{i});
    arg_name = inputname(i+2);
    flname = [ver_str,'_',class_name,'_',arg_name,'.mat'];
    if save_variables
        eval([arg_name,' = varargin{i};']);
        try
            save(fullfile(tmp_dir,flname),arg_name);
            ok = true;
        catch
            disp(['*** ERROR: Problem writing ',arg_name,' to ',flname])
            ok = false;
        end
    else
        tmp = load(fullfile('saved_class_versions_as_mat_files',flname),arg_name);
        if isequal(varargin{i},tmp.(arg_name))
            ok = true;
        else
            ok = false;
            disp(['*** ERROR: Argument ''',arg_name,''' read from ',flname,' does not match original'])
        end
    end
end
