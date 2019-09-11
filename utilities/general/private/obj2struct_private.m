function output = obj2struct_private(input, public)
% Recursively convert object arrays into structure arrays of object properties
%
%   >> output = obj2struct_private(input, type)
%
% Input:
% ------
%   input   The initial call must be with the input being an object array
%           or a structure array
%
%   public  Logical flag:
%            true:  keep public properties (independent and dependent)
%                   More specifically, it calls an object method called 
%                  structPublic if it exists; otherwise it calls the
%                  generic function structPublic.
%            false: keep independent properties only (hidden, protected and
%                   public)
%                   More specifically, it calls an object method called 
%                  structIndep if it exists; otherwise it calls the
%                  generic function structIndep.
%
% Output:
% -------
%   output  Structure array with all objects arrays resolved into structure
%           arrays


% T.G.Perring. Inspired by a solution from Stack Overflow:
%   https://stackoverflow.com/questions/35736917/convert-matlab-objects-to-struct
% where all that was done was to wrap to work on object and struct arrays


if isstruct(input) || isobject(input)
    if numel(input)<=1  % include empty structure or object
        output = obj2struct_private_single(input,public);   % keep it simple for scalar case
    else
        output = arrayfun(@(x)obj2struct_private_single(x,public), input);
    end
elseif iscell(input)
    if isempty(input)
        output = input;
    elseif numel(input)==1
        output = {obj2struct_private(input{1},public)};     % keep it simple for scalar case
    else
        output = cellfun(@(x)obj2struct_private(x,public), input, 'UniformOutput', false);
    end
else
    output = input;
end

%---------------------------------------------------------------------------
function output = obj2struct_private_single(input,public)
% On entry obj will be a scalar object or a scalar structure.
% Converts obj into a struct by examining the independent properties of obj.
% If a property contains another object, this function recursively calls
% itself on that object. Else, it copies the property and its value to
% output_struct. This function treats structs the same as objects.

if isobject(input)
    if public
        output = structPublic(input);
    else
        output = structIndep(input);
    end
else
    output = input;     % pointer - only a small overhead
end

properties = fieldnames(output);
for i = 1:length(properties)
    val = output.(properties{i});
    if isstruct(val) || isobject(val) || iscell(val)
        output.(properties{i}) = obj2struct_private(val,public);
    end
end
