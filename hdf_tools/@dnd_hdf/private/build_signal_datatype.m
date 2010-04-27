function this=build_signal_datatype(this)
% internal method for one_sqw
% the function defines the signal datatype layout (hdf5 complex datatype)
% which has to be consistent with the structure 
% used to keep signal, error and npix  information in sqw structure
%
%
% $Revision$ ($Date$)
%
% *** > check if it is memory or file datatype; looks like file datatype
basic_type  = H5T.copy('H5T_NATIVE_DOUBLE');               

% 3 for s,e and npix;
this.signal_DT=H5T.array_create (basic_type, 1,3, []);

H5T.close(basic_type);
 
