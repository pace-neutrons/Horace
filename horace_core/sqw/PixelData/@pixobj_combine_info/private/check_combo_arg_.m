function obj = check_combo_arg_(obj)
%CHECK_COMBO_ARG_ validate consistency of cellarray of pixels data and
% cellarray of distributions, describing these pixels
if isempty(obj.npix_list_) && ~isempty(obj.infiles_)
    obj.do_check_combo_arg_ = false; % avoid calling this routine recursively
    obj.npix_list = num2cell(obj.npix_each_file_);
    obj.do_check_combo_arg_ = true;    
end

if numel(obj.npix_list_) == 1
    obj.npix_list_ = repmat(obj.npix_list_,obj.nfiles,1);
end
if numel(obj.infiles_) ~= numel(obj.npix_list_)
    error('HORACE:pixobj_combine_info:invalid_argument',...
        'number of input objects: %d not equal to the number of their distributions: %d',...
        numel(obj.pos_npixstart_),numel(obj.infiles_));
end
npix_desc = cellfun(@(x)sum(x(:)),obj.npix_list_);
if any(npix_desc(:) ~= obj.npix_each_file_(:))
    error('HORACE:pixobj_combine_info:invalid_argument',...
        'Some npix distributions do not have number of elements equal to number of pixels they describe')
end

