function list=dir_name_list(directory,varargin)
% Return list of directories in a directory that satisfy a selection of filters. Works on PC or Unix
%
%   >> list = dir_name_list (directory)
%   >> list = dir_name_list (directory, include)
%   >> list = dir_name_list (directory, include, exclude)
%
% Input:
% --------
%   directory           Directory (full path)
%   include             List of directory names to include (default: all)
%                      (If empty, then uses default)
%                       Format: e.g. 'temp', 'te*; *mat*'
%                       If empty, then uses default
%   exclude             List of directory names to exclude (default: none)
%                      (If empty, then uses default)
%                       Format: e.g. 'temp', 'te*; *mat*'
%
% Output:
% --------
%   list                Cell array of directory names

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
    contents=dir(directory);
    list_all=contents_to_namecellstr(contents,find([contents.isdir]));
    if ~include_all
        list={};
        for i=1:numel(include)
            if ~isempty(strfind(include{i},'*'))
                contents=dir(fullfile(directory,include{i}));   % appropriately ignores case for PC systems
                list=[list,contents_to_namecellstr(contents,find([contents.isdir]))];
            else
                if ispc
                    ind=find(strcmpi(include{i},list_all));
                else
                    ind=find(strcmp(include{i},list_all));
                end
                if ~isempty(ind)
                    list=[list,list_all{ind}];
                end
            end
        end
    else
        contents=dir(directory);
        list=contents_to_namecellstr(contents,find([contents.isdir]));
    end
    if ~exclude_none
        excllist={};
        for i=1:numel(exclude)
            if ~isempty(strfind(exclude{i},'*'))
                contents = dir(fullfile(directory,exclude{i})); % appropriately ignores case for PC systems
                excllist=[excllist,contents_to_namecellstr(contents,find([contents.isdir]))];
            else
                if ispc
                    ind=find(strcmpi(exclude{i},list_all));
                else
                    ind=find(strcmp(exclude{i},list_all));
                end
                if ~isempty(ind)
                    excllist=[excllist,list_all{ind}];
                end
            end
        end
        ind=array_keep(list,excllist);
        list=list(ind);
    end
end
