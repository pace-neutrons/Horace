function [pix,pix_range,clOb] = get_pix_with_fake_faccess(data, npix_in_page)
% helper function generating pixel data with fake fileaccess
clobW = set_temporary_warning('off', 'HOR_CONFIG:set_mem_chunk_size');
clOb = set_temporary_config_options(hor_config(),'mem_chunk_size',npix_in_page);
pix = PixelDataFileBacked(data);
pix_range = [min(data(1:4,:),[],2),max(data(1:4,:),[],2)]';
end
