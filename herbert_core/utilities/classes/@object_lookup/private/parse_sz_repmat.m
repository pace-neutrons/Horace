function sz_repmat_out = parse_sz_repmat (sz_repmat, n_objArr, ntot_objArr)
% Check that the repmat option for implicitly expanding the stored arrays in an
% object_lookup object is valid. Throw an error if not.
%
%   >> sz_repmat_out = parse_sz_repmat (sz_repmat, n_objArr, ntot_objArr)

% Make sz_repeat a cell array for convenience
if ~iscell(sz_repmat)
    sz_repmat = {sz_repmat};    
end

% Check input is not empty
nsz_repmat = numel(sz_repmat);
if nsz_repmat==0
    error('HERBERT:object_lookup:invalid_argument', ...
        'If it has been given, the set of repeat sizes cannot be empty')
end

% Check each input is a valid single expansion argument to repmat
is_size_vector = @(x)(isnumeric(x) && isrow(x) && numel(x)>=1 && ...
    all(x>=0) && all(rem(x,1)==0));
if ~all (cellfun(@(x)is_size_vector(x), sz_repmat), 'all')
    error('HERBERT:object_lookup:invalid_argument', ...
        'Repeat sizes must all be an integer>=0 or a valid Matlab array size')
end

% Check consistency of number of object arrays and number of repmat arguments
% One or both can be scalar, but if they are both non-scalar then they must have
% the same number.
% The case of one object array to repmat, multiple repmats, but the total number
% of object arrays in the object_lookup is greater than one, that is not
% permitted either
if ~(n_objArr==1 || nsz_repmat==1 || n_objArr==nsz_repmat)
    error('HERBERT:object_lookup:invalid_argument', ...
        ['The number of object arrays and repeat sizes must ',...
        'be the same if they are both other than one'])
end
if (n_objArr==1 && nsz_repmat~=1 && ntot_objArr~=1)
    error('HERBERT:object_lookup:invalid_argument', ...
        ['Multiple repeat sizes for just one object_array is not permitted ',...
        'if there are other stored object arrays'])
end

% Turn any single number value of sz_repmat{i}, n, into [n,n] to be a true array
% size vector, and return sz_repmat as a column vector
sz_repmat_out = cellfun (@(x)make_size_vector(x), sz_repmat(:),...
    'uniformOutput', false);


%-------------------------------------------------------------------------------
function sz_out = make_size_vector (sz_in)
% Make the size vector for a square matrix if a scalar input
if numel(sz_in)==1
    sz_out = [sz_in, sz_in];
else
    sz_out = sz_in;
end
