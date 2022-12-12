classdef dnd_metadata < serializable
    %DND_METADATA The class describes DND object image and
    %contains all information, describing this image.
    %
    % The purpose of this class is storing/restoring DnD object metadata
    % into custom bindary file.
    %
    properties(Dependent)
        dimensions;
        axes;
        proj;
        creation_date_str;
        creation_date_defined
    end
    properties(Access=protected)
        axes_;
        proj_;
        creation_date_;
        creation_date_defined_ = false;
    end


    methods
        function obj = dnd_metadata(varargin)
            %DND_METADATA Construct an instance of metadata class
            %
            % the dnd_metadata class can be constructed only from DnD type
            % object
            if nargin == 0
                return;
            end
            dnd_obj = varargin{1};
            if isa(dnd_obj,'DnDBase')
                obj.axes = dnd_obj.axes;
                obj.proj = dnd_obj.proj;
                if dnd_obj.creation_date_defined
                    obj.creation_date_str = dnd_obj.creation_date;
                end
            else
                flds = obj.saveableFields();
                [obj,remains] = obj.set_positional_and_key_val_arguments(...
                    flds,false,varargin{:});
                if ~isempty(remains)
                    error('HORACE:dnd_metadata:invalid_argument',...
                        ' Class constructor has been invoked with non-recognized parameters: %s',...
                        disp2str(remains));
                end
            end
        end
        %------------------------------------------------------------------
        function nd = get.dimensions(obj)
            if isempty(obj.axes_)
                nd = [];
                return
            end
            nd = obj.axes_.dimensions;
        end
        function ab = get.axes(obj)
            ab = obj.axes_;
        end
        function pr = get.proj(obj)
            pr = obj.proj_;
        end
        function cd = get.creation_date_str(obj)
            if obj.creation_date_defined_
                cd_dt = obj.creation_date_;
                cd = main_header_cl.convert_datetime_to_str(cd_dt);
            else
                cd = '';
                return;
            end

        end
        function def = get.creation_date_defined(obj)
            def = obj.creation_date_defined_;
        end
        %------------------------------------------------------------------
        function obj = set.axes(obj,val)
            if ~isa(val,'axes_block')
                error('HORACE:dnd_metadata:invalid_argument', ...
                    'you can set axes using an instance of axes_block class only. Input class is: %s', ...
                    class(val));
            end
            obj.axes_ = val;
        end
        function obj = set.proj(obj,val)
            if ~isa(val,'aProjection')
                error('HORACE:dnd_metadata:invalid_argument', ...
                    'you can set proj using an instance of aProjection class only. Input class is: %s', ...
                    class(val));
            end
            obj.proj_ = val;
        end
        function obj = set.creation_date_str(obj,val)
            if isempty(val)
                obj.creation_date_  = '';
                obj.creation_date_defined_ = false;
            else
                obj.creation_date_ = main_header_cl.check_datetime_valid(val);
                obj.creation_date_defined_ = true;
            end
        end
    end
    %======================================================================
    % SERIALIZABLE INTERFACE
    methods
        function S = saveobj(obj)
            if ~obj.creation_date_defined_
                obj.creation_date_ = datetime('now');
                obj.creation_date_defined_ = true;
            end
            S = saveobj@serializable(obj);
        end
        function ver  = classVersion(~)
            ver = 1;
        end
        function flds = saveableFields(~)
            % Return cellarray of public property names, which fully define
            % the state of a serializable object, so when the field values are
            % provided, the object can be fully restored from these values.
            %
            flds = {'axes','proj','creation_date_str'};
        end
    end
end