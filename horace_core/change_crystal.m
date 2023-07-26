function out = change_crystal(in_data,alignment_info,varargin)
% Change the crystal lattice and orientation of an sqw object stored in a file
% or celarray of files
%
%   >> change_crystal (filenames, alignment_info) % change lattice parameters and orientation
%                                                 % of the crystal according to the
%                                                 % crystal alignment information provided
%
%
% Input:
% -----
%   w           Input sqw object
%
% alignment_info -- class helper containing all information about crystal
%                   realignment, produced by refine_crystal procedure.
%
%              do:
%              >> help refine_crystal  for more details.
%
% Output:
% -------
%   wout        Output sqw object with changed crystal lattice parameters and orientation
%
% NOTE
%  The input data set(s) can be reset to their original orientation by inverting the
%  input data e.g.
%    - call with inv(rlu_corr)
%    - call with the original alatt, angdeg, u and v

% Original author: T.G.Perring
%


% This routine used to change the crystal in sqw files, when it overwrites the input file.

% Parse input
% -----------
if ischar(in_data)
    in_data = {in_data};
end
if ~isa(alignment_info,'crystal_alignment_info') || nargin>2
    error('HORACE:change_crystal:invalid_argument',...
        ['Old interface to modify the crystal alignment is deprecated.\n', ...
        ' Use crystal_alignment_info object obtained from "refine_crystal" routine to realign crystal.\n', ...
        ' Call >>help refine_crystal for the details']);
end

% Perform operations
out = cell(1,numel(in_data));
for i=1:numel(in_data)
    if isa(in_data{i},'SQWDnDBase')
        out{i} = in_data{i}.change_crystal(alignment_info);
    else
        out{i} = in_data{i};
        ld = sqw_formats_factory.instance().get_loader(in_data{i});
        data    = ld.get_dnd();
        ld = ld.set_file_to_update();
        if ld.sqw_type
            exp_info= ld.get_exp_info('-all');
            exp_info = change_crystal(exp_info,alignment_info);
            ld.put_headers(exp_info,'-no_sampinst');
            ld.put_samples(exp_info.samples);
            %
            if ~alignment_info.legacy_mode
                pix_info = ld.get_pix_metadata();
                pix_info.alignment_matr = alignment_info.rotmat;
                ld = ld.put_pix_metadata(pix_info);
            end
        end
        data= data.change_crystal(alignment_info);
        ld = ld.put_dnd_metadata(data);

        ld.delete();
        clear ld;
    end
end
