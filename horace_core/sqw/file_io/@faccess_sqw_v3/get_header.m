function [exp_info,pos,runid_map] = get_header(obj,varargin)
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
[ok,mess,get_all,no_isamp_inst,~]= parse_char_options(varargin,{'-all','-no_samp_inst'});
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
    instr = obj.get_instrument(varargin{:});
    main_sampl = obj.get_sample(varargin{:});
end
if ~isempty(main_sampl)
    if numel(main_sampl) > 1
        % nsampl needs to be equal to number of runs
        if numel(main_sampl) ~= exp_info.n_runs
            error('HORACE:file_io:runtime_error',...
                'Multiple sample in footer contains %d runs and number of runs stored in header=%d',...
                numel(main_sampl),exp_info.n_runs)
        end
        if ~iscell(main_sampl)
            main_sampl = num2cell(main_sampl);
        end
    else % we need to propagate the sample(s), stored in the footer to all headers
        if iscell(main_sampl)
            main_sampl = main_sampl{1};
        end
        if isa(main_sampl,'unique_objects_container')
            if main_sampl.n_runs()==1
                tmp_sampl = unique_objects_container('type','{}','baseclass','IX_samp');
                tmp_sampl = tmp_sampl.add(main_sampl{1});
                for i=2:n_runs
                    tmp_sampl = tmp_sampl.add(main_sampl{1});
                end
                main_sampl = tmp_sampl;
            elseif main_sampl.n_runs()==n_runs
                % container is fine, leave as is for assignment to exp_info
                % below
            else
                error('HORACE:get_header:invalid argument',...
                      ['samples for file is neither a single sample ', ...
                       'nor containes a sample for each run']);
            end
        else
            main_sampl = repmat({main_sampl},1,exp_info.n_runs);
        end
    end
    footer_sample_present = true;
else
    footer_sample_present = false;
end


% Lets assume that when we store headers and sample(s) on disk, lattice
% stored in headers is always correct. Some old Horace versions did not store
% correct lattice to sample. This is why, here we set up sample lattice
% from headers here regardless of version.
% Base class header have read header and built basic sample with lattice
% parameters from header and here we set up this lattice to the particular
% implementation of sample if such implementation is present.
if footer_sample_present % set up its lattice
    for i=1:n_runs
        bas_sample= exp_info.samples{i};
        main_si = main_sampl{i};
        if isempty(main_si.alatt)
            main_si.alatt = bas_sample.alatt;
        end
        if isempty(main_si.angdeg)
            main_si.angdeg = bas_sample.angdeg;
        end
        main_sampl{i} = main_si;
    end
    exp_info.samples = main_sampl;
else % basic sample have already been built from lattice stored in header
end  % so nothibng to do.
%
% TODO: this needs to be optimized not to copy the array of identical samples
if ~any(isempty(instr)) % all instruments are valid instruments
    if numel(instr)==1
        if iscell(instr)
            instr = instr{1};
        end
        if isa(instr,'unique_objects_container')
            % equivalent to repmat in the else clause below
            if instr.n_runs()==1
                % initial temp container as exp info currently not allowing
                % setting of instruments to empty container nor to
                % container with wrong number of runs, so assemble tmp
                % container with correct properties before assigning
                tmp_instr = unique_objects_container('type','{}','baseclass','IX_inst');
                tmp_instr = tmp_instr.add(instr{1});
                for i=2:n_runs
                    tmp_instr = tmp_instr.add(instr{1}); %exp_info.instruments.add(instr{i});
                end
                exp_info.instruments = tmp_instr;
            elseif instr.n_runs()==n_runs
                exp_info.instruments = instr;
            else
                error('HORACE:get_header:invalid argument', ...
                      ['instruments from file is neither a single instrument, ' ...
                       'nor contains an instrument for each run']);
            end
        else
            exp_info.instruments  = repmat({instr},1,n_runs);
        end
    else
        if ~iscell(instr)
            instr = num2cell(instr);
        end
        exp_info.instruments = instr;
    end
end
