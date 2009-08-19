function s=to_slice(w,varargin)
% Create slice object from sqw object
%
%   >> s = to_slice (w)
%   >> s = to_slice (w, 'signal','Q')   % make signal equal to |Q| (other options available too)
%
%   w           2D sqw object
%   
%   'signal'    [Optional] keyword to make the signal axis another coordinate than the intensity.
%               Useful to see the variation of e.g. energy across a slice.
%               Valid coordinates are: 
%                   'h', 'k', 'l'       r.l.u.
%                   'E'                 energy transfer
%                   'Q'                 |Q|         

% Note: this would normally be called just slice, which is the class of the output object.
% However, because we have already used 'cut' as the name of another method of sqw objects,
% we can't use the method 'cut' for 1D sqw object, and have called it 'to_cut'.
% In sympathy, we have called the corresponding method for slices 'to_slice'.

% Conversion only possible if 2D sqw-type object
if ~is_sqw_type(w)
    error('Conversion of only sqw-type object to cut object is possible')
end

if dimensions(w)~=2
    error('Conversion to cut only possible for a 2D sqw object')
end
    
% Check only one spe file
if ~w.main_header.nfiles==1
    error('Conversion of sqw object only possible if just one contributing .spe file')
end

% Check direct or indirect geometry
if ~(w.header.emode==1||w.header.emode==2)
    error('Conversion of sqw object only possible for inelastic data (direct or indirect geometry)')
end

% Get keywords, if any
keywords={'signal'};
[ok,mess,ind,xlist]=parse_keywords(keywords,varargin{:});
if ~ok
    error(mess)
end

% Perform conversion
% ------------------
xlist=['d1','d2',xlist];
[ok,mess,xvals,xpix,xvar,xdevsqr]=coordinates_calc(w,xlist);
if ~ok
    error(mess)
end

ind_signal=find(ind==1);    % will be empty if 'signal' was not a supplied keyword

% Fill structure
npixtot=size(w.data.pix,2);
ecent=0.5*(w.header.en(2:end)+w.header.en(1:end-1));
de=w.header.en(2)-w.header.en(1);    % energy bin size assumed all the same
de=repmat(de,npixtot,1);

pax=w.data.pax;
dax=w.data.dax;
s.xbounds=w.data.p{dax(1)}';
s.ybounds=w.data.p{dax(2)}';
s.x=xvals{1};
s.y=xvals{2};
if~isempty(ind_signal);
    s.c=xvals{ind_signal};
    s.e=sqrt(xvar{ind_signal});
else
    s.c=w.data.s;
    s.e=sqrt(w.data.e);
end
s.c(w.data.npix==0)=NaN;
s.e(w.data.npix==0)=0;
s.npixels=w.data.npix;
s.pixels=zeros(npixtot,7);
s.pixels(:,1)=w.data.pix(6,:)';
s.pixels(:,2)=ecent(w.data.pix(7,:));
s.pixels(:,3)=de;
s.pixels(:,4)=xpix{1};
s.pixels(:,5)=xpix{2};
if~isempty(ind_signal);
    s.pixels(:,6)=xpix{ind_signal};
    s.pixels(:,7)=sqrt(xdevsqr{ind_signal});
else
    s.pixels(:,6)=w.data.pix(8,:)';
    s.pixels(:,7)=sqrt(w.data.pix(9,:)');
end

if all(w.data.dax==[2,1])    % axes are permuted for plotting purposes
    s.x=s.x'; s.y=s.y'; s.c=s.c'; s.e=s.e'; s.npixels=s.npixels';
    s.pixels = permute_pix_array (s.pixels', w.data.npix, [2,1])';
end
s.x=s.x(:)'; s.y=s.y(:)'; s.c=s.c(:)'; s.e=s.e(:)'; s.npixels=s.npixels(:)';    % make row vectors

[title_main, title_pax] = data_plot_titles (w.data);    % note: axes annotations correctly account for permutation in w.data.dax
s.x_label=title_pax{1};
s.y_label=title_pax{2};
s.z_label='Intensity';
s.title=title_main(2:end);      % the first line in the Horace title is the file the data was read from
ulen = w.data.ulen(pax(dax));   % unit length in order of the display axes
s.x_unitlength=ulen(1);
s.y_unitlength=ulen(2);
s.SliceFile=w.main_header.filename;
s.SliceDir=w.main_header.filepath;

% Turn into a slice object
s=slice(s);
