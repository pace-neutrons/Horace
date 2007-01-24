function [data, count_out, status_ok, message, fid] = fread_catch (fid, count_in, precision, skip, machineformat)
% Version of fread that catches errors, trie to re-read the file if possible,
% and allows for an error message to be passed back if fails to read.
%
% Input arguments same as built-in Matlab fread; there are optional additional output arguments
%
% To behave just as fread:
%   >> [data, count] = fread_catch (fid,...)
%
% To catch errors:
%   >> [data, count, status_ok] = fread_catch (fid)
%   >> [data, count, status_ok, message] = fread_catch (fid)
%               status_ok = 1 if OK, =0 otherwise
%               message = ''  if OK, =0 otherwise
%
% If a specified number of element
%   >> [data, count, status_ok] = fread_catch (fid, count,...)
%               status_ok(1) = 1 if OK, =0 otherwise
%               status_ok(2) = 1 if read the requested number of elements, =0 otherwise
%
% To catch errors and return an error message:


%
%   >> [data, count, status_ok, message] = fread_catch (fid, count,...)
%               message = '' if all(status_ok(1))=1  (i.e. status_ok(1)=status_ok(2)=1)
%                       = failure message of fread if status_ok(1)=0
%                       = message indicating count discrepancy if status_ok(2)=0
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
% $Revision$ ($Date$)

ntry_retry=6;   % maximum number of attempts to read before trying to reopen
ntry_reopen=6;  % further attempts with reopening

pos_initial = ftell(fid);   % location before attempt to read
ntry_max=ntry_retry+ntry_reopen;
ntry=1;
while ntry<=ntry_max
    ferror(fid,'clear');        % clear error status - we assume that all is OK before entry
    try
    % If several attempts, then getting serious... close file and reopen
        if ntry>=ntry_retry;  
            disp('...try closing and reopening file...')
            pause_time = max(2.5,0.1*ntry + 0.1*(ntry-ntry_retry)^2);
            pause(pause_time);     % pause to give time for a problem to settle down...   
            [flname,mode]=fopen(fid);
            fclose(fid);
            pause(pause_time);
            fid=fopen(flname,mode);
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
                pos_present = ftell(fid);
                if pos_present>0    % able to determine where in file is at present
                    fseek(fid,(pos_initial-pos_present),'cof');
                else
                    if nargin>=2; status_ok = [0,0]; else; status_ok = 0; end
                    message = ['Cannot determine location in file during read error recovery '...
                        '(attempt ',num2str(ntry),') - unrecoverable read error'];
                    disp(message)
                    return
                end
            else
                % if got this far, then should have read data succesfully
                if nargout>=3; if nargin>=2; status_ok = [1,1]; else; status_ok = 1; end; end
                if nargout>=4; message=''; end
                return
            end
        else
            disp(['Error reading from file, but no fatal error in fread (attempt ',num2str(ntry),...
                ') - trying to recover [',f_message,'  ',num2str(f_errnum),']'])
            ferror(fid,'clear');
            % try to go to location
            fseek(fid,pos_initial,'bof');
            [f_message2,f_errnum2] = ferror(fid);
            if f_errnum2~=0
                if ~exist('data'), data=[]; end
                if ~exist('count_out'), count_out=[]; end
                if nargin>=2; status_ok = [0,0]; else; status_ok = 0; end
                message = ['Unrecoverable read error (attempt ',num2str(ntry),') [',f_message2,'  ',num2str(f_errnum2),']'];
                disp(message)
                return
            end
        end

    catch
        tmp=lasterror;
        disp(['Error reading from file: Fatal error in fread (attempt ',num2str(ntry),') - trying to recover [',tmp.message,']'])
        ferror(fid,'clear');
        % try to go to location
        fseek(fid,pos_initial,'bof');
        [f_message2,f_errnum2] = ferror(fid);
        if f_errnum2~=0
            if ~exist('data'), data=[]; end
            if ~exist('count_out'), count_out=[]; end
            if nargin>=2; status_ok = [0,0]; else; status_ok = 0; end
            message = ['Unrecoverable read error (attempt ',num2str(ntry),') [',f_message2,'  ',num2str(f_errnum2),']'];
            disp(message)
            return
        end

    end
    ntry = ntry + 1;

end

if ~exist('data'), data=[]; end
if ~exist('count_out'), count_out=[]; end
if nargin>=2; status_ok = [0,0]; else; status_ok = 0; end
message = ['Unrecoverable read error after maximum no. tries (attempt ',num2str(ntry_max),')'];
disp(message)
if isempty(fopen(fid))
    disp ('     File not open')
end