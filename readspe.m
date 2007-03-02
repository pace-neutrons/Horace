function data=readspe(msp,spe,varargin)
% Read a spe file into a Horace data set, using the facilities provided by 
% mslice. Powder data will be read into a two dimensional dataset while 
% single crystal data will be read into either a three or two dimensional 
% dataset depending on the whether the data was collected on a PSD or 
% conventional detector array. 
%
% Syntax:
%   Loading powder data:
%   Use the data stored in the msp file
%   >>data=readspe(msp, spe)
%
%   Change the incident energy:
%   >>data=readspe(msp,spe,ei)
%
%   For single crystal data:
%   PSD detectors:
%   Give the psi angle, but use the projection axes given in the msp file
%   >>data=readspe(msp, spe, psi, p1_bin, p2_bin, p3_bin)
%
%   adding labels to the three projection axes:
%   >>data=readspe(msp, spe, psi, p1_bin, p2_bin, p3_bin, p1_lab, p2_lab, p3_lab)
%
%   Give all three projection axes (must be orthogonal for mslice to work)
%   >> gen_hkle (msp, spe, psi, p1, p2,p3, p1_bin, p2_bin, p3_bin)
%
%   adding labels to the three projection axes:
%   >> gen_hkle (msp, spe, psi, p1, p2, p1_bin, p2_bin, p3_bin, p1_lab, p2_lab, p3_lab)
%
%   Conventional detectors:
%   Give the psi angle, but use the projection axes given in the msp file
%   >>data=readspe(msp, spe, psi, p1_bin, p2_bin)
%
%   adding labels to the three projection axes:
%   >>data=readspe(msp, spe, psi, p1_bin, p2_bin, p1_lab, p2_lab)
%
%   Give all three projection axes (must be orthogonal for mslice to work)
%   >> gen_hkle (msp, spe, psi, p1, p2, p1_bin, p2_bin)
%
%   adding labels to the three projection axes:
%   >> gen_hkle (msp, spe, psi, p1, p2, p1_bin, p2_bin, p1_lab, p2_lab)
% NOTES:
%   1) This routine requires that mslice is running in the background.
%   2) In the case of powder data the routine assumes that the plot
%   axes are |Q| and Energy.
%   3) Becareful the p's given here are the same as one would give in
%   mslice (u1, u2 and u3: row vectors of length 4)and not those one would give in gen_hkle
%   or gen_sqe.
%   4) We use p's instead of u's to make this routine consistend with the
%   anotation used in other Horace routines.
%
%   5) In the case of single crystal data it only works for PSD data.
%
% Input:
% ------
%   msp        Mslice parameter file (including path if not in current
%               directory). Must have correct .phx file, scattering
%               plane etc. The only information that will be over-written 
%               by this function is the .spe file, psi and projection axes.
%
%   spe        spe file (including path if not in current directory)
%
%   ei         incident energy of the corresponding ei file.
%
%   psi        psi value (deg) of the corresponding spe file. 
%
%   p1    --|   Projection axes in which to label pixel centres [row vectors] in the format [a*,b*,c*,energy]
%   p2      |--   e.g.    p1 = [1,0,0,0], p2=[0,1,0,0], p3=[0,0,1,0]
%   p3    --|     e.g.    p1 = [1,1,0,0], p2=[-1,1,0,0], p3=[0,0,0,0] here u3 is the energy axis
%
%   p1_bin       Binning along u1: 
%                - if this is to be a plot axis 
%                   [u1_start, u1_step, u1_end]
%   p2_bin       Binning along u2: 
%                - if this is to be a plot axis 
%                   [u2_start, u2_step, u2_end]
%   p3_bin       Binning along u3: 
%                - if this is to be a plot axis 
%                   [u3_start, u3_step, u3_end]
%
%   p1_lab--|   Optional labels for the projection axes (e.g. 'Q_h' or 'Q_{kk}')
%   p2_lab  |-- If not provided, then default values will be written
%   p3_lab--|   
%
% Output:
% -------
%   data    Dataset containng the data read from the spe file. 
%

% Original author: J. van Duijn
%
% $Revision: $ ($Date: $)
%
% Horace v0.1   J. van Duijn, T.G.Perring

% Status of mslice - if this routine opens mslice, then opened_mslice will not be empty
opened_mslice = [];

% parameter used to check rounding
small = 1.0e-13;

% Determine if mslice is running, and try to open if it is not
fig=findobj('Tag','ms_ControlWindow');
if isempty(fig),
    disp('Mslice control window not active. Starting mslice...');
    disp (' ')
    mslice
    disp (' ')
    opened_mslice = findobj('Tag','ms_ControlWindow');
    if isempty(opened_mslice),
        error('ERROR: Unable to start mslice. Please check your mslice setup.');
    end
end

% Determine if values contained in the msp file need to be changed.
if nargin==2 || nargin==3 || nargin==5 ||nargin==6,
    labels= 0;
    if nargin==3,
        ei= varargin{1};
    end
    if nargin== 5,
        psi= varargin{1};
        p1_bin= varargin{2};
        p2_bin= varargin{3};
    end
    if nargin==6,
        psi= varargin{1};
        p1_bin= varargin{2};
        p2_bin= varargin{3};
        p3_bin= varargin{4};
    end
elseif nargin==7,
    psi= varargin{1};
    if isa_size(varargin{4},'row','char'),
        labels= 2;
        p1_bin= varargin{2};
        p2_bin= varargin{3};
        p1_lab= varargin{4};
        p2_lab= varargin{5};
    else
        labels= 0;
        p1= varargin{2};
        p2= varargin{3};
        p1_bin= varargin{4};
        p2_bin= varargin{5};
    end
elseif nargin==9,
    psi= varargin{1};
    if isa_size(varargin{5},'row','double') && isa_size(varargin{6},'row','char'),
        labels= 2;
        p1= varargin{2};
        p2= varargin{3};
        p1_bin= varargin{4};
        p2_bin= varargin{5};
        p1_lab= varargin{6};
        p2_lab= varargin{7};
    elseif isa_size(varargin{5},'row','char'),
        labels= 3;
        p1_bin= varargin{2};
        p2_bin= varargin{3};
        p3_bin= varargin{4};
        p1_lab= varargin{5};
        p2_lab= varargin{6};
        p3_lab= varargin{7};
    else
        labels= 3;
        p1= varargin{2};
        p2= varargin{3};
        p3= varargin{4};
        p1_bin= varargin{5};
        p2_bin= varargin{6};
        p3_bin= varargin{7};
    end
elseif nargin== 12,
    labels= 3;
    psi= varargin{1};
    p1= varargin{2};
    p2= varargin{3};
    p3= varargin{4};
    p1_bin= varargin{5};
    p2_bin= varargin{6};
    u3_bin= varargin{7};
    p1_lab= varargin{8};
    p2_lab= varargin{9};
    p3_lab= varargin{10};
else
    error ('ERROR: Check the number and type of input arguments')
end

% Check type of input variables - not necessarily exhaustive, but should
% catch the obvious syntactical errors...
if ~(exist(msp,'file') && ~exist(msp,'dir'))
    error ('ERROR: .msp file does not exist - check input arguments')
end
if ~(exist(spe,'file') && ~exist(spe,'dir'))
    error ('ERROR: .spe file does not exist - check input arguments')
end
%if nargin>3 && ~(exist('p1_bin','var') && exist('p2_bin','var') && exist('p3_bin','var')),
%    error('ERROR: p1_bin, p2_bin and p3_bin need to be given - check input arguments')
%end
if exist('p3_bin', 'var'),
    if ~(isa_size(p1_bin,[1,3],'double') && isa_size(p2_bin,[1,3],'double') && isa_size(p3_bin,[1,3],'double'))
        error ('ERROR: Must provide binning for the plotting axes plotting in form [pi_start, pi_step, pi_end]')
    end
end
if exist('p2_bin', 'var') && ~exist('p3_bin', 'var'),
     if ~(isa_size(p1_bin,[1,3],'double') && isa_size(p2_bin,[1,3],'double'))
        error ('ERROR: Must provide binning for the plotting axes plotting in form [pi_start, pi_step, pi_end]')
    end
end
if exist('p3','var'),
    if ~(isa_size(p1,[1,4],'double') && isa_size(p2,[1,4],'double') && isa_size(p3,[1,4],'double'))
        error ('ERROR: p1, p2 and p3 must be a row vector with length=4')
    elseif max(abs(p1))==0 || max(abs(p2))==0 || max(abs(p3))==0
        error ('ERROR: Length of vectors p1,p2 and p3 must be greater than zero')
    end
end
if exist('p2','var') && ~exist('p3','var'),
    if ~(isa_size(p1,[1,4],'double') && isa_size(p2,[1,4],'double'))
        error ('ERROR: p1 and p2 must be a row vector with length=4')
    elseif max(abs(p1))==0 || max(abs(p2))==0 
        error ('ERROR: Length of vectors p1 and p2 must be greater than zero')
    end
end
if labels
    if labels== 2 && ~(isa_size(p1_lab,'row','char') && isa_size(p2_lab,'row','char')),
        error ('ERROR: Axis labels must be character strings')
    elseif labels== 3 && ~(isa_size(p1_lab,'row','char') && isa_size(p2_lab,'row','char') && isa_size(p3_lab,'row','char'))
        error ('ERROR: Axis labels must be character strings')
    end
end

% Set up Q-space viewing axes
disp('loading msp file');
ms_load_msp(msp);

% update the msp file if needed
if exist('ei','var');
    ms_setvalue('efixed',ei);
end
if exist('psi','var'),
    ms_setvalue('psi_samp',psi);
end
if exist('u1','var'),
    if exist('u3','var'), % PSD detectors
        set(findobj('Tag','ms_det_type'),'value',1); % Make sure that mslice is ready for PSD detectors 
        ms_setvalue('u11',p1(1));
        ms_setvalue('u12',p1(2));
        ms_setvalue('u13',p1(3));
        ms_setvalue('u14',p1(4));
        ms_setvalue('u21',p2(1));
        ms_setvalue('u22',p2(2));
        ms_setvalue('u23',p2(3));
        ms_setvalue('u24',p2(4));
        ms_setvalue('u31',p3(1));
        ms_setvalue('u32',p3(2));
        ms_setvalue('u33',p3(3));
        ms_setvalue('u34',p3(4));
    else % Conventional detectors
        set(findobj('Tag','ms_det_type'),'value',1); % Make sure that mslice is ready for conventional detectors 
        ms_setvalue('u11',p1(1));
        ms_setvalue('u12',p1(2));
        ms_setvalue('u13',p1(3));
        ms_setvalue('u14',p1(4));
        ms_setvalue('u21',p2(1));
        ms_setvalue('u22',p2(2));
        ms_setvalue('u23',p2(3));
        ms_setvalue('u24',p2(4));
    end
end
if labels
    if labels==2,
        ms_setvalue('u1label',p1_lab);
        ms_setvalue('u2label',p2_lab);
    else
        ms_setvalue('u1label',p1_lab);
        ms_setvalue('u2label',p2_lab);
        ms_setvalue('u3label',p3_lab);
    end
end

% load and calculate the projection of the spe file
[spe_path,spe_file,spe_ext,spe_ver] = fileparts(spe);
if isempty(spe_path),
    ms_setvalue('DataDir',spe_path);
else
    ms_setvalue('DataDir',[spe_path,filesep]);
end
ms_setvalue('DataFile',[spe_file,spe_ext]);
ms_load_data;
ms_calc_proj;
d = fromwindow;
disp('Writing data to Horace data structure')

% Create the appropriate data structure
data.file= d.filename;
data.grid= 'orthogonal-grid';
data.title= d.title_label;
if isfield(d,'psi_samp'), %Single crystal data set
    data.a= ms_getvalue('as');
    data.b= ms_getvalue('bs');
    data.c= ms_getvalue('cs');
    data.alpha= ms_getvalue('aa');
    data.beta= ms_getvalue('bb');
    data.gamma= ms_getvalue('cc');
    if size(d.u,1)==3, % PSD detectors
        if max(d.u(:,4))==0, % Energy axis not selected as a viewing axis
            data.u= [d.u', [0 0 0 1]']; % energy axis needs to be present for dnd_cut_titles to work
        else
            data.u= [d.u', [0 0 0 0]'];
        end
        data.ulen= [d.axis_unitlength', 0];
        data.label= {ms_getvalue('u1label'),ms_getvalue('u2label'),ms_getvalue('u3label'), ''};
        data.p0= [0;0;0;0];
        data.pax= [1,2,3];
        data.iax= [4];
        data.uint= [0;0];
        % initiate grid, d.v contains the bin centres these will be used to
        % generate a grid.
        sized=size(d.v);
        % p1
        data.p1= [p1_bin(1):p1_bin(2):p1_bin(3)]'; % Contains the bin boundaries
        % p2
        data.p2= [p2_bin(1):p2_bin(2):p2_bin(3)]';
        % p3
        data.p3= [p3_bin(1):p3_bin(2):p3_bin(3)]';
        % Generate the grids
        np1 = length(data.p1)-1; % number of bins
        np2 = length(data.p2)-1;
        np3 = length(data.p3)-1;
        data.s = zeros(np1,np2,np3);
        data.e = zeros(np1,np2,np3);
        data.n = zeros(np1,np2,np3);
        vstep= reshape(d.v, sized(1)*sized(2), 3)';
        % convert vstep into index array where vstep(i,1)= 1 corresponds to data between pi(1) and pi(2).        
        vstep(1,:) = floor((vstep(1,:)-p1_bin(1))/p1_bin(2))+1;
        vstep(2,:) = floor((vstep(2,:)-p2_bin(1))/p2_bin(2))+1;
        vstep(3,:) = floor((vstep(3,:)-p3_bin(1))/p3_bin(2))+1;
        st= reshape(d.S, sized(1)*sized(2), 1)';
        et= (reshape(d.ERR.^2, sized(1)*sized(2), 1)'); % errors are stored as the variance
        lis = find(1<=vstep(1,:) & vstep(1,:)<=floor((max(data.p1)-p1_bin(1))/p1_bin(2)) & ...
            1<=vstep(2,:) & vstep(2,:)<=floor((max(data.p2)-p2_bin(1))/p2_bin(2)) & ...
            1<=vstep(3,:) & vstep(3,:)<=floor((max(data.p3)-p3_bin(1))/p3_bin(2)));
        % sum up the intensity, errors and hits into their corresponding 3D arrays.
        % add a reference to the last bin of data.s with zero intensity to make sure
        % that the accumulated array has the same size as data.s
        data.s = data.s + accumarray(vstep(:,lis)', st(lis), [np1, np2, np3]);    % summed 3D intensity array
        data.e = data.e + accumarray(vstep(:,lis)', et(lis), [np1, np2, np3]);    % summed 3D variance array
        data.n = data.n + accumarray(vstep(:,lis)', ones(1,length(lis)), [np1, np2, np3]);
    else % conventional detectors
        if max(d.u(:,4))==0, % Energy axis not selected as a viewing axis
            data.u= [d.u', [0 0 0 0]',[0 0 0 1]']; % energy axis needs to be present for dnd_cut_titles to work
        else
            data.u= [d.u', [0 0 0 0]',[0 0 0 0]'];
        end
        data.ulen= [d.axis_unitlength', 0, 0];
        data.label= {ms_getvalue('u1label'),ms_getvalue('u2label'), '', ''};
        data.p0= [0;0;0;0];
        data.pax= [1,2];
        data.iax= [3,4];
        data.uint= [0 0;0 0];
        % initiate grid, d.v contains the bin centres these will be used to
        % generate a grid.
        sized=size(d.v);
        % p1
        data.p1= [p1_bin(1):p1_bin(2):p1_bin(3)]'; % Contains the bin boundaries
        % p2
        data.p2= [p2_bin(1):p2_bin(2):p2_bin(3)]';
        % Generate the grids
        np1 = length(data.p1)-1; % number of bins
        np2 = length(data.p2)-1;
        data.s = zeros(np1,np2);
        data.e = zeros(np1,np2);
        data.n = zeros(np1,np2);
        vstep= reshape(d.v, sized(1)*sized(2), 2)';
        % convert vstep into index array where vstep(i,1)= 1 corresponds to data between pi(1) and pi(2).        
        vstep(1,:) = floor((vstep(1,:)-p1_bin(1))/p1_bin(2))+1;
        vstep(2,:) = floor((vstep(2,:)-p2_bin(1))/p2_bin(2))+1;
        st= reshape(d.S, sized(1)*sized(2), 1)';
        et= (reshape(d.ERR.^2, sized(1)*sized(2), 1)'); % errors are stored as the variance
        lis = find(1<=vstep(1,:) & vstep(1,:)<=floor((max(data.p1)-p1_bin(1))/p1_bin(2)) & ...
            1<=vstep(2,:) & vstep(2,:)<=floor((max(data.p2)-p2_bin(1))/p2_bin(2)));
        % sum up the intensity, errors and hits into their corresponding 3D arrays.
        % add a reference to the last bin of data.s with zero intensity to make sure
        % that the accumulated array has the same size as data.s
        data.s = data.s + accumarray(vstep(:,lis)', st(lis), [np1, np2]);    % summed 2D intensity array
        data.e = data.e + accumarray(vstep(:,lis)', et(lis), [np1, np2]);    % summed 2D variance array
        data.n = data.n + accumarray(vstep(:,lis)', ones(1,length(lis)), [np1, np2]);
    end
else % Powder data 
    data.a= 0;
    data.b= 0;
    data.c= 0;
    data.alpha= 90;
    data.beta= 90;
    data.gamma= 90;
    data.u= [1 0 0 0; 0 0 0 0; 0 0 0 0; 0 1 0 0];
    data.ulen= [d.axis_unitlength',0, 0];
    data.label= {ms_getvalue('u1label'),ms_getvalue('u2label'),'',''};
    data.p0= [0;0;0;0];
    data.pax= [1,2];
    data.iax= [3,4];
    data.uint= [0 0;0 0];
    % initiate grid, d.v contains the bin centres these will be used to
    % generate a grid.
    sized=size(d.v);
    % p1 Q axis
    binsize= (max(max(d.v(:,:,1)))-min(min(d.v(:,:,1))))/(sized(1)-1);
    p1_bin= [(min(min(d.v(:,:,1)))-binsize/2),binsize,(max(max(d.v(:,:,1)))+binsize/2)];
    data.p1= [p1_bin(1):p1_bin(2):p1_bin(3)]';
    % p2 energy axis
    enbin= (d.en(end)-d.en(1))/(length(d.en)-1);  % energy grid is stored as bin centres
    p2_bin= [(d.en(1)-enbin/2),enbin,(d.en(end)+enbin/2)];
    data.p2= [p2_bin(1):p2_bin(2):p2_bin(3)]';
    np1 = length(data.p1)-1; % number of bins
    np2 = length(data.p2)-1;
    data.s = zeros(np1,np2);
    data.e = zeros(np1,np2);
    data.n = zeros(np1,np2);
    vstep= reshape(d.v, sized(1)*sized(2), 2)';
    % convert vstep into index array where vstep(i,1)= 1 corresponds to data between pi(1) and pi(2).        
    vstep(1,:) = floor((vstep(1,:)-p1_bin(1))/p1_bin(2))+1;
    vstep(2,:) = floor((vstep(2,:)-p2_bin(1))/p2_bin(2))+1;
    st= reshape(d.S, sized(1)*sized(2), 1)';
    et= (reshape(d.ERR.^2, sized(1)*sized(2), 1)'); % errors are stored as the variance
    lis = find(1<=vstep(1,:) & vstep(1,:)<=floor((max(data.p1)-p1_bin(1))/p1_bin(2)) & ...
        1<=vstep(2,:) & vstep(2,:)<=floor((max(data.p2)-p2_bin(1))/p2_bin(2)));
    % sum up the intensity, errors and hits into their corresponding 3D arrays.
    % add a reference to the last bin of data.s with zero intensity to make sure
    % that the accumulated array has the same size as data.s
    data.s = data.s + accumarray(vstep(:,lis)', st(lis), [np1, np2]);    % summed 2D intensity array
    data.e = data.e + accumarray(vstep(:,lis)', et(lis), [np1, np2]);    % summed 2D variance array
    data.n = data.n + accumarray(vstep(:,lis)', ones(1,length(lis)), [np1, np2]);
end

% Create class from structure
data = dnd_create(data);

% Close mslice if opened in this function
if ~isempty(opened_mslice),
   disp(' ')
   disp('Closing MSlice Control Window opened by the function gen_hkle')
   delete(opened_mslice);
end