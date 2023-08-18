function [obj_out,al_info] = apply_alignment(obj,keep_original)
%APPLY_ALIGNMEMT Method takes realigned sqw object and applies the
% alignment info stored in this object
% to pixels and image so the object becomes realigned as from
% the beginning and the aligment information is not necessary any more
%
% Input:
% obj -- the realigned sqw object
% Optional
% al_info   -- crystal_alignment_info object, containing lattice, which
%              should replace current lattice. Rotation matrix, stored in
%              al_info class, will be ignored
%
if ~obj.pix.is_misaligned % nothing to do
    return
end
if nargin == 1
    keep_original = false;
end
rotmat  = obj.pix.alignment_matr;
rotvec  = rotmat_to_rotvec2(rotmat');
alatt   = obj.data.proj.alatt;
angdeg  = obj.data.proj.angdeg;
al_info = crystal_alignment_info(alatt,angdeg,rotvec);


obj.data.proj.proj_aligned  = false;
if obj.pix.is_filebacked
    new_file = get_tmp_filename(obj.pix.full_filename);
else
    new_file  = [];
end
obj = obj.get_new_handle(new_file);
pix = obj.pix.apply_alignment();
obj.pix = pix;
if ~isempty(new_file)
    if keep_original
        obj_out = obj;
    else

    end

else
    obj_out = obj;
end





function fn_out = get_tmp_filename(orig_fn)
[fp,fn,fe] = fileparts(orig_fn);
fn_out = fullfile(fp,[fn,'_aligned',fe]);
if ~isfile(fn_out)
    return;
end
for i=1:100
    fname = sprintf('%s_aligned_%d%s',fn,i,fe);
    fn_out = fullfile(fp,fname);
    if ~isfile(fn_out)
        return;
    end
end
error('HORACE:apply_alignment:runtime_error', ...
    'Can not find temporarty filename in the form %s_aligned_<Num>.%s for Num from 1 to 100 in the folder %s',...
    fn,fe,fp);

