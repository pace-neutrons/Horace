function list=list_tmp(varargin)
%
% does not work properly and is not completed
%
% function builds the list of the tmp files which corresponds to the input
% spe files
% the first argument: the list of spe files or the folder where these files
% reside
% the second argument (optional)
% the folder to place output tmp files; if not present, files will be
% placed in spe files folder
%
% $Revision: 271 $ ($Date: 2009-09-02 16:23:16 +0100 (Wed, 02 Sep 2009) $)
%

new_file_extention='tmp';
%
usage_string=...
['usage: list_tmp({spe_file list, folder with spe files},[folder to place tmp files])\n'...
 '****** where the first argument is the list of spe files or folder where these files reside and \n'...
 '****** the optional second argument is the folder where tmp files should be placed. If not present,\n'...
 '****** the tmp files will be placed into the spe files folder' ];
if(nargin==1)
    [spe_list,pathstr]=splitSpeList_fromPath_andReplaceExtention(varargin{1},new_file_extention,usage_string);
    list=build_list_in_theFolderGiven(spe_list,pathstr);
elseif(nargin == 2)
    [spe_list,pathstr]=splitSpeList_fromPath_andReplaceExtention(varargin{1},new_file_extention,usage_string);
    if(~isdir(varargin{2}))
        error('HORACE:wrongFunctionCall',' the folder %s does not exist', varargin{2});
%         disp(['directory' varargin{2}  'does not exist']);
%         user_entry = input(' would you like to create one (y) or use the folder %s instead (n)? (y/n/c):',pathstr);
%         switch lower(user_entry(1))
%             case('y')
%                 [folder_path,folder_name,folder_ext]=fileparts(varargin{2});
%                 if(strcmp(folder_path,'')) % folder is placed relatively to current one
%                     path
%                 else
%                 end
%             case('n')
%                  warning('HORACE:wrongFunctionCall',' using the directory %s where spe files reside for temporary files',pathstr);
%             otherwise
%                 error('HORACE:wrongFunctionCall',' the folder %s does not exist', varargin{2});
%         end;
    else
        if(regexp(varargin{2},filesep,'once')) % this is probably full path
            pathstr=varargin{2};
        else
            pathstr=[pwd,filesep,varargin{2}];
        end
    end
    list=build_list_in_theFolderGiven(spe_list,pathstr);
else
    error(usage_string);
end
end
%% ************************************************************************
function [spe_list, spe_path] = splitSpeList_fromPath_andReplaceExtention(...
                                spe_list_or_path,new_file_extention,usage_string)
    if(iscell(spe_list_or_path))
        filename=spe_list_or_path{1};
        spe_path = fileparts(filename);
        spe_list=spe_list_or_path;
    elseif(isdir(spe_list_or_path))
        spe_path = spe_list_or_path;
        spe_list=file_list(pathstr,'spe');
    else
        error(usage_string);
    end
    for i=1:length(spe_list)
        [spe_path, name] = fileparts(spe_list{i});
        if(~strcmp(name,''))
            spe_list{i}=[name,'.',new_file_extention];
        end
    end
end
%% ************************************************************************
function list=build_list_in_theFolderGiven(spe_list,output_folder)
    list=cell(1,length(spe_list));
    for i=1:length(spe_list)
        list{i}=[output_folder,filesep,spe_list{i}];
    end
end
