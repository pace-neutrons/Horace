function lookup=divergence_sampling_table(div,varargin)
% Create divergence lookup table and index arrays
%
%   >> lookup = divergence_sampling_table (div)
%   >> lookup = divergence_sampling_table (div,npnt)
%   >> lookup = divergence_sampling_table (...,opt)
%
% Input:
% ------
%   div         Cell array of divergence profile object arrays, one per sqw object
%   npnt        [Optional] Number of points in sampling table (uses default if not given)
%   opt         [Optional] Purge the lookup table if set to 'purge'
%
%   
%
% Output:
% -------
%   lookup      Structure with fields:
%                 lookup.ind    Cell array of indicies into table, where
%                              ind{i} is a row vector of indicies for ith
%                              sqw object; length(ind{i})=no. runs in sqw object
%                 lookup.table  Lookup table size(npnt,nhdiv), where nhdiv is
%                              the number of unique tables. Note that the angle
%                              is in radians, NOT degrees.

% Assemble the objects and get unique entries
nw=numel(div);
nr=zeros(1,nw);
for i=1:nw
    nr(i)=numel(div{i});
end
nrend=cumsum(nr);
nrbeg=1+[0,nrend(1:end-1)];
nrtot=nrend(end);

div_all=repmat(IX_divergence_profile,[nrtot,1]);
for i=1:nw
    div_all(nrbeg(i):nrend(i))=div{i};
end

% Create lookup table, using any buffered results
[table,ind]=buffered_sampling_table(div_all,varargin{:});

% Create output structure
lookup=struct('ind',{mat2cell(ind,1,nr)},'table',table);
