classdef fcloser < handle
    % class-helper to close opened file on request
    %

    properties
        file_handle
    end

    methods
        function obj = fcloser(fh)
            %FCLOSER Construct an instance of this class providing opened
            %file handle.
            %
            % when file goes out of scope, handle will get deleted
            fn = fopen(fh);
            if isempty(fn)
                error('HORACE:utilities:invalid_argument', ...
                    'FCLOSER need open file handle for its construction')
            end
            obj.file_handle = fh;
        end

        function delete(obj)
            fn = fopen(obj.file_handle);
            if ~isempty(fn)
                fclose(obj.file_handle);
            end
        end
    end
end