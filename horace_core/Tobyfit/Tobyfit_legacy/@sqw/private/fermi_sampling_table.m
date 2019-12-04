function lookup=fermi_sampling_table(fermi,varargin)
% Create Fermi chopper lookup table and index arrays
%
%   >> lookup=fermi_sampling_table(fermi)
%   >> lookup=fermi_sampling_table(fermi,npnt)
%   >> lookup=fermi_sampling_table(...,opt)
%
% Input:
% ------
%   chopper     Cell array of chopper object arrays, one per sqw object
%   npnt        [Optional] Number of points in sampling table (uses default if not given)
%   opt         [Optional] Purge the lookup table if set to 'purge'
%
% Output:
% -------
%   lookup      Structure with fields:
%                 lookup.ind    Cell array of indicies into table, where
%                              ind{i} is column vector of indicies for ith
%                              sqw object; length(ind{i})=no. runs in sqw object
%                 lookup.table  Lookup table size(npnt,nchop), where nchop is
%                              the number of unique tables. Note that the time
%                              is in seconds, NOT microseconds.

% Assemble the chopper objects and get unique entries
nw=numel(fermi);
nr=zeros(nw,1);
for i=1:nw
    nr(i)=numel(fermi{i});
end
nrend=cumsum(nr);
nrbeg=1+[0;nrend(1:end-1)];
nrtot=nrend(end);

fermi_all=repmat(IX_fermi_chopper,[nrtot,1]);
for i=1:nw
    fermi_all(nrbeg(i):nrend(i))=fermi{i};
end

% Create lookup table, using any buffered results
[table,ind]=buffered_sampling_table(fermi_all,varargin{:});
ind=ind(:);     % make a column

% Create output structure
table=1e-6*table;   % convert to seconds
lookup=struct('ind',{mat2cell(ind,nr)},'table',table);
