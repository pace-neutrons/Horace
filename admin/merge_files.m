function [err,message] = merge_files(file1,file2,varargin)
%merge_files: combine two (text) files together
%
%
% $Revision$ ($Date$)
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
