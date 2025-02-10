n_keys = 100;
base_key = 10+round(rand(1,10*n_keys)*(10*n_keys-1));
base_key = unique(base_key);


base_key = base_key(1:n_keys);
keysUint = uint32(base_key);
mm = min_max(keysUint)

n_operations= 10000;


test_keys = repmat(base_key,1,n_operations);
n_idx = n_keys*n_operations;
rnd_idx = randperm(n_idx);
test_keys= test_keys(rnd_idx);



map_stor1 = containers.Map('KeyType',class(keysUint),'ValueType','double');


% check presence and add values

tv = tic;
for i=1:n_idx
    [idx1,map_stor1] = add_to_map(map_stor1,test_keys(i));
end
tv = toc(tv);
fprintf('Find & Add keys to UINT        map   takes %gsec\n',tv)
fm = fast_map();
tv = tic;
for i=1:n_idx
    if fm.isKey(test_keys(i))
        idx1 = fm.get(test_keys(i));
    else
        fm = fm.add(test_keys(i),i);
    end
end
tv = toc(tv);
fprintf('Find & Add keys FAST MAP       map   takes %gsec\n',tv)
tv = tic;
for i=1:n_idx
    idx1 = map_stor1(test_keys(i));
end
tv = toc(tv);
fprintf('Find       keys in UINT        map   takes %gsec\n',tv)
tv = tic;
for i=1:n_idx
    idx1 = fm.get(test_keys(i));
end
tv = toc(tv);
fprintf('Find    keys in FAST MAP       map   takes %gsec\n',tv)

tv = tic;
idx1 = fm.get_values_for_keys(test_keys);
tv = toc(tv);
fprintf('Find all keys in FAST MAP      map   takes %gsec\n',tv)


fm.optimized = true;
tv = tic;
for i=1:n_idx
    idx1 = fm.get(test_keys(i));
end
tv = toc(tv);
fprintf('Find keys in FAST MAP Opt      map   takes %gsec\n',tv)

tv = tic;
idx1 = fm.get_values_for_keys(test_keys,true);
tv = toc(tv);
fprintf('Find all keys in FAST MAP opt  map   takes %gsec\n',tv)



function [idx,map] = add_to_map(map,value)
is = map.isKey(value);
if is
    idx = map(value);
else
    idx = map.length;
    map(value) = idx+1;
end
end

