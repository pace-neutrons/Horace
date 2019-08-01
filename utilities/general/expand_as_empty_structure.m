function sout=expand_as_empty_structure(sin,sz,id)
% Expand a scalar structure as an empty structure, except retaining element id as the input
%
%   >> sout=expand_as_empty_structure(sin,sz,id)
%
% Input:
% ------
%   sin     Structure (must be scalar structure)
%   sz      Size of output struture based on sin
%   id      Element of output structure to be set to sin
%
% Output:
% -------
%   sout    Array of structures with empty fields apart from sout(id)=sin

if isstruct(sin) && isscalar(sin)
    nams=fieldnames(sin);
    args=[nams';repmat({[]},1,numel(nams))];
    sout=repmat(struct(args{:}),sz);
    sout(id)=sin;
else
    error('Input not a scalar structure')
end
