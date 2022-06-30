function S=struct_special(obj)
% Convert an array of divergence objects into a column vector structure array
%
%   >> S=struct_special(obj)
%
% Input:
% ------
%   obj     Array of divergence objects
%   
% Output:
% -------
%   S       Structure array (column vector) with fields matching those of the
%          divergence object, with arrays converted to a fields of scalars:
%          angle => a1,a2,a3...  and profile => p1,p2,p3...
%           The arrays are padded with -Inf as required by the longest array
%
% This is a utility routine used in sorting.

% Create a structure with angle and profile arrays turned into scalars
% and concatenate with structure made from other fields of the object
nobj=numel(obj);
npnts=zeros(nobj,1);
for i=1:nobj
    npnts(i)=numel(obj(i).angle);
end
npnts_max=max(npnts);
ang=-Inf(npnts_max,nobj);
prof=-Inf(npnts_max,nobj);
for i=1:nobj
    ang(1:npnts(i),i)=obj(i).angle;
    prof(1:npnts(i),i)=obj(i).profile;
end
ang=ang';
prof=prof';

arg=cell(2,2*npnts_max);
for i=1:npnts_max
    arg{1,i}=['a',num2str(i)];
    arg{2,i}=num2cell(ang(:,i));
end
for i=1:npnts_max
    arg{1,npnts_max+i}=['p',num2str(i)];
    arg{2,npnts_max+i}=num2cell(prof(:,i));
end

S=catstruct(rmfield(struct(obj(:)),{'angle','profile'}),struct(arg{:}));
S=struct(arg{:});
