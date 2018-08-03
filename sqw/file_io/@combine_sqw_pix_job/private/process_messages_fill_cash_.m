function  [obj,pix_section] = process_messages_fill_cash_(obj,messages)
% processed the received messages, forms and returns combined data block to write and
% stores the pixels corresponding to not fully filled bins into the pixels
% cash.
%h_log = obj.h_log_file;
h_log = false;
obj.pix_cash_ = obj.pix_cash_.push_messages(messages,h_log);
[obj.pix_cash_,pix_section] = obj.pix_cash_.pop_pixels(h_log);

if h_log
    fprintf(h_log,' Saving n_pixels: %d\n',size(pix_section,2));
end

