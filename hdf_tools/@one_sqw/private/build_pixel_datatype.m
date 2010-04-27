function this=build_pixel_datatype(this)
% internal method for one_sqw
%
% the function defines the pixels datatype layout (hdf5 complex datatype)
% which has to be consistent with the structure 
% used to keep all pixel information together
%
% $Revision$ ($Date$)
%

try 
% close all previous instances of datatype (if any) to avoid resources leak
    H5T.close(this.pixel_DT);
catch
end

switch(this.pixel_accuracy)
    case 'double'
        basic_type  = H5T.copy('H5T_NATIVE_DOUBLE');               
    otherwise
        basic_type  = H5T.copy('H5T_NATIVE_FLOAT');       
end
pixel_width        = this.pixel_dims(1);

this.pixel_DT  = H5T.array_create (basic_type, 1,fliplr(pixel_width), []);

H5T.close(basic_type);



