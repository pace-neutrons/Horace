function Rrlu = rand_mosaic (obj, sz, alatt, angdeg)
% Return random rotation matricies that sample the mosaic spread

mosaic = obj.eta;

% Get UB matrix and inverse, for the xaxis-yaxis frame
B = bmatrix(alatt,angdeg);
UB = ubmatrix(mosaic.xaxis, mosaic.yaxis, B);
UBinv = inv(UB);

% Get random rotation vectors in the xaxis-yaxis frame
func = mosaic.mosaic_pdf;
X = func(sz, mosaic.parameters{:});

% Get matrix to turn nominal h,k,l into values for mosaic crystallites
tmp = rotvec_to_rotmat (reshape(-X,[3,prod(sz)]));
tmp = mtimesx_horace (tmp, UB);
Rrlu = mtimesx_horace (UBinv, tmp);
Rrlu = reshape(Rrlu,[3,sz]);
