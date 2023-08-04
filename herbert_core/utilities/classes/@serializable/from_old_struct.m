function obj = from_old_struct (obj, S)
% Restore object or object array from structure created by prior class versions
%
%   >> function obj = from_old_struct (obj, S)
%
% The method is ultimately called by loadobj or deserialize in the case when the
% input structure derives from an earlier version of the class, or from a
% structure that pre-dates the use of serializable (or indeed a structure with
% any other provenance).
%
% Overloading: customising how structures from earlier class versions are updated
% -------------------------------------------------------------------------------
% In the simplest cases when the older structure has missing fields which can
% simply be filled from default properties of the current object version,
% nothing needs to be done.
%
% In most other cases, all that is needed is to overload the default
% serializable method convert_old_struct. For details see
% <a href="matlab:help('serializable/convert_old_struct');">convert_old_struct</a>.
%
% If the design pattern for your class is particularly complex it might be
% necessary to have a more sophisticated handling of earlier versions that
% requires that this method is overloaded.
%
% A typical general form of the method to add to your classdef file is:
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
% 2) In some complex class designs then the final conversion may have to call
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


% Convert older structure to one that would be produced by the current class
% version

if isfield (S, 'version')
    % Created from earlier class version
    ver = S.version;
    if isfield (S, 'array_dat')
        dat = S.array_dat;
    else
        dat = S; % this should not happen
    end
else
    % Created from version before the class was defined as a child class of
    % serializable
    ver = NaN;    % convention for no explicit version
    dat = S;
end
nobj = numel(dat);
if nobj == 1
    [datastruct,obj] = convert_old_struct (obj, dat, ver);
else
    % S corresponds to an array of objects
    if ~isequal(size(obj),size(dat))
        obj = repmat(obj(1),size(dat));
    end
    i=1:nobj;
    [datastruct,obj] = arrayfun (@(n)convert_old_struct(obj(n),dat(n),ver), i);
    if ~isequal(size(datastruct),size(dat))
        datastruct= reshape(datastruct,size(dat));
    end
end

% Recover the object or object array
obj = obj.from_bare_struct (datastruct);

end
