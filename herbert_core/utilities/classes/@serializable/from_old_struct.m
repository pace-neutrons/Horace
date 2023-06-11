function obj = from_old_struct (obj, S)
% Restore object or object array from structure created by prior class versions
%
%   >> function obj = from_old_struct (obj, S)
%
% The method is called by loadobj or deserialize in the case when the input
% structure derives from an earlier version of the class, or from a structure
% that pre-dates the use of serializable - or indeed a structure with any other
% provenance.
%
% Overloading this method to deal with older class versions
% ---------------------------------------------------------
% This function interfaces the default from_bare_struct method,
% which will recover objects created from earlier versions if the differences
% are only from the addition of properties that can be set from the default
% values in the latest object constructor.
%
% In general, however, if the saved object was an earlier version of the class
% you need to overload this method for your class so that it can handle all the
% structures you want to be able to convert. The most general form of the method
% to add to your classdef file is:
%
%      :
%   methods(Access=protected)
%       function obj = from_old_struct (obj, S)
%           % Update input structure S to have the properties defined in the
%           % class method "saveable" for the current class implementation.
%
%           if isfield (S, 'version')
%               % Created from earlier class version
%               % Suppose current version is version 3, then
%               if version==2
%                     :
%                   S_updated = ...
%               elseif version==2
%                     :
%                   S_updated = ...
%               end
%           else
%               % Created from version before the class was defined as a 
%               % child class of serializable
%                   :
%               S_updated = ...
%           end
%           obj = from_old_struct@serializable (obj, S_updated);
%       end
%   end
%    :
%
%
% Notes on this code outline:
%
% 1) Recall that the structure created by classes that inherit serializable has
%   the following fields:
%
%               .serial_name        Name of the class
%               .version            Class version
%
%           and either:
%               .array_dat          Structure array each element of
%                                   the array being the structure 
%                                   created from one object. The 
%                                   field names match the property
%                                   names returned from the method
%                                   "saveableFields".
%           or there was only one object:
%               .<property_1>       First property in saveableFields()
%               .<property_2>       Second    "     "    "
%                     :                 :
%
%   The blocks in the if...end construct in the above example of from_old_struct
%   need to be able to branch on the structure representing a single object or
%   an object array.
%
% 2) The form can be simpler, for example, if there has only been one version
%   since the class was serialised - when the code could look like:
%
%   methods(Access=protected)
%       function obj = from_old_struct (obj, S)
%           if ~isfield (S, 'version')
%               % Created from version before the class was defined as a 
%               % child class of serializable
%                   :
%               S_updated = ...
%           end
%           obj = from_old_struct@serializable (obj, S_updated);
%       end
%   end
%
% 3) In some complex class designs then the final conversion may have to call
%   an overloaded version of from_old_struct for some other class, or there to
%   be other variations on the general form.
%
%
% Input:
% ------
%   obj             Scalar instance of the class to be recovered.
%                   This is needed because the structure created by the method
%                  to_bare_struct does not contain the class type. The object
%                  is used to provide the class to be recovered, and the value
%                  of any missing properties if recovering from an older
%                  version. 
%
%   S               Structure or structure array of data.
%
% Output:
% -------
%   obj             Object or array of objects of the same class as the input
%                  argument obj.


if isfield (S, 'array_dat')
    obj = obj.from_bare_struct (S.array_dat);   % array of objects
else
    obj = obj.from_bare_struct (S);     % scalar instance
end

end
