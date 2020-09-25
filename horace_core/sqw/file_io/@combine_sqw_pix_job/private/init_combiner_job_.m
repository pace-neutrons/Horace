function obj = init_combiner_job_(obj)
% process job inputs and return initial information for combiner job
%

obj.pix_cache_ = pix_cache(...
        obj.mess_framework.numLabs-obj.reader_id_shift_,...
        obj.common_data_.nbin);


