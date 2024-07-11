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
          try
        if ~isfield(filename, 'Filename')
            error('HERBERT:hdf_nexus:read_nexus_groups_recursive', 'filename and nexus_path must be strings');
        elseif exist('nexus_path', 'var')
            error('HERBERT:hdf_nexus:read_nexus_groups_recursive', 'filename provided as struct, but nexus_path also provided');
        end
          catch ME
              disp(' ')
          end
        try
        dinfo = filename;
        filename = dinfo.Filename;
        catch ME
            disp(' ')
        end
      case {'string', 'char'}
          try
        if ~exist('nexus_path', 'var')
            error('HERBERT:hdf_nexus:read_nexus_groups_recursive', 'filename provided as string, but nexus_path not provided');
        end

        if isstring(nexus_path) || ischar(nexus_path)
            dinfo = h5info(filename, nexus_path);
        else
            dinfo = nexus_path;
        end
          catch ME
              disp(' ')
          end

      otherwise
        error('HERBERT:hdf_nexus:read_nexus_groups_recursive', ...
              'filename (%s) and nexus_path (%s) must be struct, char or string', ...
              class(filename), class(nexus_path));

    end
    try
    datastruct = read_nexus_datasets(filename, dinfo);
    catch ME
        disp(' ')
    end
    for ii = 1:numel(dinfo.Groups)
        try
        pathfields = split(dinfo.Groups(ii).Name, '/');
        catch ME
            disp(' ')
        end
        % while spurious fields starting 'rep_' are present in nxspe files, ignore them.
        % the formation of the datastruct field has been split up to ensure that the 'rep_'
        % field does not generate an invalid field error (unclear why this was happening 
        % but the refactor here fixes it.)
        try
            pfe = pathfields(end);
            pfe{1}
            if strncmp(pfe{1},'rep_',4)
                disp(' ')
                isrep = true;
            elseif strcmp(pfe{1},'moderator')
                disp(' ')
                isrep = false;
            else
                isrep = false;
            end
        catch ME
            disp(' ');
        end
        if ~isrep
        try
        substruct = read_nexus_groups_recursive(filename, dinfo.Groups(ii));
        catch ME
            disp(' ');
        end
        try
        datastruct.(pfe{1}) = substruct;
        catch ME
            disp(' ');
        end
        end
    end
end

function datasets = read_nexus_datasets(filename, nexus_struct)
try
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
catch ME
    disp(' ')
end
end
