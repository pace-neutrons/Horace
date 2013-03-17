function put_variable_to_binfile(fid,var)
% Write a variable to an already open binary file
%
%   >> put_variable_to_binfile(fid,var)
%
% Itput:
% ------
%   fid     File identifier of file already open for writing as binary
%
% Output:
% -------
%   var     Variable to be written. Can be an array. The contents are
%          written recursively, writing cell arrays, structure and objects
%          as required.
%
% To read the variable from a file, use
%   get_variable_from_binfile
%
% The reason for creating this routine is that it allows low level
% data access routines to be used to read the file. Normally just
% use the built-in Matlab load and save routines.

type=class(var);
sz=size(var);

if iscell(var)
    put_class(fid,type,sz)
    for i=1:numel(var)
        put_variable_to_binfile(fid,var{i})
    end
    
elseif isstruct(var)
    names=fieldnames(var);
    put_class(fid,type,sz)
    put_fnames(fid,names)
    for i=1:numel(var)
        for j=1:numel(names)
            put_variable_to_binfile(fid,var(i).(names{j}))
        end
    end
    
elseif isobject(var)
    names=fieldnames(var);
    put_class(fid,type,sz)
    put_fnames(fid,names)
    for i=1:numel(var)
        tmpvar=struct(var(i));
        for j=1:numel(names)
            put_variable_to_binfile(fid,tmpvar(i).(names{j}))
        end
    end
    
else
    class_type={'char','double','single','logical','int8','int16','int32','int64','uint8','uint16','uint32','uint64'};
    fmt={'char*1','float64','float32','ubit1','int8','int16','int32','int64','uint8','uint16','uint32','uint64'};
    ind=find(strcmp(type,class_type));
    if ~isempty(ind)
        put_class(fid,type,sz)
        fwrite(fid,var,fmt{ind});
    else
        error(['Cannot write class ''',type,''' to binary file'])
    end
end

%--------------------------------------------------------------------------
function put_class(fid,type,sz)
% Write the class name and array size. Note that neither can be empty
fwrite(fid,length(type),'double');
fwrite(fid,type,'char*1');
fwrite(fid,length(sz),'double');
fwrite(fid,sz,'double');

%--------------------------------------------------------------------------
function put_fnames(fid,names)
% Write the field names of a structure. Can be empty cell array
nn=numel(names);
fwrite(fid,nn,'double');
for i=1:nn
    fwrite(fid,length(names{i}),'double');
    fwrite(fid,names{i},'char*1');
end
