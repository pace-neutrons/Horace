classdef fcloser < handle
    % class-helper to close opened file on request by calling delete
    % operation explicitly or automatically, when the object goes out of
    % scope.
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
            if nargin==0
                obj.file_handle = [];
                return;
            end

            fn = fopen(fh);
            if isempty(fn)
                error('HORACE:utilities:invalid_argument', ...
                    ['FCLOSER need open file handle for its construction.' ...
                    ' file-handle: %d is not resonsible for any open file'], ...
                    fh)
            end
            obj.file_handle = fh;
        end
        function is = isempty(obj)
            is = ~isvalid(obj) || isempty(obj.file_handle);
        end

        function delete(obj)
            if isempty(obj.file_handle)
                return;
            end
            fn = fopen(obj.file_handle);
            if ~isempty(fn)
                fclose(obj.file_handle);
            end
            obj.file_handle = [];
        end
    end
end