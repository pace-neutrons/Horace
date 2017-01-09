function test_data_out
% Test data_out format

test_data

if ~test_class(c1), error('c1'), end
if ~test_class({c1}), error('{c1}'), end
if ~test_class(w1), error('w1'), end
if ~test_class(s1), error('s1'), end
if ~test_class({s1}), error('{s1}'), end

%--------------------------------------------------------------------------
function status = test_class(dat_in)
kk=mfclass(dat_in);
kk=kk.set_fun(@mfgauss,[100,45,10]);
kk=kk.set_bfun(@mfgauss,[0,0]);
tmp=kk.data;
status = isequal(tmp{1},dat_in);
