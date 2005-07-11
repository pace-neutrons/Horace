function d = slice_3d (data_source, u, v, p0, stype, u1_bin, u2_bin, u3_bin, thick, type)
% 
% input:
%   data_source File containing (h,k,l,e) data
%   u(1:3)      Vector defining first plot axis (r.l.u.)
%   v(1:3)      Vector defining plane of plot in Q-space (r.l.u.)
%           The plot plane is defined by u and the perpendicular to u in the
%           plane of u and v. The unit lengths of the axes are determined by the
%           character codes in the variable 'type' described below
%            - if 'a': unit length is one inverse Angstrom
%            - if 'r': then if (h,k,l) in r.l.u., is normalised so max([h,k,l])=1
%           Call the orthogonal set created from u and v: u1, u2, u3.
%   p0(1:3)     Vector defining origin of the plane in Q-space (r.l.u.)
%   stype       type of slice, 'QE' (bin along the perpendicular of the plot plane) 
%               or 'QQ' (bining along energy (to obtain constant E
%               slices)).
%   u1_bin(1:3)   Binning along u axis: [u1_start, u1_step, u1_end]
%   u2_bin(1:3)   Binning perpendicular to u axis within the plot plane:
%                                     [u2_start, u2_step, u2_end]
%   u3_bin(1:3)   depending on stype this will either be binning along the
%                 energy axis or the u3 axis which is perpendicular to the
%                 plot plane.
%   thick       Thickness of binning perpendicular to plot plane: +/-(thick/2)
%   type        Units of binning and thickness: a three-character string,
%               each character indicating if u1, u2, u3 normalised to Angstrom^-1
%               or r.l.u., max(h,k,l)=1.

% get the step sizes
if strcmp(stype, 'QE'),
    ustep = [u1_bin(2), u2_bin(2), thick]; 
elseif strcmp(stype, 'QQ'),
    ustep = [u1_bin(2), u2_bin(2), u3_bin(2)];
else
    disp('Wrong stype given, only QE or QQ options are allowed');
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
d.stype= stype;
d.u_to_rlu= u_to_rlu;
d.p0= p0;
d.ulen= ulen;
d.u1= u1_bin(1):u1_bin(2):u1_bin(3);
d.u2= u2_bin(1):u2_bin(2):u2_bin(3);
d.u3= u3_bin(1):u3_bin(2):u3_bin(3);
nu1= length(d.u1);
nu2= length(d.u2);
nu3= length(d.u3);
d.rint= zeros(nu1,nu2,nu3);
d.eint= zeros(nu1,nu2,nu3);
d.nint= int16(d.rint);

for iblock = 1:h_main.nfiles,
    h = getblock(fid); % read in spe block
    
    Vstep= rlu_to_ustep*h.v; % convert h.v into the equivalent step matrix along the new 
                            % orthogonal set given by u_to_rlu
    for j=1:3,
        Vstep(j,:)=Vstep(j,:)-p0n(j); % subtract the origin vector
    end
    Vstep= round(Vstep); % round to give the number of steps from the origin point of the plane
    
    % generate the energy vector corresponding to each hkl vector
    Emat= repmat(h.en, h.size(1), 1);
    Emat= reshape(Emat, h.size(1)*h.size(2),1);
    Emat= Emat';
    
    % determine the max and min values along the 3 binning directions in
    % their multiples of the respective stepsize
    u1_min= u1_bin(1)/u1_bin(2);
    u1_min= round(u1_min);
    u1_max= u1_bin(3)/u1_bin(2);
    u1_max= round(u1_max);
    u2_min= u2_bin(1)/u2_bin(2);
    u2_min= round(u2_min);
    u2_max= u2_bin(3)/u2_bin(2);
    u2_max= round(u2_max);
    u3_min= u3_bin(1)/u3_bin(2);
    u3_min= round(u3_min);
    u3_max= u3_bin(3)/u3_bin(2);
    u3_max= round(u3_max);
    
    % sum up the Intensity, errors and hits into the 3D array. 
    if strcmp(stype, 'QE'),
        Emat=Emat/u3_bin(3);
        Emat=round(Emat);
        lis= find(u1_min<=Vstep(1,:)& Vstep(1,:)<=u1_max &...
            u2_min<=Vstep(2,:)& Vstep(2,:)<=u2_max &...
            Vstep(3,:)==0 & u3_min<=Emat & Emat<=u3_max);
        iu1= Vstep(1,:)-u1_min+1; % calculate the indexes of the affected pixels
        iu2= Vstep(2,:)-u2_min+1;
        iu3= Emat-u3_min+1;
    else
        Emat=Emat/thick;
        Emat=round(Emat);
        lis= find(u1_min<=Vstep(1,:)& Vstep(1,:)<=u1_max &...
            u2_min<=Vstep(2,:)& Vstep(2,:)<=u2_max &...
            u3_min<=Vstep(3,:)& Vstep(3,:)<=u3_max & Emat==0);
        iu1= Vstep(1,:)-u1_min+1; % calculate the indexes of the affected pixels
        iu2= Vstep(2,:)-u2_min+1;
        iu3= Vstep(3,:)-u3_min+1;
    end
    for ip=1:length(lis),
       d.rint(iu1(lis(ip)),iu2(lis(ip)),iu3(lis(ip)))= d.rint(iu1(lis(ip)),iu2(lis(ip)),iu3(lis(ip)))+ h.S(lis(ip));
       d.eint(iu1(lis(ip)),iu2(lis(ip)),iu3(lis(ip)))= d.eint(iu1(lis(ip)),iu2(lis(ip)),iu3(lis(ip)))+ h.ERR(lis(ip));
       d.nint(iu1(lis(ip)),iu2(lis(ip)),iu3(lis(ip)))= sum([d.nint(iu1(lis(ip)),iu2(lis(ip)),iu3(lis(ip))),1]);
    end
    
end

% any pixels that have not recieved any intensity will be given the value
% -1 as flag

fclose(fid);
    