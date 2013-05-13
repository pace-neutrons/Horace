function S=struct_special(moderator)
% Convert an array of moderator objects into a column vector structure array
%
%   >> S=struct_special(mod)
%
% Input:
% ------
%   mod     Array of moderator objects
%   
% Output:
% -------
%   S       Structure array (column vector) with fields matching those of the
%          modeartor object, with arrays converted to a fields of scalars:
%          pp => pp1,pp2,pp3...  and pf => pf1,pf2,pf3,...
%           The arrays are padded with -Inf as required by the longest array
%          pp, and also pf.
%
% This is a utility routine used in sorting.

% Create a structure with pulse shape and flux model parameters turned into scalars
% and concatenate with structure made from other fields of moderator
nmod=numel(moderator);
npp=zeros(nmod,1);
npf=zeros(nmod,1);
for i=1:nmod
    npp(i)=numel(moderator(i).pp);
    npf(i)=numel(moderator(i).pf);
end
nppmax=max(npp);
npfmax=max(npf);
pp=-Inf(nppmax,nmod);
pf=-Inf(npfmax,nmod);
for i=1:nmod
    pp(1:npp(i),i)=moderator(i).pp;
    pf(1:npf(i),i)=moderator(i).pf;
end
pp=pp';
pf=pf';

arg=cell(2,nppmax+npfmax);
for i=1:nppmax
    arg{1,i}=['pp',num2str(i)];
    arg{2,i}=num2cell(pp(:,i));
end
for i=1:npfmax
    arg{1,nppmax+i}=['pf',num2str(i)];
    arg{2,nppmax+i}=num2cell(pf(:,i));
end

S=catstruct(rmfield(struct(moderator(:)),{'pp','pf'}),struct(arg{:}));
