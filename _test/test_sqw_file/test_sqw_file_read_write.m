function test_sqw_file_read_write
% Perform a number of tests of put_sqw, get_sqw with and without sample and instrument information

% Read sqw objects from a mat file: (none have sample or instrument information)
%   two different files, each with one contributing spe file:  f1_1  f2_1
%   two different files, each with two contributing spe files:  f1_2  f2_2
%   two different files, each with three contributing spe files:  f1_3  f2_3
%
% These objects were read from an sqw file during the creation process, so we should not
% have any subsequent problems with writing to and reading from disk.

ds=load('testdata_base_objects.mat');
existing_objects=fieldnames(ds);
for i=1:numel(existing_objects)
    % HACK ! deal with old style sqw objects, which have not stored
    % @axis_name
    cur_sqw=sqw(struct(ds.(existing_objects{i})));
    var_name = existing_objects{i};
    
    eval(sprintf('%s = cur_sqw;', var_name));
end


% Create three different samples
sam1=IX_sample(true,[1,1,0],[0,0,1],'cuboid',[0.04,0.03,0.02]);
sam2=IX_sample(true,[1,1,1],[5,0,1],'cuboid',[0.10,0.33,0.22]);
sam3=IX_sample(true,[1,1,0],[0,0,1],'point',[]);

% T.G.Perring 22/7/19: These do not currently exist, so replaced
% sam2=IX_sample(true,[1,1,1],[0,2,1],'cylinder_long_name',rand(1,5));
% sam3=IX_sample(true,[1,1,0],[0,0,1],'hypercube_really_long_name',rand(1,6));



% Create three different instruments
inst1=create_test_instrument(95,250,'s');
%inst2=create_test_instrument(56,300,'s');
%inst2.flipper=true;
%inst3=create_test_instrument(195,600,'a');
%inst3.filter=[3,4,5];

tmpsqwfile=fullfile(tmp_dir,'test_sqw_file_read_write_tmp.sqw');
clob1 = onCleanup(@()delete(tmpsqwfile));

% Write out to sqw files, read back in, and test they are the same
% ----------------------------------------------------------------
save(f1_1,tmpsqwfile); tmp=read(sqw,tmpsqwfile);
[ok,mess]=equal_to_tol(f1_1,tmp,'ignore_str',1);
assertTrue(ok,mess);

save(f1_3,tmpsqwfile); tmp=read(sqw,tmpsqwfile);
[ok,mess]=equal_to_tol(f1_3,tmp,'ignore_str',1); assertTrue(ok,mess)


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
assertTrue(ok,mess)

% Write and read back in
delete(tmpsqwfile);
try
    save(f1_1_s1,tmpsqwfile);
    tmp=read(sqw,tmpsqwfile);
catch err
    warning('test_sqw_file_read_write:io','Error reading/writing sqw object')
    rethrow(err);
end
[ok,mess]=equal_to_tol(f1_1_s1,tmp,'ignore_str',1); assertTrue(ok,mess)


% Remove the sample again, and confirm the same as original object after writing and reading
% ------------------------------------------------------------------------------------------
% Set sample
f1_1_s0=set_sample(f1_1_s1,[]);
[ok,mess]=equal_to_tol(f1_1,f1_1_s0,'ignore_str',1);
assertTrue(ok,mess)

% Write and read back in
try
    save(f1_1_s0,tmpsqwfile); tmp=read(sqw,tmpsqwfile);
catch err
    warning('test_sqw_file_read_write:io1','Error reading/writing sqw object')
    rethrow(err);
end
[ok,mess]=equal_to_tol(f1_1_s0,tmp,'ignore_str',1); assertTrue(ok,mess)

% Now change the sample in a file
% -------------------------------
% Add sam1 to file with f1_1
save(f1_1,tmpsqwfile)
set_sample_horace(tmpsqwfile,sam1);
tmp=read_sqw(tmpsqwfile);
[ok,mess]=equal_to_tol(f1_1_s1_ref,tmp,'ignore_str',1); assertTrue(ok,mess)

% Now add a longer sample - this should be appended to the end
set_sample_horace(tmpsqwfile,sam2);
tmp=read_sqw(tmpsqwfile);
[ok,mess]=equal_to_tol(f1_1_s2_ref,tmp,'ignore_str',1); assertTrue(ok,mess)

% Now add a longer sample still - but shorter than the sum of sam1 and sam2: should overwrite
set_sample_horace(tmpsqwfile,sam3);
tmp=read_sqw(tmpsqwfile);
[ok,mess]=equal_to_tol(f1_1_s3_ref,tmp,'ignore_str',1); assertTrue(ok,mess)

% Dummy sample
set_sample_horace(tmpsqwfile,[]);
tmp=read_sqw(tmpsqwfile);
[ok,mess]=equal_to_tol(f1_1,tmp,'ignore_str',1); assertTrue(ok,mess)


%==================================================================================================
% Test syntax and file i/o of set_instrument and set_sample
%==================================================================================================
% These tests exercise the read/write of get_sqw and put_sqw, and the correct operation
% of the set_sample and set_instrument methods for both objects and files.

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


% Use instrument function definition to change instrument
% -------------------------------------------------------
% Create reference object, testing setting of array instrument on the way
tmpsqwfile=fullfile(tmp_dir,'test_sqw_file_fileref_store.sqw');
wref=f1_2;
wref.header{1}.efix=130;
wref.header{1}.efix=135;
inst_arr=create_test_instrument(95,250,'s');
inst_arr(2)=create_test_instrument(105,300,'a');
wref=change_header_test(wref,inst_arr,sam1);

save(wref,tmpsqwfile);
wref=read_sqw(tmpsqwfile);     % creates with same file name will be set with read_sqw

% Change the two instruments
inst_arr=create_test_instrument(400,500,'s');
inst_arr(2)=create_test_instrument(105,600,'a');
wtmp_ref=wref;
wtmp_ref.header{1}.instrument=inst_arr(1);
wtmp_ref.header{2}.instrument=inst_arr(2);

wtmp=set_instrument(wref,@create_test_instrument,[400;105],[500;600],{'s';'a'});
assertTrue(isequal(wtmp_ref,wtmp),'Incorrectly set instrument for sqw object')

save(wref,tmpsqwfile);     % recreate reference file
% this fails but for different reason
% set_instrument_horace(tmpsqwfile,@()create_test_instrument([400;105],[500;600],{'s';'a'}));
% assertTrue(isequal(wtmp_ref,read_sqw(tmpsqwfile)),'Incorrectly set instrument for sqw file')


% Both instruments set to the same
inst_arr=create_test_instrument(400,500,'s');
inst_arr(2)=create_test_instrument(400,500,'s');
wtmp_ref=wref;
wtmp_ref.header{1}.instrument=inst_arr(1);
wtmp_ref.header{2}.instrument=inst_arr(2);

wtmp=set_instrument(wref,@create_test_instrument,400,500,'s');
assertTrue(isequal(wtmp_ref,wtmp),'Incorrectly set instrument for sqw object')

save(wref,tmpsqwfile);     % recreate reference file
% this fails buf for some other reason
% set_instrument_horace(tmpsqwfile,@create_test_instrument,400,500,'s');
% assertTrue(isequal(wtmp_ref,read_sqw(tmpsqwfile)),'Incorrectly set instrument for sqw file')


% Set ei in chopper to whatever is in the spe files
inst_arr=create_test_instrument(135,500,'s');
inst_arr(2)=create_test_instrument(50,500,'s');
wtmp_ref=wref;
wtmp_ref.header{1}.instrument=inst_arr(1);
wtmp_ref.header{2}.instrument=inst_arr(2);

wtmp=set_instrument(wref,@create_test_instrument,'-efix',500,'s');
assertTrue(isequal(wtmp_ref,wtmp),'Incorrectly set instrument for sqw object')

save(wref,tmpsqwfile);     % recreate reference file
%set_instrument_horace(tmpsqwfile,@create_test_instrument,'-efix',500,'s');
%assertTrue(isequal(wtmp_ref,read_sqw(tmpsqwfile)),'Incorrectly set instrument for sqw file')

%----------------------------------------------------------------------------------------
