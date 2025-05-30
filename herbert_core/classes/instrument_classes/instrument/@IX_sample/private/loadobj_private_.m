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

obj = IX_sample();  % default instance of the object

% Version history
% ----------------
%   unversioned Old-style Matlab class with properties identical to
%   unversioned Old-style Matlab class with properties identical to
%               current (July 2019) public properties
%
%   1           Class defined by classdef construct. Independent properties
%               are identical to the unversioned class properties with '_'
%               appended to the end, with the exception that there is the
%               additional property:
%                   - class_version_    Numeric version number

nams = fieldnames(S);

if isfield(S,'class_version_')
    ver = S.class_version_;
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
else % A 0 version of the sample class encountered.
    % Assume the structure contains public properties of the old version object
    % Catch case of empty xgeom or ygeom - this can happen if not single crystal
    % Catch the case of empty shape so we keep the new default
    if isempty(S.xgeom)
        S = rmfield(S,'xgeom');
    end
    if isempty(S.ygeom)
        S = rmfield(S,'ygeom');
    end
    if isempty(S.shape)
        S = rmfield(S,{'shape','ps'});
    end
    
    all_empty = true;
    for i=1:numel(nams)
        nam = nams{i};
        if ~isempty(S.(nam))
            all_empty = false;
        end
        obj.(nam) = S.(nam);
    end
    % consequences of sealed empty on superclass. Deal with on refactoring
    if ~all_empty
        if isempty(S.name)
            obj.name_ = '_';
        end
    end
end
