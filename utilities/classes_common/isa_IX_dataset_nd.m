function ok=isa_IX_dataset_nd(w)
% Test if the input object is a valid IX_dataset_nd (n=1,2 or 3)
%
%   >> ok=is_IX_dataset_nd(w)   % ok is true or false

ok = isa(w,'IX_dataset_1d') || isa(w,'IX_dataset_2d') || isa(w,'IX_dataset_3d');
