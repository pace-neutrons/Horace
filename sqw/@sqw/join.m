function wout=join(w,wi)
% Join an array of sqw objects into an single sqw object
% This is intended only as the reverse of split
%
%   >> wout=join(w,wi)
%   >> wout=join(w)
%
% Input:
% ------
%   w       array of sqw objects, each one made from a single spe data file
%   wi      initial pre-split sqw object (optional, recommended).
%
% Output:
% -------
%   wout    sqw object

% Original author: G.S.Tucker
% 2015-01-20

%
% $Revision$ ($Date$)
%

nfiles=length(w);

% Catch case of single contributing spe dataset
if nfiles==1
    wout=w;
    return
end

initflag=false;
if nargin >1 && ~isempty(wi) && isa(wi,'sqw') ...
   && wi.main_header.nfiles==nfiles
	initflag=true;
end

% Default output
if initflag; wout=sqw(wi); else wout=sqw(); end

% Check for identical main_headers
if initflag; main_header=wi.main_header; else main_header=w(1).main_header; end
main_header_fields=fields(main_header);
main_header_fields(strcmp(main_header_fields,'nfiles'))=[]; % No need to compare these, as we know they're different.
hFNM=true; hFVM=true;
for i=1:nfiles
    wi_main_header_fields=fields(w(i).main_header);
    wi_main_header_fields(strcmp(wi_main_header_fields,'nfiles'))=[];
    for j=1:length(wi_main_header_fields)
        hFNM=hFNM & any(strcmp(main_header_fields,wi_main_header_fields{j}));
        hFVM=hFVM & all(main_header.(wi_main_header_fields{j})==w(i).main_header.(wi_main_header_fields{j}));
    end
end
if ~hFNM; errstr='fields'; elseif ~hFVM; errstr='field values'; end
if ~hFNM || ~hFVM
    if initflag; 
        errstr=sprintf('have main_header %s that do not match those in wi',errstr);
    else
        errstr=sprintf('do not have matching main_header %s',errstr);
    end
    error('sqw:join:input','sqw objects in input array %s',errstr)
end

% Start pulling in data
header=cell(size(w)); detpar=header; data=header;
for i=1:nfiles
    header{i}=w(i).header; % Will be used as is
    detpar{i}=w(i).detpar; % Needs to be reduced to only a single struct
    data{i}=w(i).data;     % Needs to be combined
end

% Check that each detpar is identical
if initflag; detpar0=wi.detpar; else detpar0=detpar{1}; end
detpar0_fields=fields(detpar0);
for i=1:length(detpar)
    detpari_fields=fields(detpar{i});
    for j=1:length(detpari_fields);
        hFNM=hFNM & any(strcmp(detpar0_fields,detpari_fields{j}));
        hFVM=hFVM & all(detpar0.(detpari_fields{j})==detpar{i}.(detpari_fields{j}));
    end
end
if ~(hFNM && hFVM)
    error('sqw:join:input','sqw objects in input array have non-matching detpar structures')
end

% Check which sqw objects in the input structure contributed to the
% pre-split sqw object.
run_contributes=true(nfiles,1);
for i=1:nfiles
    if ~sum(abs(data{i}.s(:))) && ~sum(data{i}.e(:)) && ~sum(data{i}.npix(:)) ...
       &&  all(isnan(data{i}.urange(:)/Inf)) && ~sum(abs(data{i}.pix(:)))
        % Then this data structure is a copy of 'datanull' from split.m
        run_contributes(i)=false;
    end
end
main_header.nfiles=sum(run_contributes); % For the output structure

rc_idx = find(run_contributes);
for i=1:length(rc_idx)
    data{rc_idx(i)}.pix(5,:)=i; % repopulate individual run numbers
end


% Now I'm not entirely sure how to proceed. So I'll stab blindly and hope
% that recombining the data.s, data.e, data.npix, and data.pix arrays and
% then using recompute_bin_data will do the trick.

wout.main_header=main_header;
wout.header=header; % This should be a cell array of the individual headers
wout.detpar=detpar0;

wout.data=data{run_contributes(1)};
sz=size(wout.data.npix); % size of contributing signal, variance, and npix arrays
wout.data.s   =zeros(sz);
wout.data.e   =zeros(sz);
wout.data.npix=zeros(sz);
wout.data.pix =[]; % The pix field *must* be re-intialized to empty

for i=1:nfiles
    if run_contributes(i)
        wout.data.s   = wout.data.s   + (data{i}.s).*(data{i}.npix);
        wout.data.e   = wout.data.e   + (data{i}.e).*(data{i}.npix).^2;
        wout.data.npix= wout.data.npix+ data{i}.npix;
        wout.data.pix = [wout.data.pix,data{i}.pix];
    end
end
wout.data.s = wout.data.s ./ wout.data.npix;
wout.data.e = wout.data.e ./ (wout.data.npix).^2;
wout.data.s(~wout.data.npix)=0;
wout.data.e(~wout.data.npix)=0;

% It seems that sorting of the pix field is necessary, however I'm not
% aware of an easy way of accomplishing this.
% Re-performing a cut with 
%   wout=cut_sqw(wout,proj,[],[],[],[]); 
% does the trick, but that is projection-specific and it might not be right
% to build up a proj struct from the information present in a sqw.
%
% An alternative is to use the projection-axis cut form
%   wout=cut_sqw(wout,[]...) 
% wrapped with commands to temporarily silence Horace.
hc_log_level=get(hor_config,'log_level');
set(hor_config,'log_level',-Inf);
cut_args = repmat({[]},size(wout.data.p));
wout=cut_sqw(wout,cut_args{:});
set(hor_config,'log_level',hc_log_level);
