function rez = read (sqw_obj,varargin)
% Read sqw object from a file or array of sqw objects from a set of files
% 
%   >> w=read(sqw,file)
%
% Need to give first argument as an sqw object to enforce a call to this function.
% Can simply create a dummy object with a call to sqw:
%    e.g. >> w = read(sqw,'c:\temp\my_file.sqw')
%
% Input:
% -----
%   sqw         Dummy sqw object to enforce the execution of this method.
%               Can simply create a dummy object with a call to sqw:
%                   e.g. >> w = read(sqw,'c:\temp\my_file.sqw')
%
%   file        File name, or cell array of file names. In this case, reads
%               into an array of sqw objects
%
% Output:
% -------
%   w           sqw object, or array of sqw objects if given cell array of
%               file names

% Original author: T.G.Perring
%
% $Revision$ ($Date$)



% Perform operations
% ------------------
% Check number of arguments
if isempty(varargin)
    error('SQW:invalid_argument','read: Check number of input arguments')
end

if iscell(varargin)
    argi = varargin;
else
    argi = {varargin};
end
%
all_fnames = cellfun(@ischar,argi,'UniformOutput',true);
if ~any(all_fnames)
    error('SQW:invalid_argument','read: not all input arguments represent filenames')    
end

nw=numel(argi);
loaders = cell(1,nw);
for i=1:nw
    file = argi{i};
    loaders{i} = sqw_formats_factory.instance.get_loader(file);
end

trez = cell(1,nw);
% Now read data
for i=1:nw
    trez{i} = loaders{i}.get_sqw();
end

if nw == 1
    rez = trez{1};
    return
end

type_list = cellfun(@class,trez,'UniformOutput',false);
boss_type = type_list{1};
same_types = cellfun(@(x)strcmp(boss_type,x),type_list,'UniformOutput',true);
if all(same_types) % return array of the same type classes
    boss_class = feval(bt);
    rez = repmat(boss_class,1,nw);
    for i=1:nw
        rez(i) = trez{i};
    end
else % return cellarray of heterogeneous types
    rez = trez;
end