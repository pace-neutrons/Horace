function obj = loadobj_private_ (S)
% Instantiate a scalar object from a scalar structure of class properties
%
%   >> obj = loadobj_private_ (S)
%
% Input:
% ------
%   S       Input structure (scalar)
%
% Output:
% -------
%   obj     Reconstructed object
%
% Backwards compatibility function. It must be able to instantiate from a
% - structure of independent class properties from the current class version
% - structure returned by the matlab intrinsic load function when reading
%   .mat files into which earlier versions of the object were saved
% - any other bespoke structures that were saved by earlier versions of the
%   class
%
% It is not designed to interpret the arguments passed to the current class
% constructor.
%
% Generally a class-specific function

obj = IX_null_inst();  % default instance of the object

% Version history
% ----------------
%   1           Class defined by classdef construct.

nams = fieldnames(S);
if isempty(nams)
    return;
end

if isfield(S,'class_version_')
    ver = S.class_version_;
else
    ver=1;
end
if ver==1
    % Assume the structure is of independent properties
    for i=1:numel(nams)
        nam = nams{i};
        obj.(nam) = S.(nam);
    end
else
    error('init_object_from_structure_:unrecognisedVersion',...
        'Unrecognised class version number')
end
