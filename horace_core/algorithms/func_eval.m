function wout = func_eval(source, varargin)
% Evaluate a function at the plotting bin centres of sqw/dnd objects or files
% Syntax:
%   >> wout = func_eval (win, func_handle, pars)
%   >> wout = func_eval (win, func_handle, pars, ['all'])
%
% If function is called on sqw-type object, the pixels signal is also
% modified and evaluated
%
% For more info see help sqw/func_eval
DND_CLASSES = {'d0d', 'd1d', 'd2d', 'd3d', 'd4d'};

if is_string(source)
    % Get a loader instance that can tell us what kind of file this is
    % We expect either a .sqw or .dnd file, throw an error otherwise.
    ldr = sqw_formats_factory.instance().get_loader(source);
    if ldr.sqw_type
        % Load the .sqw file using the sqw constructor so that we can pass the
        % pixel_page_size argument to get an sqw with file-backed pixels.
        pixel_page_size = get(hor_config, 'pixel_page_size');
        sqw_dnd_obj = sqw(source, 'pixel_page_size', pixel_page_size);
    else
        % In contrast to the above case, we can use the loader to get the dnd
        % as no extra constructor arguments are required.
        sqw_dnd_obj = ldr.get_dnd(source);
    end
    ldr.delete();
elseif isa(source, 'sqw') || ismember(class(source), DND_CLASSES)
    sqw_dnd_obj = source;
else
    error('HORACE:cut', ...
          ['Cannot take cut of object of class ''%s''.\n' ...
           'Argument ''source'' must be sqw, dnd or a valid file path.'], ...
          class(source));
end

if nargout > 0
    wout = func_eval(sqw_dnd_obj, varargin{:});
else
    func_eval(sqw_dnd_obj, varargin{:});
end
