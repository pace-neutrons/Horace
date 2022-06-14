function S=mergestruct(varargin)
% Merge structures, succesively updating fields, adding new fields as required.
%
%   >> S = updatestruct (S1,S2,S3,...)
%
% Input:
% ------
%   S1,S2,...   Structures (must be scalar structure)
%
% Output:
% -------
%   S           Single structure with the fields of S1, S2,...
%               If S2 has a field that is not in S1, then it is
%              appended to the end; if the field name matches one in
%              S1 then the value of the field in S1 is updated. This is
%              repeated for S3, S4,...

% Probably inefficient - but will do the job

for i=1:nargin
    if ~isstruct(varargin{i}) || ~(isscalar(varargin{i})||isempty(varargin{i}))
        error('Each input argument must be a scalar structures or an empty structures')
    end
end

S=varargin{1};
for i=2:nargin
    if ~isempty(S)
        Snext=varargin{i};
        for f=fieldnames(Snext)'
            S.(f{1})=Snext.(f{1});
        end
    else
        S=varargin{i};
    end
end
