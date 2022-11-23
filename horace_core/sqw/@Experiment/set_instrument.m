function   obj = set_instrument(obj,instrument)        
 % add or reset instrument, related to the given experiment class
 % 
obj.instruments = instrument;
if obj.instruments.n_runs ~= obj.n_runs
    inst = obj.instruments;
    inst = inst.expand_runs(obj.n_runs);
    obj.instruments = inst;
end