function test_gensort

% Cell array with elements in increasing order
anum = {[33,99;44,55], [33,44;99,55], [11;9;4], [11;9;4;6;1]};

a = anum([3,1,1,2,3,2,1,3]);
aStruct = struct('a',a);

ix_ref = [2     3     7     4     6     1     5     8];
b_ref = aStruct(ix_ref);

% Test sorting functions
[b0,ix0] = sortStruct(aStruct,'a');
if ~(isequal(b_ref,b0) && isequal(ix_ref,ix0))
    error('Problem with: sortStruct(aStruct,''a'')')
end

[b1,ix1] = sortStruct(aStruct);
if ~(isequal(b_ref,b1) && isequal(ix_ref,ix1))
    error('Problem with: sortStruct(aStruct)')
end

[b2,ix2] = gensort(aStruct);
if ~(isequal(b_ref,b2) && isequal(ix_ref,ix2))
    error('Problem with: gensort(aStruct)')
end
