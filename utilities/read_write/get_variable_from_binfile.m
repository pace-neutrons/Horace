function var=get_variable_from_binfile(fid)
% Read a variable, written by put_variable_to_binfile, from an already open binary file
%
%   >> var=get_variable_from_binfile(fid)
%
% Input:
% ------
%   fid     File identifier of file already open for reading as binary
%
% Output:
% -------
%   var     Variable to be read. Can be an array. The contents are
%          read recursively, writing cell arrays, structure and objects
%          as required.
%
% To write the variable to a file, use
%   put_variable_to_binfile
%
% The reason for creating this routine is that it allows low level
% data access routines to be used to write the file. Normally just
% use the built-in Matlab load and save routines.

[type,sz]=get_class(fid);

if strcmp(type,'cell')
    var=cell(sz);
    for i=1:prod(sz)
        var{i}=get_variable_from_binfile(fid);
    end
    
elseif strcmp(type,'struct')
    names=get_fnames(fid);
    if ~isempty(names)
        var=repmat(cell2struct(cell(numel(names),1),names,1),sz);   % works for any sz (including zero dimensions)
        for i=1:prod(sz)
            for j=1:numel(names)
                var(i).(names{j})=get_variable_from_binfile(fid);
            end
        end
    else    % can have no field names
        if isequal(sz,[0,0])
            var=struct([]);
        elseif isequal(sz,[1,1])
            var=struct;
        else
            var=repmat(struct,sz);  % this is the way to get arbitrary size, not with struct([])
        end
    end
    
else
    class_type={'char','double','single','logical','int8','int16','int32','int64','uint8','uint16','uint32','uint64'};
    fmt={'*char*1','float64=>double','float32=>single','ubit1=>logical','int8','int16','int32','int64','uint8','uint16','uint32','uint64'};
    ind=find(strcmp(type,class_type));
    if ~isempty(ind)
        var=fread(fid,sz,fmt{ind});
    else
        % Must be a user defined class
        names=get_fnames(fid);
        var=make_object(type,sz);
        if ~isempty(var)     % not recognised as an object
            tmpvar=cell2struct(cell(numel(names),1),names,1);
            for i=1:prod(sz)
                for j=1:numel(names)
                    tmpvar.(names{j})=get_variable_from_binfile(fid);
                end
                var(i)=make_object(type,tmpvar);
            end
        else
            disp(['WARNING: unable to create object of type ''',type,'''. Creating structure instead.'])
            var=repmat(cell2struct(cell(numel(names),1),names,1),sz);
            for i=1:prod(sz)
                for j=1:numel(names)
                    var(i).(names{j})=get_variable_from_binfile(fid);
                end
            end
        end
    end
end

%--------------------------------------------------------------------------
function [type,sz]=get_class(fid)
% Read the class name and array size. Note that neither can be empty
nchar=fread(fid,1,'double');
type=fread(fid,[1,nchar],'*char*1');
nel=fread(fid,1,'double');
sz=fread(fid,[1,nel],'double');

%--------------------------------------------------------------------------
function names=get_fnames(fid)
% Read the field names of a structure. Can be empty cell array
nn=fread(fid,1,'double');
names=cell(nn,1);
for i=1:nn
    nchar=fread(fid,1,'double');
    names{i}=fread(fid,[1,nchar],'*char*1');
end

%--------------------------------------------------------------------------
function this=make_object(classname,arg)
% Create an instance of the object with provided name. 
%
%   >> this=make_object(classname)          % default object (scalar)
%   >> this=make_object(classname,sz)       % array of default objects with given size
%   >> this=make_object(classname,struct)   % single instance filled from a structure
%
% Assumes
%   - the constructor returns a valid object if given no input arguments,
%   - the constructor can create a single instance from a structure
fh=str2func(classname);
if nargin==2 && isstruct(arg)
    this=fh(arg);
else
    try
        this=fh();
    catch
        this=[];
        return
    end
    if nargin==2
        try
            this=repmat(this,arg);
        catch
            % Generic way of making an array of objects - I think
            % (works with libisis objects, for which repmat doesn't work)
            this(arg)=this;
        end
    end
end
