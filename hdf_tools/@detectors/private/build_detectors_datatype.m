function detectors_DT=build_detectors_datatype(this)
% internal method for detectors
%
% the function defines the detector datatype layout (hdf5 complex datatype)
% which has to be consistent with the structure 
% used to keep all detector information together
%
% $Revision$ ($Date$)
%

doubleType  = H5T.copy('H5T_NATIVE_FLOAT');

n_fields    = numel(this.detector_data_fields);

detectors_DT=H5T.array_create (doubleType, 1,n_fields, []);

H5T.close(doubleType);
