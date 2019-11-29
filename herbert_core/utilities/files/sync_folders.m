function sync_folders (p1, p2, syncdirect)
% Synchronise two folders and all their files and sub-folders. Ignores .svn folders.
%
%   >> sync_folders (p1, p2)
%   >> sync_folders (p1, p2, sync_direction)
%
%   p1, p2          Two folder names (absolute paths)
%
%   sync_direction  Controls the behaviour of the synchronisation
%
%       =0  Synchronisation takes place both ways, with the more recent
%           version of a common file being retained, and files in just one 
%           of the folders are copied to the other.
%
%       =1  The newer contents of p1 are copied to p2, that is, older versions
%           of files in p2 are replaced from p1, and files only in p1 are
%           copied to p2.
%
%       =2  'Hard' synchronisation: the same as above, but in addition files
%           in p2 that are not in p1 are deleted.
%
%       =-1 Same as 1 with the roles of p1 and p2 reversed
%           
%       =-2 Same as 2 with the roles of p1 and p2 reversed

% From Matlab file exchange:
% Copyright: zhang@zhiqiang.org, 2010
% Modified T.G.Perring 19 Jan 2013:
%   - make the help clearer
%   - name change from syncfolder to sync_folder
%   - ignore folders with name .svn

svn='.svn';

% the sync direct is two-way by default
if ~exist('syncdirect', 'var'), syncdirect = 0; end;
if ischar(syncdirect), syncdirect = str2double(syncdirect); end
tmpRecycle = recycle;
recycle on;

% if p1 or p2 is not a directory, then make one
p1=fullfile(p1);
p2=fullfile(p2);
try
    if ~isdir(p1), mkdir(p1); end
    if ~isdir(p2), mkdir(p2); end
catch ME
    error([p1 ' or ' p2 ' is not a directory']);    
end

% get the files and subdirectories, and sort them by alphabetically
files1 = sortstruct(dir(p1), 'name');
files2 = sortstruct(dir(p2), 'name');


%% compare the files and subdirectories one by one
nf1 = 1; nf2 = 1;
while nf1 <= numel(files1) || nf2 <= numel(files2)
    % deal with '.' and '..'
    if nf1 <= numel(files1) && ...
            (strcmpi(files1(nf1).name, '.') || strcmpi(files1(nf1).name, '..'))
        nf1 = nf1 + 1;
        continue;
    end
    if nf2 <= numel(files2) && ...
            (strcmpi(files2(nf2).name, '.') || strcmpi(files2(nf2).name, '..'))
        nf2 = nf2 + 1;
        continue;
    end
    
    % the same files or directories in p1 and p2
    if nf1 <= numel(files1) && nf2 <= numel(files2) && ...
            strcmpi(files1(nf1).name, files2(nf2).name)
        % the same directories, recursively syncfolder
        if files1(nf1).isdir
            if ~strcmpi(files1(nf1).name, svn)
                sync_folders(fullfile(p1, files1(nf1).name), fullfile(p2, files2(nf2).name), syncdirect)
            end
        else % the same files, copy the newer file to old file
            if files1(nf1).datenum > files2(nf2).datenum + 1.0/24/60
                if syncdirect >= 0
                    display(['''' fullfile(p1, files1(nf1).name) ''' --> ''' ...
                        fullfile(p2, files2(nf2).name) '''']);                    
                    copyfile(fullfile(p1, files1(nf1).name), fullfile(p2, files2(nf2).name), 'f');
                end
            elseif files1(nf1).datenum < files2(nf2).datenum - 1.0/24/60
                if syncdirect <= 0
                    display(['''' fullfile(p1, files1(nf1).name) ''' <-- ''' ...
                        fullfile(p2, files2(nf2).name) '''']);                            
                    copyfile(fullfile(p2, files2(nf2).name), fullfile(p1, files1(nf1).name), 'f');            
                end
            end
        end
        nf1 = nf1 + 1;
        nf2 = nf2 + 1;
    % a file or directory in p1 and not in p2
    elseif nf1 <= numel(files1) && ...
            (nf2 > numel(files2) || strcmpc(files1(nf1).name, files2(nf2).name) < 0)
        if files1(nf1).isdir % is a dir
            if ~strcmpi(files1(nf1).name, svn)
                if syncdirect >= 0
                    display(['''' fullfile(p1, files1(nf1).name) ''' --> ''' ...
                        p2, '''']);
                    mkdir( fullfile(p2, files1(nf1).name));
                    copyfile(fullfile(p1, files1(nf1).name), fullfile(p2, files1(nf1).name), 'f');
                elseif syncdirect <= -2 % this subdirectory will be deleted
                    rmdir(fullfile(p1, files1(nf1).name), 's');
                    display(['''' fullfile(p1, files1(nf1).name) '\'' is deleted']);
                end
            end
        else % is a file
            if syncdirect >= 0
                display(['''' fullfile(p1, files1(nf1).name) ''' --> ''' ...
                        p2,  '''']);                                
                copyfile(fullfile(p1, files1(nf1).name), p2, 'f');                
            elseif syncdirect <= -2 % this file will be deleted
                display(['''' fullfile(p1, files1(nf1).name) ''' is deleted']);
                delete(fullfile(p1, files1(nf1).name));
            end
        end
        nf1 = nf1 + 1;
        
    % a file or diretory in p2 not in p1
    elseif nf2 <= numel(files2) && ...
            (nf1 > numel(files1) || strcmpc(files2(nf2).name, files1(nf1).name) < 0)
        
        if files2(nf2).isdir % is a dir
            if ~strcmpi(files2(nf2).name, svn)
                if syncdirect <= 0
                    display(['''' p1, ''' <-- ''' ...
                        fullfile(p2, files2(nf2).name) '''']);
                    mkdir( fullfile(p1, files2(nf2).name));
                    copyfile(fullfile(p2, files2(nf2).name),  fullfile(p1, files2(nf2).name), 'f');
                elseif syncdirect >= 2 % this subdirectory will be deleted
                    display(['''' fullfile(p2, files2(nf2).name) '\'' is deleted']);
                    rmdir(fullfile(p2, files2(nf2).name), 's');
                end
            end
        else % is a file
            if syncdirect <= 0
                display(['''' p1 ''' <-- ''' ...
                        fullfile(p2, files2(nf2).name) '''']);   
                copyfile(fullfile(p2, files2(nf2).name), p1, 'f');                 
            elseif syncdirect >= 2 % this file will be deleted
                display(['''' fullfile(p2, files2(nf2).name) ''' is deleted']);                                
                delete(fullfile(p2, files2(nf2).name));
            end
        end
        nf2 = nf2 + 1;
    end
end


recycle(tmpRecycle);

%% sort a struct
function [sortedStruct index] = sortstruct(aStruct, fieldName, direction)
% [sortedStruct index] = sortStruct(aStruct, fieldName, direction)
% sortStruct returns a sorted struct array, and can also return an index
% vector. The (one-dimensional) struct array (aStruct) is sorted based on
% the field specified by the string fieldName. The field must a single
% number or logical, or a char array (usually a simple string).
%
% direction is an optional argument to specify whether the struct array
% should be sorted in ascending or descending order. By default, the array
% will be sorted in ascending order. If supplied, direction must equal 1 to
% sort in ascending order or -1 to sort in descending order.

%% check inputs
if ~isstruct(aStruct)
    error('first input supplied is not a struct.')
end % if

if sum(size(aStruct)>1)>1 % if more than one non-singleton dimension
    error('I don''t want to sort your multidimensional struct array.')
end % if

if ~ischar(fieldName) || ~isfield(aStruct, fieldName)
    error('second input is not a valid fieldname.')
end % if

if nargin < 3
    direction = 1;
elseif ~isnumeric(direction) || numel(direction)>1 || ~ismember(direction, [-1 1])
    error('direction must equal 1 for ascending order or -1 for descending order.')
end % if

%% figure out the field's class, and find the sorted index vector
fieldEntry = aStruct(1).(fieldName);

if (isnumeric(fieldEntry) || islogical(fieldEntry)) && numel(fieldEntry) == 1 % if the field is a single number
    [dummy index] = sort([aStruct.(fieldName)]);
elseif ischar(fieldEntry) % if the field is char
    [dummy index] = sort({aStruct.(fieldName)});
else
    error('%s is not an appropriate field by which to sort.', fieldName)
end % if ~isempty

%% apply the index to the struct array
if direction == 1 % ascending sort
    sortedStruct = aStruct(index);
else % descending sort
    sortedStruct = aStruct(index(end:-1:1));
end

function c = strcmpc(s1,s2)
% STRCMPC  - String comparison using C-convention
%	STRCMPC(S1,S2) returns :
%    < 0	S1 less than S2
%    = 0	S1 identical to S2
%    > 0	S1 greater than S2
%	See also STRCMP.

%	S. Helsen 23-09-96
%	Copyright (c) 1984-96 by VCST-VT

l=min(length(s1), length(s2));
if l==0
	if length(s1)
		c=1;
	else
		c=-1;
	end
	return
end
i=find(s1(1:l)~=s2(1:l));
if isempty(i)
	if length(s1)<length(s2)
		c=-1;
	elseif length(s1)==length(s2)
		c=0;
	else
		c=1;
	end
	return
end
i=i(1);
if s1(i)<s2(i)
	c=-1;
else
	c=1;
end

