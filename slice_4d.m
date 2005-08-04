function d = slice_4d (binfil, u, v, p0, p1_bin, p2_bin, p3_bin, varargin)
% Reads a binary spe file and creates a 4D data set from it.
%
% Syntax:
%  To retain original energy binning from spe file:
%   >> d = slice_4d (binfil, u, v, p0, p1_bin, p2_bin, p3_bin, type)
%  
%  To alter energy binning:
%   >> d = slice_4d (binfil, u, v, p0, p1_bin, p2_bin, p3_bin, p4_bin, type)
% 
%  To use non-default axis labels for the momentum axes, add them as extra
%  parameters to either of the two cases above:
%   e.g.
%   >> d = slice_4d (binfil, u, v, p0, p1_bin, p2_bin, p3_bin, p4_bin, type, ...
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
%                           [p3_start, p3_step, p3_end]
%   p4_bin(1:3)     Binning along the energy axis:
%                           [p4_start, p4_step, p4_end]
%                    *OR* to use bin size from original spe files but change range:
%                           [p4_start, p4_end] 
%                    *OR* to use range and bin size from original spe files
%                           -- omit p4_bin --
%                   If p4_step is smaller than that in the spe files, it is set
%                   equal to that in the spe files.
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
%   d               4D dataset defined on orthogonal axes above

% Original author: J. van Duijn
%
% $Revision$ ($Date$)
%
% Horace v0.1   J. van Duijn, T.G.Perring

% parameter used to check rounding
small = 1.0e-13;

% Check input parameters - not necessarily exhaustive, but should catch the obvious syntactical errors...
% Check number of parameters
if nargin==8 & iscell(varargin{1}) % interpret as having been passed a varargin (as cell array is not a valid type to be passed to slice_4d)
    args = varargin{1};
else
    args = varargin;
end
nargs= length(args);
if isa_size(args{1},'row','double'),
    p4_bin= args{1};
    type= args{2};
    nstart= 3;
elseif isa_size(args{1},'row','char'),
    type= args{1};
    nstart=2;
else
    error ('ERROR - Check input arguments p4_bin or type')
end
if nargs>=nstart,
    j= 1;
    k= 1;
    for i= nstart:nargs,
        if isa_size(args{i},[1,3],'double'),
            nsym(j,:)= args{i};
            j= j+1;
        elseif isa_size(args{i},'row','char'),
            p_lab{k}= args{i};
            k= k+1;
        else
            error('ERROR - Check symmetry and p_label input arguments')
        end
    end
end

% If axis labels have been given extract them from p_lab
if exist('p_lab','var'),
    if size(p_lab,2)==3
        p1_lab = p_lab{1};
        p2_lab = p_lab{2};
        p3_lab = p_lab{3};
    else
        error('ERROR - need to give 3 p_labels when giving them')
    end
end

% Check normalisation of Q axes: (do this first, as omitting this is a common error to make)
if ~isa_size(type,[1,3],'char')
    error ('ERROR: Check type of argument ''type''')
end

% check u, v, p0, p1_bin, p2_bin, p3_bin:
if ~isa_size(u,[1,3],'double') | ~isa_size(v,[1,3],'double') | ~isa_size(p0,[1,3],'double') |...
        ~isa_size(p1_bin,[1,3],'double') | ~isa_size(p2_bin,[1,3],'double') | ~isa_size(p3_bin,[1,3],'double')
    error ('ERROR: Check length and shape of u, v, p0, p1_bin, p2_bin, p3_bin - must be row vectors length 3')
end

% check p4_bin:
if exist('p4_bin','var') && ~(isa_size(p4_bin,[1,2],'double') | isa_size(p4_bin,[1,3],'double'))
    error ('ERROR: Must provide binning for energy axis plotting in form [en_lo, eh_hi] or [en_start, en_step, en_end]')
end

% Check form of labels:
if exist('p1_lab','var') && ~(isa_size(p1_lab,'row','char') & ...
        isa_size(p2_lab,'row','char') & isa_size(p3_lab,'row','char'))
    error ('ERROR: If axis labels are given, they must be character strings')
end


% Now start calculation proper
% -----------------------------

fid= fopen(binfil, 'r');    % open spebin file
if fid<0; error (['ERROR: Unable to open file ',binfil]); end
disp('Reading binary file header ...');

[h_main,mess] = get_header(fid);   % get the main header information
if ~isempty(mess); fclose(fid); error(mess); end
if isfield(h_main,'grid')
    if ~strcmp(h_main.grid,'spe')
        fclose(fid);
        error ('ERROR: The function slice_4d only reads binary spe data ');
    end
else
    fclose(fid);
    error (['ERROR: Problems reading binary spe data from ',binfil])
end

% write h.ulen into spe_ulen as these vaklues will be needed if one wants to
% do symmetrisation of the data.
spe_ulen= h.ulen;

% obtain the conversion matrix that will convert the hkle vectors in the
% spe file in to equivalents in the orthogonal set defined by u and v
ustep = [p1_bin(2),p2_bin(2),p3_bin(2)];
[rlu_to_ustep, u_to_rlu, ulen] = rlu_to_ustep_matrix ([h_main.a,h_main.b, h_main.c],...
    [h_main.alpha,h_main.beta,h_main.gamma], u, v, ustep, type);

% convert p0 to the equivalent vector in the new orthogonal set given by
% u_to_rlu
p0n= rlu_to_ustep*p0(1:3)';

for iblock = 1:h_main.nfiles,
    disp(['reading spe block no.: ' num2str(iblock)]);
    [h,mess] = get_spe_datablock(fid); % read in spe block
    if ~isempty(mess); fclose(fid); error(mess); end
    
    if iblock==1, % Create the output data structure
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
        % set labels
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
        d.p0=[p0,0]';
        d.pax=[1,2,3,4];
        d.iax=[]; % create empty index of integration array
        d.uint=[];
        d.p1= [p1_bin(1):p1_bin(2):p1_bin(3)]'; % length of d.u1=floor((u1_bin(3)-u1_bin(1))/u1_bin(2))+1
        d.p2= [p2_bin(1):p2_bin(2):p2_bin(3)]'; % Contains the bin boundaries
        d.p3= [p3_bin(1):p3_bin(2):p3_bin(3)]';
        % Allow for energy range only to be given
        enbin = (h.en(end)-h.en(1))/(length(h.en)-1);  % energy grid is stored as bin centres
        if ~exist('p4_bin','var')   % use intrinsic energy bin and step
            p4_bin = [(h.en(1)-enbin/2),enbin,(h.en(end)+enbin/2)];
            disp('Using energy range and binning from first spe file')
        else
            if length(p4_bin)==2 | (length(p4_bin)==3 & enbin>p4_bin(2)) % binning is smaller then the intrinsic binning, or is not given
                % tweak limits so that where there is existing spe data, the bin boundaries will match
                p4_bin = [enbin*(ceil((p4_bin(1)-h.en(1))/enbin)-0.5)+h.en(1), enbin, ...
                          enbin*(floor((p4_bin(end)-h.en(1))/enbin)+0.5)+h.en(1)];
                if enbin>p4_bin(2)
                    disp ('Requested energy bin size is smaller than that of first spe file')
                end
                disp ('Using energy bin size from first spe file')
            end
        end
        d.p4= [p4_bin(1):p4_bin(2):p4_bin(3)]';
        np1= length(d.p1)-1; % number of bins
        np2= length(d.p2)-1;
        np3= length(d.p3)-1;
        np4= length(d.p4)-1;
        d.s= zeros(np1,np2,np3,np4); % generate the 4D data structures
        d.e= zeros(np1,np2,np3,np4);
        d.n= zeros(np1,np2,np3,np4,'int16');            
    end
    
    % If nsym array exists, symmetrise the data before it gets
    % converted into the equivalent step matrix along the new new orthogonal set given by u_to_rlu
    if exist('nsym','var'),
        for isym=1:length(nsym),
            h.v=symmetry(h.v,[spe_ulen(nsym(isym,1)),spe_ulen(nsym(isym,2))],nsym(isym,:));
        end
    end
        
    % convert h.v into the equivalent step matrix along the new orthogonal set given by u_to_rlu
    vstep= rlu_to_ustep*h.v; 
                            
    %generate the energy vector corresponding to each hkl vector
    emat= repmat(h.en, h.size(1), 1);
    emat= reshape(emat, 1, h.size(1)*h.size(2));
    
    % convert vstep into index array where vstep(i,1)= 1 corresponds to data
    % between pi(1) and pi(2).
    vstep(1,:)= floor(vstep(1,:)-p0n(1)-p1_bin(1)/p1_bin(2))+1;
    vstep(2,:)= floor(vstep(2,:)-p0n(2)-p2_bin(1)/p2_bin(2))+1;
    vstep(3,:)= floor(vstep(3,:)-p0n(3)-p3_bin(1)/p3_bin(2))+1;
    
    % generate equivalent energy matrix
    emat= floor((emat-p4_bin(1))/p4_bin(2))+1;
    
    % find the index array 
    lis=find(1<=vstep(1,:) & vstep(1,:)<=floor((max(d.p1)-p1_bin(1))/p1_bin(2)) & ...
             1<=vstep(2,:) & vstep(2,:)<=floor((max(d.p2)-p2_bin(1))/p2_bin(2)) & ...
             1<=vstep(3,:) & vstep(3,:)<=floor((max(d.p3)-p3_bin(1))/p3_bin(2)) & ...
             1<=emat       &       emat<=floor((max(d.p4)-p4_bin(1))/p4_bin(2)));
    
    % sum up the intensity, errors and hits into their corresponding 4D arrays.
    % add a reference to the last bin of d.s with zero intensity to make sure
    % that the accumulated array has the same size as d.s
    d.s= d.s + accumarray([[vstep(1:3,lis);emat(lis)], [np1; np2; np3; np4]]',[h.S(lis) 0]);    % summed 4D intensity array
    d.e= d.e + accumarray([[vstep(1:3,lis);emat(lis)], [np1; np2; np3; np4]]',[h.ERR(lis) 0]);  % summed 4D error array
    d.n= d.n + int16(accumarray([[vstep(1:3,lis);emat(lis)], [np1; np2; np3; np4]]', [ones(1,length(lis)) 0])); 
end

fclose(fid);

% Make class out of structure:
d = d4d(d);
