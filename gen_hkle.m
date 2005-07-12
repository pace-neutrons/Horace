function gen_hkle (msp, fin, fout, u1, u2, u3);
% Read in a number of spe files and use the projection facilities in 
% mslice to calculate the (Q,E) components for each pixel, and write these
% and the intensity to a binary file suitable for use in the Horace routines.
%
% Syntax:
%   >> gen_hkle (msp, fin, fout, u1, u2, u3)
%
% NOTES:
% (1) If the binary output file already exists, the routine appends the new
%     data to the end of it. 
% (2) This routine requires that mslice is running in the background.
%
% Input:
% ------
%   msp         Mslice parameter file. Must have correct .phx file, scattering
%               plane etc. The only information that will be over-written is
%               the .spe file, psi, projection axes.
%   fin         File with psi values (deg) and the spe file names to be included
%               Format of this file: e.g.
%                       90   MAP07491.SPE
%                       89   MAP07492.SPE
%                        :         :
%                       
%   fout        File name for the binary output file (format described below). 
%   u1    --|   Projection axes in which to label pixel centres
%   u2      |--   e.g.    u1 = [1,0,0], u2=[0,1,0], u3=[0,0,1]
%   u3    --|     e.g.    u1 = [1,1,0], u2=[-1,1,0], u3=[0,0,1]
%
% Output:
% -------
% header block:
%   data.grid   Type of grid ('spe') [Character string]
%   data.title  Title [Character string]
%   data.a      Lattice parameters (Angstroms)
%   data.b           "
%   data.c           "
%   data.alpha  Lattice angles (degrees)
%   data.beta        "
%   data.gamma       "
%   data.u      Matrix (4x4) of projection axes in original 4D representation
%               u(:,1) first vector - u(1:3,1) r.l.u., u(4,1) energy etc.
%   data.ulen   Length of vectors in Ang^-1 or meV [row vector]
%   data.label  Labels of the projection axes [1x4 cell array of charater strings]
%   data.nfiles Number of spe file data blocks in the remainder of the file
%
% For each spe file in succession:
%   data.ei     Incident energy used for spe file (meV)
%   data.psi    Psi angle (deg)
%   data.cu     u crystal axis (r.l.u.) (see mslice) [row vector]
%   data.cv     v crystal axis (r.l.u.) (see mslice) [row vector]
%   data.file   File name of .spe file corresponding to the block being read
%   data.size   size(1)=number of detectors; size(2)=number of energy bins [row vector]
%   data.v      Array containing the components along the mslice projection
%              axes u1, u2, u3 for each pixel in the .spe file.
%              Note: size(data.v) = [3, no. dets * no. energy bins]
%   data.en     Vector containing the energy bin centres [row vector]
%   data.S      Intensity vector [row vector]
%   data.ERR    Variance vector [row vector]
%

% Original author: J. van Duijn
%
% $Revision$ ($Date$)
%
% Horace v0.1   J. van Duijn, T.G.Perring


% Read input spe file information
[psi,fnames] = textread(fin,'%f %s');  
nfiles = length(psi);

% Determine if binary file already exists
if exist(fout)
    % Open existing file, read the header, update number of files and
    % position writing at the end of the file
    append = 1;
    fid=fopen(fout, 'r+');
    data=get_header(fid);
    data.nfiles=data.nfiles+nfiles;
    fseek(fid, 0, 'eof');
else
    % Open a new binary file
    append = 0;
    fid=fopen(fout,'w');
end

% Set up Q-space viewing axes
ms_load_msp(msp);
ms_setvalue('u11',u1(1));
ms_setvalue('u12',u1(2));
ms_setvalue('u13',u1(3));
ms_setvalue('u14',0);
ms_setvalue('u1label','Q_h');
ms_setvalue('u21',u2(1));
ms_setvalue('u22',u2(2));
ms_setvalue('u23',u2(3));
ms_setvalue('u24',0);
ms_setvalue('u2label','Q_k');
ms_setvalue('u31',u3(1));
ms_setvalue('u32',u3(2));
ms_setvalue('u33',u3(3));
ms_setvalue('u34',0);
ms_setvalue('u3label','Q_l');

% Read and convert each spe file then write data to binary file 
for i = 1:nfiles
    ms_setvalue('DataFile',fnames(i));
    ms_setvalue('psi_samp',psi(i));
    ms_load_data;
    ms_calc_proj;
    d = fromwindow;
    if i==1 & ~append
        % The very first time around generate all the header information.
        data.grid= 'spe';
        data.title= d.title_label;
        data.a=ms_getvalue('as');
        data.b=ms_getvalue('bs');
        data.c=ms_getvalue('cs');
        data.alpha=ms_getvalue('aa');
        data.beta=ms_getvalue('bb');
        data.gamma=ms_getvalue('cc');
        data.u= [u1',u2',u3',[0 0 0 1]'];
        data.ulen= [d.axis_unitlength', 1];
        data.nfiles= nfiles;
        write_header(fid,data);
    end
    fwrite(fid, d.efixed, 'float32'); 
    fwrite(fid, psi(i), 'float32');
    fwrite(fid, d.uv(1,:), 'float32');
    fwrite(fid, d.uv(2,:), 'float32');
    n=length(d.filename);
    fwrite(fid, n, 'int32');
    fwrite(fid, d.filename, 'char');
    sized= size(d.v);
    fwrite(fid,sized(1:2), 'int32');
    % Reshape and transpose the data.v array so that it becomes data.v(1:3,:) where each
    % column corresponds to components along u1, u2, u3 for one pixel.
    % Do the corresponding reshape and transpose for the signal and error arrays.
    nt= sized(1)*sized(2);
    fwrite(fid, reshape(d.v, nt, 3)','float32');
    fwrite(fid, d.en, 'float32');
    fwrite(fid, reshape(d.S, 1, nt), 'float32');
    fwrite(fid, reshape(d.ERR, 1, nt).^2, 'float32');  % store error squared 
end

% if all the files are correctly appended to the binary file update the
% header with the total number of spe files. 
if append
    fseek(fid, 0, 'bof');       % go to beginning of file
    write_header(fid,data);     % overwrite header information with the updated header
end

fclose(fid);
