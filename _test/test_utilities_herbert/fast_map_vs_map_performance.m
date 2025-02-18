% script to compare performance of custom fast_map class and
% with performance of standard MATLAB map class.
%
% Run to estimate the price of using  MATLAB map wrt custom fast_map
% class
%

% generate specified number of random keys in the range
% exceeding  number of keys by 10. This approximate runids obtained from
% two  independent experiments provided in two cycles which are not too far
% from each other in time.
n_keys = 200;
base_key = 10+round(rand(1,10*n_keys)*(10*n_keys-1)); %generate 10 times
% more keys then necessary to ensure sufficient unique keys pool.
base_key = unique(base_key); % ensure absence of duplicated keys

n_keys = min(n_keys,numel(base_key));
base_key = base_key(1:n_keys); % leave the expected number of keys
keysUint = uint32(base_key);   % convert them into requested type.
mm = min_max(keysUint)         % display range of keys used in tests

n_operations= 10000; % specify the number of operations to perfrom over maps
% to estimate performance

% prepare test arrays with swarms of test keys to estimate performance
test_keys = repmat(base_key,1,n_operations);
n_idx = n_keys*n_operations;
rnd_idx = randperm(n_idx);     % mix keys to ensure we retrieve their
test_keys= test_keys(rnd_idx); % values randomly


map_stor = containers.Map('KeyType',class(keysUint),'ValueType','double');

% Measure the time and estimate the performance for different operations
% with maps
%
%
% Measure access/insertion time for MATLAB map
tv = tic;
for i=1:n_idx
    is = map_stor.isKey(test_keys(i));
    if is
        idx = map_stor(test_keys(i));
    else
        idx = map_stor.length;
        map_stor(test_keys(i)) = idx+1;
    end

end
tv = toc(tv);
fprintf('Find & Add keys to UINT        map   takes %gsec\n',tv)

% Measure access/insertion time for fast_map map
fm = fast_map();
tv = tic;
for i=1:n_idx
    if fm.isKey(test_keys(i))
        idx1 = fm.get(test_keys(i));
    else
        idx = fm.n_members;        
        fm  = fm.add(test_keys(i),idx+1);
    end
end
tv = toc(tv);
fprintf('Find & Add keys FAST MAP       map   takes %gsec\n',tv)

% Measure access time for MATLAB map
tv = tic;
for i=1:n_idx
    idx1 = map_stor(test_keys(i));
end
tv = toc(tv);
fprintf('Find       keys in UINT        map   takes %gsec\n',tv)

% Measure access time for fast_map
tv = tic;
for i=1:n_idx
    idx1 = fm.get(test_keys(i));
end
tv = toc(tv);
fprintf('Find    keys in FAST MAP       map   takes %gsec\n',tv)

% Measure access time for fast_map using remapper method for all keys
tv = tic;
fm.optimized = false;
idx1 = fm.get_values_for_keys(test_keys);
tv = toc(tv);
fprintf('Find all keys in FAST MAP  non-opt   takes %gsec\n',tv)

% Measure access time for optimized fast_map
fm.optimized = true;
tv = tic;
for i=1:n_idx
    idx1 = fm.get(test_keys(i));
end
tv = toc(tv);
fprintf('Find keys in FAST MAP opt      map   takes %gsec\n',tv)

% Measure access time for optimized fast_map using remapper method for all keys
fm = fast_map(base_key,1:numel(base_key));
fm.optimized = true;
tv = tic;
idx1 = fm.get_values_for_keys(test_keys,true);
tv = toc(tv);
fprintf('Find all keys in FAST MAP opt  map   takes %gsec\n',tv)

