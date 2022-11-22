function [exp_info,pos] = get_header(obj,varargin)
% Get full data header or headers for sqw file written in format v3
%
% If instrument and sample are present in the file (not the empty
% structures) it loads instruments and samples from the file and attaches
% them to the header(s)
%
% Usage:
%>>exp_info = obj.get_header();
%>>exp_info = obj.get_header(1);      -- get header number 1
%>>exp_info = obj.get_header(number); -- get header with specified number
%>>exp_info = obj.get_header('-all');
%>>exp_info = obj.get_header('-no_samp_inst'); % do not set up sample and instrument to header
%                    even if they are defined in the file, except the basic sample and inst,
%                    defined in version 2 (downgrades header to version 2)
%
% First three forms return single header, first two return header number 1.
%
% Method throws HORACE:file_io:invalid_argument if the header number is out
% of existing headers range.
%
%
%
[ok,mess,get_all,no_isamp_inst,argi]= parse_char_options(varargin,{'-all','-no_samp_inst'});
if ~ok
    error('HORACE:file_io:invalid_argument',mess);
end
% recovers old (v2) header without actual sample and instrument
% despite that, it builds basic sample and sets up sample lattice
% parameters from header
[exp_info,pos] = get_header@sqw_binfile_common(obj,varargin{:});
%
n_runs = exp_info.n_runs;
if no_isamp_inst
    return;
end
if get_all % load all runs
    instr = obj.get_instrument('-all');
    main_sampl = obj.get_sample('-all');
else % only one run requested
    % then sqw_binfile_common part got only one header and n-runs here is 1
    n_runs = 1;
    instr = obj.get_instrument(argi{:});
    main_sampl = obj.get_sample(argi{:});
end
if ~(isa(main_sampl,'IX_null_sample') || ...
        (isa(main_sampl,'unique_objects_container') && isa(main_sampl{1},'IX_null_sample')) ...
        )
    if isa(main_sampl,'unique_objects_container') && main_sampl.n_runs > 1
        % nsampl needs to be equal to number of runs
        if main_sampl.n_runs ~= exp_info.n_runs
            error('HORACE:file_io:runtime_error',...
                'Multiple sample in footer contains %d runs and number of runs stored in header=%d',...
                numel(main_sampl),exp_info.n_runs)
        end
    else % we need to propagate the sample(s), stored in the footer to all headers
        if iscell(main_sampl)
            main_sampl = main_sampl{1};
        end
        if isa(main_sampl,'unique_objects_container')
            if main_sampl.n_runs==1
                main_sampl = main_sampl.expand_runs(n_runs);
            elseif main_sampl.n_runs==n_runs
                % container is fine, leave as is for assignment to exp_info
                % below
            else
                if get_all
                    error('HORACE:get_header:invalid_argument',...
                        ['samples for file is neither a single sample ', ...
                        'nor contains a sample for each run']);
                else
                    % there is problem with this function. It does not work
                    % for single header any more
                    %TODO: resolve
                end
            end
        else
            ms  =unique_objects_container('IX_samp');
            ms{1} = main_sampl;
            main_sampl = ms.expand_runs(n_runs);
        end
    end
    footer_sample_present = true;
else
    footer_sample_present = false;
end


% Lets assume that when we store headers and sample(s) on disk, lattice
% stored in headers is always correct. (it may be realigned)
% Some old Horace versions did not store
% correct lattice to sample. This is why, here we set up sample lattice
% from headers here regardless of version.
% Base class header have read header and built basic sample with lattice
% parameters from header and here we set up this lattice to the particular
% implementation of sample if such implementation is present.
if footer_sample_present % set up its lattice if the lattice is not present
    bas_sample= exp_info.samples.unique_objects;
    main_si   = main_sampl.unique_objects;
    n_latt = numel(bas_sample);
    n_samp = numel(main_si);
    if n_latt  ~= n_samp && ~(n_latt == 1 || n_samp == 1)
        error('HORACE:faccess_sqw_v3:runtime_error',....
            'Number of unique lattices (%d) differs from number of unique samples (%d) and no one of them are 1',...
            n_latt,n_samp);
    end
    if n_latt == 1
        if n_samp == 1
            main_si{1} = set_lattice(main_si{1},bas_sample{1});
        else
            for i=1:n_samp
                main_si{i} = set_lattice(main_si{i},bas_sample{1});
            end
        end
    else
        if n_samp == 1
            main_si{1} = set_lattice(main_si{1},bas_sample{1});
        else
            for i=1:n_samp
                main_si{i} = set_lattice(main_si{i},bas_sample{i});
            end
        end
    end
    main_sampl.unique_objects = main_si;
    exp_info.samples = main_sampl;
else % basic sample have already been built from lattice stored in header
end  % so nothibng to do.
%

if ~(isa(instr,'IX_null_inst') || ...
        (isa(instr,'unique_objects_container') && isa(instr{1},'IX_null_inst')) ...
        ) % all instruments are valid instruments
    if numel(instr)==1
        if iscell(instr)
            instr = instr{1};
        end
        if isa(instr,'unique_objects_container')
            % equivalent to repmat in the else clause below
            if instr.n_runs==1
                instr= instr.expand_runs(n_runs);
                exp_info.instruments = instr;
            elseif instr.n_runs == n_runs
                exp_info.instruments = instr;
            else
                error('HORACE:get_header:invalid_argument', ...
                    ['instruments from file is neither a single instrument, ' ...
                    'nor contains an instrument for each run']);
            end
        else
            ms  =unique_objects_container('IX_inst');
            ms{1} = instr;
            exp_info.instruments  = ms.expand_runs(n_runs);
        end
    else
        if ~iscell(instr)
            instr = num2cell(instr);
        end
        exp_info.instruments = instr;
    end
else % IX_null_inst
    % is already in the header
end
function sample = set_lattice(sample,source)
if isempty(sample.alatt)
    sample.alatt = source.alatt;
end
if isempty(sample.angdeg)
    sample.angdeg = source.angdeg;
end
