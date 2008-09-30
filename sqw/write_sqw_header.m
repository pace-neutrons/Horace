function mess = write_sqw_header (fid, data)
% Write the header block for the results of performing calculate projections on spe file(s).
%
%   >> mess = write_sqw_header (fid, data)
%
% Input:
%   fid             File identifier of output file (opened for binary writing)
%   data            Data structure which must contain (at least) the fields listed below
%
% Output:
%   mess            Message if there was a problem writing; otherwise mess=''
%
%
% Fields written to file are: 
%   data.filename   Name of sqw file excluding path
%   data.filepath   Path to sqw file including terminating file separator
%   data.efix       Fixed energy (ei or ef depending on emode)
%   data.emode      Emode=1 direct geometry, =2 indirect geometry
%   data.alatt      Lattice parameters (Angstroms)
%   data.angdeg     Lattice angles (deg)
%   data.cu         First vector defining scattering plane (r.l.u.)
%   data.cv         Second vector defining scattering plane (r.l.u.)
%   data.psi        Orientation angle (deg)
%   data.omega      --|
%   data.dpsi         |  Crystal misorientation description (deg)
%   data.gl           |  (See notes elsewhere e.g. Tobyfit manual
%   data.gs         --|
%   data.en         Energy bin boundaries (meV) (column vector)
%   data.uoffset    Offset of origin of projection axes in r.l.u. and energy ie. [h; k; l; en] [column vector]
%   data.u_to_rlu   Matrix (4x4) of projection axes in hkle representation
%                      u(:,1) first vector - u(1:3,1) r.l.u., u(4,1) energy etc.
%   data.ulen       Length of projection axes vectors in Ang^-1 or meV [row vector]
%   data.ulabel     Labels of the projection axes [1x4 cell array of character strings]
%
% Notes:
% ------
%   There are some other items written to the file to help when reading the file using get_sqw_data. 
% These are indicated by comments in the code.
%
%   The header contains the information for a single spe file, except for the detector info
% and the data itself. In a more general implementation, this will be all the instrument
% information for a single run.
%   The detector data is written separately, as a combined list is made for all the contributing
% spe files, as mostly the detector data is the same. The data is made by the combination of the
% data from all the spe fies.
%   We write the projection axes information for each spe file. In principle, for example, the
% lengths ulen could be different for different spe file, for example because the lattice
% parameters are% slightly different due to different temperatures. Nevertheless, we would
% not want this to prevent different spe files from being binned together. For the data section
% itself, we keep some sort of average u_to_rlu, ulen etc. For the moment, allow grouping only
% when the u_to_rlu, ulen etc. are identical for every spe file.
%   The u_to_rlu, ulen and ulabel in this header block are those for teh coordinates in which the
% data for individual pixels is expressed in the data block. This may be different to that for the
% projection axes for plotting and integration in the data block. See write_sqw_data for more details.
%
% Comparison with Horace v1
% -------------------------
% * Change name of data.u to data.u_to_rlu (to avoid confusion with vector u that defines
%  scattering plane of crystal)
% * change name of data.label to data.ulabel (to keep association with projection axes)

% T.G.Perring 16/6/07

mess = '';

% Skip if fid not open
flname=fopen(fid);
if isempty(flname)
    mess = 'No open file with given file identifier. Skipping write routine';
    return
end

% Write to file
n=length(data.filename);
fwrite(fid,n,'int32');              % write length of filename
fwrite(fid,data.filename,'char');

n=length(data.filepath);
fwrite(fid,n,'int32');              % write length of file path
fwrite(fid,data.filepath,'char');

fwrite(fid,data.efix,'float32');
fwrite(fid,data.emode,'int32');
fwrite(fid,data.alatt,'float32');
fwrite(fid,data.angdeg,'float32');
fwrite(fid,data.cu,'float32');
fwrite(fid,data.cv,'float32');
fwrite(fid,data.psi,'float32');
fwrite(fid,data.omega,'float32');
fwrite(fid,data.dpsi,'float32');
fwrite(fid,data.gl,'float32');
fwrite(fid,data.gs,'float32');

ne=length(data.en);                 % write length of array of bin boundaries
fwrite(fid, ne, 'int32');
fwrite(fid, data.en, 'float32');

fwrite(fid,data.uoffset,'float32');
fwrite(fid,data.u_to_rlu,'float32');
fwrite(fid,data.ulen,'float32');

ulabel=char(data.ulabel);
n=size(ulabel);                     % write size of the character array of axes labels
fwrite(fid,n,'int32');
fwrite(fid,ulabel,'char'); 
