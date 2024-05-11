function [sqw_obj,al_info] = finalize_alignment(filename,varargin)
%FINALIZE_ALIGNMEMT Utility takes aligned file and apply alignment information
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
% sqw_obj -- sqw object with information, changed according to alignment.
%            If file is big enough, sqw_obj will be filebacked.
% al_data -- crystal_alignment_info class instance describing the alignment
%            (reverse) applies to the object.
%            empty if no alignment was identified/applied
%

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
if ~pmd.is_misaligned && pmd.is_range_valid % nothing to do
    al_info = [];
    ld.delete();
    return;
end

sqw_obj = sqw(ld);
if keep_original
    % for filebacked, will create temporary object
    argi = {};
else
    % will replace original
    argi = {ld.full_filename};
end
[sqw_obj,al_info] = sqw_obj.finalize_alignment(argi{:});
% TODO: Re #1320 -- add save(obj, file, '-no_update') if called without
% output arguments
