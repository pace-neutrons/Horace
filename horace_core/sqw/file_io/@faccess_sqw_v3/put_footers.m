function obj = put_footers(obj)
%PUT_FOOTERS Write SQW footers (including instrument records) to file.
%
obj = put_sample_instr_records_(obj);
% should not be necessary, as init calculated it correctly, but to be on a
% safe side...
obj.position_info_pos_= obj.instr_sample_end_pos_;
obj = obj.put_sqw_footer();
