function [sqw_type_obj,npix] = fake_pixels(dnd_type_obj,run_ind)
% create pixels of sqw object from a dnd object
% so that signal and error of the sqw object image (calculated from pixels)
% are equivalent to the original dnd object data
%
% The signal moved to pixels and npix of the modified object is set to 1
%
% Temporary function-fix for rel_3_5. Should be moved to appropriate 
% location and may be modified further for new sqw object.
if nargin<2
    run_ind = 1;
end


qw = calculate_qw_bins(dnd_type_obj);
qw = [qw{:}]';
s  = reshape(dnd_type_obj.data.s,1,numel(dnd_type_obj.data.s));
e  = reshape(dnd_type_obj.data.e,1,numel(dnd_type_obj.data.e));
npix = dnd_type_obj.data.npix;
[~,~,en_index] = unique(qw(4,:));
det_index = 1:size(qw,2);% completely incorrect. Single run number of pixels is ndet x n_en_index. 
run_index = run_ind*ones(1,size(qw,2)); 
zer_npix = npix(:)==0;
s(zer_npix)=0;
e(zer_npix)=0;

sqw_type_obj = dnd_type_obj;
sqw_type_obj.data.pix = PixelData([qw;run_index;det_index;en_index';s;e]);
sqw_type_obj.data.npix(npix>0)=1;


