function [headers,pos] = get_header(obj,varargin)
% Get full data header or headers for sqw file written in format v3
%
% If instrument and sample are present in the file (not the empty
% structures) it loads instruments and samples from the file and attaches
% them to the header(s)
%
% Usage:
%>>header = obj.get_header();
%>>header = obj.get_header(1);
%>>header = obj.get_header(number);
%>>header = obj.get_header('-all');
%
% First three forms return single header, first two return header number 1.
%
% Method throws SQW_FILE_IO:invalid_argument if the header number is out
% of existing headers range.
%
%
% $Revision:: 1759 ($Date:: 2020-02-10 16:06:00 +0000 (Mon, 10 Feb 2020) $)
%
%
[ok,mess,get_all,~]= parse_char_options(varargin,{'-all'});
if ~ok
    error('SQW_FILE_IO:invalid_argument',mess);
end

[headers,pos] = get_header@sqw_binfile_common(obj,varargin{:});
if get_all
    instr = obj.get_instrument('-all');
    sampl = obj.get_sample('-all');
else
    instr = obj.get_instrument(varargin{:});
    sampl = obj.get_sample(varargin{:});
end

n_files = numel(headers);

if isstruct(headers)
    if isstruct(instr)
        if isempty(instr) || isempty(fieldnames(instr))
            instr = IX_null_inst();
        else
            instr = IX_inst(instr);
        end
    end
    headers.instrument = instr;
    if isstruct(sampl)
        if isempty(sampl) || isempty(fieldnames(sampl))
            sampl = IX_null_sample;
        else
            sampl = IX_sample(sampl);
        end
    end
    headers.sample = sampl;
else
    for i=1:n_files
        if numel(instr)>1
            if iscell(instr)
                inst = instr{1};
            else
                inst = instr(i);
            end
        else
            inst = instr;
        end
        if isstruct(inst)
            if isempty(inst) || isempty(fieldnames(inst))
                inst = IX_null_inst();
            else
                inst = IX_inst(inst);
            end
        end
        headers{i}.instrument = inst;

        if numel(sampl)>1
            if iscell(sampl)
                samp = sampl{1};
            else
                samp = sampl(i);
            end
        else
            samp = sampl;
        end
        if isstruct(samp)
            if isempty(samp) || isempty(fieldnames(samp))
                samp = IX_null_sample();
            else
                samp = IX_sample(samp);
            end
        end
        headers{i}.sample = samp;
    end
end


