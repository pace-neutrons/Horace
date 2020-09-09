classdef combine_sqw_job_tester < combine_sqw_pix_job
    % the class helper for combine_sqw_pix_job class, providing fake
    % read_pix method
    
    
    properties
        pix_combine_info;
        fid
    end
    methods
        function [obj,mess]=init(obj,fbMPI,intercom_class,InitMessage,is_tested)
            [obj,mess] = init@combine_sqw_pix_job(obj,fbMPI,intercom_class,InitMessage,is_tested);
            
            %obj.mess_framework_ = fake_mess_framework();
        end
        function px = get.pix_combine_info(obj)
            px = obj.pix_combine_info_;
        end
        function obj = set.pix_combine_info(obj,val)
            obj.pix_combine_info_ = val;
        end
        function fid = get.fid(obj)
            fid = obj.fid_;
        end
        function obj = set.fid(obj,val)
            obj.fid_ = val;
        end
        
        
    end
    
    methods(Static)
        function [pix_buffer,pos_pixstart] = read_pixels(fid,pos_pixstart,npix2read)
            pix_buffer = ones(9,npix2read)*pos_pixstart;
            if isnumeric(fid)
                pix_buffer(6,:) = fid;
            end
            pos_pixstart = pos_pixstart+npix2read;
        end
    end
end
