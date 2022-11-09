function test_load_instrument_classes (varargin)
% Test that earlier versions of classes can be read in by the latest class
% definitions
%
%   >> test_instrument_class_load_save                  % perform tests for 'ver0'
%   >> test_instrument_class_load_save (ver)            % perform tests for named version
%   >> test_instrument_class_load_save (ver, '-save')   % save results with version name
%
% The version name is just a character string for construction of file names,
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
