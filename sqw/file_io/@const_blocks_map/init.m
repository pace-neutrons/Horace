function  obj = init(obj,pos_info)
% Calculate the byte-sizes and positions of constant blocks for upgrading data on hdd

bsm = init_map_(obj,pos_info);
if isfield(pos_info,'num_contrib_files_') % sqw file may have multiple headers
    if pos_info.num_contrib_files_ > 1
        val = [bsm('$n_header'),bsm('$0_header')];
        bsm('header') = val;
    else
        bsm('header') = bsm('$0_header');
        
    end
    bsm = remove(bsm,{'$0_header','$n_header'});
end 

obj.cblocks_map_ = bsm;
