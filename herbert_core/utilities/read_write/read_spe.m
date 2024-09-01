function varargout = read_spe(filename,varargin)
% Get signal, error and energy bin boundaries for spe file
%
%>> [S,ERR,en] = read_spe(filename,['-info_only'])
%Input:
%    filename   -- name ascii spe file to read infornation from
%
% Optional Input:
%    '-info_only'
%                -- if present, function reads and
%                   returns ne,ndet,en parameters only i.e.
%>> [ne,ndet,en] = read_spe(filename,'-info_only')
%
%   ne     - number of energy bin and
%   ndet   - number of detectors
%
% Otherwise Returns:
%
%   S          [ne x ndet] array of signal values
%   ERR        [ne x ndet] array of error values (st. dev.)
%   en         Column vector of energy bin boundaries
%


% Original author: T.G.Perring
%
%
% Based on Radu coldea routine load_spe in mslice
[ok,mess,info_ony] = parse_char_options(varargin,{'-info_only'});
if ~ok
    error('HERBERT:read_spe:invalid_argument',mess);
end

filename=strtrim(filename); % Remove blanks from beginning and end of filename
if isempty(filename)
    error('Filename is empty')
end
fid=fopen(filename,'rt');
if fid==-1
    error('HERBERT:read_spe:invalid_argument',[' Can not open file ',filename]);
end
clob = onCleanup(@()fclose(fid));

% Read number of detectors and energy bins
ndet=fscanf(fid,'%d',1);
ne  =fscanf(fid,'%d',1);
if isempty(ne)|| isempty(ndet)
    error('HERBERT:read_spe:invalid_argument', ...
        ' file %s is not proper spe file as can not interpret ndet and ne parameters in first row',...
        filename);
end
if (ndet<0) || (ndet > 1e+32) || (ne<0) || (ne> 100000)
    error('HERBERT:read_spe:runtime_error',...
        'found ndet=%d and ne=%d when interpreting file %s',ndet,ne,filename);
end
temp=fgetl(fid);    % read eol
temp=fgetl(fid);    % read string '### Phi Grid'
temp=fscanf(fid,'%10f',ndet+1); % read phi grid, last value superfluous
temp=fgetl(fid);    % read eol character of the Phi grid table
temp=fgetl(fid);    % read string '### Energy Grid'
en=fscanf(fid,'%10f',ne+1); % read energy grid
%
if info_ony
    varargout{1}   = ne;
    if nargout>1
        varargout{2} = ndet;
    end
    if nargout>2
        varargout{3} = en;
    end
    return;
end
%
fw = config_store.instance().get_value('hor_config','spe_file_en_transf_field_width');
fmt = ['%',num2str(fw),'f'];

% Read data
S=zeros(ne,ndet);
ERR=zeros(ne,ndet);
try
    for i=1:ndet
        temp  =fgetl(fid);        % read eol character
        s_text=fgetl(fid);        % get rid of line ### S(Phi,w)
        S(:,i)=fscanf(fid,fmt,ne);
        temp  =fgetl(fid);        % read eol character
        temp  =fgetl(fid);        % get rid of line ### Errors
        ERR(:,i)=fscanf(fid,fmt,ne);
    end
catch ME
    error('HERBERT:loader_ascii:io_error', ...
        'Error reading file %s, issue: %s',filename,ME.message);
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
