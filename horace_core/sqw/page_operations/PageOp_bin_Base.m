classdef PageOp_bin_Base < PageOpBase
    % Single page pixel operation used by
    % binary operation manager and applied to two sqw objects and
    % number or array of numbers with size 1, numel(npix) or
    % PixelData.n_pixels
    %
    %
    properties
        % property contains handle to function, which defines binary operation
        op_handle;
        % contains second operand of the binary operation
        operand;
        flip   % if true, actual operation is performed between w2 and w1
        % objects instead of w1,  w2 as defined by input order of the init
        % function.
    end
    properties(Access = protected)
        % location of fields, containing all indices defining neutron event
        all_idx_
        % indices of signal and variance fields in pixels
        sigvar_idx_
        % Preallocate two operands, participating in operation
        sigvar1 = sigvar();
        sigvar2 = sigvar();
    end

    methods
        function obj = PageOp_bin_Base(varargin)
            obj = obj@PageOpBase(varargin{:});
            obj.sigvar_idx_ = PixelDataBase.field_index('sig_var');
            obj.all_idx_ = PixelDataBase.field_index('all_indexes');

            obj.split_at_bin_edges = true;
        end
        function [obj,name1_obj] = init(obj,w1,operand,operation,flip,npix)
            obj = init@PageOpBase(obj,w1);
            if nargin<5
                flip = false;
            end

            obj.op_handle = operation;
            obj.operand   = operand;
            obj.flip      = flip;
            if isempty(obj.img_)
                name1_obj = 'pix'; % this is for pix-pix operations
            else
                name1_obj = 'sqw';
            end

            if nargin>5 && ~isempty(npix)
                if obj.pix_.num_pixels ~= sum(npix(:))
                    error('HORACE:PageOp_bin_Base:invalid_argument',[ ...
                        'Number of pixels of the first operand (%d) inconsistent ' ...
                        'with their bin-distribution, provided as #5-th argument npix (%d)'], ...
                        obj.pix_.num_pixels,sum(npix(:)));
                end
                obj.npix = npix(:);
            end
            if ~obj.changes_pix_only
                obj.var_acc_ = zeros(numel(obj.npix),1);
            end
            obj.pix_idx_start_ = 1;
        end
        function [obj,pix_idx] = get_page_data(obj,idx,npix_blocks)
            % retrieve block of data used in page operation
            %
            % Overloaded for dealing with two PixelData objects so returns
            % indices of the first data object

            npix_block = npix_blocks{idx};
            npix = sum(npix_block(:));
            pix_idx_end = obj.pix_idx_start_+npix-1;

            pix_idx = obj.pix_idx_start_:pix_idx_end;
            obj.page_data_ = obj.pix_.get_pixels(pix_idx,'-raw');

            obj.pix_idx_start_ = pix_idx_end+1;
        end

        %
        function obj = set_op_name(obj,obj1_name,obj2_name)
            % Define the name of the binary operation from the class of the
            % participating objects and the name of the operation
            if obj.flip
                name1 = obj2_name;
                name2 = obj1_name;
            else
                name1 = obj1_name;
                name2 = obj2_name;
            end
            obj.op_name_ = ...
                sprintf('binary op: %s between %s and %s', ...
                func2str(obj.op_handle),name1,name2);
        end
    end
end