function [sqw_obj,al_info] = apply_alignment(filename,varargin)
%APPLY_ALIGNMEMT Utility takes aligned file and apply alignment information
%stored in it to pixels and image so the object becomes realigned as from
% the beginning and the aligment information is not necessary any more.
%
% Input:
% filename -- name of sqw file to apply alignment on or loader for this
%             file
% Optional:
% '-keep_original' -- store result in different file. By default, original
%                     file is aligned and overwritten
%Returns:
% al_data -- crystal_alignment_info class instance describing the alignmnet
%            (reverse) applies to the object.
%            empty if no alignment was identified/applied

[ok,mess,keep_original] = parse_char_options(varargin,{'-keep_original'});
if ~ok
    error('HORACE:algorithms:invalid_argument',mess)
end
%
if isa(filename,'horace_binfile_interface')
    ld = filename;
else
    ld = sqw_formats_factory.instance().get_loader(filename);
end
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
[sqw_obj,al_info] = sqw_obj.apply_alignment(keep_original);

