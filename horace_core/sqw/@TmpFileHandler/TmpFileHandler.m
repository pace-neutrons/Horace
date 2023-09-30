classdef TmpFileHandler < handle
    % Class to handle temporary PixelDataFileBacked files
    %
    % Created by PixelData file-backed on starting modifying operation
    % (PixelDataFileBacked.get_new_handle), which stores the path tmp_file
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
        ref_count;
        locked;
    end
    properties(Access=private)
        ref_count_ = 0;
        locked_ = false;
    end
    methods
        function obj = TmpFileHandler(orig_name)
            [~, name] = fileparts(orig_name);

            for i = 1:5
                obj.file_name = fullfile(tmp_dir(), ...
                    [name, '.tmp_', str_random()]);
                if ~is_file(obj.file_name)
                    break
                end
            end
            % Unlikely to happen, but best to check fail to generate
            if i == 5 && is_file(obj.file_name)
                error('HORACE:TmpFileHandler:runtime_error', ...
                    ['Can not generate available tmp file name for %s. \n\n', ...
                    'Check %s and clear any .pix_<id> files'], ...
                    orig_name, tmp_dir());
            end
            obj.ref_count_ = 1;
        end

        function delete(obj)
            obj.ref_count_ = obj.ref_count_ - 1;
            if obj.locked_
                return;
            end
            fn = obj.file_name;
            if ~isempty(fn) && is_file(fn)
                ws = warning('off','MATLAB:DELETE:Permission');
                delete(fn);
                if isfile(fn) % deleteon for files accessed trough matlab
                    % memmapfile. Windows bug?
                    if ispc()
                        system(sprintf('del %s',fn));
                    else
                        system(sprintf('rm %s',fn));
                    end
                end
                warning(ws);

            end
        end
        %==================================================================
        function rc = get.ref_count(obj)
            rc = obj.ref_count_;
        end
        function copy(obj)
            obj.ref_count_ = obj.ref_count_+1;
        end
        function is = get.locked(obj)
            is = obj.locked_;
        end
        function set.locked(obj,val)
            obj.locked_ = logical(val);
        end
    end
end
