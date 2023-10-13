classdef fcloser < handle
    % class-helper to close opened file on request by calling delete
    % operation explicitly or automatically, when the object goes out of
    % scope.
    %
    properties
        io_handle
    end

    methods
        function obj = fcloser(fh)
            %FCLOSER Construct an instance of this class providing opened
            %file handle.
            %
            % when file goes out of scope, handle will get deleted
            if nargin==0
                obj.io_handle = [];
                return;
            end

            fn = fopen(fh);
            if isempty(fn)
                error('HORACE:utilities:invalid_argument', ...
                    ['FCLOSER need open file handle for its construction.' ...
                    ' file-handle: %d is not resonsible for any open file'], ...
                    fh)
            end
            obj.io_handle = fh;
        end
        function fclose(obj)
            fn = fopen(obj.io_handle);
            if ~isempty(fn)
                fclose(obj.io_handle);
            end
            obj.io_handle = [];
        end

        function is = isempty(obj)
            is = ~isvalid(obj) || isempty(obj.io_handle);
        end

        function delete(obj)
            if isempty(obj.io_handle)
                return;
            end
            obj.fclose();
        end
    end
end
