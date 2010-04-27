function [found,exactGroupName,globalGroupName] = findGroupRecursively(fileinfo,group_name,globalGroupName)
% the function recursively scans the structure fileinfo for entry, which
% starts with group_name and may contain sign _ and auxiliarly group number 
% and returns group ID to access this group.
%
% if number of similar group exists, the function returns the first deepest
% group
%
% inputs:
% fileinfo   -- the structure returned by Matlab function hdf5info(file,'ReadAttributes',true)
% group_name -- the name of the group to look for
% globalGroupName -- the name of the group calculated in relation to the top file group e.g.
%                     c:/aaa/bbb/ddd/group_name
%                    
% 
% outputs:
% found          -- the boolean parameter indicating if the group has been
%                   found

% exactGroupName -- the name of the group combined with the instance of the
%                   group e.g. exactGroupName_XXX where XXX is the number
%                   of the instance
%
% $Revision$ ($Date$)
%
found      = false;
nameLength = length(group_name);
if isfield(fileinfo,'Name')        
        if strncmp(fileinfo.Name,group_name,nameLength)
            exactGroupName=fileinfo.Name;
            found = true; 
            return
        end
end

if isfield(fileinfo,'Groups')
    if ~isempty(fileinfo.Groups)
        gf = fileinfo.Groups;
        for i=1:numel(gf)
          globalGroupName = [globalGroupName,gf(i).Name];        
          [found,exactGroupName,globalGroupName]=findGroupRecursively(fileinfo.Groups,group_name,globalGroupName);        
         if found
             break;
         end
        end
    end
end




