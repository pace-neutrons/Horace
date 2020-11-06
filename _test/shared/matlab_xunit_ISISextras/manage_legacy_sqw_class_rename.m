function processed = manage_legacy_sqw_class_rename(data)
% Perform pre-processing on data loaded from .mat files
%
% Called as part of the TestCaseWithSave workflow or after `load(file, vars...)`
% in old-style tests.
%
% This is a temporary function to manage reengineering of the `sqw` object
% during which the old class is renamed as `sqw_old`, and will load as
% a struct rather than class instance
%
% An old `sqw` object will not be recognised as an instance of the 'sqw_old'
% object and will be created as a struct. This function recurses through the `data`
% and updates any structs which are sqw-like to be instances of `sqw_old`.

% Example of handled data types:
%
% sqw_like                                      % sqw-like - updated
% sqw_like_array                                % each element updated
% non_sqw_like_struct                           % other structure - unchanged
% 'string', 16                                  % scalars - unchanged
%
% A struct 'S' containing a mix of data types, e.g.
% S.scalar = 15
% S.non_sqw_like_struct = aa                    % aa is not sqw-like struct
% S.sqw_like = d1                               % d1 is sqw-like
% S.sqw_array-like = [w1a, w1b]                 % w1a, w2b are sqw-like
% S.nested.sqw_array_like_one = [k11, k12, k13] % k1j are sqw-like
% S.nested.sqw_array_like_two = [k21, k22, k23] % k2j are sqw-like
% S.nested.cellarray = { 'one', 'two' }


% input data is a sqw-like structure
if isfield(data, 'main_header') && isfield(data, 'header') && isfield(data, 'detpar')
    processed = sqw_old(data);

% input is a struct or array-of-structs
elseif isstruct(data)
    field_names = fields(data);

    % loop over the fields of the struct. In the array case these will be the
    % same for every element and array-index or field-name may be iterated first
    for idx = 1:length(field_names)
        field_name = field_names{idx};

        % if field value is a struct or an array-of-struct we need to recursively
        % call this function
        if (isstruct(data.(field_name)))
            % cache the array dimensions
            initial_size = size(data.(field_name));

            % loop over each element of the array, recursively calling this function with the fields
            % structure. If the value is not an array, numel is 1 and this will execute exactly once
            for inner_idx = 1:numel(data.(field_name))
                processed.(field_name)(inner_idx) = manage_legacy_sqw_class_rename(data.(field_name)(inner_idx));
            end

            % restore the initial array shape the loop will have constructed a [1, n] array
            processed.(field_name) = reshape(processed.(field_name), initial_size);
        else
            % copy any non-struct values into the return value unchanged
            processed.(field_name) = data.(field_name);
        end
    end

% value is neither a struct or sqw-like object so return input unchanged
else
    processed = data;
end
end