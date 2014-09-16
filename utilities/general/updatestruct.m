function S=updatestruct(varargin)
% Merge structures, succesively updating fields, but NOT adding new ones
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
%              ignored; if the field name matches one in
%              S1 then the value of the field in S1 is updated. This is
%              repeated for S3, S4,...

% Probably inefficient - but will do the job

for i=1:nargin
    if ~isstruct(varargin{i}) || ~(isscalar(varargin{i})||isempty(varargin{i}))
        error('Each input argument must be a scalar structures or an empty structures')
    end
end

S=varargin{1};
if isempty(S)
    return  % nothing to be updates
else
    nam=fieldnames(S);
end

for i=2:nargin
    Snext=varargin{i};
    ind=find(isfield(Snext,nam));
    if ~isempty(ind)
        for j=1:numel(ind)
            S.(nam{ind(j)})=Snext.(nam{ind(j)});
        end
    end
end
