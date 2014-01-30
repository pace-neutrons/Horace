function test_sqw_file_read_write
% Perform a number of tests of put_sqw, get_sqw with and without sample and instrument information

% Read sqw objects from a mat file: (none have sample or instrument information)
%   two different files, each with one contributing spe file:  f1_1  f2_1
%   two different files, each with two contributing spe files:  f1_2  f2_2
%   two different files, each with three contributing spe files:  f1_3  f2_3
%
% These objects were read from an sqw file during the creation process, so we should not
% have any subsequent problems with writing to and reading from disk.

load('testdata_base_objects.mat')

% Create three different samples
sam1=IX_sample(true,[1,1,0],[0,0,1],'cuboid',[0.04,0.03,0.02]);
sam2=IX_sample(true,[1,1,1],[0,2,1],'cylinder_long_name',rand(1,5));
sam3=IX_sample(true,[1,1,0],[0,0,1],'hypercube_really_long_name',rand(1,6));

% Create three different instruments
inst1=create_test_instrument(95,250,'s');
inst2=create_test_instrument(56,300,'s');
inst2.flipper=true;
inst3=create_test_instrument(195,600,'a');
inst3.filter=[3,4,5];



tmpsqwfile=fullfile(tempdir,'test_sqw_file_read_write_tmp.sqw');

% Write out to sqw files, read back in, and test they are the same
% ----------------------------------------------------------------
save(f1_1,tmpsqwfile); tmp=read(sqw,tmpsqwfile);
[ok,mess]=equal_to_tol(f1_1,tmp,'ignore_str',1); if ~ok, assertTrue(false,mess), end

save(f1_3,tmpsqwfile); tmp=read(sqw,tmpsqwfile);
[ok,mess]=equal_to_tol(f1_3,tmp,'ignore_str',1); if ~ok, assertTrue(false,mess), end


% Reference sqw objects with different samples
% --------------------------------------------
f1_1_s1_ref=set_header_fudge(f1_1,'sample',sam1);
f1_1_s2_ref=set_header_fudge(f1_1,'sample',sam2);
f1_1_s3_ref=set_header_fudge(f1_1,'sample',sam3);


%==================================================================================================
% Systematic test of '-v3' format and writing - test rather complex append/overwrite algorithms
%==================================================================================================

% Add a sample, write out and read back in
% ----------------------------------------
% Set sample
f1_1_s1=set_sample(f1_1,sam1);
[ok,mess]=equal_to_tol(f1_1_s1_ref,f1_1_s1,'ignore_str',1);
if ~ok, assertTrue(false,mess), end

% Write and read back in
try
    save(f1_1_s1,tmpsqwfile); tmp=read(sqw,tmpsqwfile);
catch
    assertTrue(false,'Error reading/writing sqw object')
end
[ok,mess]=equal_to_tol(f1_1_s1,tmp,'ignore_str',1); if ~ok, assertTrue(false,mess), end

% Remove the sample again, and confirm the same as original object after writing and reading
% ------------------------------------------------------------------------------------------
% Set sample
f1_1_s0=set_sample(f1_1_s1,[]);
[ok,mess]=equal_to_tol(f1_1,f1_1_s0,'ignore_str',1);
if ~ok, assertTrue(false,mess), end

% Write and read back in
try
    save(f1_1_s0,tmpsqwfile); tmp=read(sqw,tmpsqwfile);
catch
    assertTrue(false,'Error reading/writing sqw object')
end
[ok,mess]=equal_to_tol(f1_1_s0,tmp,'ignore_str',1); if ~ok, assertTrue(false,mess), end

% Now change the sample in a file
% -------------------------------
% Add sam1 to file with f1_1
save(f1_1,tmpsqwfile)
set_sample_horace(tmpsqwfile,sam1);
tmp=read_sqw(tmpsqwfile);
[ok,mess]=equal_to_tol(f1_1_s1_ref,tmp,'ignore_str',1); if ~ok, assertTrue(false,mess), end

% Now add a longer sample - this should be appended to the end
set_sample_horace(tmpsqwfile,sam2);
tmp=read_sqw(tmpsqwfile);
[ok,mess]=equal_to_tol(f1_1_s2_ref,tmp,'ignore_str',1); if ~ok, assertTrue(false,mess), end

% Now add a longer sample still - but shorter than the sum of sam1 and sam2: should overwrite
set_sample_horace(tmpsqwfile,sam3);
tmp=read_sqw(tmpsqwfile);
[ok,mess]=equal_to_tol(f1_1_s3_ref,tmp,'ignore_str',1); if ~ok, assertTrue(false,mess), end

% Dummy sample
set_sample_horace(tmpsqwfile,[]);
tmp=read_sqw(tmpsqwfile);
[ok,mess]=equal_to_tol(f1_1,tmp,'ignore_str',1); if ~ok, assertTrue(false,mess), end


%==================================================================================================
% Test syntax and file i/o of set_instrument and set_sample
%==================================================================================================

% Add sample to a single spe file sqw object
f1_1_s1=change_header_test(f1_1,'-none',sam1);

% Add sample to a multiple spe file sqw object
f1_2_s1=change_header_test(f1_2,'-none',sam1);

% Add instrument to a single spe file sqw object
f1_1_i1=change_header_test(f1_1,inst1,'-none');

% Add instrument to a multiple spe file sqw object
f1_2_i1=change_header_test(f1_2,inst1,'-none');

% And instrument and sample to a ingle spe file sqw object
f1_1_i1s1=change_header_test(f1_2,inst1,sam1);

% And instrument and sample to a multiple spe file sqw object
f1_2_i1s1=change_header_test(f1_2,inst1,sam1);

% Do some fancy stuff: overwrite instrument and sample
f1_2_i0s2=change_header_test(f1_2_i1s1,struct,sam2);

% Do some fancy stuff: remove instrument and sample
f1_2_i0s0=change_header_test(f1_2_i1s1,struct,struct);
















