function obj = loadobj (S, obj_template)
% Method used by Matlab load function to reconstruct object from custom storage
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
% which will recover objects created from the current version, and earlier
% versions too if the differences are only from the addition of properties that
% can be set from the default values in the latest object constructor.
%
% In general, however, if the saved object was an earlier version of the class
% you need to write a method for your class called from_old_struct
% that will convert the structure to one that follows the latest structure. 
% Details about what is required are in <a href="matlab:help('serializable/from_old_struct');">from_old_struct</a>.
%
% If the saved object is sufficiently old that it was not based on the
% serializable class, then in addition you need to overload the loadobj method.
% In your class definition, add the following method into the class definition
% file, substituting the name of your class in place of "my_class" but otherwise
% leaving the code unchanged:
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
%   S       Either (1) an object of the class, or (2) a structure or structure
%          array previously obtained by the saveobj method.
%
%   obj     The instance of a serializable class to recover from the input
%           structure S.
%
% Output:
% -------
%   obj     Either (1) the object passed without change, or (2) an
%           object (or object array) created from the input structure
%           (or structure array)


if isstruct(S)
    % As S is a structure, attempt to load using from_struct_ (recall
    % from_struct is a static method so must call private method of serializable
    % from_struc_ directly)
    if nargin == 1
        obj = from_struct_ (S);
    else
        obj = from_struct_ (S, obj_template);
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
