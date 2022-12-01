function varargout = set_instrument (w,inst_or_fun,varargin)
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


% This routine is also used to set the instrument in sqw files, when it overwrites the input file.

% Parse input
% -----------
if ~iscell(w)
    w = {w};
end


% Perform operations
% ==================
nobj=numel(w);     % number of sqw objects or files
out = cell(1,nobj);
for i=1:nobj
    win = w{i};
    if ischar(win)||isstring(win)
        out{i} = win;
        ldr = sqw_formats_factory.instance().get_loader(win);
        if ~ldr.sqw_type
            % Check that the data has the correct type
            error('HORACE:algorithms:invalid_argument', ...
                'Instrument can only be set or changed in sqw-type data. File N%d, name: %s does not contain sqw object', ...
                i,win)
        end
        exper = ldr.get_header('-all');
        exper = exper.set_instrument(inst_or_fun,varargin{:});
        ldr= ldr.upgrade_file_format(); % also reopens file in update mode if format is already the latest one
        ldr.put_instruments(exper.instruments);
        ldr.delete();
    elseif isa(win,'sqw')
        out{i} = win;
        exper = win.experiment_info;
        exper = exper.set_instrument(inst_or_fun,varargin{:});
        out{i}.experiment_info = exper;
    else
        error('HORACE:algorithms:invalid_argument', ...
            'Instrument can only be set or changed in sqw-type data. Object N%d, has type %s', ...
            i,class(win));
    end
end

% format output parameters according to the output request
if nargout == 1 && nobj>1
    varargout{1} = out;
else
    for i=1:nargout
        varargout{i} = out{i};
    end
end

