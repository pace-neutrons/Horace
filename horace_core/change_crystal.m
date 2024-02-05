function out = change_crystal(in_data,alignment_info,varargin)
% Change the crystal lattice and orientation of sqw/dnd object or objects
% placed in various type of containers.
%
% Usage:
%   >>change_crystal (in_data, alignment_info,varargin);
%   >>out = change_crystal (in_data, alignment_info,varargin);
%
%
% Input:
% -----
%  in_data       --  Input sqw.dnd object, cellarray of sqw/dnd objects or
%                    filename or cellarray of filenames containing sqw/dnd
%                    objects.
%
% alignment_info -- crystal_alignment_info class helper containing all
%                   information about crystal realignment, produced by
%                   refine_crystal procedure.
%
%              do:
%              >> help refine_crystal
%              or
%              >> help crystal_alignment_info
%              for more details.
% Optional:
% '-dnd_only'   -- Align only dnd object, so will work on files
%                  or cellarray of objects contaning dnd objects only.
%                  Algorithm will fail if applied to .sqw files or cellarrays
%                  containing sqw objects.
% '-sqw_only'   -- align only sqw objects or files containing sqw objects.
%                  Throw error if dnd object (as member of cellarray) or
%                  dnd object in .sqw file is provided as input.
%
% Output:
% -------
%   out        Output sqw object with changed crystal lattice parameters and orientation
%              or cellarray contaning such objects.
%
% NOTE
%  The input data set(s) can be reset to their original orientation by inverting the
%  input data i.e. providing alignment_info with original alatt and angdeg
%  and rotvec describing 3-D rotation in the direction opposite to initial
%  direction. (rovect_inv = -rotvec_alignment)
%

% Original author: T.G.Perring
%

% Parse input
% -----------
[ok,mess,dnd_only,sqw_only]  = parse_char_options(varargin,{'-dnd_only','-sqw_only'});
if ~ok
    error('HORACE:algorithms:invalid_argument',mess);
end
if sqw_only && dnd_only
    error('HORACE:algorithms:invalid_argument', ...
        '-sqw_only and -dnd_only options can not be used together');
end

if ischar(in_data)
    in_data = {in_data};
end
if ~isa(alignment_info,'crystal_alignment_info')
    error('HORACE:change_crystal:invalid_argument',...
        ['Old interface to modify the crystal alignment is deprecated.\n', ...
        ' Use crystal_alignment_info object obtained from "refine_crystal" routine to realign crystal.\n', ...
        ' Call >>help refine_crystal for the details']);
end

% Perform operations
out = cell(1,numel(in_data));
for i=1:numel(in_data)
    if isa(in_data{i},'SQWDnDBase')
        is_sqw = isa(in_data{i},'sqw');
        if sqw_only && ~is_sqw
            error('HORACE:change_crystal:invalid_argument',...
                'change_crystal called to align sqw objects but obj N%d is dnd object',i)
        end
        if dnd_only
            if is_sqw
                out{i} = in_data{i}.data.change_crystal(alignment_info);
            else
                out{i} = in_data{i}.change_crystal(alignment_info);
            end
        else
            out{i} = in_data{i}.change_crystal(alignment_info);
        end
    else
        out{i} = in_data{i};
        ld = sqw_formats_factory.instance().get_loader(in_data{i});
        if ld.faccess_version<4
            alignment_info.legacy_mode = true;
        end
        data = ld.get_dnd();
        ld   = ld.set_file_to_update();
        if ld.sqw_type
            if dnd_only
                ld.delete();
                error('HORACE:change_crystal:invalid_argument',...
                    'file: %s contains sqw object but it is modified in dnd-mode only', ...
                    in_data{i});
            end
            exp_info= ld.get_exp_info('-all');
            if alignment_info.legacy_mode
                exp_info = change_crystal(exp_info,alignment_info,data.proj);
            else
                exp_info = change_crystal(exp_info,alignment_info);
            end
            ld=ld.put_headers(exp_info,'-no_sampinst');
            ld=ld.put_samples(exp_info.samples);
            %
            if ~alignment_info.legacy_mode
                pix_info = ld.get_pix_metadata();
                pix_info.alignment_matr = alignment_info.rotmat;
                ld = ld.put_pix_metadata(pix_info);
            end
        elseif sqw_only
            error('HORACE:change_crystal:invalid_argument',...
                'change_crystal called to align sqw objects but file%s contains dnd object', ...
                in_data{i})
        end
        data= data.change_crystal(alignment_info);
        ld = ld.put_dnd_metadata(data);

        ld.delete();
        clear ld;
    end
end
