function grid_hkle(msp,fin,fout,hs,dh,he,ks,dk,ke,ls,dl,le);
% Read any number of spe files and populate a regular (h,k,l,e)
% grid with total intensity that falls in each pixel and number of
% instrument pixels that map onto each pixel. This information is stored in
% a binary file. This binary file can now be viewed with appropriate
% software. For example gklproj.m can project to a (kle) volume of
% intensities that can then be viewed with sliceomatic.m
%
% This routine requires that mslice.m is running in the background.
% Projection facilities in mslice are used to convert spe files to
% (h,k,l,e,intensity) data. 
%
% Input: 
%   msp: mslice parameter file
%   fin: file with psi values and the names of spe files to be included
%   fout: file name for the binary output file. If this file exists new
%         data will be appended to it. 
%   hs,dh,he: specify equidistant h values from hs to he with steps dh
%   ks,dk,ke: specify equidistant k values from ks to ke with steps dk
%   ls,dl,le: specify equidistant l values from ls to le with steps dl
%
%   NOTE: If the binary output file is found to already exist, then the
%   routine will append the new data to the end of it. In that case any
%   input beyond fout is disguarded. 
%
% Output: 
%   binary file containing data with the following content:
%       nhv = length(hv)  : number of grid boundaries along Q_h
%       nkv = length(kv)  : number of grid boundaries along Q_k
%       nlv = length(lv)  : number of grid boundaries along Q_l
%       nev = length(ev)  : number of grid boundaries along E
%       hv                : grid boundaries along Q_h
%       kv                : grid boundaries along Q_k
%       lv                : grid boundaries along Q_l
%       ev                : grid boundaries along E
%       rint(length(hv),length(kv),length(lv),length(ev)) float32
%       eint(length(hv),length(kv),length(lv),length(ev)) float32
%       nint(length(hv),length(kv),length(lv),length(ev)) int16
%
%    rint is the cumulative intensity in the grid defined by hv,kv,lv,ev.
%    eint is the cumulative variance in the grid defined by hv,kv,lv,ev.
%    Number of pixels that contributed to a grid point is given by nint
%
%    rint, eint and nint have length one greater along each dimension than is
%    actually required to hold the data.

% read input spe file information
[psi,fnames] = textread(fin,'%f %s');  
nfiles  =   length(psi);

if exist(fout)
    append  =   1;
    %read binary input file
    data=readgrid(fout);
else
    append  =   0;
    data.hv  =   hs:dh:he;
    data.kv  =   ks:dk:ke;
    data.lv  =   ls:dl:le;
    data.nhv =   length(data.hv);
    data.nkv =   length(data.kv);
    data.nlv =   length(data.lv);
end


% set up Q-space viewing axes
ms_load_msp(msp);
ms_setvalue('u11',1);
ms_setvalue('u12',0);
ms_setvalue('u13',0);
ms_setvalue('u14',0);
ms_setvalue('u1label','Q_h');
ms_setvalue('u21',0);
ms_setvalue('u22',1);
ms_setvalue('u23',0);
ms_setvalue('u24',0);
ms_setvalue('u2label','Q_k');
ms_setvalue('u31',0);
ms_setvalue('u32',0);
ms_setvalue('u33',1);
ms_setvalue('u34',0);
ms_setvalue('u3label','Q_l');

%read and convert each spe file then drop data into intensity grid. 
for i = 1:nfiles
    ms_setvalue('DataFile',fnames(i));
    ms_setvalue('psi_samp',psi(i));
    ms_load_data;
    ms_calc_proj;
    d   =   fromwindow;
    
    if i == 1 & append~=1
        %the very first time around generate the energy vector and output
        %arrays from the information in the first spe file. 
        data.ev  =   d.en;
        data.nev  =   length(data.ev);
        data.rint    =   zeros(data.nhv,data.nkv,data.nlv,data.nev);
        data.eint    =   zeros(data.nhv,data.nkv,data.nlv,data.nev);
        data.nint    =   int16(data.rint);
    end

    for ie = 1:data.nev
        %calculate the indexes of affected output pixels
        ih  =   int32((d.v(:,ie,1)-hs)/dh+1);   % guarantees ih in range (1->nhv)
        ik  =   int32((d.v(:,ie,2)-ks)/dk+1);
        il  =   int32((d.v(:,ie,3)-ls)/dl+1);
        lis =   find(ih>0 & ih<data.nhv & ik>0 & ik<data.nkv & il>0 & il<data.nlv);    % guarantees ih in range (1->nhv-1) etc
        for j=1:length(lis)
            %Actual addition of intensities and "hits"
            data.rint(ih(lis(j)),ik(lis(j)),il(lis(j)),ie)   =   data.rint(ih(lis(j)),ik(lis(j)),il(lis(j)),ie)+d.S(lis(j),ie);
            data.eint(ih(lis(j)),ik(lis(j)),il(lis(j)),ie)   =   data.eint(ih(lis(j)),ik(lis(j)),il(lis(j)),ie)+d.ERR(lis(j),ie).^2;
            data.nint(ih(lis(j)),ik(lis(j)),il(lis(j)),ie)   =   sum([data.nint(ih(lis(j)),ik(lis(j)),il(lis(j)),ie),1]);
        end
    end
end


%open and write binary output file 
writegrid(data,fout);