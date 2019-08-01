function [w,ok,mess] = cellarray_to_map(map)
% Make map structure from a cell array

nw=numel(map);
if ~iscell(map) || isempty(map)
    w=[]; ok=false; mess='Mapping data must be non-empty'; return
end

ns=zeros(1,nw);
% Get number of spectra in the workspaces
for i=1:nw
    if isnumeric(map{i})
        ns(i)=numel(map{i});
    else
        w=[]; ok=false; mess='Mapping data must be numeric'; return
    end
end
% Get the spectrum numbers
s=zeros(1,sum(ns));
nend=cumsum(ns);
nbeg=nend-ns+1;
for i=1:nw
    s(nbeg(i):nend(i))=map{i};
end

w.ns=ns;
w.s=s;
ok=true;
mess='';
