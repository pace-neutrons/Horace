function mess_out = ass (source_in)
% Sets a run number, dae or crpt as data source
%
%   >> ass (123)
%   >> ass ('dae')
%   >> ass ('crpt')
%
%   >> ass 123
%   >> ass dae
%   >> ass crpt
%
%   >> mess = ass ...   % if error, fill error message (mess is empty if all OK) rather than throw error

global mgenie_globalvars

% Determine failure mode and set default return argument
mess='';
if nargout==1, fail_on_error=0; else fail_on_error=1; end

% Get input argument, evaluating in caller workspace if necessary
if nargin==1
    if isstring(source_in) && ~strcmpi(source_in,'crpt') && ~strcmpi(source_in,'dae')
        try
            source=evalin('caller',source_in);
        catch
            source=source_in;
        end
    else
        source=source_in;
    end
else
    mess = 'Command must have one argument';
    if fail_on_error, error(mess); else mess_out=mess; return; end
end

% Assign data source
if isnumeric(source) && isscalar(source)
    [run_char,mess]=runno_char(source);
    if ~isempty(mess)
        if fail_on_error, error(mess); else mess_out=mess; return; end
    end
    src=mgenie_globalvars.source;
    if ~(isempty(src.inst)||isempty(src.ext))
        file_in=make_file(src.disk, src.dir, [src.inst,run_char], src.ext);
        [filename,ok,mess]=translate_read(file_in);
        if ~ok
            if fail_on_error, error(mess); else mess_out=mess; return; end
        end
    else
        mess='Instrument and/or extension not assigned';
        if fail_on_error, error(mess); else mess_out=mess; return; end
    end
    mgenie_globalvars.source.run=source;
    mgenie_globalvars.source.run_char=run_char;
    mgenie_globalvars.source.filename=filename;
    % Replace \ with / in file name to avoid genie silliness.
    filename_translated=strrep(filename,'\\','/');
    filename_translated=strrep(filename_translated,'\','/');
    genie_perform_command(['set/file/input "',filename_translated,'"']);
    
elseif isstring(source_in) && strcmpi(source_in,'crpt')
    % *** Not sure if this is the best way to do it
    genie_perform_command('assign $crpt')
    
elseif isstring(source_in) && strcmpi(source_in,'dae')
    % *** Not sure if this is the best way to do it
    genie_perform_command('assign $dae')
    
else
    mess='Check input argument to assign data source';
    if fail_on_error, error(mess); else mess_out=mess; return; end
    
end

% All was OK if reach this point
if nargout==1, mess_out=mess; end


% -------------------------------------------------------------------------------------------------
function [runchar,mess]=runno_char(runno)
% Convert run number into character string
% Assumes ISIS format i.e. 5 digits or 8 digits, i.e.
%  - if       0 <= runno <= 99999       padded with zeros to make 5 characters long
%  - if  100000 <= runno <= 99999999    padded with zeros to make 8 characters long

if runno<0
    runchar=''; mess='Run number must be in the range 0-99999999'; return
elseif runno<=99999
    ndigits=5;
elseif runno<=99999999
    ndigits=8;
else
    runchar=''; mess='Run number must be in the range 0-99999999'; return
end

runchar = num2str(runno);
xlen = ndigits - length(runchar);
if xlen > 0
    runchar = [repmat('0', 1, xlen) runchar];
end
mess='';

% -------------------------------------------------------------------------------------------------
function file = make_file (disk, dir, filename, ext)
% Construct file name

path=fullfile(disk,dir);
file_in=[filename,'.',ext];
if ~isempty(path)
    ind=strfind(path,':::');
    if ~isempty(ind) && numel(ind)==1 && ind>1 && ind==numel(path)-2
        path=path(1:ind-1);
    end
    ind=strfind(path,':');
    if ~isempty(ind) && numel(ind)==1 && ind>1 && ind==numel(path)
        path=path(1:ind-1);
    end
    % Now, could be a global path, environment variable, or disk ('c:')
    if existgpath(path) || ~isempty(getenv(path))
        file=[path,':',file_in];
    else
        file=fullfile(path,file_in);
    end
else
    file=file_in;
end
