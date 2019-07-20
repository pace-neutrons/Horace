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

obj = IX_moderator();  % default instance of the object

% Version history
% ----------------
%   unversioned Old-style matlab class with properties identical to
%               current (July 2019) public properties
%
%   1           Class defined by classdef construct. Independent properties
%               are identical to the unversioned class properties with '_'
%               appended to the end, with the exception that there are two
%               additional properties:
%                   - class_version_    Numeric version number
%                   - energy_           Neutron energy
%                   - pdf_              Lookup for random sampling
%                   - valid_            pdf validity status

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
else
    % Assume the structure contains public properties of the old version object
    % Set pulse_model and flux_model before the corresponding parameter arrays
    
    % A flaw in the original definition is that for pulse model 'ikcarp_param'
    % the neutron energy was allowed to be zero. In consequence, the default
    % energy of 0 meV in version 1 of the class definition will cause an
    % error. We must set the energy to be non-zero. 
    
    % Additionally, there was no check on the flux model. Catch the case of 
    % empty flux model
    if strcmp(S.flux_model,'ikcarp_param')
        obj.energy = 1;
    end
    for i=1:numel(nams)
        nam = nams{i};
        if ~(strcmp(nam,'pp') || strcmp(nam,'pf'))
            if ~strcmp(nam,'flux_model') || ~isempty(S.flux_model)
                obj.(nam) = S.(nam);
            end
        end
    end
    obj.pp = S.pp;
    if ~isempty(S.pf)
        obj.pf = S.pf;
    end
end
