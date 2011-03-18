function list=dir_name_list(directory,varargin)
% Return list of files in a directory that satisfy a selection of filters
%   >> list = dir_name_list (directory)
%   >> list = dir_name_list (directory, include)
%   >> list = dir_name_list (directory, include, exclude)
%
% Input:
% --------
%   directory           Directory (full path)
%   include             List of file names to include (default: all)
%                       Format: e.g. 'temp.txt', 'te*.*; *mat*.m'
%                       If empty, then uses default
%   exclude             List of directory names to exclude (default: none)
%                       Format: e.g. 'temp.txt', 'te*.*; *mat*.m'
%
% Output:
% --------
%   list                Cell array of file names

% *** Ways to improve: can count the number of outputs rather than have arrays grow in loop
% *** Synchronise with equivalent routine for list of file names


if nargin==1
    include=pathstring_to_cellstr('');
    exclude=pathstring_to_cellstr('');
elseif nargin==2
    include=pathstring_to_cellstr(varargin{1});
    exclude=pathstring_to_cellstr('');
elseif nargin==3
    include=pathstring_to_cellstr(varargin{1});
    exclude=pathstring_to_cellstr(varargin{2});
end

% Get list of all files to search
include_all=(isempty(include)||(numel(include)==1 && strcmp(include{1},'*')));
exclude_none=isempty(exclude);
if include_all && exclude_none
    contents=dir(directory);
    list=contents_to_namecellstr(contents,find([contents.isdir]));
else
    if ~include_all
        list={};
        for i=1:numel(include)
            contents=dir(fullfile(directory,include{i}));
            list=[list,contents_to_namecellstr(contents,find([contents.isdir]))];
        end
    else
        contents=dir(directory);
        list=contents_to_namecellstr(contents,find([contents.isdir]));
    end
    if ~exclude_none
        excllist={};
        for i=1:numel(exclude)
            contents = dir(fullfile(directory,exclude{i}));
            ind = find([contents.isdir]);
            excllist=[excllist,contents_to_namecellstr(contents,ind)];
        end
        ind=array_keep(list,excllist);
        list=list(ind);
    end
end
