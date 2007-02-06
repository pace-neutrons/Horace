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
%           - [plo, pstep, phi]     Plot axis: minimum and maximum bin centres and step size
%
%   p4_bin          [Optional] binning along the energy axis:
%           - omit          Plot axis: energy binning of first .spe file; plot limits from extent of the data
%           - [pstep]       Plot axis: sets step size; plot limits taken from extent of the data
%                          If step=0 then use binning of first .spe file
%           - [plo, phi]    Integration axis: range of integration
%           - [plo, pstep, phi]     Plot axis: minimum and maximum bin centres and step size,
%                                  and if step=0 then use binning of first .spe file
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


tic

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

% Read header information from sqe file:
fid= fopen(binfil, 'r');    % open sqe file
if fid<0; error (['ERROR: Unable to open file ',binfil]); end

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


% Create header for output dataset: 
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
npax = 0;
niax = 0;
pax = zeros(1,4);
iax = zeros(1,4);
uint= zeros(2,4);
vstep = zeros(4,1); % will contain requested step sizes
vlims = zeros(4,2); % will contain requested limits of bin centres / integration range
for idim=1:4
    if length(lims{idim})==2    % the case of an integration axis
        niax = niax + 1;
        iax(niax) = idim;
        vlims(idim,:) = lims{idim};
    else                        % must be a plot axis
        npax = npax + 1;
        pax(npax) = idim;
        if length(lims{idim})==0        % recall that for energy axis length could be zero
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
        if idim==4 && vstep(idim)<0
            fclose(fid);
            error('ERROR: Cannot have negative energy step size')
        elseif idim~=4 && vstep(idim)==0
            fclose(fid);
            error(['ERROR: Cannot have zero step size - plot axis ',num2str(idim)])
        end
    end
    % check validity of data ranges
    if vlims(idim,2)<vlims(idim,1)
        fclose(fid);
        error(['ERROR: Check upper limit greater or equal to the lower limit - axis ',num2str(idim)])
    end
end
pax = pax(1:npax);
iax = iax(1:niax);
if npax>0
    d.pax = pax;
else
    d.pax = [];
end
if niax>0
    d.iax = iax;
    % Get actual limits determined by extent of data - otherwise annotations will give misleading impression of integration range
    d.uint = [max(h.urange(1,iax),vlims(iax,1)');min(h.urange(2,iax),vlims(iax,2)')];
%     out_of_range = find(d.uint(2,:)-d.uint(1,:)<0);
%     if length(out_of_range)>0
%         fclose(fid);
%         error(['ERROR: Integration range for axis ',num2str(out_of_range(1)),' lies outside range of data'])
%         return
%     end
else
    d.iax = [];
    d.uint = [];
end

% Now create p1,p2... arrays for output dataset, and create arrays pstep, pbeg, plims for reading data and acuumulating
% counts in output data arrays
plims = zeros(4,2);     % to hold limits for reading data
if niax>0
    plims(iax,:) = d.uint';    
end
if npax>0
    [pvals, mess] = plot_axis_arrays (pax, h.urange, vstep', vlims', h.en0, h.ebin(1));
    if ~isempty(mess)
        fclose(fid);
        error(mess)
    end
    pstep = pvals.pstep;    % keep these out to condense code later on
    pbeg = zeros(1,npax);   % first bin centres
    psize = zeros(1,npax);  % number of bins along each axis
    for i=1:npax
        nam = ['p',num2str(i)];
        pbeg(i) = pvals.(nam)(1);
        psize(i) = length(pvals.(nam));
        d.(nam) = [pvals.(nam)-0.5*pstep(i), pvals.(nam)(end)+0.5*pstep(i)]';
        plims(pax(i),:) = [d.(nam)(1),d.(nam)(end)];
    end
    if length(psize)==1
        psize = [psize,1];  % make nx1 for case of 1D dataset
    end
else
    psize = [1,1];          % case of a scalar integral (zero dimensions)
end


% Read data from sqe file and accumulate into dataset arrays:

d.s = zeros(psize);
d.e = zeros(psize);
d.n = zeros(psize);         % make this int16 at the very end if 4D

t_start = toc;
summary.t_get_sqe_datablock = 0;
summary.t_get_sqe_lis = 0;
summary.n_total = 0;
summary.n_read = 0;
summary.n_kept = 0;
for ifile=1:h.nfiles
    [data, mess, lis, info] = get_sqe_datablock (fid, plims);
    if ~isempty(mess); fclose(fid); error(mess); end
    summary.t_get_sqe_datablock = summary.t_get_sqe_datablock + info.t_read;
    summary.t_get_sqe_lis = summary.t_get_sqe_lis + info.t_lis;
    summary.n_total = summary.n_total + prod(data.size);
    summary.n_read = summary.n_read + length(data.S);
    summary.n_kept = summary.n_kept + length(lis);
%    disp([num2str(prod(data.size)),'   ',num2str(length(data.S)),'   ',num2str(length(lis)),'   '])
    if isempty(lis)
        continue    % no data in requested range, so move to next iteration of the for loop
    end
    data.v = data.v(:,lis);
    data.S = data.S(lis);
    data.ERR = data.ERR(lis);
    if npax>0
        for i=1:npax
            data.v(pax(i),:) = round((data.v(pax(i),:)-pbeg(i))/pstep(i)) + 1;
        end
        d.s = d.s + accumarray(data.v(pax,:)', data.S, psize);
        d.e = d.e + accumarray(data.v(pax,:)', data.ERR, psize);
        d.n = d.n + accumarray(data.v(pax,:)', ones(1,length(data.S)), psize);
    else
        d.s = d.s + sum(data.S);
        d.e = d.e + sum(data.ERR);
        d.n = d.n + length(data.S);
    end
    % print message if more than two seconds since last update
    t_calc = toc;
    delta_time = t_calc - t_start;
    if delta_time > 2   % print message after two seconds
        percent_done = round(min(100,100*(ifile/h.nfiles)));
        disp (['fraction completed: ',num2str(percent_done),'%'])
        t_start = t_calc;   % reset time origin for this message
    end
end

% Close input file and make class out of structure:
fclose(fid);
if npax==4
    d.n = int16(d.n);
end
d = dnd_create(d);

% Print time to perform projection
t_total = toc;
disp(' ')
disp('--------------------------------------------------------------------------------')
disp(['Total time to compute dataset: ',num2str(t_total),' s'])
disp(['      Total time reading data: ',num2str(summary.t_get_sqe_datablock),' s'])
disp(['   Total time to find listing: ',num2str(summary.t_get_sqe_lis),' s'])
disp(' ')
disp(['     Number of points in file: ',num2str(summary.n_total)])
disp(['        Fraction of file read: ',num2str(100*summary.n_read/summary.n_total),' %'])
disp(['    Fraction of file retained: ',num2str(100*summary.n_kept/summary.n_total),' %'])
disp('--------------------------------------------------------------------------------')
disp(' ')