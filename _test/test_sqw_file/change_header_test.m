function wnew=change_header_test(w,inst,samp)
% Alter an object's header, and test against altering with set_sample and set_header,
% both in object form and file form.
%
% Return the altered object, so it can be used as input into further tests, with
% name of file that contains the object on disk

no_inst=true;
no_samp=true;
tmpsqwfile=fullfile(tmp_dir,'change_header_test.sqw');

% Make an sqw object with a sample
wnew=w;
if ~(ischar(inst) && strcmpi(inst,'-none'))
    wnew=set_header_fudge(wnew,'instrument',inst);
    no_inst=false;
end
if ~(ischar(samp) && strcmpi(samp,'-none'))
    wnew=set_header_fudge(wnew,'sample',samp);
    no_samp=false;
end

% Use set_instrument &/or set_sample on object
tmp=w;
if ~no_inst, tmp=set_instrument(tmp,inst); end
if ~no_samp, tmp=set_sample(tmp,samp); end
[ok,mess]=equal_to_tol(wnew,tmp);
if ~ok, assertTrue(false,mess), end

% Save to file and set object
save(w,tmpsqwfile);
if ~no_inst, set_instrument_horace(tmpsqwfile,inst); end
if ~no_samp, set_sample_horace(tmpsqwfile,samp); end
tmpfromfile=read_sqw(tmpsqwfile);
% ignore file creation date
wnew.main_header.creation_date = tmpfromfile.main_header.creation_date;
wnew.experiment_info.instruments = wnew.experiment_info.instruments.reorder();
tmpfromfile.experiment_info.instruments = tmpfromfile.experiment_info.instruments.reorder();

assertEqualToTol(wnew,tmpfromfile,[1.e-8,1.e-8],'ignore_str',1)

% Delete output file, if can
delete(tmpsqwfile)
