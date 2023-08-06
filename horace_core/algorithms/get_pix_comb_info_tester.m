function [data_sum,img_range,job_disp]=get_pix_comb_info_tester(infiles)
% public interface to get_pix_comb_info_ routine, used by write_nsq_to_sqw
% routine and exposed for testing purposes
%
data_range = PixelDataBase.EMPTY_RANGE;
[data_sum,img_range,job_disp]=get_pix_comb_info_(infiles,data_range,[], ...
                                                 true,false);

end
