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
% $Revision:: 1753 ($Date:: 2019-10-24 20:46:14 +0100 (Thu, 24 Oct 2019) $)
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
    headers.instrument = instr;
    headers.sample = sampl;
else
    for i=1:n_files
        if numel(instr) > 1
            if iscell(instr)
                headers{i}.instrument = instr{i};
            else
                headers{i}.instrument = instr(i);
            end
        else
            headers{i}.instrument = instr ;
        end
        if numel(sampl) > 1
            if iscell(sampl)
                headers{i}.sample = sampl{i};
            else
                headers{i}.sample = sampl(i);
            end
        else
            headers{i}.sample = sampl;
        end
    end
end

