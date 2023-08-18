function [sqw_obj,al_info] = apply_alignment(filename,varargin)
%APPLY_ALIGNMEMT Utility takes aligned file and apply alignment information
%stored in it to pixels and image so the object becomes realigned as from
% the beginning and the aligment information is not necessary any more.
%
% Input:
% filename -- name of sqw file to apply alignment on
% Optional:
% '-keep_original' -- store result in different file. By default, original
%                     file is aligned and overwritten
%Returns:
% al_data -- crystal_alignment_info class instance describing the alignmnet
%            (reverse) applies to the object.
%            empty if no alignment was identified/applied

[ok,mess,keep_original] = parse_char_options(varargin,{'-keeep_original'});
if ~ok
    error('HORACE:algorithms:invalid_argument',mess)
end


ld = sqw_formats_factory.instance().get_loader(filename);
if ~ld.sqw_type % can not realign dnd object
    al_info = [];
    return;
end
pmd = ld.get_pix_metadata();
if ~pmd.is_misaligned % nothing to do
    al_info = [];
    ld.delete();
    return;
end

sqw_obj = sqw(ld);

new_file = get_tmp_filename(filename);
sqw_obj = sqw_obj.get_new_handle(new_file);
[sqw_obj,al_info] = sqw_obj.apply_alignment();


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

