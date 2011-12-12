function p = gen_System_path(d)
% Generate recursive toolbox path.  Differs from the standard Matlab
% function genpath as it works  excluding from the path subversion (.svn) folders
% (it seems,  this is relevant for Windows only, as unix ignores them anyway)
%
% It also analyses and usually ignores the folders, which names start with underscore _
% but if the name of this folder corresponds to the Matlab name of the system running on the machine
% it adds this folder to the path.
%
% In addition to the above, the function analyses the current matlab version
% and appends to the path only to the folders with names relevant to the
% current MATLAB version. 
% The function also copies the dll=s which are prererquested for the application, and
% reside in the system folder to the location where the application can
% access these DLL

% Otherwise, it behaves like normal genpath,
% namely:
%
%   P = GENPATH returns a new path string by adding all the subdirectories
%   of MATLABROOT/toolbox, including empty subdirectories.
%
%   P = GENPATH(D) returns a path string starting in D, plus, recursively,
%   all the subdirectories of D, including empty subdirectories.
%
%   NOTE 1: GENPATH will not exactly recreate the original MATLAB path.
%
%   NOTE 2: GENPATH only includes subdirectories allowed on the MATLAB
%   path.
%
%   See also PATH, ADDPATH, RMPATH, SAVEPATH.

%   Copyright 1984-2006 The MathWorks, Inc.
%   Modified in ISIS
%
%   Libisis:
%   $Revision$ $Date$
%------------------------------------------------------------------------------
if nargin==0,
  p = genpath(fullfile(matlabroot,'toolbox'));
  if length(p) > 1, p(end) = []; end % Remove trailing pathsep
  return
end


% initialise variables
classsep = '@';      % qualifier for overloaded class directories
packagesep = '+';    % qualifier for overloaded package directories
CVS        = '.svn'; % qualifier for subversion folder
serviceDir    = '_';
p = '';                % path to be returned

% Generate path based on given root directory
files = dir(d);
if isempty(files)
  return
end
% modify last system version files
%--->   THERE ARE NO SUCH FUNCTIONS AT THE MOMENT    
%    % replace or susbstitute version specific functios here
%    % with their version specific equivalents;
%     isfile = ~logical(cat(1,files.isdir));
%     my_files  = files(isfile);
%     file_names={my_files(:).name};   
%     if verLessThan('matlab', '7.11.0') 
%         fun_to_replace={'isrow_.m','iscolumn_.m'};  
%         fun_replacements={'isrow.m','iscolumn.m'};
%         if any(ismember(file_names,fun_to_replace))
%             run_replacement(fun_to_replace,fun_replacements,d);
%         end
%     else % matlab high version has such functions;
%         fun_to_replace={'isrow.m','iscolumn.m'};        
%         fun_replacements={'isrow_.m','iscolumn_.m'};        
%         if any(ismember(file_names,fun_to_replace))
%             run_replacement(fun_to_replace,fun_replacements,d);
%         end                  
%     end


% Add d to the path even if it is empty.
p = [p d pathsep];

% set logical vector for subdirectory entries in d
isdir = logical(cat(1,files.isdir));
%
% Recursively descend through directories which are neither
% private nor "class" directories.
%
dirs = files(isdir); % select only directory entries from the current listing

for i=1:length(dirs)
   dirname = dirs(i).name;
   if    ~strcmp( dirname,'.')           && ...
         ~strcmp( dirname,'..')          && ...
         ~strcmp( dirname,CVS)           && ...
         ~strncmp( dirname,classsep,1)   && ...
         ~strncmp( dirname,packagesep,1) && ...
         ~strcmp( dirname,'private')
          if(~strncmp(dirname,serviceDir,1))
            p = [p gen_System_path(fullfile(d,dirname))]; % recursive calling of this function.
          else
             if(OS_Corresponds2Directory(dirname))
                      dirName = fullfile(d,dirname);
                    %addpath(dirName);
                    [VersionFolderName,versionDLLextention]=matlab_version_folder(dirname);
                    if(strncmpi(dirname,'_PCWIN',6)) % under windows copy the contents of the VersionFolderName to the current folder
                        p = [p dirName pathsep];                      
                        sourceName=fullfile(dirName,VersionFolderName);
                        CopyDLLPrerequested(sourceName,dirName,versionDLLextention);
                    else  % under other os add the folder to the search path
                        % And move libisis executive, if found in the upper
                        % folder directory, into the version specifie
                        % directory
                        libisis_name = fullfile(dirName,['libisisexc.' versionDLLextention]);
                        dirName      = fullfile(dirName,VersionFolderName);                        
                        if exist(libisis_name ,'file')
                            movefile(libisis_name,fullfile(dirName,['libisisexc.' versionDLLextention]),'f');
                        end                                                   
                        p = [p dirName pathsep];
                    end
             end
         end
   end
end
%% -----------------------------------------------------------------------------
function status =run_replacement(fun_to_replace,fun_replacements,dir)
for i=1:numel(fun_to_replace)
%    try
     status =movefile(fullfile(dir,fun_to_replace{i}),fullfile(dir,fun_replacements{i}),'f');
%    catch
%    end
end
%% --------------------------------------------------------------------------

function true_false=OS_Corresponds2Directory(dirname)
true_false=strcmpi(['_',computer],dirname);
%% --------------------------------------------------------------------------


%--------------------------------------------------------------------------
function copyFileList(sourcePath,destPath,filelist)
% set logical vector for files entries in 
isfile = ~logical(cat(1,filelist.isdir));
fileList = filelist(isfile); % select only files from the current listing

for i=1:length(fileList)
    [path,name,ext]=fileparts(fileList(i).name);
    destFile  = [destPath,filesep,name,ext];
    if(exist(destFile,'file'))
        fileInfo=dir(destFile);
        if(fileInfo.bytes==fileList(i).bytes) % the file we want to copy is 
                            %probably the same as the one already there;
            continue;       % skip copying;                
        end
    end
    [success,message]=copyfile([sourcePath,filesep,fileList(i).name],destFile,'f');   
    if(~success)
       warning([' Can not copy file: %s, to its working destination,\n', ... 
                ' copyfile returned message: %s \n ', ...
                ' installation may not work properly\n'],fileList(i).name,message);       
    end

end


function CopyDLLPrerequested(sourcePath,destPath,fileExtension)
% copying the mex-files from the folder 1 (OSFolderPath) to folder 2 (dirName)
% Generate mex list based on given root directory and file extension
%


    mex_s = dir([sourcePath,filesep,'*',fileExtension]);
    copyFileList(sourcePath,destPath,mex_s);

    %
    % Generate dll list based on given root directory
    dlls = dir([sourcePath,filesep,'*.dll']);
    if isempty(dlls)
        return
    end   
    copyFileList(sourcePath,destPath,dlls);   



