function varargout = get_spe_matlab(filename,varargin)
% Get signal, error and energy bin boundaries for spe file
%
%>> [S,ERR,en] = get_spe_matlab(filename,[info])
%Input:
%    filename   -- name ascii spe file to read infornation from
%    info       -- optional parameter -- if present, fuunction reads and
%                  returns enegy boundaries only when  S and ERR become
%   S=ne        -- number of energy bin and
%   ERR=ndet    -- number of detectors
%
%
%   S          [ne x ndet] array of signal values
%   ERR        [ne x ndet] array of error values (st. dev.)
%   en         Column vector of energy bin boundaries

% Original author: T.G.Perring
%
% $Revision:: 830 ($Date:: 2019-04-08 16:16:02 +0100 (Mon, 8 Apr 2019) $)
%
% Based on Radu coldea routine load_spe in mslice

filename=strtrim(filename); % Remove blanks from beginning and end of filename
if isempty(filename),
    error('Filename is empty')
end
fid=fopen(filename,'rt');
if fid==-1,
    error('LOADER_ASCII:get_spe_matlab',[' Can not open file ',filename]);
end
clob = onCleanup(@()fclose(fid));

% Read number of detectors and energy bins
ndet=fscanf(fid,'%d',1);
ne=fscanf(fid,'%d',1);
if isempty(ne)|| isempty(ndet)
    error('LOADER_ASCII:get_spe_matlab', ...
        ' file %s is not proper spe file as can not interpret ndet and ne parameters in first row',...
        filename);
end
if (ndet<0) || (ndet > 1e+32) || (ne<0) || (ne> 100000)
    error('LOADER_ASCII:problems_with_file','found ndet=%d and ne=%d when interpreting file %s',ndet,ne,filename);
end
temp=fgetl(fid);    % read eol
temp=fgetl(fid);    % read string '### Phi Grid'
temp=fscanf(fid,'%10f',ndet+1); % read phi grid, last value superfluous
temp=fgetl(fid);    % read eol character of the Phi grid table
temp=fgetl(fid);    % read string '### Energy Grid'
en=fscanf(fid,'%10f',ne+1); % read energy grid
%
if nargin > 1
    varargout{1}   = ne;
    if nargout>1
        varargout{2} = ndet;
    end
    if nargout>2
        varargout{3} = en;
    end
    return;
end


% Read data
S=zeros(ne,ndet);
ERR=zeros(ne,ndet);
try
    for i=1:ndet,
        temp  =fgetl(fid);        % read eol character
        s_text=fgetl(fid);        % get rid of line ### S(Phi,w)
        S(:,i)=fscanf(fid,'%10f',ne);
        temp  =fgetl(fid);        % read eol character
        temp  =fgetl(fid);        % get rid of line ### Errors
        ERR(:,i)=fscanf(fid,'%10f',ne);
    end
catch ME
    ME.message = ['IO error at: ',s_text,' reason: ',ME.message];
    rethrow(ME);
end
if nargout>0
    varargout{1}=S;
end
if nargout>1
    varargout{2}=ERR;
end
if nargout>2
    varargout{3}=en;
end

