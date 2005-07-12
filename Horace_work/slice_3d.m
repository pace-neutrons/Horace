function d = slice_3d (data_source, u, v, p0, p1_bin, p2_bin, p3_bin, thick, type)
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
%   p1_bin(1:3)     Binning along u axis: [p1_start, p1_step, p1_end]
%   p2_bin(1:3)     Binning perpendicular to u axis within the plot plane:
%                                     [p2_start, p2_step, p2_end]
%   p3_bin(1:3)     Depending on thick this will either be binning along the
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
%   d.stype         'orthogonal-grid'
%   d.file          File from which (h,k,l,e) data was read
%   d.title         Title of the binary file from which (h,k,l,e) data was read
%   d.u     Matrix (4x4) of projection axes in original 4D representation
%              u(:,1) first vector - u(1:3,1) r.l.u., u(4,1) energy etc.
%   d.ulen  Length of vectors in Ang^-1, energy
%   d.label Labels of theprojection axes (1x4 cell array of charaterstrings)
%   d.p0    Offset of origin of projection [ph; pk; pl; pen]
%   d.pax   Index of plot axes in the matrix din.u
%              e.g. if data is 3D, din.pax=[2,4,1] means u2, u4, u1 axes are x,y,z in any plotting
%                               2D, din.pax=[2,4]     "   u2, u4,    axes
%                               are x,y   in any plotting
%   d.p1            Vector of u1 bin boundary values 
%   d.p2            Vector of u2 bin boundary values
%   d.p3            Vector of u3 bin boundary values
%   d.s(length(d.u1)-1,length(d.u2)-1, length(d.u3)-1)
%                   Cumulative intensity array
%   d.e(length(d.u1)-1,length(d.u2)-1, length(d.u3)-1)
%                   Cumulative variance array 
%   d.n(length(d.u1)-1,length(d.u2)-1, length(d.u3)-1)
%                   Number of pixels that contributed to a bin [int16]

% Original author: J. van Duijn
%
% $Revision$ ($Date$)
%
% Horace v0.1   J. van Duijn, T.G.Perring

% get the step sizes

stype=length(thick); % defines the type of slice we are going to do
if stype==1,
    ustep = [p1_bin(2), p2_bin(2), thick]; % (QQE)
    d.grid= 'orthogonal-grid';
    d.pax= [1,2,4];
elseif stype==2,
    ustep = [p1_bin(2), p2_bin(2), p3_bin(2)]; % (QQQ)
    d.grid= 'orthogonal-grid';
    d.pax= [1,2,3];
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
p0n= rlu_to_ustep*p0(1:3)';

% Generate the output vectors (u1, u2, u3) and corresponding intensity,
% error and pixel count array. 
d.file= data_source;
d.title=h_main.title;
d.a= h_main.a;
d.b= h_main.b;
d.c= h_main.c;
d.alpha= h_main.alpha;
d.beta= h_main.beta;
d.gamma= h_main.gamma;
d.u= [[u_to_rlu; 0 0 0], [0 0 0 1]'];
lis= find(round(u_to_rlu));
if length(lis)==3,
    tl= {'Q_h','Q_k','Q_l','E'};
    d.label= [tl(lis(1)),tl(lis(2)-3),tl(lis(3)-6),tl(4)];
else
    d.label= {'Q_\zeta','Q_\xi','Q_\eta','E'};
end
d.p0= p0';
d.ulen= [ulen,1];
d.p1= [p1_bin(1):p1_bin(2):p1_bin(3)]'; % length of d.u1=floor((u1_bin(3)-u1_bin(1))/u1_bin(2))+1
d.p2= [p2_bin(1):p2_bin(2):p2_bin(3)]'; % Contains the bin boundaries
d.p3= [p3_bin(1):p3_bin(2):p3_bin(3)]';
np1= length(d.p1)-1; % number of bins
np2= length(d.p2)-1;
np3= length(d.p3)-1;
d.s= zeros(np1,np2,np3);
d.e= zeros(np1,np2,np3);
d.n= double(d.s);

if strcmp(h_main.grid,'spe'), % Binary file constist of block spe data
    for iblock = 1:h_main.nfiles,
        disp(['reading block no.: ' num2str(iblock)]);
        h = getblock(fid, h_main); % read in spe block
    
        vstep= rlu_to_ustep*h.v; % convert h.v into the equivalent step matrix along the new 
                            % orthogonal set given by u_to_rlu
                            
        % generate the energy vector corresponding to each hkl vector
        emat= repmat(h.en, h.size(1), 1);
        emat= reshape(emat, h.size(1)*h.size(2),1);
        emat= emat';
    
        if stype==2, % QQQ
            % convert vstep into index array where vstep(i,1)= 1 corresponds to data
            % between pi(1) and pi(2).
            vstep(1,:)= floor(vstep(1,:)-p0n(1)-p1_bin(1)/p1_bin(2))+1;
            vstep(2,:)= floor(vstep(2,:)-p0n(2)-p2_bin(1)/p2_bin(2))+1;
            vstep(3,:)= floor(vstep(3,:)-p0n(3)-p3_bin(1)/p3_bin(2))+1;
      
            % generate equivalent energy matrix
            emat=round((emat-thick(1))/thick(2)); % the pixels we are interested have are those
                                          % where emat=0
            d.iax=4;
            d.uint=[thick(1)-thick(2)/2;thick(1)+thick(2)/2];
                                          
            % find the index array 
            lis=find(1<=vstep(1,:) & vstep(1,:)<=floor((max(d.p1)-p1_bin(1))/p1_bin(2)) & ...
                1<=vstep(2,:) & vstep(2,:)<=floor((max(d.p2)-p2_bin(1))/p2_bin(2)) & ...
                1<=vstep(3,:) & vstep(3,:)<=floor((max(d.p3)-p3_bin(1))/p3_bin(2)) & ...
                emat==0);
      
            % sum up the Intensity, errors and hits into the 3D array.
            % add the stepsize of the last bin of d.int with 0 int to make sure
            % that the accumulated array has the same szie as d.int
            %a=(accumarray(vstep(1:3,lis)',h.S(lis)))
            d.s= d.s + accumarray([[vstep(1:3,lis)], [np1; np2; np3]]',[h.S(lis) 0]); % summed 3D intensity array
            d.e= d.e + accumarray([[vstep(1:3,lis)], [np1; np2; np3]]',[h.ERR(lis) 0]); % summed 3D variance array
            d.n= d.n + double(accumarray([[vstep(1:3,lis)], [np1; np2; np3]]', [ones(1,length(lis)) 0]));
        
        else %QQE
            % convert vstep into index array where vstep(i,1)= 1 corresponds to data
            % between ui(1) and ui(2). Do this only for vectors along u1 and u2.
            vstep(1,:)= floor(vstep(1,:)-p0n(1)-p1_bin(1)/p1_bin(2))+1;
            vstep(2,:)= floor(vstep(2,:)-p0n(2)-p2_bin(1)/p2_bin(2))+1;
            vstep(3,:)= round(vstep(3,:)-p0n(3)); % binning along this axis stepsize is already in units of the thickness
            
            d.iax=3;
            d.uint=[p0n(3)-thick/2;p0n(3)+thick/2];
      
            % generate equivalent energy matrix
            emat= floor((emat-p3_bin(1) )/p3_bin(2))+1;
      
            % find the index array 
            lis=find(1<=vstep(1,:) & vstep(1,:)<=floor((max(d.p1)-p1_bin(1))/p1_bin(2)) & ...
                1<=vstep(2,:) & vstep(2,:)<=floor((max(d.p2)-p2_bin(1))/p2_bin(2)) & ...
                1<=emat & emat<=floor((max(d.p3)-p3_bin(1))/p3_bin(2)) & ...
                vstep(3,:)==0);
      
            % sum up the Intensity, errors and hits into the 3D array.
            % add the stepsize of the last bin of d.int with 0 int to make sure
            % that the accumulated array has the same size as d.int
            %a=(accumarray(vstep(1:3,lis)',h.S(lis)))
            d.s= d.s + accumarray([[vstep(1:2,lis);emat(lis)], [np1; np2; np3]]',[h.S(lis) 0]); % summed 3D intensity array
            d.e= d.e + accumarray([[vstep(1:2,lis);emat(lis)], [np1; np2; np3]]',[h.ERR(lis) 0]); % summed 3D error array
            d.n= d.n + double(accumarray([[vstep(1:2,lis);emat(lis)], [np1; np2; np3]]', [ones(1,length(lis)) 0]));
        end
    end
else % Binary file constists of 4D grid
    disp('Reading 4D grid');
    h = getblock(fid, h_main); % read in 4D grid
    
    % data will be broken down in to blocks along h.p4. Generate the large
    % vector arrays for h.p1,h.p2 and h.p3. The size of each vector is
    % length(h.p1)*length(h.p2)*length(h.p3)
    p1=(h.p1(1:length(h.p1)-1)+h.p1(2:length(h.p1)))/2;
    p2=(h.p2(1:length(h.p2)-1)+h.p2(2:length(h.p2)))/2;
    p3=(h.p3(1:length(h.p3)-1)+h.p3(2:length(h.p3)))/2;
    p4=(h.p4(1:length(h.p4)-1)+h.p4(2:length(h.p4)))/2;
    pt1= repmat(p1',1, length(p2)*length(p3));
    pt2= repmat(p2',length(p1),length(p3));
    pt2= reshape(pt2, 1, length(p1)*length(p2)*length(p3));
    pt3= repmat(p3',length(p1)*length(p2),1);
    pt3= reshape(pt3, 1, length(p1)*length(p2)*length(p3));
    
    vstep= rlu_to_ustep*[pt1;pt2;pt3]; % convert [pt1;pt2;pt3] into the equivalent step matrix along the new 
                            % orthogonal set given by u_to_rlu
    if stype==2, % QQQ
        % convert vstep into index array where vstep(i,1)= 1 corresponds to data
        % between pi(1) and pi(2).
        vstep(1,:)= floor(vstep(1,:)-p0n(1)-p1_bin(1)/p1_bin(2))+1;
        vstep(2,:)= floor(vstep(2,:)-p0n(2)-p2_bin(1)/p2_bin(2))+1;
        vstep(3,:)= floor(vstep(3,:)-p0n(3)-p3_bin(1)/p3_bin(2))+1;
        
        % generate equivalent energy matrix
        emat=round((p4-thick(1))/thick(2)); % the pixels we are interested have are those
                                          % where emat=0
        d.iax=4;
        d.uint=[thick(1)-thick(2)/2;thick(1)+thick(2)/2];
        
        for iblock= 1:(length(p4)),
            disp(['processing block no.: ' num2str(iblock)]);
            % find the index array 
            lis=find(1<=vstep(1,:) & vstep(1,:)<=floor((max(d.p1)-p1_bin(1))/p1_bin(2)) & ...
                1<=vstep(2,:) & vstep(2,:)<=floor((max(d.p2)-p2_bin(1))/p2_bin(2)) & ...
                1<=vstep(3,:) & vstep(3,:)<=floor((max(d.p3)-p3_bin(1))/p3_bin(2)) & ...
                emat(iblock)==0)
            
            if isempty(lis),
                
            else
                % generate the correct block intensity, error and n array
                st= reshape(h.s(:,:,:,iblock),1,(length(p1))*(length(p2))*(length(p3)));
                et= reshape(h.e(:,:,:,iblock),1,(length(p1))*(length(p2))*(length(p3)));
                nt= double(reshape(h.n(:,:,:,iblock),1,(length(p1))*(length(p2))*(length(p3))));
            
                % sum up the Intensity, errors and hits into the 3D array.
                % add the stepsize of the last bin of d.int with 0 int to make sure
                % that the accumulated array has the same szie as d.int
                %a=(accumarray(vstep(1:3,lis)',h.S(lis)))
                d.s= d.s + accumarray([[vstep(1:3,lis)], [np1; np2; np3]]',[st(lis) 0]); % summed 3D intensity array
                d.e= d.e + accumarray([[vstep(1:3,lis)], [np1; np2; np3]]',[et(lis) 0]); % summed 3D variance array
                d.n= d.n + double(accumarray([[vstep(1:3,lis)], [np1; np2; np3]]', [nt(lis) 0]));
            end
        end
    else %QQE
        % convert vstep into index array where vstep(i,1)= 1 corresponds to data
        % between ui(1) and ui(2). Do this only for vectors along u1 and u2.
        vstep(1,:)= floor(vstep(1,:)-p0n(1)-p1_bin(1)/p1_bin(2))+1;
        vstep(2,:)= floor(vstep(2,:)-p0n(2)-p2_bin(1)/p2_bin(2))+1;
        vstep(3,:)= round(vstep(3,:)-p0n(3)); % binning along this axis stepsize is already in units of the thickness
      
        d.iax=3;
        d.uint=[p0n(3)-thick/2;p0n(3)+thick/2];
        
        for iblock= 1:(length(p4)),
            disp(['processing block no.: ' num2str(iblock)]);
            
            % generate equivalent energy matrix
            emat=p4(iblock)*ones(1,length(vstep));
            emat= floor((emat-p3_bin(1) )/p3_bin(2))+1;
        
             % find the index array 
            lis=find(1<=vstep(1,:) & vstep(1,:)<=floor((max(d.p1)-p1_bin(1))/p1_bin(2)) & ...
                1<=vstep(2,:) & vstep(2,:)<=floor((max(d.p2)-p2_bin(1))/p2_bin(2)) & ...
                1<=emat & emat<=floor((max(d.p3)-p3_bin(1))/p3_bin(2)) & ...
                vstep(3,:)==0);
            
            if isempty(lis),
                
            else
                % generate the correct block intensity, error and n array
                st= reshape(h.s(:,:,:,iblock),1,(length(p1))*(length(p2))*(length(p3)));
                et= reshape(h.e(:,:,:,iblock),1,(length(p1))*(length(p2))*(length(p3)));
                nt= double(reshape(h.n(:,:,:,iblock),1,(length(p1))*(length(p2))*(length(p3))));
            
                % sum up the Intensity, errors and hits into the 3D array.
                % add the stepsize of the last bin of d.int with 0 int to make sure
                % that the accumulated array has the same size as d.int
                %a=(accumarray(vstep(1:3,lis)',h.S(lis)))
                d.s= d.s + accumarray([[vstep(1:2,lis);emat(lis)], [np1; np2; np3]]',[st(lis) 0]); % summed 3D intensity array
                d.e= d.e + accumarray([[vstep(1:2,lis);emat(lis)], [np1; np2; np3]]',[et(lis) 0]); % summed 3D error array
                d.n= d.n + double(accumarray([[vstep(1:2,lis);emat(lis)], [np1; np2; np3]]', [nt(lis) 0]));
            end
        end
    end
end
   
fclose(fid);