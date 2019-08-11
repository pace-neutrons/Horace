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

obj = IX_mosaic();  % default instance of the object

% Version history
% ----------------
%   unversioned Old-style matlab class with properties identical to
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
            if strcmp(nam,'mosaic_pdf_') && (ischar(S.(nam)) || isa(S.(nam),'function_handle'))
                if isa(S.(nam),'function_handle')
                    S.(nam) = func2str(S.(nam));
                end
                % The mosaic function handle must be a private function of IX_mosaic
                % This is because of a stitch-up that enables a socoped function handle
                % to be returned by hlp_serialize as a character string and then
                % read back by hlp_deserialize as a character string. We then have a
                % custom catch in IX_mosaic/loadobj_private_ that catches mosaic_pdf_
                % if it is a character string and uses str2func to convert to the
                % scoped handle again.
                obj.(nam) = str2func(S.(nam));
            else
                obj.(nam) = S.(nam);
            end
        end
    else
        error('init_object_from_structure_:unrecognisedVersion',...
            'Unrecognised class version number')
    end
else
    error('init_object_from_structure_:unrecognisedStructure',...
        'Unrecognised structure')
end
