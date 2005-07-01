function gen_hkle(msp,fin, fout, u1, u2,u3);
%
% This routine requires that mslice.m is running in the background.
% 
% Read in a number of spe files and  use the projection facilities in 
% mslice are to convert spe files to(h,k,l,e,intensity) data. Which will
% then be written out to a binary file. This binary file can now be
% accessed using the appropriate software. 
%
% Input:
%   msp: mslice parameter file
%   fin: file with psi values and the names of the spe files to be included
%   fout: file name for the binary output file. 
%   u1,u2,u3: projection axes 

%   NOTE: If the binary output file is found to already exist, then the
%   routine will append the new data to the end of it. 
%
% Output:
%   header:
%       data.grid: type of binary file (4D grid, blocks of spe file, etc)
%       data.title_label: title label
%       data.a: a axis
%       data.b: b axis
%       data.c c axis
%       data.alpha: alpha
%       data.beta: beta
%       data.gamma: gamma
%       data.u     Matrix (4x4) of projection axes in original 4D representation
%              u(:,1) first vector - u(1:3,1) r.l.u., u(4,1) energy etc.
%       data.ulen  Length of vectors in Ang^-1, energy
%       data.nfiles: number of spe files contained within the binary file
%
%       list of psi, u,v (crystal orientation) and file name of the spe
%       file, followed by:
%       sized: size u1, u2, u3, I, Err arrays
%       data.v: 2 D array containing collums of hkl corresponding to each
%       pixel.
%       en: vector containing energy bins
%       S: intensity vector (size=sized(1)*sized(2)=number of
%       detectors*number of energy bins)
%       ERR: Error vector (as the variance, ie err^2)

% Author:
%   J. van Duijn     01/06/2005
% Modified:
%
% Horace v0.1   J.Van Duijn, T.G.Perring


% read input spe file information
[psi,fnames] = textread(fin,'%f %s');  
nfiles  =   length(psi);

if exist(fout)
    append  =   1;
    % append new spe files at the end of the file and correct the total
    % number of spe files in the header;
    data=readheader(fout);
    data.nfiles=data.nfiles+nfiles;
else
    append=0;
end

% set up Q-space viewing axes
ms_load_msp(msp);
ms_setvalue('u11',u1(1));
ms_setvalue('u12',u1(2));
ms_setvalue('u13',u1(3));
ms_setvalue('u14',u1(4));
ms_setvalue('u1label','Q_h');
ms_setvalue('u21',u2(1));
ms_setvalue('u22',u2(2));
ms_setvalue('u23',u2(3));
ms_setvalue('u24',u2(4));
ms_setvalue('u2label','Q_k');
ms_setvalue('u31',u3(1));
ms_setvalue('u32',u3(2));
ms_setvalue('u33',u3(3));
ms_setvalue('u34',u3(4));
ms_setvalue('u3label','Q_l');

%read and convert each spe file then write data to binary file 
for i = 1:nfiles
    ms_setvalue('DataFile',fnames(i));
    ms_setvalue('psi_samp',psi(i));
    ms_load_data;
    ms_calc_proj;
    d   =   fromwindow;
    
    if i==1 & append~=1
       %the very first time around generate all the header information.
       data.title= d.title_label;
       data.grid= 'spe';
       data.a=ms_getvalue('as');
       data.b=ms_getvalue('bs');
       data.c=ms_getvalue('cs');
       data.alpha=ms_getvalue('aa');
       data.beta=ms_getvalue('bb');
       data.gamma=ms_getvalue('cc');
       data.u= [u1',u2',u3',[0 0 0 1]'];
       data.ulen= [d.axis_unitlength; 1];
       data.nfiles= nfiles;
       writeheader(data,fout);
    end
    if i==1,
        fid=fopen(fout, 'r+');
        fseek(fid, 0, 'eof');
    end
    fwrite(fid, d.efixed, 'float32'); 
    fwrite(fid, psi(i), 'float32');
    fwrite(fid, d.uv(1,:), 'float32');
    fwrite(fid, d.uv(2,:), 'float32');
    n=length(d.filename);
    fwrite(fid, n, 'int32');
    fwrite(fid, d.filename, 'char');
    sized= size(d.v);
    fwrite(fid,sized(1:2),'int32');
    % reorder the data.v array so that it is data.v(:,1:3) where each
    % collum corresponds to hkl.
    nt= sized(1)*sized(2);
    d.v= reshape(d.v, nt, 3);
    d.v=d.v';
    fwrite(fid,d.v,'float32');
    fwrite(fid,d.en,'float32');
    d.S=reshape(d.S, nt, 1);
    d.S=d.S';
    fwrite(fid,d.S,'float32');
    d.ERR=reshape(d.ERR, nt, 1);
    d.ERR=d.ERR';
    d.ERR=d.ERR.^2;
    fwrite(fid,d.ERR,'float32');    
end
fclose(fid);

% if all the files are correctly appended to the binary file update the
% header with the total number of spe files. 
if append==1,
    appendheader(data.nfiles, fout);
end