function spinw_off()

sw_path = which('spinw');
if isempty(sw_path)
    return
end
sw_path = fileparts(fileparts(fileparts(sw_path)));
all_path = genpath(sw_path);
rmpath(all_path)