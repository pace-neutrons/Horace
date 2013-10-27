function test_mask
% Test manipulations on IX_mask objects
%
% Author: T.G.Perring

banner_to_screen(mfilename)

tmpfile=fullfile(tempdir,'tmp.msk');

% -----------------------------------------------------------------------------
% Empty mask - read and write, test consistency
% ---------------------------------------------
w1=IX_mask;
if ~isempty(w1.msk), assertTrue(false,'Default mask constructor problem'), end
save(w1,tmpfile)
wtmp=read(IX_mask,tmpfile);
if ~isequal(w1,wtmp), assertTrue(false,'Write+read does not make an identity'), end


%------------------------------------------------------------------------------
% Create a mask from array input
% ------------------------------
try
    w1=IX_mask(0:9);    % should not contain zeros
    ok=false;
catch
    ok=true;
end
if ~ok, assertTrue(false,'Mask constructor should have failed but did not'), end

w1ref=IX_mask([34:54,2:5,30:40]);
if ~isequal(w1ref.msk,[2:5,30:54]), assertTrue(false,'Constructor not eliminating duplicates and sorting'), end

w2ref=IX_mask([60:-1:50,2:5,30:40,19:23]);
if ~isequal(w2ref.msk,[2:5,19:23,30:40,50:60]), assertTrue(false,'Constructor not eliminating duplicates and sorting'), end

% A simple mask  - read and write, test duplicates removed, and test read/write
w1=IX_mask('msk_1.msk');
if ~isequal(w1ref,w1), assertTrue(false,'File and array constructors not equivalent'), end
save(w1,tmpfile)
wtmp=read(IX_mask,tmpfile);
if ~isequal(w1,wtmp), assertTrue(false,'Write+read does not make an identity'), end

w2=IX_mask('msk_2.msk');
if ~isequal(w2ref,w2), assertTrue(false,'File and array constructors not equivalent'), end
save(w2,tmpfile)
wtmp=read(IX_mask,tmpfile);
if ~isequal(w2,wtmp), assertTrue(false,'Write+read does not make an identity'), end


%------------------------------------------------------------------------------
% Test combine two masks, which have some shared elements
% -------------------------------------------------------
c1=combine(w1);
if ~isequal(c1,w1), assertTrue(false,'Error combining masks'), end

c1=combine(w1,IX_mask);
if ~isequal(c1,w1), assertTrue(false,'Error combining masks'), end

c2=combine(w1,w2);
c2ref=IX_mask([2:5,19:23,30:60]);
if ~isequal(c2,c2ref), assertTrue(false,'Error combining masks'), end

%------------------------------------------------------------------------------
% Success announcement
% --------------------
try
    delete(tmpfile)
catch
    disp('Unable to delete temporary file')
end
banner_to_screen([mfilename,': Test(s) passed'],'bot')
