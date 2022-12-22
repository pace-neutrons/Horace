classdef binfile_v4_block_tester < serializable
    % Class used to test common operations on block allocation table and 
    % faccess_v4_common classes.
    % 
    % Its main purpose to be the source of the blocks with variable, 
    % defined for testing purposes size.
    properties
        num_data_in_blocks = 10;
        block_filler = 'a';
    end
    properties(Dependent)
        level2_a;
        level2_b;
        level2_c;
        data;
    end
    properties(Access=protected)
        level2_a_;
        level2_b_;
        level2_c_;
        data_;
    end


    methods
        function obj = binfile_v4_block_tester(varargin)
            flds = obj.saveableFields();
            [obj,remains] = obj.set_positional_and_key_val_arguments(...
                flds,false,varargin{:});
            if ~isempty(remains)
                error('HORACE:binfile_v4_block_tester:invalid_argument',...
                    ' Class constructor has been invoked with non-recognized parameters: %s',...
                    disp2str(remains));
            end
        end
        function db = get.data(obj)
            dnd =  dnd_data( ...
                ones(obj.num_data_in_blocks,1), ...
                2*ones(obj.num_data_in_blocks,1), ...
                4*ones(obj.num_data_in_blocks,1));
            db = struct('nd_data',dnd);
        end
        function obj = set.data(obj,val)
            if isstruct(val) && isfield(val,'nd_data')
                val = val.nd_data;
            end
            if ~isa(val,'dnd_data')
                error('HORACE:binfile_v4_block_tester:invalid_argument', ...
                    'this property accepts only dnd_data block')
            end
            obj.num_data_in_blocks = numel(val.sig);
        end

        function a = get.level2_a(obj)
            if isempty(obj.level2_a_)
                a = repmat(obj.block_filler,obj.num_data_in_blocks,1);
            else
                a = obj.level2_a_;
            end
        end
        function obj = set.level2_a(obj,val)
            obj.level2_a_ = val;
        end
        function b = get.level2_b(obj)
            if isempty(obj.level2_b_)
                b = repmat(obj.block_filler,2*obj.num_data_in_blocks,1);
            else
                b = obj.level2_b_;
            end
        end
        function obj = set.level2_b(obj,val)
            obj.level2_b_ = val;
        end
        function c = get.level2_c(obj)
            if isempty(obj.level2_c_)
                c = repmat(obj.block_filler,3*obj.num_data_in_blocks,1);
            else
                c = obj.level2_c_;
            end
        end
        function obj = set.level2_c(obj,val)
            obj.level2_c_ = val;
        end

        function [nd,b_size] = dimensions(obj)
            % this is common sqw interface used in preparing the sqw file
            % header
            b_size = size(obj.data.nd_data.sig);
            nd = numel(b_size);
            if nd == 2 && any(b_size==1)
                nd = 1;
            end
        end
    end
    % SERIALIZABLE INTERFACE
    methods
        function  ver  = classVersion(~)
            % serializable fields version
            ver = 1;
        end
        function flds = saveableFields(~)
            flds = {'num_data_in_blocks';'block_filler'};
        end
        %------------------------------------------------------------------
    end

end