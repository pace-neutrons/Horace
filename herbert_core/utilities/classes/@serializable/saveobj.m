function S = saveobj (obj)
% Perform custom conversion to structure prior to saving with Matlab save.
%
%   >> S = saveobj (obj)
%
% This method is used by Matlab when the intrinsic save function is used to save
% to a .mat file (or any of the other supported file formats). When the object
% is saved its full class name is stored by Matlab with the data; the saveobj
% method allows custom storage of the data of an object. In this implementation
% for serializable objects, the customised structure created by the method
% to_struct is used.
%
% When loading the data back from a .mat file, the corresponding static method
% loadobj defined for the serializable class unpacks the custom structure.
%
%
% Input:
% ------
%   obj     Scalar instance of the object class object
%
% Output:
% -------
%   S       Structure created from obj that is to be saved
%
% Adds the field "version" to the result of 'to_struct
%                operation
%.version     -- containing result of getVersion
%                function, to distinguish between different
%                stored versions of a serializable class
%------------------------------------------------------------------
% Generic loadobj and saveobj
% - to enable custom saving to .mat files and bytestreams
% - to enable older class definition compatibility
%------------------------------------------------------------------

S = to_struct (obj);

end
