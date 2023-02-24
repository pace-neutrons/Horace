classdef PixelTmpFile < handle
% Class temporary PixelDataFileBacked files
%
% Created by PixelData file-backed on starting modifying operation
% (PixelDataFileBacked.get_new_handle) stores the path for the short-term
% tmp_file (while operation is taking place) and path for the long-term tmp_file
% (to be referenced by the PixelDataFileBacked object when the operation is
% complete)
%
% Upon deletion of the parent PixelDataFileBacked this object will be cleared
% resulting in the deletion of the temporary files if they have not
% been saved.
%
% File path is structured so as to reflect the file origin but be unlikely to
% conflict with other temporary files from the same origin and also to avoid
% name explosions should temporaries of temporaries be created.
%
% Temporary filepath will be located in the Horace tmp_dir
    properties
        file_name;
    end

    properties(Dependent)
        tmp_name;
    end

    methods
        function obj = PixelTmpFile(orig_name)
            [~, name] = fileparts(orig_name);

            for i = 1:5
                obj.file_name = fullfile(tmp_dir(), ...
                                             [name, '.pix_', str_random()]);
                if ~is_file(obj.file_name) && ~is_file(obj.tmp_name)
                    break
                end
            end
            % Unlikely to happen, but best to check fail to generate
            if i == 5 && (is_file(obj.file_name) || is_file(obj.tmp_name))
                error('HORACE:PixelDataFileBacked:runtime_error', ...
                      ['Can not generate available tmp file name for file-backed pixels. \n\n', ...
                       'Check %s and clear any .pix_<id>[_tmp] files'], ...
                      tmp_dir());
            end

        end

        function tmp_file_name = get.tmp_name(obj)
            tmp_file_name = [obj.file_name '_tmp'];
        end

        function obj = delete(obj)
            ["deleting ", obj.file_name]
            if is_file(obj.file_name)
                delete(obj.file_name);
            end
            if is_file(obj.tmp_name)
                delete(obj.tmp_name);
            end
        end

    end

end
