function obj = build_from_old_headers_(obj,varargin)
%
% Input
% ------
%   >> ~ : the object (an Experiment), not used - a completely new
%          Experiment is created and output at the end
%   >> headers == varargin{1}: cell array of old-style header structs
%
% Output
% -------
%   >> obj: an Experiment object as the new-style header packaging the
%           old-style header info
%
% COMMENT:
% This should really be static method - it relates to Experiment but does
% not use Experiment object contents
%------------------------------------------------------------------------

% Name varargin{1} as (old-style) headers to clarify what is coming in
headers = varargin{1};

% Make arrays of the hew-style header class types to receive the data
% coming from each run in headers
expdata     = repmat(IX_experiment(), 1,numel(headers));
instruments = repmat({IX_null_inst()},  1,numel(headers));
samples     = repmat({IX_null_sample()},1,numel(headers));

% convert old headers, restored differently from sqw and mat files into the
% same format - there appear to be cases where old-style header structs and
% Experiments mix - this converts to old-style before we start, though not
% not convinced it is needed or correct
headers = normalize_old_headers(headers);

% Now operate on the assumed old-style header structs, either received or
% converted
for i=1:numel(headers)
    % Name  i'th header locally
    hdr = headers{i};
    [expdata(i),alatt,angdeg] = IX_experiment.build_from_binfile_header(hdr);    

    % Local name the instrument (not liking plural instruments -
    % should be the single instrument from the old-syle header structure
    instr = hdr.instruments;

    % If instr is a struct
    if isstruct(instr)
        % Instrument in header is empty struct, replace with null instrument
        if isempty(instr) || numel(fieldnames(instr))==0
            instruments{i} = IX_null_inst();
            % Struct may have data to make an instrument, delegate to factory
            % method (which may reject the struct and throw)
        else
            instruments{i} = make_instrument_from_struct(instr);
        end
        % If instr is actually an instrument object (subclass of IX_inst)
        % just assign
    elseif isa(instr,'IX_inst')
        instruments{i} = instr;
    else
        error('HORACE:Experiment:invalid_argument',...
            'unknown type of instrument header: %s for header N %d',...
            class(instr),i)
    end

    % Locally name the sample (again, not liking plural samples, same reason)
    sampl = hdr.samples;

    % If sampl is a struct
    if isstruct(sampl)
        % Sample in header is an empty struct, replace with null sample and
        % populate with the lattice parameters
        if isempty(sampl) || isempty(fieldnames(sampl))
            sampl = IX_samp();
            sampl.alatt = alatt;
            sampl.angdeg = angdeg;
            samples{i} = sampl;
            % struct may have enough info to make a sample (though this is not
            % defined yet - call to factory method will probably fail)
        else
            samples{i} = make_sample_from_struct(sampl);
        end
        % Sample is actually a subclass of IX_samp, so keep it but overwrite
        % the lattice parameters if they were not in the old version
    elseif isa(sampl,'IX_samp')
        if isempty(sampl.alatt)
            sampl.alatt = alatt;
        elseif sampl.alatt ~= alatt
            warning('HORACE:Experiment:invalid_parameter',...
                'incoming sample alatt and old header alatt do not match');
        end
        if isempty(sampl.angdeg)
            sampl.angdeg = angdeg;
        elseif sampl.alatt ~= alatt
            warning('HORACE:Experiment:invalid_parameter',...
                'incoming sample angdeg and old header angdeg do not match');
        end
    end
    samples{i} = sampl;

    % Construct the experiment data from the rest of the header

end

% Construct the new header Experiment object
% update with expdata, which maybe should go in the Experiment constructor
obj.instruments = instruments;
obj.samples = samples;
% this also calculates and sets up consistent runid_map
obj.expdata = expdata;

end % function build_from_old_headers

%-------------------------------------------------------------------------
function headers = normalize_old_headers(headers)
%
% Headers may come from
% (1) sqw object on file written in the old style (currently the file
%     storage of headers is still old-style even for code using the new
%     style Experiment)
% (2) .mat file, in which case it may be a new-style header written to .mat
%     in recent sessions, or an old one written earlier.
% This routine takes the headers of various formats, restored differently
% from sqw file and mat objects into one single format.

% Loop over all contents of headers
for i=1:numel(headers)
    % Local name i'th element - assumes headers is cell array which suggests
    % this has to be an old-style header
    hdr = headers{i};

    % Check if a field 'instrument' is present (true for old-style header
    % structs
    if isfield(hdr,'instrument')
        % if field instruments is also present (implies it is a new-style
        % Experiment, not clear why it should be in a cellarray though)
        if isfield(hdr,'instruments')
            % Being generous and assuming this can be a single old-style
            % header instrument, although it would have to be a single
            % instrument to work.....
            warning('HORACE:Experiment:invalid_argument',...
                ['both old instrument and new instruments fields are present in the '
                'old headers. Something wrong with program logic. Using old field instrument values'])
        end
        % Give it the old style correct name (assumes instrument is wrong
        % and instruments is right, difficult to see why this is not an
        % error condition) and keep instrument as instruments
        hdr.instruments = hdr.instrument;
        hdr = rmfield(hdr,'instrument');
    end

    % repeat for sample as with instrument above, same comments
    if isfield(hdr,'sample')
        if isfield(hdr,'samples')
            warning('HORACE:Experiment:invalid_argument',...
                ['both old sample and new sample fields are present in the '
                'old headers. Something wrong with the program logic. Using old field sample values'])
        end
        hdr.samples = hdr.sample;
        hdr = rmfield(hdr,'sample');
    end

    % Repack the header struct into the cell array
    headers{i} = hdr;
end % numel(headers)

end % function normalise_old_headers

%-------------------------------------------------------------------------
function instr = make_instrument_from_struct(instr_info)
%
% Temporary location for this instrument factory which should really go in
% Herbert instrument classes location
%
% Given info on e.g. moderator, aperture, chopper, constructs a specific
% instrument from the pre-defined instruments
%
% Input
% -----
%   >> instr_info: struct with fields for moderator, aperture, chopper
%                  but not otherwise well defined (TODO)
%
% Output
% ------
%   >> instr: the constructed instrument, if successful
%
% Errors
% ------
% If the struct does not sufficiently define one of the predefined
% instruments, an error will be thrown

if ~isfield(instr_info, 'moderator') || ~isfield(instr_info, 'aperture')
    error('HORACE:Experiment:invalid_argument',...
        'unknown structure tried to be recovered as instrument [1]');
end

if isfield(instr_info,'fermi_chopper')
    instr = IX_inst_DGfermi(instr_info.moderator, ...
        instr_info.aperture,  ...
        instr_info.fermi_chopper);
elseif isfield(instr_info,'disk_chopper')
    instr = IX_inst_DGdisk(instr_info.moderator, ...
        instr_info.aperture,  ...
        instr_info.disk_chopper);
else
    error('HORACE:Experiment:invalid_argument',...
        'unknown structure tried to be recovered as instrument [2]');
end

end % function make_instrument_from_struct

%-------------------------------------------------------------------------
function sample = make_sample_from_struct(~) % when used, change ~ to sample_info)
%
% Temporary location for this sample factory which should really go in
% Herbert instrument classes location
%
% Given info on e.g. moderator, aperture, chopper, constructs a specific
% instrument from the pre-defined instruments
%
% Input
% -----
%   >> sample_info: struct with fields for sample things (TODO)
%
% Output
% ------
%   >> sample: the constructed sample, currently not implemented, so fails
%
% Errors
% ------
% If the struct does not sufficiently define a sample (which it won't, not
% defined yet), an error will be thrown

sample = IX_null_sample(); % suppress error, should be removed when proper
% functionality added here

error('HORACE:Experiment:invalid_argument',...
    'unknown structure tried to be recovered as sample');

end % function make_sample_from_struct