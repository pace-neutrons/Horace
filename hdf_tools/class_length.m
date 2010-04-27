function type_length=class_length(type)
% function returns the length of a standard matlab class in bytes
%
% error is returned if the matlab type is cell or unknown
%
% $Revision$ ($Date$)
%
switch (class(type))
    case {'int8' 'uint8' 'char'}
        type_length = 1;
    case {'int16' 'uint16'}
        type_length = 2;
    case {'int32' 'uint32'}
        type_length = 4;
    case 'single'
        type_length = 4;
    case {'int64' 'uint64' 'double'}
        type_length = 8;
% cells of cells are currently not supported        
%    case{'cell'}
%        type_name=hdf_type(type{1});
    otherwise
        error('MATLAB:hdf_tools:badtype', ['Unaccepted or unknown type ',class(type),' provided as an argument.']);
end
