function d = slice_3d (binfil, u, v, p0, p1_bin, p2_bin, p3_bin, varargin)
% Reads a binary spe file *OR* binary 4D dataset file and creates a 3D data set
% by integrating over one of the momentum or energy axes.
%
% Syntax:
%   >> d = slice_3d (binfil, u, v, p0, p1_bin, p2_bin, p3_bin, p4_bin, type)
%
%  To give custom labels to the momentum axis labels
%   >> d = slice_3d (binfil, u, v, p0, p1_bin, p2_bin, p3_bin, p4_bin, type, ...
%                                                     p1_lab, p2_lab, p3_lab)
% 
% Input:
% ------
%   binfil          Binary spe file created using function gen_hkle
%   u(1:3)          Vector defining first plot axis (r.l.u.)
%   v(1:3)          Vector defining plane of plot in Q-space (r.l.u.)
%        These two directions define a plane with the first axis parallel to u
%       and the second perpendicular to u in the plane of u and v. A third axis 
%       is defined as perpendicular to the plane of u and v, forming a right-hand
%       set. Call the orthogonal set created from u and v: p1, p2, p3.
%        The 4D grid is now built up from p1, p2, p3 and energy (called p4 below).
%        The unit lengths along the axes p1, p2 and p3 are determined by the 
%       character codes in the variable 'type' described below.
%           
%   p0(1:3)         Vector defining origin of the grid in momentum space (r.l.u.)
%   p1_bin(1:3)     Binning along p1 axis: [p1_start, p1_step, p1_end]
%   p2_bin(1:3)     Binning perpendicular to u axis within the plot plane:
%                           [p2_start, p2_step, p2_end]
%   p3_bin(1:3)     Binning perpendicular to p1 and p2: 
%                   - if this is to be the 3rd plot axis (i.e. energy will be integrated)
%                           [p3_start, p3_step, p3_end]
%                   - if integration is along this axis, give either
%                           [p3_start, p3_end]
%                     *OR*   p3_thick    - equivalent to  [-thick/2, +thick/2]
%   p4_bin(1:3)     Binning along the energy axis:
%                   - if this is the 3rd plot axis (i.e. p3 will be integrated):
%                           [p4_start, p4_step, p4_end]
%                     *OR* to use bin size from original spe files but change range:
%                           [p4_start, p4_end] 
%                     *OR* to use range and bin size from original spe files
%                        -- omit p4_bin --
%                       (If p4_step is smaller than that in the spe files,
%                         it is set equal to that in the spe files)
%                   - if integration is along this axis:
%                           [p4_start, p4_end] 
%   type            Defines measure of units length for binning.
%        Three-character string, each character indicating if p1, p2, p3 are
%       normalised to Angstrom^-1 or r.l.u., max(abs(h,k,l))=1:
%        - if 'a': unit length is one inverse Angstrom
%        - if 'r': then if (h,k,l) in r.l.u., is normalised so max(abs([h,k,l]))=1
%       e.g. type='rrr' or 'raa'
%
%   p1_lab          Short label for p1 axis (e.g. 'Q_h' or 'Q_{kk}')
%   p2_lab          Short label for p2 axis
%   p3_lab          Short label for p3 axis
%
%
% Output:
% -------
%   d       3D dataset defined on orthogonal axes above
%           For a complete description of the fields of the dataset, type
%               >> help dnd_checkfields
%
%
% EXAMPLES
%   >> d = slice_3d ('RbMnF3.bin', [1,1,0], [0,0,1], [0.5,0.5,0.5],...
%                            [-1.5,0.05,1.5], [-2,0.05,2], 0.1, 'rrr')

% Original author: J. van Duijn
%
% $Revision$ ($Date$)
%
% Horace v0.1   J. van Duijn, T.G.Perring


% parameter used to check rounding
small = 1.0e-13;

% Check input parameters - not necessarily exhaustive, but should catch the obvious syntactical errors...
% Check number of parameters
if nargin==8
    type= varargin{1};
elseif nargin==9,
    p4_bin=varargin{1};
    type= varargin{2};
elseif nargin==11
    type= varargin{1};
    p1_lab = varargin{2};
    p2_lab = varargin{3};
    p3_lab = varargin{4};
elseif nargin==12
    p4_bin=varargin{1};
    type= varargin{2};
    p1_lab = varargin{3};
    p2_lab = varargin{4};
    p3_lab = varargin{5};
else
    error ('ERROR - Check number of arguments')
end

% check u, v, p0, p1_bin, p2_bin:
if ~isa_size(u,[1,3],'double') | ~isa_size(v,[1,3],'double') | ~isa_size(p0,[1,3],'double') |...
        ~isa_size(p1_bin,[1,3],'double') | ~isa_size(p2_bin,[1,3],'double')
    error ('ERROR: Check length and shape of u, v, p0, p1_bin, p2_bin - must be row vectors length 3')
end

% check p3_bin:
if isa_size(p3_bin,[1,3],'double')       % p3 will be a plot axis
    qqq = 1;
elseif isa_size(p3_bin,[1,2],'double')|isa_size(p3_bin,[1,1],'double')   % p3 will be integration axis
    qqq = 0;
else
    error ('ERROR: Check length and shape of p3_bin')
end

% check p4_bin:
if qqq  % energy integration
    if ~exist('p4_bin','var') || ~isa_size(p4_bin,[1,2],'double')
        error ('ERROR: Must provide energy integration range in form [en_start, en_end]')
    end
else
    if exist('p4_bin','var') && ~(isa_size(p4_bin,[1,2],'double') & isa_size(p4_bin,[1,3],'double'))
        error ('ERROR: Must provide binning for energy axis plotting in form [en_lo, eh_hi] or [en_start, en_step, en_end]')
    end
end

% Check normalisation of Q axes:
if ~isa_size(type,[1,3],'char')
    error ('ERROR: Check type of argument ''type''')
end

% Check form of labels:
if exist('p1_lab','var') && ~(isa_size(p1_lab,'row','char') & ...
        isa_size(p2_lab,'row','char') & isa_size(p3_lab,'row','char'))
    error ('ERROR: If axis labels are given, they must be character strings')
end


% Now start calculation proper
% -----------------------------

fid= fopen(binfil, 'r');    % open bin file
h_main = get_header(fid);   % get the main header information

% obtain the conversion matrix that will convert the hkle vectors in the
% spe file in to equivalents in the orthogonal set defined by u and v
if qqq
    centre = (p4_bin(1)+p4_bin(2))/2;
    thick = (p4_bin(2)-p4_bin(1));
    ustep = [p1_bin(2), p2_bin(2), p3_bin(2)];
else
    if length(p3_bin)==2
        centre = (p3_bin(1)+p3_bin(2))/2;
        thick = (p3_bin(2)-p3_bin(1));
    else
        centre = 0;
        thick = p3_bin;
    end
    ustep = [p1_bin(2), p2_bin(2), thick];
end
[rlu_to_ustep, u_to_rlu, ulen] = rlu_to_ustep_matrix ([h_main.a,h_main.b, h_main.c],...
    [h_main.alpha,h_main.beta,h_main.gamma], u, v, ustep, type);

% convert p0 to the equivalent vector in the new orthogonal set given by
% u_to_rlu
p0n= rlu_to_ustep*p0(1:3)';

% Create header for output dataset 
d.file= binfil;
d.grid= 'orthogonal-grid';
d.title=h_main.title;
d.a= h_main.a;
d.b= h_main.b;
d.c= h_main.c;
d.alpha= h_main.alpha;
d.beta= h_main.beta;
d.gamma= h_main.gamma;
d.u= [[u_to_rlu; 0 0 0], [0 0 0 1]'];
d.ulen= [ulen,1];
if exist('p1_lab','var')    % labels were provided
    d.label = {p1_lab,p2_lab,p3_lab,'E'};
else
    % determine if the three axes are h, k and l (or some permutation)
    if max(max(abs(sort(u_to_rlu)-[0,0,0;0,0,0;1,1,1]))) < small
        lis= find(round(u_to_rlu));  % find the elements equal to unity
        tl= {'Q_h','Q_k','Q_l','E'};
        d.label= [tl(lis(1)),tl(lis(2)-3),tl(lis(3)-6),tl(4)];
    else
        d.label= {'Q_\zeta','Q_\xi','Q_\eta','E'};
    end
end
d.p0= [p0,0]';
if qqq
    d.pax = [1,2,3];
    d.iax = 4;
else
    d.pax = [1,2,4];
    d.iax = 3;
end
d.uint = [centre-thick/2; centre+thick/2];

%--------------------------------------------------------------------------------------------------------
if strcmp(h_main.grid,'spe')    % Binary file consists of block spe data
    disp('Reading spe files from binary file ...');
    for iblock = 1:h_main.nfiles,
        disp(['reading spe block no.: ' num2str(iblock)]);
        h = get_spe_datablock(fid); % read in spe block

        if iblock==1    % initialise grid data block
            d.p1 = [p1_bin(1):p1_bin(2):p1_bin(3)]'; % length of d.u1=floor((u1_bin(3)-u1_bin(1))/u1_bin(2))+1
            d.p2 = [p2_bin(1):p2_bin(2):p2_bin(3)]'; % Contains the bin boundaries
            if qqq
                d.p3 = [p3_bin(1):p3_bin(2):p3_bin(3)]';
            else
                % Allow for energy range only to be given
                enbin = (h.en(end)-h.en(1))/(length(h.en)-1);  % energy grid is stored as bin centres
                if ~exist('p4_bin','var')   % use intrinsic energy bin and step
                    p4_bin = [(h.en(1)-enbin/2),enbin,(h.en(end)+enbin/2)];
                    disp('Using energy range and binning from first spe file')
                else
                    if length(p4_bin)==2 | (length(p4_bin)==3 & enbin>p4_bin(2)) % binning is smaller then the intrinsic binning, or is not given
                        % tweak limits so that where there is existing spe data, the bin boundaries will match
                        p4_bin = [enbin*(ceil((p4_bin(1)-h.en(1))/enbin)-0.5), enbin, ...
                                  enbin*(floor((p4_bin(end)-h.en(1))/enbin)+0.5)];
                        if enbin>p4_bin(2)
                            disp ('Requested energy bin size is smaller than that of first spe file')
                        end
                        disp ('Using energy bin size from first spe file')
                    end
                end
                d.p3 = [p4_bin(1):p4_bin(2):p4_bin(3)]';
            end
            np1 = length(d.p1)-1; % number of bins
            np2 = length(d.p2)-1;
            np3 = length(d.p3)-1;
            d.s = zeros(np1,np2,np3);
            d.e = zeros(np1,np2,np3);
            d.n = zeros(np1,np2,np3);
        end

        % convert h.v into the equivalent step matrix along the new orthogonal set given by u_to_rlu
        vstep = rlu_to_ustep*h.v;
                            
        % generate the energy vector corresponding to each hkl vector. Leave this in the loop over
        % iblock = 1:(no. spe files) in case the energy bins are different from one spe file to the next
        emat = repmat(h.en, h.size(1), 1);
        emat = reshape(emat, 1, h.size(1)*h.size(2));
    
        if qqq
            % convert vstep into index array where vstep(i,1)= 1 corresponds to data
            % between pi(1) and pi(2).
            vstep(1,:) = floor(vstep(1,:)-p0n(1)-p1_bin(1)/p1_bin(2))+1;
            vstep(2,:) = floor(vstep(2,:)-p0n(2)-p2_bin(1)/p2_bin(2))+1;
            vstep(3,:) = floor(vstep(3,:)-p0n(3)-p3_bin(1)/p3_bin(2))+1;
      
            % generate equivalent energy matrix
            emat=round((emat-centre)/thick); % the pixels we are interested have are those where emat=0
                                          
            % find the index array 
            lis = find(1<=vstep(1,:) & vstep(1,:)<=floor((max(d.p1)-p1_bin(1))/p1_bin(2)) & ...
                       1<=vstep(2,:) & vstep(2,:)<=floor((max(d.p2)-p2_bin(1))/p2_bin(2)) & ...
                       1<=vstep(3,:) & vstep(3,:)<=floor((max(d.p3)-p3_bin(1))/p3_bin(2)) & ...
                       emat==0);
      
            % sum up the intensity, errors and hits into their corresponding 3D arrays.
            % add a reference to the last bin of d.s with zero intensity to make sure
            % that the accumulated array has the same size as d.s
            d.s = d.s + accumarray([[vstep(1:3,lis)], [np1; np2; np3]]', [h.S(lis) 0]);   % summed 3D intensity array
            d.e = d.e + accumarray([[vstep(1:3,lis)], [np1; np2; np3]]', [h.ERR(lis) 0]); % summed 3D variance array
            d.n = d.n + double(accumarray([[vstep(1:3,lis)], [np1; np2; np3]]', [ones(1,length(lis)) 0]));
        
        else
            % convert vstep into index array where vstep(i,1)= 1 corresponds to data
            % between pi(1) and pi(2). Do this only for vectors along p1 and p2.
            vstep(1,:) = floor(vstep(1,:)-p0n(1)-p1_bin(1)/p1_bin(2))+1;
            vstep(2,:) = floor(vstep(2,:)-p0n(2)-p2_bin(1)/p2_bin(2))+1;
            vstep(3,:) = round(vstep(3,:)-p0n(3)-centre/thick);
      
            % generate equivalent energy matrix
            emat= floor((emat-p4_bin(1))/p4_bin(2))+1;
      
            % find the index array 
            lis = find(1<=vstep(1,:) & vstep(1,:)<=floor((max(d.p1)-p1_bin(1))/p1_bin(2)) & ...
                       1<=vstep(2,:) & vstep(2,:)<=floor((max(d.p2)-p2_bin(1))/p2_bin(2)) & ...
                       vstep(3,:)==0                                                      & ...
                       1<=emat       &       emat<=floor((max(d.p3)-p4_bin(1))/p4_bin(2)) );
      
            % sum up the intensity, errors and hits into their corresponding 3D arrays.
            % add a reference to the last bin of d.s with zero intensity to make sure
            % that the accumulated array has the same size as d.s
            d.s = d.s + accumarray([[vstep(1:2,lis);emat(lis)], [np1; np2; np3]]', [h.S(lis) 0]);    % summed 3D intensity array
            d.e = d.e + accumarray([[vstep(1:2,lis);emat(lis)], [np1; np2; np3]]', [h.ERR(lis) 0]);  % summed 3D error array
            d.n = d.n + double(accumarray([[vstep(1:2,lis);emat(lis)], [np1; np2; np3]]', [ones(1,length(lis)) 0]));
        end
    end

%--------------------------------------------------------------------------------------------------------
else    % Binary file consists of 4D grid
    % Read in the 4D grid data
    disp('Reading 4D grid ...');
    h = get_grid_data(fid, 4); % read in 4D grid

    % Initialise the grid data block 
    d.p1 = [p1_bin(1):p1_bin(2):p1_bin(3)]'; % length of d.u1=floor((u1_bin(3)-u1_bin(1))/u1_bin(2))+1
    d.p2 = [p2_bin(1):p2_bin(2):p2_bin(3)]'; % Contains the bin boundaries
    if qqq
        d.p3 = [p3_bin(1):p3_bin(2):p3_bin(3)]';
    else
        % Allow for energy range only to be given
        enbin = (h.p4(end)-h.p4(1))/(length(h.p4)-1);
        if ~exist('p4_bin','var')   % use intrinsic energy bin and step
            p4_bin = [h.p4(1),enbin,h.p4(end)];
            disp('Using energy range and binning from 4D grid')
        else
            if length(p4_bin)==2 | (length(p4_bin)==3 & enbin>p4_bin(2)) % binning is smaller then the intrinsic binning, or is not given
                % tweak limits so that where there is existing data, the bin boundaries will match
                p4_bin = [enbin*ceil((p4_bin(1)-h.p4(1))/enbin), enbin, ...
                                  enbin*floor((p4_bin(end)-h.p4(1))/enbin)];
                if enbin>p4_bin(2)
                    disp ('Requested energy bin size is smaller than that of 4D grid')
                end
                disp ('Using energy bin size from 4D grid')
            end
        end
        d.p3 = [p4_bin(1):p4_bin(2):p4_bin(3)]';
    end
    np1 = length(d.p1)-1; % number of bins
    np2 = length(d.p2)-1;
    np3 = length(d.p3)-1;
    d.s = zeros(np1,np2,np3);
    d.e = zeros(np1,np2,np3);
    d.n = zeros(np1,np2,np3);
    
    % data will be broken down in to blocks along h.p4. Generate the large
    % vector arrays for h.p1,h.p2 and h.p3. The size of each vector is
    % length(h.p1)*length(h.p2)*length(h.p3)
    p1 = (h.p1(1:end-1)+h.p1(2:end))/2;
    p2 = (h.p2(1:end-1)+h.p2(2:end))/2;
    p3 = (h.p3(1:end-1)+h.p3(2:end))/2;
    p4 = (h.p4(1:end-1)+h.p4(2:end))/2;

    pt1 = repmat(p1', 1, length(p2)*length(p3));
    pt2 = repmat(p2', length(p1), length(p3));
    pt2 = reshape(pt2, 1, length(p1)*length(p2)*length(p3));
    pt3 = repmat(p3', length(p1)*length(p2), 1);
    pt3 = reshape(pt3, 1, length(p1)*length(p2)*length(p3));
    
    % convert [pt1;pt2;pt3] into the equivalent step matrix along the new orthogonal set given by u_to_rlu
    vstep = rlu_to_ustep*[pt1;pt2;pt3]; 

    if qqq
        % convert vstep into index array where vstep(i,1)= 1 corresponds to data
        % between pi(1) and pi(2).
        vstep(1,:) = floor(vstep(1,:)-p0n(1)-p1_bin(1)/p1_bin(2))+1;
        vstep(2,:) = floor(vstep(2,:)-p0n(2)-p2_bin(1)/p2_bin(2))+1;
        vstep(3,:) = floor(vstep(3,:)-p0n(3)-p3_bin(1)/p3_bin(2))+1;
        
        % generate equivalent energy matrix
        emat=round((p4-centre)/thick);  % the pixels we are interested have are those where emat=0
        
        for iblock= 1:(length(p4))
            disp(['processing energy slice no.: ' num2str(iblock)]);
            % find the index array 
            lis = find(1<=vstep(1,:) & vstep(1,:)<=floor((max(d.p1)-p1_bin(1))/p1_bin(2)) & ...
                       1<=vstep(2,:) & vstep(2,:)<=floor((max(d.p2)-p2_bin(1))/p2_bin(2)) & ...
                       1<=vstep(3,:) & vstep(3,:)<=floor((max(d.p3)-p3_bin(1))/p3_bin(2)) & ...
                       emat(iblock)==0);
            
            if ~isempty(lis)
                % generate the correct block intensity, error and n array
                st = reshape(h.s(:,:,:,iblock),1,(length(p1))*(length(p2))*(length(p3)));
                et = reshape(h.e(:,:,:,iblock),1,(length(p1))*(length(p2))*(length(p3)));
                nt = double(reshape(h.n(:,:,:,iblock),1,(length(p1))*(length(p2))*(length(p3))));
            
                % see .spe branch of outer if statement for explanation of logic of the following
                d.s = d.s + accumarray([[vstep(1:3,lis)], [np1; np2; np3]]', [st(lis) 0]);  % summed 3D intensity array
                d.e = d.e + accumarray([[vstep(1:3,lis)], [np1; np2; np3]]', [et(lis) 0]);  % summed 3D variance array
                d.n = d.n + double(accumarray([[vstep(1:3,lis)], [np1; np2; np3]]', [nt(lis) 0]));
            end
        end
    else
        % convert vstep into index array where vstep(i,1)= 1 corresponds to data
        % between pi(1) and pi(2). Do this only for vectors along p1 and p2.
        vstep(1,:) = floor(vstep(1,:)-p0n(1)-p1_bin(1)/p1_bin(2))+1;
        vstep(2,:) = floor(vstep(2,:)-p0n(2)-p2_bin(1)/p2_bin(2))+1;
        vstep(3,:) = round(vstep(3,:)-p0n(3)-centre/thick);

        for iblock= 1:(length(p4)),
            disp(['processing energy slice no.: ' num2str(iblock)]);
            % generate equivalent energy matrix
            emat = p4(iblock)*ones(1,size(vstep,2));
            emat = floor((emat-p4_bin(1))/p4_bin(2))+1;
        
            % find the index array 
            lis = find(1<=vstep(1,:) & vstep(1,:)<=floor((max(d.p1)-p1_bin(1))/p1_bin(2)) & ...
                       1<=vstep(2,:) & vstep(2,:)<=floor((max(d.p2)-p2_bin(1))/p2_bin(2)) & ...
                       vstep(3,:)==0                                                      & ...
                       1<=emat       &       emat<=floor((max(d.p3)-p4_bin(1))/p4_bin(2)) );
            
            if ~isempty(lis)
                % generate the correct block intensity, error and n array
                st= reshape(h.s(:,:,:,iblock),1,(length(p1))*(length(p2))*(length(p3)));
                et= reshape(h.e(:,:,:,iblock),1,(length(p1))*(length(p2))*(length(p3)));
                nt= double(reshape(h.n(:,:,:,iblock),1,(length(p1))*(length(p2))*(length(p3))));
            
                % see .spe branch of outer if statement for explanation of logic of the following
                d.s= d.s + accumarray([[vstep(1:2,lis);emat(lis)], [np1; np2; np3]]',[st(lis) 0]); % summed 3D intensity array
                d.e= d.e + accumarray([[vstep(1:2,lis);emat(lis)], [np1; np2; np3]]',[et(lis) 0]); % summed 3D error array
                d.n= d.n + double(accumarray([[vstep(1:2,lis);emat(lis)], [np1; np2; np3]]', [nt(lis) 0]));
            end
        end
    end
end
   
fclose(fid);

% Make class out of structure:
d = d3d(d);
