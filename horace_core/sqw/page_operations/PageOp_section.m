classdef PageOp_section < PageOpBase
    % Single pixel page operation used by section algorithm
    %
    properties
        new_img  % new image was precacluated before
        block_starts_
        block_sizes_
        block_chunks_;
    end
    methods
        function obj = PageOp_section(varargin)
            obj = obj@PageOpBase(varargin{:});
            obj.op_name_ = 'section';
        end
        function obj = init(obj,sqw_obj,new_img)
            obj           = init@PageOpBase(obj,sqw_obj);
            %
            obj.new_img  = new_img;
            new_axis     = new_img.axes;
            % Identify what parts of old image contributed into new image
            proj = sqw_obj.data.proj;            
            [obj.block_starts_,obj.block_sizes_] = proj.get_nrange(...
                obj.img_.npix, ...
                obj.img_.axes, ...
                new_axis,proj);
            obj.block_chunks_ = {obj.block_starts_;obj.block_sizes_};
            % assign new image as final image
            obj.img_ = new_img;            

        end
        function obj = get_page_data(obj,idx,varargin)
            % return block of data used in page operation
            %
            % Overload specific for section. It takes various pieces of
            % pixel data.
            bl_start   = obj.block_chunks_{idx};
            if iscell(bl_start)
                bl_size    = bl_start{2};
                bl_start   = bl_start{1};
            else
                bl_size    = obj.block_chunks_{2};
            end
            ind = get_ind_from_ranges(bl_start, bl_size);
            obj.page_data_ = obj.pix_.get_pixels(ind ,'-raw');
        end

        function [npix_chunks, npix_idx,obj] = split_into_pages(obj,~,chunk_size)
            % Method used to split input npix array into pages
            % Inputs:
            % obj   -- initialized PageOp_section object containing obj.block_chunks_
            %          which contribute to section
            % chunk_size
            %       -- sized of chunks to split pixels
            % Returns:
            % npix_chunks -- cellarray, containing the npix parts
            %
            % See split procedure for more details
            npix_chunks = split_data_blocks(obj.block_starts_,obj.block_sizes_, chunk_size);
            npix_idx = ones(2,numel(npix_chunks));
            obj.block_chunks_ = npix_chunks;
        end

        function obj = apply_op(obj,varargin)
            % it acually does notning here. selected pixels blocks are
            %  transferred to target without modifications
        end
        function [out_obj,obj] = finish_op(obj,out_obj)
            % transfer modifications to the target object
            [out_obj,obj] = finish_op@PageOpBase(obj,out_obj);
        end
    end
end