function [ufunc,func]=funcs_on_path (root_folder)
% Get a list of functions on the matlab path in a root folder and its subfolders

% Get all the folders on the path as a cell array of strings
pathstring=path;
ind=[0,strfind(pathstring,pathsep),numel(pathstring)+1];
np=numel(ind)-1;
pstr=cell(1,np);
for i=1:np
    pstr{i}=pathstring(ind(i)+1:ind(i+1)-1);
end

% Keep only those that start with root_folder
if root_folder(end:end)==filesep, root_folder=root_folder(1:end-1); end
ind=strncmpi(root_folder,pstr,numel(root_folder));
pstr=pstr(ind);

% Create a list of function names
ext={'m','p','mexw64','mexw32'};
dirfunc=struct([]);
for i=1:numel(pstr)
    for j=1:numel(ext)
        dirfunc=[dirfunc;dir([pstr{i},filesep,'*.',ext{j}])];
    end
end

func=cell(numel(dirfunc),1);
for i=1:numel(func)
    func{i}=dirfunc(i).name;
end
func=sort(func);

% Find overloaded functions
ufunc=cell(size(func));
for i=1:numel(ufunc)
    [dum1,ufunc{i}]=fileparts(func{i});
end

ufunc=unique(ufunc);
if numel(ufunc)~=numel(func)
    disp('WARNING: One or more functions are superceded by another earlier in the path')
end
