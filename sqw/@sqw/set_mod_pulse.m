function varargout = set_mod_pulse(varargin)
% Set the moderator pulse shape model and pulse parameters for an array of sqw objects.
%
%   >> wout = set_mod_pulse(win, pulse_model, pp)
%
% Input:
% ------
%   win         Array of sqw objects of sqw type
%   pulse_model Pulse shape model name e.g. 'ikcarp'
%   pp          Pulse shape parameters: row vector for a single set of parameters
%              or a 2D array, one row per spe data set in the sqw object(s).
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
if narg~=2
    error('Check number of input arguments')
end

pulse_model=args{1};
if ~isstring(pulse_model)
    error('Moderator pulse model name must be a character string')
end

pp=args{2};
sz=size(pp);
if ~(isnumeric(pp) && numel(sz)==2)
    error('Moderator pulse shape parameters must form a row vector, or a 2D array (one row per spe data set)')
end

% Check that the data has the correct type
if ~all(w.sqw_type(:))
    error('efix and emode can only be changed in sqw-type data')
end

% Change moderator pulse
% ----------------------
source_is_file=w.source_is_file;
nobj=numel(w.data);	% number of sqw objects or files

% Set output argument if object input
if source_is_file
    flname=w.data;  % name(s) of sqw files
else
    wout=w.data;    % set output argument if object input
end

% Check the number of spe files matches the number of parameter sets
npp=max(size(pp,1),1);  % case of no rows e.g. zeros(0,10) interpreted as a single parameter set
if npp>1
    for i=1:nobj
        if w.nfiles(i)~=npp
            error('An array of efix values was given but its length does not match the number of spe files in (all) the sqw source(s) being altered')
        end
    end
end

% Change moderator pulse for each data source in a loop
mod_def=IX_moderator;
mod_def.pulse_model=pulse_model;
for i=1:nobj
    % Read the header part of the data
    if source_is_file
        [mess,h.main_header,h.header,h.detpar,h.data]=get_sqw (flname{i},'-hisverbatim');
        if ~isempty(mess), error(mess), end
    else
        h=wout(i);  % pointer to object
    end
    % Change the header
    nfiles=h.main_header.nfiles;
    tmp=h.header;   % to keep referencing to sub-fields to a minimum
    if nfiles>1
        for ifile=1:nfiles
            if npp==1
                tmp{ifile}.instrument=set_mod_pulse_single_inst(tmp{ifile}.instrument,pulse_model,pp);
            else
                tmp{ifile}.instrument=set_mod_pulse_single_inst(tmp{ifile}.instrument,pulse_model,pp(ifile,:));
            end
        end
    else
        tmp.instrument=set_mod_pulse_single_inst(tmp.instrument,pulse_model,pp);
    end
    % Write back out
    if source_is_file
        h.header=tmp;
        mess = put_sqw (flname{i},h.main_header,h.header,h.detpar,h.data,'-his');
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


%========================================================================================
function inst=set_mod_pulse_single_inst(inst_in,pulse_model,pp)
% Change the moderator pulse model name and parameters, creating IX_moderator if required
inst=inst_in;
if isfield(inst,'moderator') && isa(inst.moderator,'IX_moderator')
    % Change existing moderator fields
    mod=inst.moderator;
    mod.pulse_model=pulse_model;
    mod.pp=pp;
    inst.moderator=mod;
else
    % Overwrite moderator if it exists, or create if doesn't
    mod=IX_moderator;   % default moderator
    mod.pulse_model=pulse_model;
    mod.pp=pp;
    inst.moderator=mod;
end
