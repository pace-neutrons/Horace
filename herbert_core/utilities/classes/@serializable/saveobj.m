function S = saveobj (obj)
% Perform custom conversion to a structure prior to saving with Matlab save.
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
%   obj     Scalar instance of the object class object.
%
% Output:
% -------
%   S       Structure created from obj that is to be saved.
%           For details on the format of the struture created by saveobj, see
%           <a href="matlab:help('serializable/to_struct');">to_struct</a>.


S = to_struct (obj);

end
