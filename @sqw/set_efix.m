function varargout = set_efix(varargin)
% Set the fixed neutron energy for an array of sqw objects.
%
%   >> wout = set_efix(win, efix)
%   >> wout = set_efix(win, efix, emode)
%
% Input:
% ------
%   win         Array of sqw objects of sqw type
%   efix        Value or array of values of efix. If an array, all sqw
%              objects must have the same number of contributing spe data sets
%   emode       [Optional] Energy mode: 1=direct inelastic, 2=indirect inelastic, 0=elastic
%
% Output:
% -------
%   wout        Output sqw objects


% Original author: T.G.Perring
%
% $Revision$ ($Date$)


% Parse input
% -----------
[w, args, mess] = horace_function_parse_input (nargout,varargin{:});
if ~isempty(mess), error(mess); end


% Perform operations
% ==================
narg=numel(args);
if narg<1 || narg>2
    error('Check number of input arguments')
end
if narg>=1
    efix=args{1}(:);
    if ~(isnumeric(efix) && numel(efix)>=1 && all(isfinite(efix)) && all(efix>=0))
        error('efix must be numeric scalar or array of finite values')
    end
end
if narg>=2
    emode=args{2};
    if ~(isnumeric(emode) && isscalar(emode) && (emode==0||emode==1||emode==2))
        error('emode must 1 (direct geometry), 2 (indirect geometry) or 0 (elastic)')
    end
else
    emode=[];   % indicates emode to be left untouched
end

% Check that the data has the correct type
if ~all(w.sqw_type(:))
    error('efix and emode can only be changed in sqw-type data')
end

% Change efix and emode
% ---------------------
source_is_file=w.source_is_file;
nobj=numel(w.data);     % number of sqw objects or files

% Set output argument if object input
if source_is_file
    flname=w.data;  % name(s) of sqw files
else
    wout=w.data;    % set output argument if object input
end

% Check the number of spe files matches the number of efix
nefix=numel(efix);
if nefix>1
    for i=1:nobj
        if w.nfiles(i)~=nefix
            error('An array of efix values was given but its length does not match the number of spe files in (all) the sqw source(s) being altered')
        end
    end
end

% Change efix and emode for each data source in a loop
for i=1:nobj
    % Read the header part of the data
    if source_is_file
        [mess,h.main_header,h.header,h.detpar,h.data]=get_sqw (flname{i},'-hverbatim');
        if ~isempty(mess), error(mess), end
    else
        h=wout(i);  % pointer to object
    end
    % Change the header
    nfiles=h.main_header.nfiles;
    tmp=h.header;   % to keep referencing to sub-fields to a minimum
    if nfiles>1
        for ifile=1:nfiles
            if nefix==1
                tmp{ifile}.efix=efix;
            else
                tmp{ifile}.efix=efix(ifile);
            end
            if ~isempty(emode)
                tmp{ifile}.emode=emode;
            end
        end
    else
        tmp.efix=efix;
        if ~isempty(emode)
            tmp.emode=emode;
        end
    end
    % Write back out
    if source_is_file
        h.header=tmp;
        mess = put_sqw (flname{i},h.main_header,h.header,h.detpar,h.data,'-h');
        if ~isempty(mess), error(['Error writing to file ',flname{i},' - check the file is not corrupted: ',mess]), end
    else
        wout(i).header=tmp;
    end
end

% Set return argument if necessary
if source_is_file
    argout={};
else
    argout{1}=wout;
end
    

% Package output arguments
% ------------------------
[varargout,mess]=horace_function_pack_output(w,argout{:});
if ~isempty(mess), error(mess), end
