function d = slice_3d (data_source, u, v, p0, u1_bin, u2_bin, u3_bin, thick, type)
% 
% input:
% --------
%   data_source     File containing (h,k,l,e) data
%   u(1:3)          Vector defining first plot axis (r.l.u.)
%   v(1:3)          Vector defining plane of plot in Q-space (r.l.u.)
%           The plot plane is defined by u and the perpendicular to u in the
%           plane of u and v. The unit lengths of the axes are determined by the
%           character codes in the variable 'type' described below
%            - if 'a': unit length is one inverse Angstrom
%            - if 'r': then if (h,k,l) in r.l.u., is normalised so max(abs([h,k,l]))=1
%           Call the orthogonal set created from u and v: u1, u2, u3.
%   p0(1:3)         Vector defining origin of the plane in Q-space (r.l.u.)
%   u1_bin(1:3)     Binning along u axis: [u1_start, u1_step, u1_end]
%   u2_bin(1:3)     Binning perpendicular to u axis within the plot plane:
%                                     [u2_start, u2_step, u2_end]
%   u3_bin(1:3)     Depending on thick this will either be binning along the
%                  energy axis or the u3 axis which is perpendicular to the
%                  plot plane.
%   thick           If scalar: thickness of binning perpendicular to
%                  plot plane: +/-(thick/2).
%                   If vector: [E0, dE], where dE is the thickness in energy.
%   type            Units of binning and thickness: a three-character string,
%                  each character indicating if u1, u2, u3 normalised to Angstrom^-1
%                  or r.l.u., max(abs(h,k,l))=1 - 'a' and 'r' respectively. e.g. type='arr'
%
% output:
% ----------
%   d.stype         Type of 3D grid, 'QQE' or 'QQQ'
%   d.file          File from which (h,k,l,e) data was read
%   d.title         Title of the binary file from which (h,k,l,e) data was read
%   d.u_to_rlu      Vectors u1, u2, u3 (r.l.u.) 
%   d.ulen          Row vector of lengths of ui in Ang^-1
%   d.p0            Vector defining origin of the plane in Q-space (r.l.u.)
%   d.u1            Vector of u1 bin boundary values 
%   d.u2            Vector of u2 bin boundary values
%   d.u3            Vector of u3 bin boundary values
%   d.int(length(d.u1)-1,length(d.u2)-1, length(d.u3)-1)
%                   Cumulative intensity array
%   d.err(length(d.u1)-1,length(d.u2)-1, length(d.u3)-1)
%                   Cumulative intensity array
%   d.nint(length(d.u1)-1,length(d.u2)-1, length(d.u3)-1)
%                   Number of pixels that contributed to a bin [int16]

% Author:
%   J. van Duijn     10/06/2005
% Modified:
%
% Horace v0.1   J.Van Duijn, T.G.Perring

% get the step sizes

stype=length(thick); % defines the type of slice we are going to do
if stype==1,
    ustep = [u1_bin(2), u2_bin(2), thick]; % (QQE)
    d.stype= 'QQE';
elseif stype==2,
    ustep = [u1_bin(2), u2_bin(2), u3_bin(2)]; % (QQQ)
    d.stype='QQQ';
else
    disp('Wrong thickness given, thick can only be scalar (QQE slices) or a vector of length 2 (QQQ slices)');
    return;
end

fid= fopen(data_source, 'r'); % open bin file

h_main = getheader(fid); % get the main header information

% obtain the conversion matrix that will convert the hkle vectors in the
% spe file in to equivalents in the orthogonal set defined by u and v
[rlu_to_ustep, u_to_rlu, ulen] = rlu_to_ustep_matrix ([h_main.a,h_main.b, h_main.c],...
    [h_main.alpha,h_main.beta,h_main.gamma], u, v, ustep, type);

% convert p0 to the equivalent vector in the new orthogonal set given by
% u_to_rlu
p0n= rlu_to_ustep*p0';

% Generate the output vectors (u1, u2, u3) and corresponding intensity,
% error and pixel count array. 
d.file= data_source;
d.title=h_main.title;
d.u_to_rlu= u_to_rlu;
d.p0= p0;
d.ulen= ulen;
d.u1= u1_bin(1):u1_bin(2):u1_bin(3); % length of d.u1=floor((u1_bin(3)-u1_bin(1))/u1_bin(2))+1
d.u2= u2_bin(1):u2_bin(2):u2_bin(3); % Contains the bin boundaries
d.u3= u3_bin(1):u3_bin(2):u3_bin(3);
nu1= length(d.u1)-1; % number of bins
nu2= length(d.u2)-1;
nu3= length(d.u3)-1;
d.int= zeros(nu1,nu2,nu3);
d.err= zeros(nu1,nu2,nu3);
d.nint= int16(d.int);

for iblock = 1:h_main.nfiles,
    disp(['reading block no.: ' num2str(iblock)]);
    h = getblock(fid); % read in spe block
    
    vstep= rlu_to_ustep*h.v; % convert h.v into the equivalent step matrix along the new 
                            % orthogonal set given by u_to_rlu
                            
    % generate the energy vector corresponding to each hkl vector
    emat= repmat(h.en, h.size(1), 1);
    emat= reshape(emat, h.size(1)*h.size(2),1);
    emat= emat';
    
   if stype==2, % QQQ
       % convert vstep into index array where vstep(i,1)= 1 corresponds to data
       % between ui(1) and ui(2).
       vstep(1,:)=floor(vstep(1,:)-p0n(1)-u1_bin(1)/u1_bin(2))+1;
       vstep(2,:)=floor(vstep(2,:)-p0n(2)-u2_bin(1)/u2_bin(2))+1;
       vstep(3,:)=floor(vstep(3,:)-p0n(3)-u3_bin(1)/u3_bin(2))+1;
      
       % generate equivalent energy matrix
       emat=round((emat-thick(1))/thick(2)); % the pixels we are interested have are those
                                          % where emat=0
                                          
       % find the index array 
       lis=find(1<=vstep(1,:) & vstep(1,:)<=floor((max(d.u1)-u1_bin(1))/u1_bin(2)) & ...
          1<=vstep(2,:) & vstep(2,:)<=floor((max(d.u2)-u2_bin(1))/u2_bin(2)) & ...
          1<=vstep(3,:) & vstep(3,:)<=floor((max(d.u3)-u3_bin(1))/u3_bin(2)) & ...
          emat==0);
      
       % sum up the Intensity, errors and hits into the 3D array.
       % add the stepsize of the last bin of d.int with 0 int to make sure
       % that the accumulated array has the same sie as d.int
       %a=(accumarray(vstep(1:3,lis)',h.S(lis)))
       d.int= d.int + accumarray([[vstep(1:2,lis);emat(lis)], [nu1; nu2; nu3]]',[h.S(lis) 0]); % summed 3D intensity array
       d.err= d.err + accumarray([[vstep(1:2,lis);emat(lis)], [nu1; nu2; nu3]]',[h.ERR(lis) 0]); % summed 3D error array
       d.nint=d.nint + int16(accumarray([[vstep(1:2,lis);emat(lis)], [nu1; nu2; nu3]]', [ones(1,length(lis)) 0]));
      
    else %QQE
       % convert vstep into index array where vstep(i,1)= 1 corresponds to data
       % between ui(1) and ui(2). Do this only for vectors along u1 and u2.
       vstep(1,:)=floor(vstep(1,:)-p0n(1)-u1_bin(1)/u1_bin(2))+1;
       vstep(2,:)=floor(vstep(2,:)-p0n(2)-u2_bin(1)/u2_bin(2))+1;
       vstep(3,:)=round(vstep(3,:)-p0n(3)); % binning along this axis stepsize is already in units of the thickness
      
       % generate equivalent energy matrix
       emat= floor((emat-u3_bin(1) )/u3_bin(2))+1;
      
       % find the index array 
       lis=find(1<=vstep(1,:) & vstep(1,:)<=floor((max(d.u1)-u1_bin(1))/u1_bin(2)) & ...
          1<=vstep(2,:) & vstep(2,:)<=floor((max(d.u2)-u2_bin(1))/u2_bin(2)) & ...
          1<=emat & emat<=floor((max(d.u3)-u3_bin(1))/u3_bin(2)) & ...
          vstep(3,:)==0);
      
       % sum up the Intensity, errors and hits into the 3D array.
       % add the stepsize of the last bin of d.int with 0 int to make sure
       % that the accumulated array has the same sie as d.int
       %a=(accumarray(vstep(1:3,lis)',h.S(lis)))
       d.int= d.int + accumarray([[vstep(1:2,lis);emat(lis)], [nu1; nu2; nu3]]',[h.S(lis) 0]); % summed 3D intensity array
       d.err= d.err + accumarray([[vstep(1:2,lis);emat(lis)], [nu1; nu2; nu3]]',[h.ERR(lis) 0]); % summed 3D error array
       d.nint=d.nint + int16(accumarray([[vstep(1:2,lis);emat(lis)], [nu1; nu2; nu3]]', [ones(1,length(lis)) 0]));
          
   end
    
end

fclose(fid);
    