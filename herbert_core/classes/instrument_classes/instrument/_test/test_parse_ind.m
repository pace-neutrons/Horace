

nel_1 = [500000];         % Single bank like MAPS or MERLIN

nel_500 = 1000*ones(1,500);     % Roughly MERLIN if one tube per bank

ind_in = randselection(1:500000,[1,1e7]);


% Single bank
bigtic
[sz, ix, iarr, ind] = parse_ind (nel_1);
bigtoc

bigtic
[sz, ix, iarr, ind] = parse_ind (nel_1,ind_in);
bigtoc


% Multiple banks
bigtic
[sz, ix, iarr, ind] = parse_ind (nel_500);
bigtoc

bigtic
[sz, ix, iarr, ind] = parse_ind (nel_500,ind_in);
bigtoc


%--------------------------------------------------------------------------
% Now test parse_ind_args

% Expect:
% --------
%   ix = [1,4,3,5,6,2]'
%   ind = {[2,1]',[1,2,1]',2}'
[sz, ix, iarr, ind] = parse_ind ([2,3,2], [2,7,3,1,4,3]);


% Should be OK:
% -------------
% args{1} = [17]
[sz, ix, iarr, ind, args] = parse_ind_args ([2,3,2], 'wvec', [2,7,3,1,4,3], 17);

% args{1} = {[11,12]',[11,13,11]',[33,11]'}'
[sz, ix, iarr, ind, args] = parse_ind_args ([2,3,2], 'wvec', [11,12,11,13,11,33,11]);

% Should fail because of the wrong number of 'wvec'
[sz, ix, iarr, ind, args] = parse_ind_args ([2,3,2], 'wvec', [2,7,3,1,4,3], [17,33]);

% args{1} = {[14,13]',[17,33,22]',[10]}
[sz, ix, iarr, ind, args] = parse_ind_args ([2,3,2], 'wvec', [2,7,3,1,4,3], [14,10,17,13,33,22]);

% And another argument
[sz, ix, iarr, ind, args] = parse_ind_args ([2,3,2], {'wvec','nog'}, [2,7,3,1,4,3], [14,10,17,13,33,22], 1422);

% No additional arguments
[sz, ix, iarr, ind, args] = parse_ind_args ([2,3,2],{});

[sz, ix, iarr, ind, args] = parse_ind_args ([2,3,2],{},[2,7,3,1,4,3]);


% Checking sizes
% ---------------
[sz, ix, iarr, ind, args] = parse_ind_args ([2,3,2],{});
if ~isequal(sz,[1,7])
    error('Wrong size')
end

[sz, ix, iarr, ind, args] = parse_ind_args ([2,3,2],{},[2,7,3,1,4,3]);
if ~isequal(sz,[1,6])
    error('Wrong size')
end

[sz, ix, iarr, ind, args] = parse_ind_args ([2,3,2],{},[2,7,3;1,4,3]);
if ~isequal(sz,[2,3])
    error('Wrong size')
end

[sz, ix, iarr, ind, args] = parse_ind_args ([2,3,2], 'wvec', [2,7,3,1,4,3], [14,10;17,13;33,22]);
if ~isequal(sz,[3,2])
    error('Wrong size')
end




