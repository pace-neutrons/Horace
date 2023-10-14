classdef TmpFileHandler < handle
    % Class to handle temporary PixelDataFileBacked files produced in
    % filebacked operations.
    %
    % Upon deletion of the parent PixelDataFileBacked this object will be cleared
    % resulting in the deletion of the temporary files if they have not
    % been saved in different place or lock has been set to true.
    %
    % File path is structured so as to reflect the file origin but be unlikely to
    % conflict with other temporary files from the same origin and also to avoid
    % name explosions should temporaries of temporaries be created.
    %
    % Temporary filepath will be located in the Horace tmp_dir
    properties
        file_name;
    end
    methods
        function obj = TmpFileHandler(source_name,use_name_provided)
            % Constructor for temporary file handler.
            % Inputs:
            % source_name - the base for the name to build temporary
            %               file name. The actual name would have random
            %               extension in the form source_name.tmp_xxxxx
            %               where xxxxx represent 12 random lower case
            %               characters.
            % Optional:
            % use_name_provided
            %             - if present and true, do not generate the
            %               temporary name but build Handler for the name,
            %               provided as input.
            if nargin<2
                use_name_provided = false;
            end
            if use_name_provided
                obj.file_name = source_name;
            else
                obj.file_name = build_tmp_file_name(source_name);
            end
        end
        function delete(obj)
            del_memmapfile_files(obj.file_name);
        end
    end
end
