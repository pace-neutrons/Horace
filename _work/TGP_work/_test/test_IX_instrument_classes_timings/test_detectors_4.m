function test_detectors_4
% Time the testing of equality and sorting of detector array objects
% This function is a sort of systems test that exercises object sorting as
% well as performing timing tests

nbank = 3;              % number of banks in each detector array
ndet = [1e5,1e4,10];    % number of detectors in each bank

ndetarr = 100;  % number of detector arrays to make
nref = 30;      % number of detector arrays that are identical to a reference array

% Create detector arrays
disp(' ')
disp('-----------------------------------------')
DD = repmat(IX_detector_array,1,ndetarr);
bigtic
for i=1:numel(DD)
    DD(i)=create_test_IX_detector_array(nbank,ndet);
end

Dref = create_test_IX_detector_array(nbank,ndet);
ieq=randperm(ndetarr,nref);
DD(ieq)=Dref;
bigtoc('Timing to create array of IX_detector_array objects:')
 

% Time to compare every detector array with a reference detector array
% ----------------------------------------------------------------------
disp(' ')
disp('-----------------------------------------')
bigtic;
ok = false(1,ndetarr);
for i=1:ndetarr
    ok(i) = isequal(Dref,DD(i));
end
bigtoc('Timing equality testing (using isequal):')


% Comparison timing
% ------------------
disp(' ')
disp('-----------------------------------------')
bigtic;
ok = false(1,ndetarr);
for i=1:ndetarr
    ok(i) = greater_thanIndep(DD(1),DD(i));
end
bigtoc('Timing greater_than (from objects):')


disp(' ')
disp('-----------------------------------------')
bigtic;
SDD = obj2structIndep(DD);
bigtoc('Time to convert to structure array (structIndep)')

disp(' ')
disp('-----------------------------------------')
bigtic
ok = false(1,ndetarr);
for i=1:ndetarr
    ok(i) = greater_than(SDD(1),SDD(i));
end
bigtoc('Timing greater_than (from structures):')


% Sorting
% ---------
disp(' ')
disp('-----------------------------------------')
bigtic
[DDsortb,ix] = gensort(DD,'resolve','indep');
bigtoc('Timing gensort (with option ''resolve'' to structures)')


% Make an array of lots of repeats to test unique
% -------------------------------------------------
DD2 = repmat(IX_detector_array,1,5);
for i=1:numel(DD2)
    DD2(i)=create_test_IX_detector_array(nbank,ndet);
end
DD2 = gensort(DD2,'resolve','indep');

DD2big = [repmat(DD2(1),1,5),repmat(DD2(2),1,10),repmat(DD2(3),1,15),repmat(DD2(4),1,8)];
ind = randperm(numel(DD2big));
DD2big = DD2big(ind);


disp(' ')
disp('-----------------------------------------')
bigtic
[DD2big_unique,m4,n4]=genunique(DD2big,'resolve','indep');
bigtoc('Timing genunique (with option ''resolve'' to structures)')

if ~isequal(DD2(1:4),DD2big_unique)
    error('Detarray unique sort not working')
end


% Array of just one detector array repeated many times
% ----------------------------------------------------
% Create detector arrays. Call like this so that no shared pointers that
% happens if use repmat
DDsame = repmat(IX_detector_array,1,ndetarr);
for i=1:numel(DDsame)
    DDsame(i)=create_test_IX_detector_array(nbank,ndet,'norand');
end

% Test equality
disp(' ')
disp('-----------------------------------------')
bigtic
ok = isequalnArr(DDsame);
bigtoc('Timing isequalnArr (all IX_detector_array the same)')
if ~ok
    error('isequalnArr failure')
end

disp(' ')
disp('-----------------------------------------')
bigtic
[DDu,m4,n4]=genunique(DDsame,'resolve','indep');
bigtoc('Timing genunique (with option ''resolve'' to structures)')
if ~isequal(DDsame(1),DDu)
    error('Detarray unique sort not working')
end

