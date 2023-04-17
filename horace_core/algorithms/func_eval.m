function wout = func_eval(source, varargin)
% Evaluate a function at the plotting bin centres of sqw/dnd objects or files
% Syntax:
%   >> wout = func_eval(win, func_handle, pars)
%   >> wout = func_eval(win, func_handle, pars, 'outfile', outfile_path)
%   >> wout = func_eval(win, func_handle, pars, ['all'])
%
% If function is called on sqw-type object (i.e. has pixels), the pixels'
% signal is also modified and evaluated
%
% For more info see help sqw/func_eval
%
sqw_dnd_obj = validate_data(source);

if nargout > 0
    wout = func_eval(sqw_dnd_obj, varargin{:});
else
    func_eval(sqw_dnd_obj, varargin{:});
end

end  % function

% -----------------------------------------------------------------------------
function sources = validate_data(source)
% Parse the data source inputs for func_eval and load any files into
% objects
%
if iscell(source)
    % We're not sure whether the inputs are sqw/dnd yet. Set the output array
    % as empty for the moment and allocate it after we've loaded the 1st object
    if isempty(source)
        sources = [];
        return;
    end

    obj_type = class(source{1});
    if ~isa(source{1}, 'SQWDnDBase')
        error('HORACE:func_eval:invalid_argument', ...
              ['Cannot take eval on object of class ''%s''. ' ...
               'Argument ''source'' must be sqw or dnd ' ...
               'or a cell array of objects.'], ...
              class(source));
    end

    for i = 1:numel(source)

        if numel(source{i}) > 1
            error('HORACE:func_eval:invalid_argument', ...
                  'Inputs within cell array must not have more than 1 element.');
        end

        if ~isa(source{i},obj_type)
            error('HORACE:func_eval:invalid_argument', ...
                  'First input object is the obj of class: "%s", and obj N:%d is the obj of class: "%s". Must be the same',...
                  obj_type, i, class(source{i}));

        end
    end

    sources = [source{:}];
else
    sources = source;
end

end
