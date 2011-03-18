function [mbeg,mend]=array_unique_ranges(a)
% Find the first and last indicies of unique ranges in an array
%
%   >> [mbeg,mend]=array_unique_ranges(a)

% T.G.Perring, 2 August 2010

if numel(a)>1
    a=a(:)';    % make row
    mbeg=find([true,diff(a)~=0]);
    mend=[mbeg(2:end)-1,numel(a)];
elseif numel(a)==1
    mbeg=1; mend=1;
elseif isempty(a)
    mbeg=[]; mend=[];
end
