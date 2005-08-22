function d = cut_sqe (binfil, p1_bin, p2_bin, p3_bin, p4_bin)
% Reads a binary sqe file and creates a 0,1,2,3 or 4D data set by integrating
% over one of the momentum or energy axes.
% 
% Syntax:
%   >> d = cut_sqe (data_source, p1_bin, p2_bin, p3_bin)
%
%   >> d = cut_sqe (data_source, p1_bin, p2_bin, p3_bin, p4_bin)
% 
% Input:
% ------
%   data_source     Data source: binary sqe file
%
%   p1_bin          Binning along first Q axis
%   p2_bin          Binning along second Q axis
%   p3_bin          Binning along third Q axis
%           - [pstep]       Plot axis: sets step size; plot limits taken from extent of the data
%           - [plo, phi]    Integration axis: range of integration
%           - [plo, pstep, phi]     Plot axis: range and step size
%
%   p4_bin          [Optional] binning along the energy axis:
%           - omit          Plot axis: energy binning of first .spe file; plot limits from extent of the data
%           - [pstep]       Plot axis: sets step size; plot limits taken from extent of the data
%                          If step=0 then use binning of first .spe file
%           - [plo, phi]    Integration axis: range of integration
%           - [plo, pstep, phi]     Plot axis: range and step size;
%                                  If step=0 then use binning of first .spe file
%           
%
% Output:
% -------
%   d               0,1,2,3 or 4D dataset
%
%
% EXAMPLES
%   >> d = slice_3d ('RbMnF3.bin', [0.4,0.5], [-1,0.025,2], [-2,0.025,2])

% Original author: T.G.Perring
%
% $Revision$ ($Date$)
%
% Horace v0.1   J. van Duijn, T.G.Perring


% Check input arguments
% ----------------------
if ~isa_size(binfil,'row','char')
    error ('ERROR: Input file name must be a character string')
end

lims = cell(1,4);
if ~(isa_size(p1_bin,'row','double') & length(p1_bin)>=1 & length(p1_bin)<=3) | ...
   ~(isa_size(p2_bin,'row','double') & length(p2_bin)>=1 & length(p2_bin)<=3) | ...
   ~(isa_size(p3_bin,'row','double') & length(p3_bin)>=1 & length(p3_bin)<=3)
    error ('ERROR: Check format of integration range / plotting description for momentum axes')
else
    lims{1} = p1_bin;
    lims{2} = p2_bin;
    lims{3} = p3_bin;
end

if exist('p4_bin','var')
    if isa_size(p4_bin,'row','double') & length(p4_bin)>=1 & length(p4_bin)<=3
        lims{4} = p4_bin;
    else
        error ('ERROR: Check format of integration range / plotting description for energy axis')
    end
else
    lims{4} = [];
end


% Now start calculation proper
% -----------------------------

fid= fopen(binfil, 'r');    % open sqe file
if fid<0; error (['ERROR: Unable to open file ',binfil]); end
disp('Reading binary file header ...');

[h,mess] = get_header(fid);   % get the main header information
if ~isempty(mess); fclose(fid); error(mess); end
if isfield(h,'grid')
    if ~strcmp(h.grid,'sqe')
        fclose(fid);
        error ('ERROR: The function cut_sqe only reads binary sqe file ');
    end
else
    fclose(fid);
    error (['ERROR: Problems reading binary sqe data from ',binfil])
end


% Create header for output dataset 
d.file= binfil;
d.grid= 'orthogonal-grid';
d.title=h.title;
d.a= h.a;
d.b= h.b;
d.c= h.c;
d.alpha= h.alpha;
d.beta= h.beta;
d.gamma= h.gamma;
d.u= h.u;
d.ulen= h.ulen;
d.label = h.label;
d.p0= [0,0,0,0]';
% fill plot and integration information
ipax = 0;
iiax = 0;
pax = zeros(1,4);
iax = zeros(1,4);
uint= zeros(2,4);
vstep = zeros(4,1);
vlims = zeros(4,2);
for idim=1:4
    if length(lims{idim})==2    % the case of an integration axis
        iiax = iiax + 1;
        iax(iiax) = idim;
        vlims(idim,:) = lims{idim};
    else                        % must be a plot axis
        ipax = ipax + 1;
        pax(ipax) = idim;
        if length(lims{idim})==0    % recall that for energy axis length could be zero
            vstep(idim) = 0;
            vlims(idim,:) = [-inf,inf];
        elseif length(lims{idim})==1
            vstep(idim) = lims{idim}(1);
            vlims(idim,:) = [-inf,inf];
        elseif length(lims{idim})==3
            vstep(idim) = lims{idim}(2);
            vlims(idim,:) = [lims{idim}(1),lims{idim}(3)];
        end
        % Check validity of step sizes
        if vstep(idim)<0
            fclose(fid);
            error(['ERROR: Cannot have negative step size - plot axis ',num2str(idim)])
        elseif idim~=4 && vstep(idim)==0
            fclose(fid);
            error(['ERROR: Cannot have zero step size - plot axis ',num2str(idim)])
        end
    end
    % check validity of data ranges
    if vlims(idim,2)<=vlims(idim,1)
        fclose(fid);
        error(['ERROR: Check upper limit greater tha lower limit - axis ',num2str(idim)])
    end
end
if ipax>0
    d.pax = pax(1:ipax);
end
if iiax>0
    d.iax = iax(1:iiax);
    d.uint = h.urange(:,iax(1:iiax));
end

% Now create p1,p2... arrays for output dataset

if ipax>0
    for i=1:ipax
        iax = pax(i)
        if iax==4 & vstep





vlims
vstep

d = 0;
return



%--------------------------------------------------------------------------------------------------------

if strcmp(h.grid,'spe')    % Binary file consists of block spe data
    % Save h.ulen - will be needed if one wants to symmetrise the data.
    saved_ulen = h.ulen;
    saved_nfiles = h.nfiles;
    disp('Reading spe files from binary file ...');
    for iblock = 1:h.nfiles,
        disp(['reading spe block no.: ',num2str(iblock),' of ',num2str(saved_nfiles)]);
% tic;
        [h,mess] = get_spe_datablock(fid); % read in spe block
% readtime(iblock)=toc;
% disp(['   reading spe file: ',num2str(readtime(iblock))])
        if ~isempty(mess); fclose(fid); error(mess); end
% tic;
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
                        p4_bin = [enbin*(ceil((p4_bin(1)-h.en(1))/enbin)-0.5)+h.en(1), enbin, ...
                                  enbin*(floor((p4_bin(end)-h.en(1))/enbin)+0.5)+h.en(1)];
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

        % If nsym array exists, symmetrise the data before it gets
        % converted into the equivalent step matrix along the new new orthogonal set given by u_to_rlu
        if exist('nsym','var'),
            for isym=1:size(nsym,1),
                h.v=symmetry(h.v,[saved_ulen(nsym(isym,1)),saved_ulen(nsym(isym,2))],nsym(isym,:));
            end
        end
        
        % convert h.v into the equivalent step matrix along the new orthogonal set given by u_to_rlu
        vstep = proj_to_ustep*h.v;
                            
        % generate the energy vector corresponding to each hkl vector. Leave this in the loop over
        % iblock = 1:(no. spe files) in case the energy bins are different from one spe file to the next
        emat = repmat(h.en, h.size(1), 1);
        emat = reshape(emat, 1, h.size(1)*h.size(2));
    
        if qqq
            % convert vstep into index array where vstep(i,1)= 1 corresponds to data between pi(1) and pi(2).        
            vstep(1,:) = floor(vstep(1,:)-p0n(1)-p1_bin(1)/p1_bin(2))+1;
            vstep(2,:) = floor(vstep(2,:)-p0n(2)-p2_bin(1)/p2_bin(2))+1;
            vstep(3,:) = floor(vstep(3,:)-p0n(3)-p3_bin(1)/p3_bin(2))+1;
            
            % generate equivalent energy matrix
            emat=round((emat-centre)/thick); % the pixels we are interested have are those where emat=0

            % find the index array
            % first filter on energy bins that satisfy criterion - we assume this is small, so short lists that are fast to create
            lis_e = find(emat==0);  
            st = h.S(lis_e);
            et = h.ERR(lis_e);
            vstep = vstep(:,lis_e);
            % now filter on the (far fewer in general) remaining points
            lis = find(1<=vstep(1,:) & vstep(1,:)<=floor((max(d.p1)-p1_bin(1))/p1_bin(2)) & ...
                       1<=vstep(2,:) & vstep(2,:)<=floor((max(d.p2)-p2_bin(1))/p2_bin(2)) & ...
                       1<=vstep(3,:) & vstep(3,:)<=floor((max(d.p3)-p3_bin(1))/p3_bin(2)) );
      
            % sum up the intensity, errors and hits into their corresponding 3D arrays.
            % add a reference to the last bin of d.s with zero intensity to make sure
            % that the accumulated array has the same size as d.s
            d.s = d.s + accumarray(vstep(:,lis)', st(lis), [np1, np2, np3]);    % summed 3D intensity array
            d.e = d.e + accumarray(vstep(:,lis)', et(lis), [np1, np2, np3]);    % summed 3D variance array
            d.n = d.n + accumarray(vstep(:,lis)', ones(1,length(lis)), [np1, np2, np3]);
            
        else
            % convert vstep into index array where vstep(i,1)= 1 corresponds to data
            % between pi(1) and pi(2). Do this only for vectors along p1 and p2.
            vstep(1,:) = floor(vstep(1,:)-p0n(1)-p1_bin(1)/p1_bin(2))+1;
            vstep(2,:) = floor(vstep(2,:)-p0n(2)-p2_bin(1)/p2_bin(2))+1;
            vstep(3,:) = round(vstep(3,:)-p0n(3)-centre/thick);
      
            % generate equivalent energy matrix
            emat= floor((emat-p4_bin(1))/p4_bin(2))+1;

            % find the index array 
            % first filter on third axis bins that satisfy criterion - we assume this is small, so short lists that are fast to create
            lis_q = find(vstep(3,:)==0);
            st = h.S(lis_q);
            et = h.ERR(lis_q);
            vstep = vstep(1:2,lis_q);
            emat = emat(lis_q);
            % now filter on the (far fewer in general) remaining points
            lis = find(1<=vstep(1,:) & vstep(1,:)<=floor((max(d.p1)-p1_bin(1))/p1_bin(2)) & ...
                       1<=vstep(2,:) & vstep(2,:)<=floor((max(d.p2)-p2_bin(1))/p2_bin(2)) & ...
                       1<=emat       &       emat<=floor((max(d.p3)-p4_bin(1))/p4_bin(2)) );
      
            % sum up the intensity, errors and hits into their corresponding 3D arrays.
            % add a reference to the last bin of d.s with zero intensity to make sure
            % that the accumulated array has the same size as d.s
            d.s = d.s + accumarray([vstep(:,lis);emat(lis)]', st(lis), [np1, np2, np3]);    % summed 3D intensity array
            d.e = d.e + accumarray([vstep(:,lis);emat(lis)]', et(lis), [np1, np2, np3]);  % summed 3D error array
            d.n = d.n + accumarray([vstep(:,lis);emat(lis)]', ones(1,length(lis)), [np1, np2, np3]);
        
        end
% calctime(iblock)=toc;
% disp([' doing calculations: ',num2str(calctime(iblock))])
    end
    fclose(fid);
% disp('----------------------------------------------------------- ')
% disp([' total time to read: ',num2str(sum(readtime))])
% disp(['       to calculate: ',num2str(sum(calctime))])
% disp('----------------------------------------------------------- ')

%--------------------------------------------------------------------------------------------------------
else    % Binary file consists of 4D grid
    if source_is_file
        % Read in the 4D grid data
        disp('Reading 4D grid ...');
        [h,mess] = get_grid_data(fid, 4, h); % read in 4D grid
        if ~isempty(mess); fclose(fid); error(mess); end
        fclose(fid);
    end
    % We must allow for the possibility that the axes have been permuted by the user; permute
    % to the standard case that the first axis is u1 in h.u, the second is u2 etc. ie invert h.pax
    order = zeros(1,4);
    for i=1:4
        order(h.pax(i)) = i;    % order(j) gives the plot axis corresponding to uj
    end
    for i=1:4
        pname{i} = ['p',num2str(order(i))]; % field names of input data corresponding to u1, u2, u3, u4
    end
    % get the p arrays in the order of the uj, and permute the signal, error and n arrays accordingly
    p1 = h.(pname{1});      
    p2 = h.(pname{2});
    p3 = h.(pname{3});
    p4 = h.(pname{4});
    signal = permute(h.s,order);
    errors = permute(h.e,order);
    npixel = permute(h.n,order);
               
    % Initialise the grid data block 
    d.p1 = [p1_bin(1):p1_bin(2):p1_bin(3)]'; % length of d.p1=floor((p1_bin(3)-p1_bin(1))/p1_bin(2))+1
    d.p2 = [p2_bin(1):p2_bin(2):p2_bin(3)]'; % Contains the bin boundaries
    if qqq
        d.p3 = [p3_bin(1):p3_bin(2):p3_bin(3)]';
    else
        % Allow for energy range only to be given
        enbin = (p4(end)-p4(1))/(length(p4)-1);
        if ~exist('p4_bin','var')   % use intrinsic energy bin and step
            p4_bin = [p4(1),enbin,p4(end)];
            disp('Using energy range and binning from 4D grid')
        else
            if length(p4_bin)==2 | (length(p4_bin)==3 & enbin>p4_bin(2)) % binning is smaller then the intrinsic binning, or is not given
                % tweak limits so that where there is existing data, the bin boundaries will match
                p4_bin = [enbin*ceil((p4_bin(1)-p4(1))/enbin)+p4(1), enbin, ...
                                  enbin*floor((p4_bin(end)-p4(1))/enbin)+p4(1)];
                if enbin>p4_bin(2)
                    disp ('Requested energy bin size is smaller than that of 4D grid')
                end
                disp ('Using energy bin size from input 4D grid data')
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
    
    % data will be broken down in to blocks along p4. Generate the large
    % vector arrays for p1, p2 and p3. The size of each vector is
    % length(p1)*length(p2)*length(p3)
    p1 = (p1(1:end-1)+p1(2:end))/2; % get bin centres
    p2 = (p2(1:end-1)+p2(2:end))/2;
    p3 = (p3(1:end-1)+p3(2:end))/2;
    p4 = (p4(1:end-1)+p4(2:end))/2;

    pt1 = repmat(p1', 1, length(p2)*length(p3));
    pt2 = repmat(p2', length(p1), length(p3));
    pt2 = reshape(pt2, 1, length(p1)*length(p2)*length(p3));
    pt3 = repmat(p3', length(p1)*length(p2), 1);
    pt3 = reshape(pt3, 1, length(p1)*length(p2)*length(p3));
    
    % convert [pt1;pt2;pt3] into the equivalent step matrix along the new orthogonal set given by u_to_rlu
    vstep = proj_to_ustep*[pt1;pt2;pt3]; 

    if qqq
        % convert vstep into index array where vstep(i,1)= 1 corresponds to data between pi(1) and pi(2).
        vstep(1,:) = floor(vstep(1,:)+p0old(1)-p0n(1)-p1_bin(1)/p1_bin(2))+1;
        vstep(2,:) = floor(vstep(2,:)+p0old(2)-p0n(2)-p2_bin(1)/p2_bin(2))+1;
        vstep(3,:) = floor(vstep(3,:)+p0old(3)-p0n(3)-p3_bin(1)/p3_bin(2))+1;

        % generate equivalent energy matrix
        emat=round((p4-centre)/thick);  % the pixels we are interested have are those where emat=0
        lis_e = find(emat==0);
        if ~isempty(lis_e)
            tic
            for iblock= lis_e(1):lis_e(end)
                % find the index array
                lis = find(1<=vstep(1,:) & vstep(1,:)<=floor((max(d.p1)-p1_bin(1))/p1_bin(2)) & ...
                           1<=vstep(2,:) & vstep(2,:)<=floor((max(d.p2)-p2_bin(1))/p2_bin(2)) & ...
                           1<=vstep(3,:) & vstep(3,:)<=floor((max(d.p3)-p3_bin(1))/p3_bin(2)) );
    
                if ~isempty(lis)
                    % generate the correct block intensity, error and n array
                    st = reshape(signal(:,:,:,iblock),1,(length(p1))*(length(p2))*(length(p3)));
                    et = reshape(errors(:,:,:,iblock),1,(length(p1))*(length(p2))*(length(p3)));
                    nt = double(reshape(npixel(:,:,:,iblock),1,(length(p1))*(length(p2))*(length(p3))));
    
                    % see .spe branch of outer if statement for explanation of logic of the following
                    d.s = d.s + accumarray(vstep(:,lis)', st(lis), [np1, np2, np3]);  % summed 3D intensity array
                    d.e = d.e + accumarray(vstep(:,lis)', et(lis), [np1, np2, np3]);  % summed 3D variance array
                    d.n = d.n + accumarray(vstep(:,lis)', nt(lis), [np1, np2, np3]);
                end
                % print message if more than two seconds since last update
                delta_time = toc;
                if delta_time > 2   % print message after two seconds
                    percent_done = round(min(100,100*((iblock-lis_e(1)+1)/(lis_e(end)-lis_e(1)))));
                    disp (['fraction completed: ',num2str(percent_done),'%'])
                    tic
                end
            end
        end
    else
        % convert vstep into index array where vstep(i,1)= 1 corresponds to data
        % between pi(1) and pi(2). Do this only for vectors along p1 and p2.
        vstep(1,:) = floor(vstep(1,:)+p0old(1)-p0n(1)-p1_bin(1)/p1_bin(2))+1;
        vstep(2,:) = floor(vstep(2,:)+p0old(2)-p0n(2)-p2_bin(1)/p2_bin(2))+1;
        vstep(3,:) = round(vstep(3,:)+p0old(3)-p0n(3)-centre/thick);

        tic
        for iblock= 1:(length(p4)),
            % generate equivalent energy matrix
            emat = p4(iblock)*ones(1,size(vstep,2));
            emat = floor((emat-p4_bin(1))/p4_bin(2))+1;
        
            % find the index array 
            % find first those points satisfying the integration axis range (as will cut data down most)
            lis_q = find(vstep(3,:)==0);
            st= reshape(signal(:,:,:,iblock),1,(length(p1))*(length(p2))*(length(p3)));
            et= reshape(errors(:,:,:,iblock),1,(length(p1))*(length(p2))*(length(p3)));
            nt= reshape(npixel(:,:,:,iblock),1,(length(p1))*(length(p2))*(length(p3)));
            st = st(lis_q);
            et = et(lis_q);
            nt = double(nt(lis_q));
            vstep_temp = vstep(1:2,lis_q);
            emat = emat(lis_q);
            % Now find those element that satisfy the other three axes criteria
            lis = find(1<=vstep_temp(1,:) & vstep_temp(1,:)<=floor((max(d.p1)-p1_bin(1))/p1_bin(2)) & ...
                       1<=vstep_temp(2,:) & vstep_temp(2,:)<=floor((max(d.p2)-p2_bin(1))/p2_bin(2)) & ...
                       1<=emat            &       emat<=floor((max(d.p3)-p4_bin(1))/p4_bin(2)) );
            
            if ~isempty(lis)
                % see .spe branch of outer if statement for explanation of logic of the following
                d.s= d.s + accumarray([vstep_temp(:,lis);emat(lis)]', st(lis), [np1, np2, np3]); % summed 3D intensity array
                d.e= d.e + accumarray([vstep_temp(:,lis);emat(lis)]', et(lis), [np1, np2, np3]); % summed 3D error array
                d.n= d.n + accumarray([vstep_temp(:,lis);emat(lis)]', nt(lis), [np1, np2, np3]);
            end
            % print message if more than two seconds since last update
            delta_time = toc;
            if delta_time > 2   % print message after two seconds
                percent_done = round(min(100,100*(iblock/length(p4))));
                disp (['fraction completed: ',num2str(percent_done),'%'])
                tic
            end
        end
    end
end

% Make class out of structure:
d = d3d(d);
