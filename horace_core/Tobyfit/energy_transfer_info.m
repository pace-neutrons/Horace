function [deps,eps_lo,eps_hi,ne]=energy_transfer_info(header)
% Get energy transfer information
%
%   >> [deps,eps_lo,eps_hi,ne]=energy_transfer_info(header)
%    
% Input:
% ------
%   header      Header field from sqw object
%
% Output:
% -------
%   The output arrays have length equal to the number of runs:
%
%   deps        Size of energy transfer bins (meV) [Column vector]
%   eps_lo      Centre of lowest energy transfer bins (mev)  [Column vector]
%   eps_hi      Centre of highest energy transfer bins (mev) [Column vector]
%   ne          Number of energy transfer bins [Column vector]


if ~iscell(header)
    ne=numel(header.en)-1;
    eps_lo=0.5*(header.en(1)+header.en(2));
    eps_hi=0.5*(header.en(end-1)+header.en(end));
    deps=(header.en(end)-header.en(1))/ne;
else
    nrun=numel(header);
    eps_lo=zeros(nrun,1);
    eps_hi=zeros(nrun,1);
    deps=zeros(nrun,1);
    ne=zeros(nrun,1);
    for i=1:nrun
        ne(i)=numel(header{i}.en)-1;
        eps_lo(i)=0.5*(header{i}.en(1)+header{i}.en(2));
        eps_hi(i)=0.5*(header{i}.en(end-1)+header{i}.en(end));
        deps(i)=(header{i}.en(end)-header{i}.en(1))/ne(i);
    end
end
