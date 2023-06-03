function datastruct = read_nexus_groups_recursive(filename, nexus_path)
    % Recursively reads a NeXus file group and returns a structure of the data
    %
    % datastruct = read_nexus_group_recursive(hdf_info_struct)
    % datastruct = read_nexus_group_recursive(filename, nexus_path)
    % datastruct = read_nexus_group_recursive(filename, group_struct)
    %
    % Inputs:
    %   hdf_info_struct - the result of h5info on the required group
    %   filename (string) - the NeXus file name
    %   nexus_path (string) - the NeXus path to the required group.
    %   group_struct - the group structure of part of a h5info output
    %
    switch class(filename)
      case 'struct'
        if ~isfield(filename, 'Filename')
            error('HERBERT:hdf_nexus:read_nexus_groups_recursive', 'filename and nexus_path must be strings');
        elseif exist('nexus_path', 'var')
            error('HERBERT:hdf_nexus:read_nexus_groups_recursive', 'filename provided as struct, but nexus_path also provided');
        end

        dinfo = filename;
        filename = dinfo.Filename;
      case {'string', 'char'}
        if ~exist('nexus_path', 'var')
            error('HERBERT:hdf_nexus:read_nexus_groups_recursive', 'filename provided as string, but nexus_path not provided');
        end

        if isstring(nexus_path) || ischar(nexus_path)
            dinfo = h5info(filename, nexus_path);
        else
            dinfo = nexus_path;
        end

      otherwise
        error('HERBERT:hdf_nexus:read_nexus_groups_recursive', ...
              'filename (%s) and nexus_path (%s) must be struct, char or string', ...
              class(filename), class(nexus_path));

    end
    datastruct = read_nexus_datasets(filename, dinfo);
    for ii = 1:numel(dinfo.Groups)
        pathfields = split(dinfo.Groups(ii).Name, '/');
        datastruct.(pathfields{end}) = read_nexus_groups_recursive(filename, dinfo.Groups(ii));
    end
end

function datasets = read_nexus_datasets(filename, nexus_struct)
    datasets = struct();
    for ii = 1:numel(nexus_struct.Datasets)
        nexus_path = [nexus_struct.Name '/' nexus_struct.Datasets(ii).Name];
        fieldstruct = struct('value', h5read(filename, nexus_path));
        attr = nexus_struct.Datasets(ii).Attributes;
        for jj = 1:numel(attr)
            fieldstruct.(attr(jj).Name) = attr(jj).Value;
        end
        fieldname = replace(nexus_struct.Datasets(ii).Name, ' ', '_');
        datasets.(fieldname) = fieldstruct;
    end
end
