function obj = set_instrument (obj,instr_or_fun,varargin)
% Change the instrument in an sqw object or array of objects
%
%   >> wout = set_instrument (w, instrument)
%
%   >> wout = set_instrument (w, inst_func, arg1, arg2,...)
%
% EXAMPLES:
%   >> wout = set_instrument (w, instrument);
%   >> wout = set_instrument (w, @maps_instrument, '-efix', 600, 'S')
%
%
% Input:
% -----
%   w               Input sqw object or array of objects
%
%   instrument      Instrument object, or array of instrument objects with
%                  number of elements equal to the number of runs contributing
%                  to the sqw object(s).
%                   If the instrument is any empty object, then the instrument
%                  is set to the empty structure struct().
%
% *OR*
%   inst_func       Function handle to generate instrument object.
%                   The function must be of the form:
%                       inst = my_func (p1, p2, ...)
%                  where p1,p2, ... are parameters to be passed to the
%                  instrument definition function (in this case called my_func),
%                  which in this example will be passed as @my_func.
%
%   arg1, arg2,...  Arguments to be provided to the instrument function.
%                  The arguments must be:
%                   - scalars, row vectors (which can be numerical, logical,
%                     structure, cell array or object), or character strings.
%                   - Multiple arguments can be passed, one for each run that
%                     constitutes the sqw object, by having one row per run
%                     i.e
%                       scalar      ---->   column vector (nrun elements)
%                       row vector  ---->   2D array (nrun rows)
%                       string      ---->   cell array of strings
%
%                  Certain arguments win the sqw object can be referred to by
%                  special strings;
%                       '-efix'     ---->   use value of fixed energy in the
%                                           header block of the sqw object
% Output:
% -------
%   wout        Output sqw object with changed instrument

% Original author: T.G.Perring
%

% Perform operations
% ==================

if isa(instr_or_fun,'IX_inst')
    % just set instrument provided as input
    obj = set_instr(obj,instr_or_fun);
    return
end
if ~isa(instr_or_fun,'function_handle')
    error('HORACE:sqw:invalid_argument',...
        ['Neither instrument (including IX_null_inst) nor function building instrument is provided as input for the method.\n', ...
        ' Setting instrument as a structure is not allowed any more'])
end
if ~isscalar(instr_or_fun)
    error('HORACE:sqw:invalid_argument',...
        'only one function handle allowed to define instrument')

end
instfunc = instr_or_fun;
obj = set_instr(obj,instfunc,varargin{:});


%--------------------------------------------------------------------------
function obj = set_instr(obj,instr,varargin)
% Change the instrument
% ---------------------

if nargin > 2
    [ok,mess,substitute_efix,argi] = parse_char_options(varargin,{'-efix'});
    if ~ok
        error('HORACE:sqw:invalid_argument',mess);
    end

    [set_single,set_per_obj,n_runs_in_obj]=find_set_mode(obj,argi{:});
    if ~set_single
        args_mat = Experiment.check_and_expand_function_args(argi{:});
        n_col = size(args_mat,2);
    end
else
    [set_single,set_per_obj,n_runs_in_obj]=find_set_mode(obj,instr);
end
n_inst_set = 0;
for i=1:numel(obj)
    if set_single
        obj(i).experiment_info = obj(i).experiment_info.set_instrument(instr,varargin{:});
    else
        if set_per_obj
            obj(i).experiment_info = obj(i).experiment_info.set_instrument(instr(i),varargin{i,:});
        else
            if nargin>2
                if substitute_efix
                    argi = cell(1,n_col+1);
                    argi{1} = '-efix';
                    ics = 1;
                else
                    argi = cell(1,n_col);
                    ics = 0;
                end
                for j=1:n_col
                    argi{j+ics} = [args_mat{n_inst_set+1:n_inst_set+n_runs_in_obj(i),j}]';
                end

                obj(i).experiment_info = obj(i).experiment_info.set_instrument( ...
                    instr,argi{:});
            else
                obj(i).experiment_info = obj(i).experiment_info.set_instrument( ...
                    instr(n_inst_set+1:n_inst_set+n_runs_in_obj(i)));
            end
            n_inst_set = n_inst_set+n_runs_in_obj(i);
        end
    end
end

%--------------------------------------------------------------------------
