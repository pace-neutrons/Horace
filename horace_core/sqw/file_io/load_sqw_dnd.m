function data = load_sqw_dnd(sources, varargin)
%LOAD_SQW_DND attempt to load the given sources into sqw/dnd objects
%
% Input:
% ------
% sources       Can be:
%                 - sqw object (scalar, array or cell array)
%                 - dnd object (scalar, array or cell array)
%                 - char array (path to an sqw/dnd file)
%                 - cellstr (cell array of sqw/dnd file paths)
%               You cannot mix types within cell arrays (e.g. a cell array of
%               file paths where one path is an sqw file, and another is a dnd
%               file, is forbidden).
%
% Keywords:
% ---------
% filebacked_pix   Set to true to use file-backed pixels. This option only
%                  applies when given in conjunction with an sqw file path(s).
%                  (default = false).
%
% Output:
% -------
% data          Array of sqw or dnd objects.
%
DND_CLASSES = {'d0d', 'd1d', 'd2d', 'd3d', 'd4d'};

sources_validator = @(x) validateattributes( ...
    x, [{'cell', 'char', 'string', 'sqw'}, DND_CLASSES{:}], {} ...
);

parser = inputParser();
parser.addRequired('sources', sources_validator);
parser.addOptional('filebacked_pix', false, @islognumscalar);
parser.parse(sources, varargin{:});
opts = parser.Results;

if iscell(sources)
    % We're not sure whether the inputs are sqw/dnd yet. Set the output array
    % as empty for the moment and allocate it after we've loaded the 1st object
    data = [];
    for i = 1:numel(sources)
        source_i = get_data_source(sources{i}, opts.filebacked_pix);
        if numel(source_i) > 1
            error('HORACE:func_eval:too_many_elements', ...
                  'Inputs within cell array must not have more than 1 element.');
        end
        if i == 1
            % Now we know what type to expect, we can allocate the output array
            data = repmat(eval(class(source_i)), [1, numel(sources)]);
        end
        try
            data(i) = source_i;  %#ok ignores AGROW warning
        catch ME
            if strcmp(ME.identifier, 'MATLAB:heterogeneousStrucAssignment')
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
    data = get_data_source(sources, opts.filebacked_pix);
end

end


% -----------------------------------------------------------------------------
function sqw_dnd_obj = get_data_source(source, filebacked_pix)
    % Inspect the given func_eval data source object and load it if it is a
    % file path
    %
    DND_CLASSES = {'d0d', 'd1d', 'd2d', 'd3d', 'd4d'};
    if is_string(source)
        % Get a loader instance that can tell us what kind of file this is
        % We expect either a .sqw or .dnd file, throw an error otherwise.
        ldr = sqw_formats_factory.instance().get_loader(source);
        try
            if ldr.sqw_type
                if filebacked_pix
                    % Load the .sqw file using the sqw constructor so that we can pass the
                    % pixel_page_size argument to get an sqw with file-backed pixels.
                    pixel_page_size = get(hor_config, 'pixel_page_size');
                    sqw_dnd_obj = sqw(source, 'pixel_page_size', pixel_page_size);
                else
                    sqw_dnd_obj = ldr.get_sqw();
                end
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
              ['Argument ''sources'' must be sqw, dnd, a valid file path \n' ...
               'or a cell array of objects/file paths.'], ...
              class(source));
    end
end
