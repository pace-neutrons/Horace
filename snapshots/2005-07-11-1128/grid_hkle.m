function grid_hkle(msp,fin,fout,u1,u2,u3,hs,dh,he,ks,dk,ke,ls,dl,le);
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
%   header:
%       data.grid: type of binary file (4D grid, blocks of spe file, etc)
%       data.title_label: title label
%       data.efixed: value of ei
%       data.a: a axis
%       data.b: b axis
%       data.c c axis
%       data.alpha: alpha
%       data.beta: beta
%       data.gamma: gamma
%       data.u1: viewing axis u1 (Q)
%       data.u2: viewing axis u2 (Q)
%       data.u3: viewing axis u3 (Q)
%       data.u4: viewing axis u4 (this is energy)
%       data.nfiles: number of spe files contributing to the binary file

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
    %read binary input file
    data=readgrid(fout);
    data.nfiles=data.nfiles+nfiles;
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
        data.title_label= d.title_label;
        data.efixed=d.efixed;
        data.grid= 'grid'; % 4D grid
        data.a= ms_getvalue('as');
        data.b= ms_getvalue('bs');
        data.c= ms_getvalue('cs');
        data.alpha= ms_getvalue('aa');
        data.beta= ms_getvalue('bb');
        data.gamma= ms_getvalue('cc');
        data.u1= u1;
        data.u2= u2;
        data.u3= u3;
        data.u4= [0,0,0,1]; % energy
        data.nfiles= nfiles;
        data.ev= d.en;
        data.nev= length(data.ev);
        data.int= zeros(data.nhv,data.nkv,data.nlv,data.nev);
        data.err= zeros(data.nhv,data.nkv,data.nlv,data.nev);
        data.nint= int16(data.int);
    end

    for ie = 1:data.nev
        %calculate the indexes of affected output pixels
        ih  =   int32((d.v(:,ie,1)-hs)/dh+1);   % guarantees ih in range (1->nhv)
        ik  =   int32((d.v(:,ie,2)-ks)/dk+1);
        il  =   int32((d.v(:,ie,3)-ls)/dl+1);
        lis =   find(ih>0 & ih<data.nhv & ik>0 & ik<data.nkv & il>0 & il<data.nlv);    % guarantees ih in range (1->nhv-1) etc
        for j=1:length(lis)
            %Actual addition of intensities and "hits"
            data.int(ih(lis(j)),ik(lis(j)),il(lis(j)),ie)   =   data.int(ih(lis(j)),ik(lis(j)),il(lis(j)),ie)+d.S(lis(j),ie);
            data.err(ih(lis(j)),ik(lis(j)),il(lis(j)),ie)   =   data.err(ih(lis(j)),ik(lis(j)),il(lis(j)),ie)+d.ERR(lis(j),ie).^2;
            data.nint(ih(lis(j)),ik(lis(j)),il(lis(j)),ie)   =   sum([data.nint(ih(lis(j)),ik(lis(j)),il(lis(j)),ie),1]);
        end
    end
end


%open and write binary output file 
writegrid(data,fout);