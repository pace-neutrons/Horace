function [headers,pos] = get_header(obj,varargin)
% get full data header or headers for file format v3
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

