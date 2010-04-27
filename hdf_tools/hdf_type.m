function type_name=hdf_type(type)
% function returns the name of the native HDF dataset as function of 
% a primary matlab Type
%
% error is returned if the matlab type does not have HDF basic equivalent
%
% $Revision$ ($Date$)
%
switch (class(type))
    case {'int8' 'uint8' 'char'}
        type_name = 'H5T_NATIVE_CHAR';
    case {'int16' 'uint16'}
       type_name = 'H5T_NATIVE_INT16'; %size = 2; ???! ***  HDF type needs checking
    case {'int32' 'uint32'}
        type_name = 'H5T_NATIVE_INT';        
    case 'single'
        type_name = 'H5T_NATIVE_FLOAT';                
    case {'int64' 'uint64'}
        type_name = 'H5T_NATIVE_INT64';        
    case 'double'
        type_name = 'H5T_NATIVE_DOUBLE';
% cells of cells are currently not supported        
%    case{'cell'}
%        type_name=hdf_type(type{1});
    otherwise
        error('MATLAB:hdf_tools:badtype', ['Unaccepted or unknown type ',class(type),' provided as an argument.']);
end
