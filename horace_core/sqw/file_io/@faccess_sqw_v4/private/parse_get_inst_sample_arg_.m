function  [argi,instr_number] = parse_get_inst_sample_arg_(obj,varargin)
% Parse get_instrument or get_sample input parameters and return
% the parameters, defining the treatment of the instrument/sample container
%
% path through the other parameters, assuming that those parameters define
% sqw source to read

if isempty(varargin)
    argi = {};
    instr_number = 1;
    return;
end

is_num = cellfun(@(x)isnumeric(x),varargin);
if any(is_num)
    instr_number = [varargin{is_num}];
    if any(instr_number>obj.num_contrib_files)
        invalid = instr_number>obj.num_contrib_files;
        error('HORACE:sqw:invalid_argument', ...
            'Number(s) of the requested component(s): %s exceeds the total number of contributed runs: %d', ...
            disp2str(instr_number(invalid)),obj.num_contrib_files);
    end
    argi = varargin(~is_num);
    if isempty(argi)
        return
    end
else
    argi = varargin;
    instr_number = 1;
end
is_par = cellfun(@(x)(ischar(x)||isstring(x))&&strcmp(x,'-all'),argi);
if any(is_par)
    instr_number = inf;
    argi = argi(~is_par);
end
