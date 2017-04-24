function test_change_crystal_2
% Perform tests of change_crystal functions and methods.
%
%   >> test_change_crystal_2
% 
% It is assumed that test_change_crystal_1 has already been successfully performed.
% That test ensures that change_crystal_sqw on a file is correct; here we check that
% all the permutations of object types and files are handled correctly.
%
% Author: T.G.Perring

banner_to_screen(mfilename)

wref_file='wref.sqw';


% Create file names
% -----------------
tmpdir=tempdir;

w2_1_file=fullfile(tmpdir,'w2_1.sqw');
w2_2_file=fullfile(tmpdir,'w2_2.sqw');
w1_1_file=fullfile(tmpdir,'w1_1.sqw');
w1_2_file=fullfile(tmpdir,'w1_2.sqw');
d2_1_file=fullfile(tmpdir,'d2_1.d2d');
d2_2_file=fullfile(tmpdir,'d2_2.d2d');
d1_1_file=fullfile(tmpdir,'d1_1.d1d');
d1_2_file=fullfile(tmpdir,'d1_2.d1d');

w2c_1_file=fullfile(tmpdir,'w2c_1.sqw');
w2c_2_file=fullfile(tmpdir,'w2c_2.sqw');
w1c_1_file=fullfile(tmpdir,'w1c_1.sqw');
w1c_2_file=fullfile(tmpdir,'w1c_2.sqw');
d2c_1_file=fullfile(tmpdir,'d2c_1.d2d');
d2c_2_file=fullfile(tmpdir,'d2c_2.d2d');
d1c_1_file=fullfile(tmpdir,'d1c_1.d1d');
d1c_2_file=fullfile(tmpdir,'d1c_2.d1d');


% Create reference data objects and corresponding files
% -----------------------------------------------------
% First create initial sqw and dnd objects, and corresponding files
wref=read_sqw(wref_file);
w2_1=section(wref, [0,1], [150,200]);
w2_2=section(wref, [0,1], [200,250]);
w1_1=cut (wref,[0,0.05,1], [150,175]);
w1_2=cut (wref,[0,0.05,1], [175,200]);
w2_arr=[w2_1,w2_2];
w1_arr=[w1_1,w1_2];
w12_arr=[w1_arr;w2_arr];

d2_1=dnd(w2_1);
d2_2=dnd(w2_2);
d1_1=dnd(w1_1);
d1_2=dnd(w1_2);
d2_arr=[d2_1,d2_2];
d1_arr=[d1_1,d1_2];

save(w2_1,w2_1_file);
save(w2_2,w2_2_file);
save(w1_1,w1_1_file);
save(w1_2,w1_2_file);
save(d2_1,d2_1_file);
save(d2_2,d2_2_file);
save(d1_1,d1_1_file);
save(d1_2,d1_2_file);


% Change crystal in the sqw object files
% --------------------------------------
% We assume only that change_crystal_sqw(<filename>,rlu_corr) works, as tested in another routine
rlu_corr =[1.0817    0.0088   -0.2016;  0.0247    1.0913    0.1802;    0.1982   -0.1788    1.0555];

copyfile(w2_1_file,w2c_1_file); change_crystal_sqw(w2c_1_file,rlu_corr);
copyfile(w2_2_file,w2c_2_file); change_crystal_sqw(w2c_2_file,rlu_corr);
copyfile(w1_1_file,w1c_1_file); change_crystal_sqw(w1c_1_file,rlu_corr);
copyfile(w1_2_file,w1c_2_file); change_crystal_sqw(w1c_2_file,rlu_corr);

% Read back the altered sqw objects
w2c_1=read_sqw(w2c_1_file);
w2c_2=read_sqw(w2c_2_file);
w1c_1=read_sqw(w1c_1_file);
w1c_2=read_sqw(w1c_2_file);
w2c_arr=[w2c_1,w2c_2];
w1c_arr=[w1c_1,w1c_2];
w12c_arr=[w1c_arr;w2c_arr];

% Convert to dnd objects, and save as files
d2c_1=dnd(w2c_1);
d2c_2=dnd(w2c_2);
d1c_1=dnd(w1c_1);
d1c_2=dnd(w1c_2);
save(d2c_1,d2c_1_file);
save(d2c_2,d2c_2_file);
save(d1c_1,d1c_1_file);
save(d1c_2,d1c_2_file);
d2c_arr=[d2c_1,d2c_2];
d1c_arr=[d1c_1,d1c_2];

log_level = get(hor_config,'log_level');
% Perform tests
% -------------
if(log_level>-1); disp('Testing...'); end
change_crystal_test(rlu_corr, w2_1, '', true, w2c_1)
change_crystal_test(rlu_corr, w2_2, '', true, w2c_2)
change_crystal_test(rlu_corr, w1_1, '', true, w1c_1)
change_crystal_test(rlu_corr, w1_2, '', true, w1c_2)
change_crystal_test(rlu_corr, w2_arr, '', true, w2c_arr)
change_crystal_test(rlu_corr, w1_arr, '', true, w1c_arr)
change_crystal_test(rlu_corr, w12_arr, '', true, w12c_arr)

if(log_level>-1); disp('Testing...'); end
change_crystal_test(rlu_corr, d2_1, '', true, d2c_1)
change_crystal_test(rlu_corr, d2_2, '', true, d2c_2)
change_crystal_test(rlu_corr, d1_1, '', true, d1c_1)
change_crystal_test(rlu_corr, d1_2, '', true, d1c_2)
change_crystal_test(rlu_corr, d2_arr, '', true, d2c_arr)
change_crystal_test(rlu_corr, d1_arr, '', true, d1c_arr)

if(log_level>-1); disp('Testing...'); end
change_crystal_test(rlu_corr, w2_1_file, 'hor', true, w2c_1_file)
change_crystal_test(rlu_corr, w2_2_file, 'hor', true, w2c_2_file)
change_crystal_test(rlu_corr, w1_1_file, 'hor', true, w1c_1_file)
change_crystal_test(rlu_corr, w1_2_file, 'hor', true, w1c_2_file)
if(log_level>-1); disp('Testing...'); end
change_crystal_test(rlu_corr, w2_1_file, 'sqw', true, w2c_1_file)
change_crystal_test(rlu_corr, w2_2_file, 'sqw', true, w2c_2_file)
change_crystal_test(rlu_corr, w1_1_file, 'sqw', true, w1c_1_file)
change_crystal_test(rlu_corr, w1_2_file, 'sqw', true, w1c_2_file)
if(log_level>-1); disp('Testing...'); end
change_crystal_test(rlu_corr, w2_1_file, 'dnd', true, w2c_1_file)
change_crystal_test(rlu_corr, w2_2_file, 'dnd', true, w2c_2_file)
change_crystal_test(rlu_corr, w1_1_file, 'dnd', true, w1c_1_file)
change_crystal_test(rlu_corr, w1_2_file, 'dnd', true, w1c_2_file)

if(log_level>-1); disp('Testing...'); end
change_crystal_test(rlu_corr, d2_1_file, 'hor', true, d2c_1_file)
change_crystal_test(rlu_corr, d2_2_file, 'hor', true, d2c_2_file)
change_crystal_test(rlu_corr, d1_1_file, 'hor', true, d1c_1_file)
change_crystal_test(rlu_corr, d1_2_file, 'hor', true, d1c_2_file)
change_crystal_test(rlu_corr, d2_1_file, 'sqw', false, d2c_1_file)
change_crystal_test(rlu_corr, d2_2_file, 'sqw', false, d2c_2_file)
change_crystal_test(rlu_corr, d1_1_file, 'sqw', false, d1c_1_file)
change_crystal_test(rlu_corr, d1_2_file, 'sqw', false, d1c_2_file)
change_crystal_test(rlu_corr, d2_1_file, 'dnd', true, d2c_1_file)
change_crystal_test(rlu_corr, d2_2_file, 'dnd', true, d2c_2_file)
change_crystal_test(rlu_corr, d1_1_file, 'dnd', true, d1c_1_file)
change_crystal_test(rlu_corr, d1_2_file, 'dnd', true, d1c_2_file)


% Clean up all the files created in this test
% -------------------------------------------
if(log_level>-1)
	disp(' ')
	disp('Cleaning up temporary files...')
 end
filename={w2_1_file,w2_2_file,w1_1_file,w1_2_file,...
          d2_1_file,d2_2_file,d1_1_file,d1_2_file,...
          w2c_1_file,w2c_2_file,w1c_1_file,w1c_2_file,...
          d2c_1_file,d2c_2_file,d1c_1_file,d1c_2_file};
      
delete_error=false;
for i=1:numel(filename)
    if exist(filename{i},'file')
        try
            delete(filename{i})
        catch
            if delete_error==false
                delete_error=true;
                disp('One or more temporary files not deleted')
            end
        end
    end
end
disp('Done')


% Success announcement
% --------------------
banner_to_screen([mfilename,': Test(s) passed (matches are within requested tolerances)'],'bot')


%==================================================================================================
function change_crystal_test(rlu_corr, input, type, expect_ok, ref_ans)
% Test if get expected result (which may also be a failure)

tmpdir=tempdir;
fatal_error=false;

% Check if can convert data
try
    if ischar(input)
        tmpfile=fullfile(tmpdir,'test_change_crystal_2.tmp');
        copyfile(input,tmpfile);
        if strcmpi(type,'hor')
            change_crystal_horace(tmpfile,rlu_corr);
        elseif strcmpi(type,'sqw')
            change_crystal_sqw(tmpfile,rlu_corr);
        elseif strcmpi(type,'dnd')
            change_crystal_dnd(tmpfile,rlu_corr);
        else
            fatal_error=true;
            mess='Check inputs';
            error(mess)
        end
        wout=read_horace(tmpfile);
        ws = warning('off','MATLAB:DELETE:Permission');
        try
            delete(tmpfile)
        catch
            fatal_error=true;
            mess='Cannot delete temporary file';
            error(mess)
        end
        warning(ws);
    else
        if isempty(type)
            wout=change_crystal(input,rlu_corr);
        else
            fatal_error=true;
            mess='Check inputs';
            error(mess)
        end
    end
catch
    if ~fatal_error     % not an error from bad argument calls, or other errors not being tested for
        if ~expect_ok
            return  % expect failure, so OK
        else
            rethrow(lasterror)
        end
    else
        error(mess)
    end
end

% If converted data, then check the conversion is correct
if ischar(ref_ans), ref_ans=read_horace(ref_ans); end
[ok_out,mess]=test_result(true, wout, ref_ans);
if ~ok_out
    assertTrue(false,mess)
end

%==================================================================================================
function [ok_out,mess]=test_result(expect_ok, wout, ref_ans)
% Test if get expected result (which may also be a failure)
try
    [ok,mess]=equal_to_tol(wout, ref_ans,-2e-7,'nan_equal',true,'ignore_str',true);
    if ok && ~expect_ok
        ok_out=false; mess='Unexpected equality within tolerance'; return
    elseif ~ok && expect_ok
        ok_out=false; mess='Unexpected inequality outside tolerance'; return
    end
    ok_out=true; mess='';
catch
    error('Should not get to here')
end
