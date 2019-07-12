function obj = init_object_from_structure_ (S)
% Instantiate a scalar object from a scalar structure
% Generally a class-specific function

obj = IX_fermi_chopper();  % default instance

% Previous version
% ----------------
% -Inf - July 2019      Old-style matlab class with properties identical to
%                       current (July 2019) public properties
%
% Assume the structure contains public properties of the old version object
% which can be set in any order, apart from slit_width which must be set
% after slit_spacing to ensure that the check slit_spacing >= slit_width
% is always achieved
nams = fieldnames(S);
for i=1:numel(nams)
    nam = nams{i};
    if ~strcmp(nam,'slit_width')
        obj.(nam) = S.(nam);
    end
end
obj.slit_width = S.slit_width;
