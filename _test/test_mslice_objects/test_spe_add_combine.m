function test_spe_add_combine
% Test reading and saving of mslice classes
%
%   >> test_spe_add_combine
%
% Author: T.G.Perring

banner_to_screen(mfilename)

% Unpack test objects to test area
% --------------------------------
flnames=unpack_data_files;
ref_dir=tempdir;

% Test combining spe files
% -------------------------
add(spe,[1,2],ref_dir,{'s1.spe','s2.spe'},'s_add_tmp.spe');
s_add=read_spe(fullfile(ref_dir,'s_add.spe'));
s_add_tmp=read_spe(fullfile(ref_dir,'s_add_tmp.spe'));
if ~equivalent_mslice_objects(s_add,s_add_tmp), assertTrue(false,'s_add,s_add_tmp not equivalent'), end

% 23 July 2013: If mslice is on the path, this calls mslice own version of add_spe, not Herbert mslice_classes version
% add_spe([1,2],ref_dir,{'s1.spe','s2.spe'},'s_add_tmp_mslice.spe');

combine(spe,[1/3,2/3],ref_dir,{'s1.spe','s2.spe'},'s_com_tmp.spe');
s_com=read_spe(fullfile(ref_dir,'s_com.spe'));
s_com_tmp=read_spe(fullfile(ref_dir,'s_com_tmp.spe'));
if ~equivalent_mslice_objects(s_com,s_com_tmp), assertTrue(false,'s_com,s_com_tmp not equivalent'), end


% Success announcement
% --------------------
% Delete data files
delete_ok=true;
for i=1:numel(flnames)
    try
        delete(flnames{i});
    catch
        if delete_ok==true
            disp('Unable to delete one or more temporary files')
            delete_ok=false;
        end
    end
end
% Delete files created by this function
try
    delete(fullfile(tempdir,'s_add_tmp.spe'));
    delete(fullfile(tempdir,'s_com_tmp.spe'));
catch
    disp('Unable to delete temporary file(s)')
end
banner_to_screen([mfilename,': Test(s) passed'],'bot')
