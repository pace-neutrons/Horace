classdef faccess_sqw_hdf < sqw_file_interface

    methods
        function faccess_sqw_hdf(obj, h5file)
            obj.filename = h5file
        end

        function [exper,pos] = get_exp_info(obj,varargin)

        end

        function detpar = get_detpar(obj,varargin)

        end

        function [inst,obj] = get_instrument(obj,varargin)

        end

        function [samp,obj] = get_sample(obj,varargin)

        end

        function pix = get_pix(obj,varargin)

        end

        function pix = get_raw_pix(obj,varargin)

        end

        function pix = get_pix_at_indices(obj,indices)

        end

        function pix = get_pix_in_ranges(obj,pix_starts,pix_ends,skip_validation,keep_precision)

        end

        function range = get_pix_range(obj)

        end

        function [meta,obj] = get_pix_metadata(obj)

        end

        function [range,obj] = get_data_range(obj)

        end


        function npix = get_npixels(obj)
            npix = h5readatt(obj.filename, '/sqw/pix', 'num_pixels');
        end

        function ps = get_filepix_size(obj)
            ps = 8
        end
        %------------------------------------------------------------------
        % common write interface

        function obj = put_main_header(obj,varargin)

        end

        function obj = put_headers(obj,varargin)

        end

        function obj = put_det_info(obj,varargin)

        end

        function obj = put_pix(obj,varargin)

        end

        function obj = put_pix_metadata(obj,varargin)

        end

        function obj = put_raw_pix(obj,pix_data,pix_idx,varargin)

        end

        function obj = put_num_pixels(obj, num_pixels)

        end

        function obj = put_sqw(obj,varargin)

        end

        function obj = put_instruments(obj,varargin)

        end

        function obj = put_samples(obj,varargin)

        end


    end


end
