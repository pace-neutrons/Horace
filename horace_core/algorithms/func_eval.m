function wout = func_eval(source, varargin)
% Evaluate a function at the plotting bin centres of sqw/dnd objects or files
% Syntax:
%   >> wout = func_eval(win, func_handle, pars)
%   >> wout = func_eval(win, func_handle, pars, 'outfile', outfile_path)
%   >> wout = func_eval(win, func_handle, pars, ['all'])
%   >> wout = func_eval(file_path, func_handle, pars)
%   >> wout = func_eval({file_path, win}, func_handle, pars)
%
% If function is called on sqw-type object (i.e. has pixels), the pixels'
% signal is also modified and evaluated
%
% For more info see help sqw/func_eval
%
sqw_dnd_obj = get_data_sources(source);

if nargout > 0
    wout = func_eval(sqw_dnd_obj, varargin{:});
else
    func_eval(sqw_dnd_obj, varargin{:});
end

end  % function

% -----------------------------------------------------------------------------
function sources = get_data_sources(source)
    % Parse the data source inputs for func_eval and load any files into
    % objects
    %
    if iscell(source)
        % We're not sure whether the inputs are sqw/dnd yet. Set the output array
        % as empty for the moment and allocate it after we've loaded the 1st object
        sources = [];
        for i = 1:numel(source)
            source_i = get_data_source(source{i});
            if numel(source_i) > 1
                error('HORACE:func_eval:too_many_elements', ...
                      'Inputs within cell array must not have more than 1 element.');
            end
            if isempty(sources)
                sources = repmat(eval(class(source_i)), [1, numel(source)]);
            end
            try
                sources(i) = source_i;
            catch ME
                if strcmp(ME.identifier, 'MATLAB:heterogeneousStrucAssignment') || strcmp(ME.identifier, 'MATLAB:UnableToConvert')
                    % We get here if a user inputs a cell array that contains a mix
                    % of sqw & dnd objects/files
                    error('HORACE:func_eval:input_type_error', ...
                          'Inputs are not all sqw or all dnd types/files.');
                else
                    rethrow(ME);
                end
            end
        end
    else
        sources = get_data_source(source);
    end
end


function sqw_dnd_obj = get_data_source(source)
    % Inspect the given func_eval data source object and load it if it is a
    % file path
    DND_CLASSES = {'d0d', 'd1d', 'd2d', 'd3d', 'd4d'};

    if is_string(source)
        % Get a loader instance that can tell us what kind of file this is
        % We expect either a .sqw or .dnd file, throw an error otherwise.
        ldr = sqw_formats_factory.instance().get_loader(source);
        try
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
        catch ME
            ldr.delete();
            rethrow(ME);
        end
    elseif isa(source, 'sqw') || ismember(class(source), DND_CLASSES)
        sqw_dnd_obj = source;
    else
        error('HORACE:cut', ...
              ['Cannot take cut of object of class ''%s''.\n' ...
               'Argument ''source'' must be sqw, dnd, a valid file path \n' ...
               'or a cell array of objects/file paths.'], ...
              class(source));
    end
end
