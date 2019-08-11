function [w,ok,mess]=get_map(filename)
% Read an ASCII .map file
%
%   >> [w,ok,mess]=get_map(filename)
%
% Input:
% ------
%   filename        Name of map file from which to read data
%
% Output:
% -------
%   w               Structure with the fields
%           ns      Row vector of number of spectra in erach workspace. There must be
%                  at least one workspace. ns(i)=0 is permitted (it means no spectra
%                  in ith workspace)
%           s       Row vector of spectrum indicies in workspaces concatenated together
%           wkno    Workspace numbers (think of them as the 'names' of the workspaces)
%
%   ok              =true if all OK; =false otherwise
%
%   mess            ='' if OK==true error message if OK==false
%
%
% Format of a map file:
% ---------------------
%       <nw (the number of workspaces)>
%       <wkno(1) (the workspace index number>
%       <no. spectra in 1st workspace>
%       <list of spectrum numbers across as many lines as required>
%           :
%       <wkno(2) (the workspace index number>
%       <no. spectra in 2nd workspace
%       <list of spectrum numbers across as many lines as required>
%           :
%       <wkno(nw) (the workspace index number>
%       <no. spectra in last workspace>
%       <list of spectrum numbers across as many lines as required>
%           :
%
% Blank lines and comment lines (lines beginning with ! or %) are skipped over
% Comments can also be put at the end of lines
%
% The old VMS format is also supported:
%   <nw (the number of workspaces)>
%   <no. spectra in 1st workspace>   <dummy value>   <dummy value>    <dummy value>
%   <list of spectrum numbers across as many lines as required>
%       :
%   <wkno(2) (the workspace index number>
%   <no. spectra in 2nd workspace>   <dummy value>   <dummy value>    <dummy value>
%   <list of spectrum numbers across as many lines as required>
%       :


% Remove blanks from beginning and end of filename
[file_tmp,ok,mess]=translate_read(strtrim(filename));
if ~ok
    w=[];
    return
end

% Read file (use matlab, as files are generally small, so Fortran or C++ code not really necessary)
str=strtrim(textcell(file_tmp));
nline=numel(str);
if nline==0
    w=[]; ok=false; mess='Data file is empty'; return
end

% Process data from file
% ----------------------
% Have a try...catch block so that wherever the failure takes place, the file can always be closed and the error thrown

% Skip over lines that begin with '!'
first_line = true;
nw = 0;
nstot=0;
iw = 1;
ns =-1;
fmt = '%d %g %g %g';    % read format until determine if VMS format or not
nval = 4;               % max number of values until determine if VMS format or not

i=1;
while i<=nline
    if first_line
        % Still need to read the number of workspaces
        nw = str_to_iarray(str{i});     % nw==0 means comment line
        i=i+1;
        if numel(nw)==1
            if nw >= 1
                nbuff= 1e2;             % initial buffer size for spectra
                nspec= zeros(1,nw);
                spec = zeros(1,nbuff);
                wkno = zeros(1,nw);     % to hold workspace number
                first_line = false;
            else
                w=[]; ok=false; mess='Check number of workspaces declared in first non-comment line'; return
            end
        elseif numel(nw>1)
            w=[]; ok=false; mess='Check format of map file'; return
        end
    else
        % Read information for each workspace
        if ns==-1   % Not yet read the number of spectra for the current workspace yet
            [wdata,count] = sscanf(str{i},fmt,nval);     % count==0 means comment line
            i=i+1;
            if count>0
                % If first workspace and not yet read any workspace information, determine format of map file
                if iw==1 && wkno(iw)==0  % first line for first workspace not yet processed
                    if count==1
                        vms_format=false;
                    elseif count==4
                        vms_format=true;
                    else
                        w=[]; ok=false; mess='Check format of .map file'; return
                    end
                    fmt='%d';
                    nval=1;
                end
                % If iw>nw, and we have read integers, then excess information
                if iw > nw
                    w=[]; ok=false; mess='Check format of .map file: excess uncommented information at bottom of file'; return
                end
                % Get workspace number (if not VMS format) and number of spectra
                if ~vms_format
                    if wkno(iw)==0  % haven't read workspace number yet
                        if wdata(1)<=0
                            w=[]; ok=false; mess='Workspace number must be greater or equal to 1'; return
                        end
                        wkno(iw)=wdata(1);
                    else
                        if wdata(1)<0
                            w=[]; ok=false; mess=['Check number of spectra declared for workspace ',num2str(wkno(iw))]; return
                        end
                        ns = wdata(1);
                        nrem = ns;
                    end
                else
                    wkno(iw)=iw;    % just 1,2,...nw
                    if wdata(1)<0
                        w=[]; ok=false; mess=['Check number of spectra declared for workspace ',num2str(wkno(iw))]; return
                    end
                    ns = wdata(1);
                    nrem = ns;
                end
                % Update total number of spectra, and increase spec array if necessary
                if ns>=0    % have read ns for the surrect workspace
                    nstot=nstot+ns;
                    if nstot>nbuff
                        spec=[spec,zeros(1,2*nstot-nbuff)];     % increase size of buffer to twice required total
                        nbuff=numel(spec);
                    end
                end
            end
            
        else    % Read spectrum numbers for the current workspace
            if ns>0
                nspec(iw)=ns;
                [spec_tmp,no_excess] = str_to_iarray(str{i},nrem);
                i=i+1;
                if ~isempty(spec_tmp)
                    spec(nstot-nrem+1:nstot-nrem+numel(spec_tmp))=spec_tmp;
                    nrem=nrem-numel(spec_tmp);
                end
                if nrem==0
                    if no_excess
                        % Get ready for next workspace
                        iw = iw + 1;
                        ns = -1;
                    else
                        w=[]; ok=false; mess=['Check number of spectra declared for workspace ',num2str(wkno(iw))]; return
                    end
                end
            else
                % Get ready for next workspace
                iw = iw + 1;
                ns = -1;
            end
        end
    end
end

% Reached end of file; check last workspace is complete
if ~((iw==nw+1 && ns==-1) || (iw==nw && ns==0))     % second condition allows for final workspace having zero spectra
    if iw<nw
        w=[]; ok=false; mess=['File contains data only up to workspace ',num2str(iw),' of ',num2str(nw)]; return
    elseif iw==nw && ns==-1
        w=[]; ok=false; mess=['File contains data only up to workspace ',num2str(iw-1),' of ',num2str(nw)]; return
    elseif nrem~=0
        w=[]; ok=false; mess=['Not all spectra are present for workspace number ',num2str(wkno(iw))]; return
    else
        w=[]; ok=false; mess='Unidentified error reading map file'; return
    end
end

% Repackage for output
if numel(spec)~=nstot
    spec=spec(1:nstot);     % remove the excess buffer space
end
w.ns=nspec;
w.s=spec;
if ~vms_format
    w.wkno=wkno;
else
    w.wkno=zeros(1,0);
end
