function out = upgrade_legacy_alignment(in_data,alatt0,angdeg0)
% Change the crystal lattice and orientation of an sqw object stored in a file
% or celarray of files
%
%   >> upgrade_legacy_alignment(filenames, alatt0,angdeg0)
% modify legacy alignment previously
%                                                 % of the crystal according to the
%                                                 % crystal alignment information provided
%
%
% Input:
% -----
%   w          cellarray of Input sqw objects or file names for sqw files,
%              containing sqw objects, aligned using legacy alignment
%
%  alatt0   -- vector of lattice parameters for initial not aligned file
%  angdeg0  -- vector of lattice angles for initial not aligned file.
%

% Output:
% -------
%   wout      cellarray of iutput sqw objects and filename containing sqw
%             objects modified
%

% This routine used to change the crystal in sqw files, when it overwrites the input file.

% Parse input
% -----------
if ischar(in_data) % process single file
    in_data = {in_data};
end
if ~isnumeric(alatt0) || ~isnumeric(angdeg0) || numel(alatt0) ~= 3 || numel(angdeg0) ~= 3 || nargin < 3
    error('HORACE:upgrade_legacy_alignment:invalid_argument',...
        'To upgrade legacy alignment to modern format, one needs to provide lattice parameters for non-aligned lattice');
end
hc = hor_config;
ll = hc.log_level;

% Perform operations
out = cell(1,numel(in_data));
for i=1:numel(in_data)
    if isa(in_data{i},'SQWDnDBase')
        out{i} = in_data{i}.upgrade_legacy_alignment(alatt0,angdeg0);
    else
        out{i} = in_data{i};
        ld = sqw_formats_factory.instance().get_loader(in_data{i});
        data    = ld.get_dnd();
        [data,al_info,no_alignment_found,alatt0,angdeg0] = upgrade_legacy_alignment(data,alatt0,angdeg0);
        if no_alignment_found
            ld.delete();
            if ll>0
                warning('HORACE:algorithms:invalid_argument', ...
                    'file %s is not legacy aligned. File ignored',in_data{i});
            end
            continue;
        end
        ld = ld.set_file_to_update();

        ld = ld.put_dnd_metadata(data);
        if ld.sqw_type
            exp_info= ld.get_exp_info('-all');
            exp_info = exp_info.upgrade_legacy_alignment(al_info,alatt0,angdeg0);

            ld= ld.put_headers(exp_info,'-no_sampinst');
            ld= ld.put_samples(exp_info.samples);
            %
            pix_info = ld.get_pix_metadata();
            pix_info.alignment_matr = al_info.rotmat;
            ld = ld.put_pix_metadata(pix_info);
        end

        ld.delete();
        clear ld;
    end
end
