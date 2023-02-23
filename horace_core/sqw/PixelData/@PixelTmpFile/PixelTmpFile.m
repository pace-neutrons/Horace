classdef PixelTmpFile < handle
% Class to handle deletion of TmpFile on closure
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
            if is_file(obj.file_name)
                delete(obj.file_name);
            end
            if is_file(obj.tmp_name)
                delete(obj.tmp_name);
            end
        end

    end

end
