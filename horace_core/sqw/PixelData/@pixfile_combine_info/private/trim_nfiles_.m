function obj=trim_nfiles_(obj,nfiles_to_leave)
% Constrain the number of files and the file information,
% contained in class by the number of files (nfiles_to_leave) provided.
%
% Checks if pixel info in all remaining files remains consistent;
%
%Usage:
%>>obj = obj.trim_nfiles(nfiles_to_leave)
%
% reduces the info stored in the file corresponding to the
% number of files provided
%
if nfiles_to_leave >= obj.nfiles
    return;
end
obj.do_check_combo_arg = false;
obj.infiles = obj.infiles(1:nfiles_to_leave);
%
obj.pos_npixstart = obj.pos_npixstart(1:nfiles_to_leave);
% array of starting positions of the pix information in each
% contributing file
obj.pos_pixstart = obj.pos_pixstart(1:nfiles_to_leave);
obj.npix_each_file= obj.npix_each_file(1:nfiles_to_leave);

obj.num_pixels_ = uint64(sum(obj.npix_each_file));
if ~isempty(obj.filenum_)
    obj.filenum_ = obj.filenum_(1:nfiles_to_leave);
end
obj.do_check_combo_arg = true;
obj = obj.check_combo_arg();
