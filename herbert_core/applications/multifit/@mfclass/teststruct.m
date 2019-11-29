function S = teststruct(obj)
% Get private fields as a structure

S.dataset_class = obj.dataset_class_;
S.data = obj.data_;
S.w = obj.w_;
S.msk = obj.msk_;
S.foreground_is_local = obj.foreground_is_local_;
S.background_is_local = obj.background_is_local_;
S.fun = obj.fun_;
S.pin = obj.pin_;
S.np = obj.np_;
S.free = obj.free_;
S.bfun = obj.bfun_;
S.bpin = obj.bpin_;
S.nbp = obj.nbp_;
S.bfree = obj.bfree_;
S.bound = obj.bound_;
S.bound_to = obj.bound_to_;
S.ratio = obj.ratio_;
S.bound_to_res = obj.bound_to_res_;
S.ratio = obj.ratio_;
