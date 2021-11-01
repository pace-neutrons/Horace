function [exp_info,pos] = get_header(obj,varargin)
% Get full data header or headers for sqw file written in format v3
%
% If instrument and sample are present in the file (not the empty
% structures) it loads instruments and samples from the file and attaches
% them to the header(s)
%
% Usage:
%>>exp_info = obj.get_header();
%>>exp_info = obj.get_header(1);
%>>exp_info = obj.get_header(number);
%>>exp_info = obj.get_header('-all');
%
% First three forms return single header, first two return header number 1.
%
% Method throws HORACE:file_io:invalid_argument if the header number is out
% of existing headers range.
%
%
%
[ok,mess,get_all,~]= parse_char_options(varargin,{'-all'});
if ~ok
    error('HORACE:file_io:invalid_argument',mess);
end

[exp_info,pos] = get_header@sqw_binfile_common(obj,varargin{:});
n_runs = exp_info.n_runs;
% only one experiment
if get_all
    instr = obj.get_instrument('-all');
    main_sampl = obj.get_sample('-all');
else
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
    else % we need to propagate the sample, stored in the footer to all headers
        main_sampl = repmat(main_sampl,1,exp_info.n_runs);
    end
else
    main_sampl = exp_info.samples;
end

if ~isempty(main_sampl(1)) && (isempty(main_sampl(1).alatt) || isempty(main_sampl(1).angdeg)) 
    % some odd bug in old file formats? sample lattice is not stored with
    % sample
    for i=1:n_runs
        header_sampl = exp_info.samples(i);
        if isempty(main_sampl(i).alatt)
            main_sampl(i).alatt = header_sampl.alatt;
        end
        if isempty(main_sampl(i).angdeg)
            main_sampl(i).angdeg = header_sampl.angdeg;
        end
    end
end
%
if ~isempty(instr)
    if numel(instr)==1
        exp_info.instruments  = repmat(instr,n_runs,1);
    else
        exp_info.instruments = instr;
    end
end
if ~isempty(main_sampl)
    exp_info.samples = main_sampl;
end
