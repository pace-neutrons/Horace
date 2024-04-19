function obj = loadobj (S, obj_template)
% Method used by the Matlab load function to reconstruct object from custom storage
%
%   >> obj = loadobj (S)
%   >> obj = loadobj (S, obj_template)
%
% Serializable objects are converted using the serializable class method saveobj
% to a custom structure before being saved to .mat files. This method converts
% the structure back to the original object.
%
% Dealing with older class versions
% ---------------------------------
% By default this method interfaces with default serializable class methods
% which will recover objects created from the current class version. They will
% also recover from earlier versions if the differences are only from the
% addition of properties that can be set from the default values in the latest
% object default constructor.
%
% More generally, it is necessary to write a method called convert_old_struct to
% convert an earlier structure to the current version. For details, see
% <a href="matlab:help('serializable/convert_old_struct');">convert_old_struct</a>
%
% In the case of particularly complex class designs the method from_old_struct
% will need to be overloaded instead (although it may be convenient to write an
% overloaded convert_old_struct to simplify the code). For details see
% <a href="matlab:help('serializable/from_old_struct');">from_old_struct</a>)
%
% If the saved object is sufficiently old that it was not based on the
% serializable class, then in addition you need to overload the loadobj method.
% In your class definition file, add the following method, substituting the name
% of your class in place of "my_class" but otherwise leaving the code unchanged:
%
%      :
%   methods (Static)
%       function obj = loadobj (S)
%       % Boilerplate loadobj method, calling the generic loadobj method of
%       % the serializable class
%           obj = my_class();
%           obj = loadobj@serializable (S, obj);
%       end
%   end
%    :
%
%
%
% Input:
% ------
%   S               Either (1) an object of the class, or (2) a structure or
%                   structure array previously obtained by the saveobj method.
% Optional:
%   obj_template    The instance of a serializable class to recover from the
%                   input structure S.
%                   Normally used by custom loadobj method to allow loading
%                   object from the structure, not previously converted to
%                   stucture using serializable to_struct method, so not
%                   containing metadata, which describe class to recover.
%
% Output:
% -------
%   obj             Either (1) the object passed without change, or (2) an
%                   object (or object array) created from the input structure
%                   (or structure array)


if isstruct(S)
    % As S is a structure, attempt to load using from_struct (recall
    % from_struct is a static method which calls private method of serializable
    % from_struc_ directly)
    if nargin>1
        obj = obj_template.from_struct(S,obj_template);
    else
        obj = serializable.from_struct(S);
    end
else
    % We allow that in the case of S being an object that matches the class of
    % the template object, then simply return S as the object
    if nargin==2
        if isa(S, class(obj_template))
            obj = S;
        else
            error('HERBERT:serializable:invalid_argument',...
                'The input data and template object class names do not match')
        end
    else
        error('HERBERT:serializable:invalid_argument',...
            'The input data is not a structure but no template object class was given')
    end
end

end
