function test_split_arr
% Tests the function split_arr which is inside func_eval_ind

arg{1} = rand(3,11);
arg{2} = rand(2,2,11);

sz_stack = [11,1];
nelmt = [2,5,4];

% First test
ix = [];
argsplit = split_arr(arg,sz_stack,ix,nelmt);

orig = arg{2}(:,:,8:11);
new = argsplit{2,3};
if ~isequal(new(:),orig(:))
    error('Problem!')
end

% Second test
ix = [6,8,3,4,1,2,5,10,9,11,7];
argsplit = split_arr(arg,sz_stack,ix,nelmt);

orig = arg{2}(:,:,[10,9,11,7]);
new = argsplit{2,3};
if ~isequal(size(new),size(orig))
    error('Problem!')
end
if ~isequal(new(:),orig(:))
    error('Problem!')
end
