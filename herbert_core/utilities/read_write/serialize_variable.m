function byte_buf=serialize_variable(var,byte_buf)
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

class_name = class(var);

if numel(byte_buf) ==0
    byte_buf = cell(1,1); 
else
    byte_buf{end+1} = {};
end

if iscell(var)
    
    for i=1:numel(var)
        byte_buf = serialize_variable(var{i},byte_buf);
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
    % 19 Sep 2014, TGP: change 'ubit1' to 'ubit8'
    class_type={'char','double','single','logical','int8','int16','int32','int64','uint8','uint16','uint32','uint64'};
    fmt={'char*1','float64','float32','ubit8','int8','int16','int32','int64','uint8','uint16','uint32','uint64'};
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
fwrite(fid,length(type),'float64');
fwrite(fid,type,'char*1');
fwrite(fid,length(sz),'float64');
fwrite(fid,sz,'float64');

%--------------------------------------------------------------------------
function put_fnames(fid,names)
% Write the field names of a structure. Can be empty cell array
nn=numel(names);
fwrite(fid,nn,'float64');
for i=1:nn
    fwrite(fid,length(names{i}),'float64');
    fwrite(fid,names{i},'char*1');
end
