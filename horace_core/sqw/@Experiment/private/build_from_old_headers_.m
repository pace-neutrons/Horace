function obj = build_from_old_headers_(~,varargin)
% in this case the header (which is what varargin{1} is in
% this case) is a cell of runs. Consequently we run over
% the runs in the cell doing just what we did to one run
% header in the if block above
headers = varargin{1};
expdata = repmat(IX_experiment,1,numel(headers));
instruments = repmat(IX_inst(),1,numel(headers));
samples = repmat(IX_samp(),1,numel(headers));

% convert old headers, resored differently from sqw and mat files into the
% same format
headers = normalize_old_headers(headers);
%
for i=1:numel(headers)
    hdr = headers{i};
    alatt = hdr.alatt;
    angdeg = hdr.angdeg;
    instr = hdr.instruments;
    
    if isstruct(instr)
        if isempty(instr) || numel(fieldnames(instr))==0
            % do nothing, its empty instrument and its already there
        elseif isfield(instr,'fermi_chopper') %TODO: should it be instrument factory which produces instruments as function of input parameters?
            % This would allow easy modify and add new instruments, not to
            % run through code looking for places to identify them
            instrument = IX_inst_DGfermi(instr.moderator, ...
                instr.aperture,  ...
                instr.fermi_chopper);
            instruments(i) = instrument;
        else
            error('HORACE:Experiment:invalid_argument',...
                'unknown structure tried to be recovered as instrument');
        end
    elseif isa(instr,'IX_inst')
        instruments(i) = instr;
    else
        error('HORACE:Experiment:invalid_argument',...        
            'unknown type of instrument header: %s for header N %d',...
            class(instr),i)
    end
    
    sampl = hdr.samples;
    %
    if isstruct(sampl) && isempty(fieldnames(sampl))
        %TODO: IBID: it should be sample factory, returning samples as function
        % of inputs. The same as instrument
        sampl = IX_samp();
        sampl.alatt = alatt;
        sampl.angdeg = angdeg;
    elseif isa(sampl,'IX_samp') && isempty(sampl)
        sampl.alatt = alatt;
        sampl.angdeg = angdeg;
    else
        sampl = IX_samp(sampl);
        if isempty(sampl)
            sampl.alatt = alatt;
            sampl.angdeg = angdeg;
        end
    end
    samples(i) = sampl;
    expdata(i) = IX_experiment(hdr);
end
obj = Experiment([], instruments, samples);
obj.expdata = expdata;

function headers = normalize_old_headers(headers)
% convert old headers, restored differently from sqw file and mat objects
% into one single format

for i=1:numel(headers)
    hdr = headers{i};
    if isfield(hdr,'instrument')
        if isfield(hdr,'instruments')
            warning('HORACE:Experiment:invalid_argument',...
                ['both old instrument and new instruments fields are present in the '
            'old headers. Something wrong with program logic. Using old field instrument values'])
        end
        hdr.instruments = hdr.instrument;
        hdr = rmfield(hdr,'instrument');
    end
    if isfield(hdr,'sample')
        if isfield(hdr,'samples')
            warning('HORACE:Experiment:invalid_argument',...
                ['both old sample and new sample fields are present in the '
            'old headers. Something wrong with the program logic. Using old field sample values'])
        end
        hdr.samples = hdr.sample;
        hdr = rmfield(hdr,'sample');
    end    
    headers{i} = hdr;
end
