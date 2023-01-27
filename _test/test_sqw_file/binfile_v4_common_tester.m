classdef binfile_v4_common_tester < binfile_v4_common
    %   Detailed explanation goes here

    properties

    end

    methods
        function obj = binfile_v4_common_tester(varargin)
            obj = obj@binfile_v4_common();
            if nargin>0
                obj  = obj.init(varargin{:});
            end
        end
    end
    methods
        % ABSTRACT, but implemented for testing only
        %---------------------------------------------------------
        function [data,obj]  = get_data(obj,varargin)
            error('HORACE:binfile_v4_common_tester:not_inplemented', ...
                'this method is not implemented on the tester')
        end
        function [data_str,obj] = get_se_npix(obj,varargin)
            error('HORACE:binfile_v4_common_tester:not_inplemented', ...
                'this method is not implemented on the tester')
        end

        function [inst,obj]  = get_instrument(obj,varargin)
            error('HORACE:binfile_v4_common_tester:not_inplemented', ...
                'this method is not implemented on the tester')

        end
        function [samp,obj]  = get_sample(obj,varargin)
            error('HORACE:binfile_v4_common_tester:not_inplemented', ...
                'this method is not implemented on the tester')

        end
        function [sqw_obj,varargout] = get_sqw(obj,varargin)

            error('HORACE:binfile_v4_common_tester:not_inplemented', ...
                'this method is not implemented on the tester')

        end
        function [dnd_obj,varargout] = get_dnd(obj,varargin)
            error('HORACE:binfile_v4_common_tester:not_inplemented', ...
                'this method is not implemented on the tester')

        end
        % -----------------------------------------------------------------
        function pix_range = get_pix_range(obj)
            error('HORACE:binfile_v4_common_tester:not_inplemented', ...
                'this method is not implemented on the tester')
        end
        function img_db_range = get_img_db_range(obj)
            error('HORACE:binfile_v4_common_tester:not_inplemented', ...
                'this method is not implemented on the tester')
        end
        % ----------------------------------------------------------------
        function obj = put_sqw(obj,varargin)
            error('HORACE:binfile_v4_common_tester:not_inplemented', ...
                'this method is not implemented on the tester')

        end
        function obj = put_dnd(obj,varargin)
            error('HORACE:binfile_v4_common_tester:not_inplemented', ...
                'this method is not implemented on the tester')

        end
        function obj = put_dnd_metadata(obj,varargin)
            error('HORACE:binfile_v4_common_tester:not_inplemented', ...
                'this method is not implemented on the tester')
        end
        function obj = put_dnd_data(obj,varargin)
            error('HORACE:binfile_v4_common_tester:not_inplemented', ...
                'this method is not implemented on the tester')
        end
    end

    methods(Access=protected)
        function obj = do_class_dependent_updates(obj,varargin)
            error('HORACE:binfile_v4_common_tester:not_inplemented', ...
                'this method is not implemented on the tester')
        end
        
        function type =  get_data_type(~)
            type  = 'b';
        end
        function is_sqw = get_sqw_type(~)
            is_sqw = false;
        end
        function bll = get_data_blocks(obj)
            if ~isempty(obj.bat_) && obj.bat_.initialized
                bll = obj.bat_.blocks_list;
            else
                bll = {data_block('','level2_a'),...
                    data_block('','level2_b'),dnd_data_block(),data_block('','level2_c')};
            end
        end
    end
end

