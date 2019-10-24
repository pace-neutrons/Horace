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
% $Revision:: 1753 ($Date:: 2019-10-24 20:46:14 +0100 (Thu, 24 Oct 2019) $)


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
if ~is_string(pulse_model)
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
mod_def.pulse_model=pulse_model;    % just to check is a valid model
for i=1:nobj
    % Read the header part of the data
    if source_is_file
        ld = w.loaders_list{i};
        nfiles = ld.num_contrib_files;
        tmp = ld.get_header('-all');        
    else
        h=wout(i);  % pointer to object
        nfiles=h.main_header.nfiles;        
        tmp=h.header;   % to keep referencing to sub-fields to a minimum
    end
    % Change the header
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
        ld = ld.upgrade_file_format(); % if file was old version one, upgrade to new, 
        % if not, opens for writing
        tt = sqw();
        tt.header = tmp;
        ld = ld.put_instruments(tt);
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
% Change the moderator pulse model name and parameters
inst=inst_in;
if isstruct(inst)
    inst = IX_inst(inst_in);
end

try
    % Change existing moderator fields
    mod=inst.moderator;
    mod.pulse_model=pulse_model;
    mod.pp=pp;
    inst.moderator=mod;
catch
    error('SQW:invalid_instrument','IX_moderator object not found in all instrument descriptions')
end
