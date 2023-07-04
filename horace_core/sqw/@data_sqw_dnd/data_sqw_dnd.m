classdef data_sqw_dnd < DnDBase
    % Transient class used as part of sqw object in the Horace, version < 4.0
    % and kept for loading data from old format .mat files.
    %
    % Do not use in any new development
    properties(Dependent)
        pix;

        % The pixels are rebinned on this grid
        img_db_range;
    end
    properties(Dependent,Hidden=true)
        %
        NUM_DIMS;
    end

    properties
        %
        % returns number of pixels, stored within the PixelData class
        num_pixels
    end
    properties(Constant,Access=private)
        fields_to_save_here_ = {'pix'};
    end
    properties(Access=protected)
        pix_ = PixelDataBase.create()      % Object containing data for each pixel
    end
    %
    methods
        function flds = saveableFields(obj)
            % get independent fields, which fully define the state of a
            % serializable object.
            flds = saveableFields@DnDBase(obj);
            flds = [flds(:);data_sqw_dnd.fields_to_save_here_(:)];
        end
        function ver  = classVersion(~)
            ver = 4;
        end
        %------------------------------------------------------------------
        function obj = data_sqw_dnd(varargin)
            % constructor || copy-constructor:
            % Builds valid data_sqw_dnd object from various data structures.
			% 
			% Legacy constructor. Used for loading old data only. Do not use for anything else.


            obj = obj@DnDBase();
            if nargin>0
                obj = obj.init(varargin{:});
            end
        end
        %
        function obj = init(obj,varargin)
            if isa(varargin{1},'data_sqw_dnd') % handle shallow copy constructor
                obj =varargin{1};              % its COW for MATLAB anyway
            elseif nargin==2 && isstruct(varargin{1})
                % old interface compatibility
                struc = varargin{1};
                if isfield(struc,'ulabel')
                    struc.label = struc.ulabel;
                    struc = rmfield(struc,'ulabel');
                end
                obj = from_bare_struct(obj,struc);
            else
                obj = init@DnDBase(obj,varargin{:});
            end
        end
        %
        function isit=dnd_type(obj)
            if isempty(obj.pix) || isempty(obj.img_db_range)
                isit = true;
            else
                isit = false;
            end
        end
        %
        %TODO: Is it still needed? Remove after refactoring
        function type= data_type(obj)
            % compatibility function
            %   data   Output data structure which must contain the fields listed below
            %          type 'b+'   fields: uoffset,...,s,e,npix
            %          [The following other valid structures are not created by this function
            %          type 'b'    fields: uoffset,...,s,e
            %          type 'a'    uoffset,...,s,e,npix,img_db_range,pix
            %          type 'a-'   uoffset,...,s,e,npix,img_db_range
            if isempty(obj.npix)
                type = 'b';
            else
                type = 'b+';
                if ~isempty(obj.img_db_range)
                    type = 'a-';
                end
                if ~isempty(obj.pix)
                    type = 'a';
                end
            end
        end

        function dnd_struct=get_dnd_data(obj,varargin)
            %function retrieves dnd structure from the sqw_dnd_data class
            % if additional argument provided (+), the resulting structure  also includes
            % img_db_range.
            dnd_struct = obj.get_dnd_data_(varargin{:});
        end
        %

        function pix = get.pix(obj)
            pix = obj.pix_;
        end
        function obj = set.pix(obj,val)
            if isa(val, 'PixelDataBase') || isa(val,'pix_combine_info')
                obj.pix_ = val;
            else
                obj.pix_ = PixelDataBase.create(val);
            end
        end

        %
        function [type,obj]=check_sqw_data(obj, type_in, varargin)
            % old style validator for consistency of input data.
            %
            % only 'a' and 'b+' types are possible as inputs and outputs
            % varargin may contain 'field_names_only' which in fact
            % disables validation
            %
            [type,obj]=check_sqw_data_(obj,type_in);
        end
        %
        function npix= get.num_pixels(obj)
            if isa(obj.pix, 'PixelDataBase')
                npix = obj.pix.num_pixels;
            else
                npix  = [];
            end
        end
        %
        %
        function rng = get.img_db_range(obj)
            rng = obj.img_range;
        end
        function obj = set.img_db_range(obj,val)
            % this property should not be used, as the change of this
            % property on defined object would involve whole pixels
            % rebinning.
            % TODO: remove this property setter or enable rebinning algorithm
            % on its change
            %warning('HORACE:data_sqw_dnd:runtime_error',...
            %    'using redundant property img_db_range. Use set/get.img_range instead')
            obj.img_range = val;
        end
        function nd = get.NUM_DIMS(obj)
            nd =obj.axes_.dimensions();
        end
        function [nd,sz] = dimensions(obj)
            nd =obj.axes_.dimensions();
            sz = obj.axes_.data_nbins;
        end
    end
    methods(Access=protected)
        function obj = from_old_struct(obj,inputs)
            % restore object from the old structure, which describes the
            % previous version of the object.
            %
            % The method is called by loadobj in the case if the input
            % structure does not contain version or the version, stored
            % in the structure does not correspond to the current version
            %
            obj = from_old_struct@DnDBase(obj,inputs);

        end
    end
    methods(Static)
        %
        function obj = loadobj(S)
            % boilerplate loadobj method, calling generic method of
            % saveable class
            obj = data_sqw_dnd();
            obj = loadobj@serializable(S,obj);
        end
    end
end
