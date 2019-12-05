function [err,message] = merge_files(file1,file2,varargin)
%merge_files: combine two (text) files together and place them one after
%another
%
%Usage:
% this option modifies the first file and places second file after the first
%>>[err,reason]=merge_files(file1,file2)
% 
% this option takes first and second file and copies them to target file, 
% second file after the first one.
%>>[err,reason]=merge_files(file1,file2,file_to_merge_to)
%
%err     -- boolean value indicating the error, 0 if no or 1 if there is an
%           error
%reason  -- text value, explaining the reason for the error
%
% in case of error, if function called without right hand arguments, 
% the function will throw the error with ID 'MERGE_FILES:invalid_argument' 
% with error message explaning the reason for error.
%
% $Revision:: 838 ($Date:: 2019-12-05 14:56:03 +0000 (Thu, 5 Dec 2019) $)
%
throw = true;
if nargout>0
    throw = false;
end
err=false;
message='';

if ~exist(file1,'file')
    [err,message]=report_err(['first file to merge: ',file1,' do not exist'],throw);
    return
end
if ~exist(file2,'file')
    [err,message]=report_err(['second file to merge: ',file2,' do not exist'],throw);
    return
end

merge_inplace = true;
target_file=file1;
if nargin>2
    target_file=varargin{1};
    merge_inplace=false;
end

if merge_inplace
    ftid = fopen(target_file,'a');
else    
    ftid = fopen(target_file,'w');
end
if ftid <=0 
   [err,message]=report_err(['can not open target merge file: ',target_file],throw);        
end

if ~merge_inplace
    fs1id = fopen(file1,'r');
    if fs1id  <=0 
       [err,message]=report_err(['can not open first source file: ',file1],throw);        
    end
    cont =fread(fs1id);
    fwrite(ftid,cont);
    fclose(fs1id);
end

fs2id = fopen(file2,'r');
if fs2id  <=0 
  [err,message]=report_err(['can not open second source file: ',file2],throw);        
end
cont2 =fread(fs2id);
fwrite(ftid,cont2);
fclose(fs2id);
fclose(ftid);



function [err,message] = report_err(message,do_throw)

if do_throw
    error('MERGE_FILES:invalid_argument','%s',message);
else
    err=true;
end

