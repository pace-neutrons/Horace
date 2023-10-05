function obj = recompute_bin_data(obj,out_file)
% Given sqw_type object, recompute w.data.s and w.data.e from the contents
% of pix array
%
% Also recaclulates pixels data_range and applies alignment to pixels if 
% initial pixels are misaligned.
%
%
% Usage:
% >> wout=recompute_bin_data(w)
% >> wout=recompute_bin_data(w,result_filename)
%
% Optional argument: (Affects mainly filebacked objects)
%
% out_file -- if provided for operation over filebacked object,
%             resulting filebacked object will be constructed around
%             file with the filename provided.
%
%             If not, original file will be modified
% Note:
% Filebacked operations are often slow and provided over copy of the original
% file, build step/by step 
%
if ~has_pixels(obj)
    return;
end


% needs the opportunity to provide outfile if sqw object is filebacked
pix_op = PageOp_nochange();
if obj.pix.is_misaligned

end
[pix_op,obj] = pix_op.init(obj);
obj    = obj.apply_c(pix_op);
