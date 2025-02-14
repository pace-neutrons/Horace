% script to compare performance of MATLAB map classes with different type
% of keys and usual key-value arrays or cellarray and search operations over
% these arrays or cellarrays 
% 
% Run to estimate the price of using  MATLAB map wrt to different other
% methods of retrieveing values corresponding to set of keys

n_keys = 100;        % number of keys to search
n_operations= 10000; % number of operations to run to evaluate performance
base_val = rand(1,n_keys); % generate random double keys

% prepare arrays to test for access speed.
test_val = repmat(base_val,1,n_operations);
n_idx = n_keys*n_operations;
rnd_idx = randperm(n_idx);
test_val= test_val(rnd_idx);

% generate different types of inputkeys
keysUint = uint32(round(base_val*(2^32-1)));
keysChar = arrayfun(@(x)char(typecast(x,'uint8')),keysUint,'UniformOutput',false);
val = 1:n_keys;

test_valU = uint32(round(test_val*(2^32-1)));
test_valD = round(test_val*(2^32-1));
test_valC = arrayfun(@(x)char(typecast(x,'uint8')),test_val,'UniformOutput',false);

% build MATLAB maps with different type of keys
map_stor1 = containers.Map('KeyType',class(keysUint),'ValueType',class(val));
map_stor2 = containers.Map('KeyType',class(test_valC{1}),'ValueType',class(val));
map_stor3 = containers.Map('KeyType',class(test_valD),'ValueType',class(val));
cell_store = {};
arr_stor   = [];
arr_stor2   = [];

% check presence and add values
% search in MATLAB map with UINT keys
tv = tic;
for i=1:n_idx
    [idx1,map_stor1] = find_in_map(map_stor1,test_valU(i));
end
tv = toc(tv);
fprintf('Find & Add keys to UINT        map   takes %gsec\n',tv)

% search in MATLAB map with CHAR keys
tv = tic;
for i=1:n_idx
    [idx2,map_stor2] = find_in_map(map_stor2,test_valC{i});
end
tv = toc(tv);
fprintf('Find & Add keys to CHAR        map   takes %gsec\n',tv)

% search in cellarray containing char keys 
tv = tic;
for i=1:n_idx
    [idx3,cell_store] = find_in_cell(cell_store,test_valC{i});
end
tv = toc(tv);
fprintf('Find & Add keys to CELL        array takes %gsec\n',tv)

% search in MATLAB map with DOUBLE keys
tv = tic;
for i=1:n_idx
    [idx4,map_stor3] = find_in_map(map_stor3,test_valD(i));
end
tv = toc(tv);
fprintf('Find & Add keys to DOUBLE      map   takes %gsec\n',tv)

% search in array containing double keys 
tv = tic;
for i=1:n_idx
    [idx5,arr_stor] = find_in_arr(arr_stor,test_valU(i));
end
tv = toc(tv);
fprintf('Find & Add keys to UINT        array takes %gsec\n',tv)

% search in array containing double keys if the array is sorted first
tv = tic;
for i=1:n_idx
    [idx5,arr_stor2] = find_in_arr_sort(arr_stor2,test_valU(i));
end
tv = toc(tv);
fprintf('Find & Add keys to UINT SORTED array takes %gsec\n',tv)

fprintf('%d\n',idx3);
% % speed of accessing keys without addition
% tic
% for i=1:n_idx
%     [idx1,map_stor1] = find_in_map(map_stor1,test_valU(i));
% end
% toc;
% tic
% for i=1:n_idx
%     [idx2,map_stor2] = find_in_map(map_stor2,test_valC{i});
% end
% toc
% tic
% for i=1:n_idx
%     [idx3,cell_store] = find_in_cell(cell_store,test_valC{i});
% end
% toc



function [idx,map] = find_in_map(map,value)
% find/insert values in MATLAB MAP
is = map.isKey(value);
if is
    idx = map(value);
else
    idx = map.length;
    map(value) = idx+1;
end
end

function [idx,hash_cell] = find_in_cell(hash_cell,value)
% find values in cell array
[in,idx] = ismember(value,hash_cell);
if ~in
    idx  = numel(hash_cell)+1;
    hash_cell{idx} = value;
end
end
function [idx,arr] = find_in_arr(arr,value)
% find values in double array
present = arr == value;
idx = find(present,1);
if isempty(idx)
    idx = numel(arr)+1;
    arr = [arr,value];
end
end
%
function [idx,arr] = find_in_arr_sort(arr,value)
% find values in double sorted array
arr = sort(arr);
present = arr == value;
idx = find(present,1);
if isempty(idx)
    idx = numel(arr)+1;
    arr = [arr,value];
end
end