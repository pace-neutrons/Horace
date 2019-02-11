function output_struct = obj2struct(obj)
% Convert an object array into a struct array of the public properties
%
%   >> output_struct = obj2struct(obj)
%
% The Matlab instrinsic function struct returns all properties (public,
% private, hidden) as a structure, and only for the first object in the
% array.
%
% Input:
% ------
%   obj             Object array or struct array
%
% Output:
% -------
%   output_struct   Struct array with the same size as the input object
%                  array, with the fields being the public properties.
%                   The function operates recursively, resolving the
%                  public properties of objects and fields of structures
%
% T.G.Perring. Based on a solution from Stack Overflow:
%   https://stackoverflow.com/questions/35736917/convert-matlab-objects-to-struct
% where all that was done was to wrap to work on object and struct arrays

if isstruct(obj)
    output_struct = obj;    % already a structure, so just make a copy
elseif isobject(obj)
    if numel(obj)==1
        output_struct = obj2struct_private(obj);    % keep it simple for scalar case
    else
        nams = fieldnames(obj);
        args = [nams';repmat({[]},1,numel(nams))];
        output_struct = repmat(struct(args{:}),size(obj));
        for i=1:numel(obj)
            output_struct(i) = obj2struct_private(obj(i));
        end
    end
else
    error('Input argument is not an object or a structure')
end

%---------------------------------------------------------------------------
function output_struct = obj2struct_private(obj)
% Converts obj into a struct by examining the public properties of obj. If
% a property contains another object, this function recursively calls
% itself on that object. Else, it copies the property and its value to
% output_struct. This function treats structs the same as objects.

properties = fieldnames(obj); % works on structs & classes (public properties)
for i = 1:length(properties)
    val = obj.(properties{i});
    if ~isstruct(val) && ~isobject(val)
        output_struct.(properties{i}) = val;
    else
        temp = obj2struct(val);
        if ~isempty(temp)
            output_struct.(properties{i}) = temp;
        end
    end
end
