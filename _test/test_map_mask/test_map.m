function test_map
% Perform tests of IX_map methods
%
% Author: T.G.Perring

banner_to_screen(mfilename)

% -----------------------------------------------------------------------------
% Test read/write
% ---------------
tmpfile=fullfile(tempdir,'tmp.map');

% Read in a variety of maps that should be valid
% ----------------------------------------------
w=IX_map('map_1_empty.map');
save(w,tmpfile)
wtmp=read(IX_map,tmpfile);
if ~isequal(w,wtmp), assertTrue(false,'save followed by read not an identity'), end

w=IX_map('map_14.map');
save(w,tmpfile)
wtmp=read(IX_map,tmpfile);
if ~isequal(w,wtmp), assertTrue(false,'save followed by read not an identity'), end

w=IX_map('map_15_1st_empty.map');
save(w,tmpfile)
wtmp=read(IX_map,tmpfile);
if ~isequal(w,wtmp), assertTrue(false,'save followed by read not an identity'), end

w=IX_map('map_15_3rd_empty.map');
save(w,tmpfile)
wtmp=read(IX_map,tmpfile);
if ~isequal(w,wtmp), assertTrue(false,'save followed by read not an identity'), end

w=IX_map('map_15_last_empty.map');
save(w,tmpfile)
wtmp=read(IX_map,tmpfile);
if ~isequal(w,wtmp), assertTrue(false,'save followed by read not an identity'), end


% Read in a variety of maps that should fail
% ----------------------------------------------
try
    w=IX_map('map_14_too_many_spectra.map');
    ok=false;
catch
    ok=true;
end
if ~ok, assertTrue(false,'Map constructor should have failed but did not'), end

try
    w=IX_map('map_14_wrong_no_workspaces_1.map');
    ok=false;
catch
    ok=true;
end
if ~ok, assertTrue(false,'Map constructor should have failed but did not'), end

try
    w=IX_map('map_14_wrong_no_workspaces_2.map');
    ok=false;
catch
    ok=true;
end
if ~ok, assertTrue(false,'Map constructor should have failed but did not'), end


% Test optional 'wkno' argument
% -----------------------------
w1=IX_map('map_15_1st_empty.map');

w2=IX_map('map_15_1st_empty.map','wkno');
wtmp=w1; wtmp.wkno=[99,1:14]; 
if ~isequal(wtmp,w2), assertTrue(false,'wkno not correctly assigned'), end

w3=IX_map('map_15_1st_empty.map','wk',11:25);
wtmp=w1; wtmp.wkno=11:25; 
if ~isequal(wtmp,w3), assertTrue(false,'wkno not correctly assigned'), end

try
    w=IX_map('map_15_1st_empty.map','wk',11:26);   % should fail (numel(wkno) is wrong)
    ok=false;
catch
    ok=true;
end
if ~ok, assertTrue(false,'Map constructor should have failed but did not'), end
    
% -----------------------------------------------------------------------------
% Test combine
% ------------
wref=IX_map('map_14.map');
w1=IX_map('map_1to8.map');
w2=IX_map('map_9to14.map');
wrefnam=IX_map('map_14.map','wkno');
w1nam=IX_map('map_1to8.map','wkno');
w2nam=IX_map('map_9to14.map','wkno');

% Trivial case of one map
wcomb=combine(w1);
if ~isequal(w1,wcomb), assertTrue(false,'Error combining two maps'), end

% Combine two maps
wcomb=combine(w1,w2);
if ~isequal(wref,wcomb), assertTrue(false,'Error combining two maps'), end

% Try to combine workspaces with shared spectra
try
    wcomb_bad=combine(w1,wref);
    ok=false;
catch
    ok=true;
end
if ~ok, assertTrue(false,'Should have failed because shared spectra'), end

% Combine workspaces with names
wcomb=combine(w1nam,w2nam,'wkno');
if ~isequal(wrefnam,wcomb), assertTrue(false,'Error combining two maps'), end

% A severe test:
m1=IX_map({[11,12,13],[21,22]});
m2=IX_map({[31,32,33,34],[41,42],51},'wkno',[2,99,5]);
m3=IX_map({61,[72,73],[81,82],(91:95)});
mtot=IX_map({[11,12,13],[21,22],[31,32,33,34],[41,42],51,61,[72,73],[81,82],(91:95)});
mtotnam=IX_map({[11,12,13],[21,22],[31,32,33,34],[41,42],51,61,[72,73],[81,82],(91:95)},'wkno',[1,3,2,99,5,4,6,7,8]);

wcomb=combine(m1,m2,m3,'wkno');
if ~isequal(mtotnam,wcomb), assertTrue(false,'Error combining three maps'), end

wcomb=combine(m1,m2,m3);
if ~isequal(mtot,wcomb), assertTrue(false,'Error combining three maps'), end


% -----------------------------------------------------------------------------
% Test mask_map
% -------------
wref=IX_map('map_14.map');
wmsk=mask_map(wref,[35000:40000,5000:20000]);
wmskref=IX_map('map_14_msk.map');
if ~isequal(wmsk,wmskref), assertTrue(false,'Error masking map object'), end

%------------------------------------------------------------------------------
% Success announcement
% --------------------
try
    delete(tmpfile)
catch
    disp('Unable to delete temporary file')
end
banner_to_screen([mfilename,': Test(s) passed'],'bot')
