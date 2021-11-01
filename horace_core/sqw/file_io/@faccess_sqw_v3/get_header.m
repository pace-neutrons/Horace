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
    sampl = obj.get_sample('-all');
else
    instr = obj.get_instrument(varargin{:});
    sampl = obj.get_sample(varargin{:});
end
if ~isempty(sampl(1)) && (isempty(sampl(1).alatt) || isempty(sampl(1).angdeg)) % some odd bug in old file formats?
    % we currently store only one sample and instrument or
    % n-samples == n_headers.
    for i=1:n_runs
        sam = exp_info.samples(i);
        if isempty(sampl(i).alatt)
            sampl(i).alatt = sam.alatt;
        end
        if isempty(sampl(i).angdeg)
            sampl(i).angdeg = sam.angdeg;
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
if ~isempty(sampl)
    sampl_array = repmat(sampl,n_runs,1);
    exp_info.samples = sampl_array;
end
