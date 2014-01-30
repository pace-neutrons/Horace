function [mess,position] = put_sqw_header (fid, header)
% Write the header blocks for the contributing spe file(s) to an sqw file.
%
%   >> [mess,position] = put_sqw_header (fid, header)
%
% Input:
% ------
%   fid             File identifier of output file
%   header          Header block: scalar structure (if single spe file) or
%                  cell array of structures, one per spe file, which must contain
%                  at least the fields listed below.
%
% Output:
% -------
%   mess            Message if there was a problem writing; otherwise mess=''
%   position        Column vector with the positions of the start of each header block
%
%
% Fields written to file are:
% ---------------------------
%   header.filename     Name of sqw file excluding path
%   header.filepath     Path to sqw file including terminating file separator
%   header.efix         Fixed energy (ei or ef depending on emode)
%   header.emode        Emode=1 direct geometry, =2 indirect geometry
%   header.alatt        Lattice parameters (Angstroms)
%   header.angdeg       Lattice angles (deg)
%   header.cu           First vector defining scattering plane (r.l.u.)
%   header.cv           Second vector defining scattering plane (r.l.u.)
%   header.psi          Orientation angle (deg)
%   header.omega        --|
%   header.dpsi           |  Crystal misorientation description (deg)
%   header.gl             |  (See notes elsewhere e.g. Tobyfit manual
%   header.gs           --|
%   header.en           Energy bin boundaries (meV) (column vector)
%   header.uoffset      Offset of origin of projection axes in r.l.u. and energy ie. [h; k; l; en] [column vector]
%   header.u_to_rlu     Matrix (4x4) of projection axes in hkle representation
%                           u(:,1) first vector - u(1:3,1) r.l.u., u(4,1) energy etc.
%   header.ulen         Length of projection axes vectors in Ang^-1 or meV [row vector]
%   header.ulabel       Labels of the projection axes [1x4 cell array of character strings]
%
% The following two fields are part of the header, but are not written by this function:
%   header.instrument   Instrument description
%   header.sample       Sample description
%
% Notes:
% ------
%   There are some other items written to the file to help when reading the file using get_sqw_header.
% These are indicated by comments in the code.
%
%   We write the projection axes information for each spe file. In principle, for example, the
% lengths ulen could be different for different spe file, for example because the lattice
% parameters are slightly different due to different temperatures. Nevertheless, we would
% not want this to prevent different spe files from being binned together. For the data section
% itself, we keep some sort of average u_to_rlu, ulen etc. For the moment, we allow grouping only
% when the u_to_rlu, ulen etc. are identical for every spe file.
%
%   The u_to_rlu, ulen and ulabel in this header block are those for the coordinates in which the
% data for individual pixels is expressed in the data block. This may be different to that for the
% projection axes for plotting and integration in the data block. See put_sqw_data for more details.


% Original author: T.G.Perring
%
% $Revision$ ($Date$)

mess='';

if isstruct(header) % should be a single header, as a data structure
    position = ftell(fid);
    mess = put_sqw_header_single (fid, header);
else    % should be a cell array of headers
    nfiles=numel(header);
    position=zeros(nfiles,1);
    for i=1:nfiles
        position(i)=ftell(fid);
        mess = put_sqw_header_single (fid, header{i});
        if ~isempty(mess)
            mess=[mess,': spe file ',num2str(i)];
            return
        end
    end
end

%------------------------------------------------------------------------------
function mess = put_sqw_header_single (fid, header)
% Write a single header structure to sqw file
%
%   >> mess = put_sqw_header_single (fid, header)
%
% Input:
% ------
%   fid             File identifier of output file
%   header          Header block: single data structure
%
% Output:
% -------
%   mess            Message if there was a problem writing; otherwise mess=''

mess = '';

try
    n=length(header.filename);
    fwrite(fid,n,'int32');              % write length of filename
    fwrite(fid,header.filename,'char');
    
    n=length(header.filepath);
    fwrite(fid,n,'int32');              % write length of file path
    fwrite(fid,header.filepath,'char');
    
    fwrite(fid,header.efix,'float32');
    fwrite(fid,header.emode,'int32');
    fwrite(fid,header.alatt,'float32');
    fwrite(fid,header.angdeg,'float32');
    fwrite(fid,header.cu,'float32');
    fwrite(fid,header.cv,'float32');
    fwrite(fid,header.psi,'float32');
    fwrite(fid,header.omega,'float32');
    fwrite(fid,header.dpsi,'float32');
    fwrite(fid,header.gl,'float32');
    fwrite(fid,header.gs,'float32');
    
    ne=length(header.en);               % write length of array of bin boundaries
    fwrite(fid, ne, 'int32');
    fwrite(fid, header.en, 'float32');
    
    fwrite(fid,header.uoffset,'float32');
    fwrite(fid,header.u_to_rlu,'float32');
    fwrite(fid,header.ulen,'float32');
    
    ulabel=char(header.ulabel);
    n=size(ulabel);                     % write size of the character array of axes labels
    fwrite(fid,n,'int32');
    fwrite(fid,ulabel,'char');
    
catch
    mess='Error writing header block to file';
end
