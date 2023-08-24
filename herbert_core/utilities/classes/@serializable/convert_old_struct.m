function [S_updated,obj] = convert_old_struct (obj, S, ver)
% Update the structure created from earlier class versions to the current version
%
%   >> S_updated = convert_old_struct (obj, S, ver)
%
% This is the default method for handling structures created from earlier class
% versions. It returns the input structure unaltered, which in simplest case of
% missing object properties being set to the default values in the current class
% constructor is sufficient. This method explicitly exists so that this default
% behaviour can be overridden for a particular class to customise the handling
% of older class versions.
%
% Overloading: customising how structures from earlier class versions are updated
% -------------------------------------------------------------------------------
% For any particular class, overload this method to implement customised
% updating for all earlier class version numbers. This is not necessary if the
% differences are only from the addition of properties that can be set from the
% default values in the latest class constructor.
%
% An example outline of the method when the current version is 3 might look like:
%
%   function S_updated = convert_old_struct (obj, S, ver)
%   % Update the structure created for scalar instance of an object
%
%   if ver==2
%           :
%       S_updated = ...
%
%   elseif ver==1
%           :
%       S_updated = ...
%
%   elseif isnan(ver)   % serializable sets ver==NaN if no version is determined
%       % Pre-serializable structure
%           :
%       S_updated = ...
%   end
%
%
% If the design pattern for your class is very complex, it might be necessary to
% have a more sophisticated handling of earlier versions that requires that the
% method from_old_struct be overloaded instead. You may or may not find it
% convenient to have an overloaded convert_old_struct to simplify your code; the
% only location where convert_old_struct is called is in the default
% from_old_struct. Details are in the help to the method
% <a href="matlab:help('serializable/from_old_struct');">from_old_struct</a>.
%
%
% Input:
% ------
%   obj             Scalar instance of the class to be recovered.
%                   This can be used to access property values necessary to 
%                  update the input structure.
%
%   S               Structure for a scalar instance of an earlier version of the
%                  class that is to be updated to the structure for the current
%                  version.
%
%   ver             Version number of the class version that produced S. In the
%                  case of a structure pre-dating the conversin of the class to 
%                  being a serializable object, ver will have been set to NaN.
%
% Output:
% -------
%   S_updated       Structure updated to correspond to the current class
%                  version. The fields must match the names returned by the
%                  class method saveable().


% For the default behaviour the object and version number are unused
S_updated = S;

end
