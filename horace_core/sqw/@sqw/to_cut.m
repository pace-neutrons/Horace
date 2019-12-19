function c=to_cut(w,varargin)
% Create cut object from sqw object
%
%   >> c = to_cut (w)
% With keywowrds:
%   >> c = to_cut (w, 'x','k')        % make x-axis the component along b* (other options available too)
%   >> c = to_cut (w, 'signal','Q')   % make y-axis equal to |Q| (other options available too)
%   >> c = to_cut (w, 'x', 'E', 'signal' 'k')
%
%   w           1D sqw object
%   'x'         [Optional] keyword to make the x-axis for the cut correspond to another coordinate
%               Valid coordinates are: 
%                   'h', 'k', 'l'       r.l.u.
%                   'E'                 energy transfer
%                   'Q'                 |Q|         
%               Default is to use the display axis of the sqw object
%   
%   'signal'    [Optional] keyword to make the signal axis another coordinate than the intensity.
%               Useful to see the variation of e.g. energy across a cut.
%   
%
% Note: this would normally be called just cut, which is the class of the output object.
% However, because we have already used 'cut' as the name of another method of sqw objects,
% we can't do that. An unfortunate problem, but one that is unavoidable.

rad2deg=180/pi;

% Conversion only possible if 1D sqw-type object
if ~is_sqw_type(w)
    error('Conversion of only sqw-type object to cut object is possible')
end

if dimensions(w)~=1
    error('Conversion to cut only possible for a 1D sqw object')
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
keywords={'x','signal'};
[ok,mess,ind,xlist]=parse_keywords(keywords,varargin{:});
if ~ok
    error(mess)
end

% Perform conversion
% ------------------
% Get x coordinates, and new signal array if requested
if ~any(ind==1)     % 'x' does not appear in keyword list (or no keywords at all)
    ind=[1,ind];
    xlist=['d1',xlist];     % x axis will be the first display axis
end
[ok,mess,xvals,xpix,xvar,xdevsqr]=coordinates_calc(w,xlist);
if ~ok
    error(mess)
end

ind_x=find(ind==1);
ind_signal=find(ind==2);

% Fill structure
npixtot=size(w.data.pix,2);
ecent=0.5*(w.header.en(2:end)+w.header.en(1:end-1));
de=w.header.en(2)-w.header.en(1);    % energy bin size assumed all the same
de=repmat(de,npixtot,1);

c.x=xvals{ind_x}';
if~isempty(ind_signal);
    c.y=xvals{ind_signal}';
    c.e=sqrt(xvar{ind_signal}');
else
    c.y=w.data.s';
    c.e=sqrt(w.data.e');
end
c.npixels=w.data.npix';
% Need to remove points with zero pixels
ok_pnts=(w.data.npix>0);
c.x=c.x(ok_pnts);
c.y=c.y(ok_pnts);
c.e=c.e(ok_pnts);
c.npixels=c.npixels(ok_pnts);

c.pixels=zeros(npixtot,6);
c.pixels(:,1)=w.data.pix(6,:)';
c.pixels(:,2)=ecent(w.data.pix(7,:));
c.pixels(:,3)=de;
c.pixels(:,4)=xpix{ind_x};
if ~isempty(ind_signal);
    c.pixels(:,5)=xpix{ind_signal};
    c.pixels(:,6)=sqrt(xdevsqr{ind_signal});
else
    c.pixels(:,5)=w.data.pix(8,:)';
    c.pixels(:,6)=sqrt(w.data.pix(9,:)');
end

[title_main, title_pax] = data_plot_titles (w.data);    % note: axes annotations correctly account for permutation in w.data.dax
if strcmpi(xlist{ind_x},'d1')  % x-axis is the same as the display axis
    c.x_label=title_pax;
else
    c.x_label=['<',xlist{ind_x},'>'];   % *** TEMPORARY
end
c.y_label='Intensity';
c.title=title_main(2:end);      % the first line in the Horace title is the file the data was read from

c.CutFile=w.main_header.filename;
c.CutDir=w.main_header.filepath;

appendix.MspFile='';
appendix.MspDir='';
appendix.efixed=w.header.efix;
appendix.emode=w.header.emode;
appendix.sample=1;
appendix.as=w.header.alatt(1);
appendix.bs=w.header.alatt(2);
appendix.cs=w.header.alatt(3);
appendix.aa=w.header.angdeg(1);
appendix.bb=w.header.angdeg(2);
appendix.cc=w.header.angdeg(3);
% Note that some of the angles are required in degrees for the following function, so convert
[u_true,v_true]=uv_correct (w.header.cu, w.header.cv, w.header.alatt, w.header.angdeg,...
    w.header.omega*rad2deg, w.header.dpsi*rad2deg, w.header.gl*rad2deg, w.header.gs*rad2deg, w.header.alatt, w.header.angdeg);
appendix.ux=u_true(1);
appendix.uy=u_true(2);
appendix.uz=u_true(3);
appendix.vx=v_true(1);
appendix.vy=v_true(2);
appendix.vz=v_true(3);
appendix.psi_samp=w.header.psi*rad2deg;     % format requires degrees

c.appendix=appendix;

% *** NEED TO SORT ON X AXIS, IN CASE THE AVERAGE X COORD HAS WRAPPED AROUND ITSELF?

% Turn into a cut object
c=cut(c);
