function [data, count_out, status_ok, message] = fread_catch (fid, count_in, precision, skip, machineformat)
% Version of fread that catches errors, trie to re-read the file if possible,
% and allows for an error message to be passed back if fails to read.
%
% Input arguments same as built-in Matlab fread; there are optional additional output arguments
%
% To behave just as fread, but having several attempts to read the data before giving up:
%   >> [data, count] = fread_catch (fid,...)
%   >> [data, count] = fread_catch (fid, count_in)
%   >> [data, count] = fread_catch (fid, count_in, precision)
%   >> [data, count] = fread_catch (fid, count_in, precision, skip)
%   >> [data, count] = fread_catch (fid, count_in, precision, skip, machineformat)
%
% Output error messages as well:
%   >> [data, count, status_ok] = fread_catch (fid,...)
%   >> [data, count, status_ok, message] = fread_catch (fid,...)
%               status_ok = 1 if OK, =0 otherwise
%               message = ''  if OK, =0 otherwise
%
% The purpose of fread_catch is to have a graceful way of catching errors. The most
% common use will be to return if unable to read the required number of elements or
% there is either a failure in fread, for example:
%
%   function [data, mess] = my_read_routine (fid)
%       :
%   [data, count, ok, mess] = fread (fid, [n1,n2], 'float32');
%   if ~all(ok)
%       return
%   end

% Original author: T.G.Perring
%
% $Revision:: 1750 ($Date:: 2019-04-09 10:04:04 +0100 (Tue, 9 Apr 2019) $)

ntry_retry=6;   % maximum number of attempts to read before trying to reopen
ntry_reopen=6;  % further attempts with reopening

% cache value for old Matlab
persistent old_matlab;
if isempty(old_matlab)
    old_matlab  = verLessThan('matlab','8.1');
end
    

if old_matlab
    count_in = double(count_in);
end

pos_initial = ftell(fid);   % location before attempt to read
ntry_max=ntry_retry+ntry_reopen;
ntry=1;
while ntry<=ntry_max
    ferror(fid,'clear');        % clear error status - we assume that all is OK before entry
    try
        % If several attempts, then getting serious... close file and reopen
        if ntry>=ntry_retry
            disp('...try closing and reopening file...')
            pause_time = max(2.5,0.1*ntry + 0.1*(ntry-ntry_retry)^2);
            pause(pause_time);     % pause to give time for a problem to settle down...
            [flname,mode]=fopen(fid);
            fid_old = fid;
            fclose(fid);
            pause(pause_time);
            fid=fopen(flname,mode);
            if fid~=fid_old
                if ~exist('data','var'), data=[]; end
                if ~exist('count_out','var'), count_out=[]; end
                status_ok = 0;
                message = ['Unrecoverable read error - cannot reopen file (attempt ',num2str(ntry_max),')'];
            end
            fseek(fid,pos_initial,'bof');
        end
        if nargin==1
            [data,count_out] = fread(fid);
        elseif nargin==2
            [data,count_out] = fread(fid,count_in);
        elseif nargin==3
            [data,count_out] = fread(fid,count_in,precision);
        elseif nargin==4
            [data,count_out] = fread(fid,count_in,precision,skip);
        elseif nargin==5
            [data,count_out] = fread(fid,count_in,precision,skip,machineformat);
        end
        
        % catch any other error reading (may have in fact gone to the catch part of this try..catch, but just in case)
        [f_message,f_errnum] = ferror(fid);
        if f_errnum==0
            % Errors that are not picked up by ferror:
            if nargin>=2 && (prod(count_in)~=inf && prod(count_out)~=prod(count_in))
                % error occurs if doesn't read the number of requested items (had this happen, but no error reported by ferror!)
                disp(['Failed to read requested number of items - trying to recover (attempt ',num2str(ntry),')...'])
                pause(0.1);
                pos_present = ftell(fid);
                if pos_present>0    % able to determine where in file is at present
                    fseek(fid,(pos_initial-pos_present),'cof');
                else
                    status_ok = 0;
                    message = ['Cannot determine location in file during read error recovery '...
                        '(attempt ',num2str(ntry),') - unrecoverable read error'];
                    disp(message)
                    return
                end
            else
                % if got this far, then should have read data succesfully
                if nargout>=3; status_ok = 1; end
                if nargout>=4; message=''; end
                return
            end
        else
            disp(['Error reading from file, but no fatal error in fread (attempt ',num2str(ntry),...
                ') - trying to recover [',f_message,'  ',num2str(f_errnum),']'])
            pause(0.1);
            ferror(fid,'clear');
            % try to go to location
            fseek(fid,pos_initial,'bof');
            [f_message2,f_errnum2] = ferror(fid);
            if f_errnum2~=0
                if ~exist('data','var'), data=[]; end
                if ~exist('count_out','var'), count_out=[]; end
                status_ok = 0;
                message = ['Unrecoverable read error (attempt ',num2str(ntry),') [',f_message2,'  ',num2str(f_errnum2),']'];
                disp(message)
                return
            end
        end
        
    catch Err
        disp(['Error reading from file: Fatal error in fread (attempt ',num2str(ntry),') - trying to recover [',Err.message,']'])
        ferror(fid,'clear');
        check_ifVersion_supportsSize(prod(count_in));
        % try to go to location
        fseek(fid,pos_initial,'bof');
        [f_message2,f_errnum2] = ferror(fid);
        if f_errnum2~=0
            if ~exist('data','var'), data=[]; end
            if ~exist('count_out','var'), count_out=[]; end
            status_ok = 0;
            message = ['Unrecoverable read error (attempt ',num2str(ntry),') [',f_message2,'  ',num2str(f_errnum2),']'];
            disp(message)
            return
        end
        
    end
    ntry = ntry + 1;
    
end

if ~exist('data','var'), data=[]; end
if ~exist('count_out','var'), count_out=[]; end
status_ok = 0;
message = ['Unrecoverable read error after maximum no. tries (attempt ',num2str(ntry_max),')'];
disp(message)
if isempty(fopen(fid))
    disp ('     File not open')
end


%-----------------------------------------------------------------------------------------------
function  check_ifVersion_supportsSize(size)
if(size<2^32-1)
    return;
end

version_field=regexp(version,'\.','split');
if(str2double(version_field{1})>=7)
    if(str2double(version_field{2})<5)
        error(' The array you are trying to read is bigger then 2^32-2 but Matlab version lower then 7.5 does not support such arrays')
    end
else
    error(' The array you are trying to read is bigger then 2^32-2 but Matlab version lower then 7.5 does not support such arrays')
end
