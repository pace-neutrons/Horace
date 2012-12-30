function [xcent,xpeak,fwhh,xneg,xpos,ypeak,wout]=peak_cwhh(w,varargin)
% Find centre of half height of main peak in a IX_dataset_1d or array of IX_dataset_1d objects
% Simple function that assumes that all data points are positive.
%
%   >> [xcent,xpeak,fwhh,xneg,xpos,ypeak]=peak_cwhh(w)      % centre half-height
%   >> [xcent,xpeak,fwhh,xneg,xpos,ypeak]=peak_cwhh(w,fac)  % centre of fac*height (fac<1)
%
%   >> [xcent,xpeak,fwhh,xneg,xpos,ypeak]=peak_cwhh(...,'outer')
%
% Input:
% ------
%   w       IX_dataset_1d or array of IX_dataset_1d in which to find the peak
%   fac     Factor of peak height at which to determine the centre-height position
%           (default=0.5 i.e. centre-fwhh)
% Peak width option:
%   'inner' Find peak width moving outwards from peak position (Default)
%   'outer' Find peak width moving inwards from limits of data - useful only
%           if there known to be a single peak in the data.
%   
% Output:
% -------
%   xcent   Centre(s) of factor-of-height
%   xpeak   Peak position(s)
%   fwhh    Full width(s) at factor-of-height
%   xneg    Position(s) of factor-of-height on lower x side
%   xpos    Position(s) of factor-of-height on higher x side
%   ypeak   Peak height(s)
%   wout    IX_dataset_1d or array of IX_dataset_1d with summary of peak search
%           Point spectra showing positions of xneg, xpos and xcent for each input IX_dataset_1d
%           Can be plotted over the input spectra to show the quality of the peak search

if nargin==1
    fac=0.5;
    inner=true;
elseif nargin==2
    if isnumeric(varargin{1})
        fac=varargin{1};
        inner=true;
    else
        fac=0.5;
        [inner,ok,mess]=use_inner(varargin{1});
        if ~ok, error(mess), end
    end
elseif nargin==3
    fac=varargin{1};
    [inner,ok,mess]=use_inner(varargin{2});
    if ~ok, error(mess), end
end

nw = length(w);
if nw==1
    if length(w.x)~=length(w.signal)
        xc=0.5*(w.x(1:end-1)+w.x(2:end));
    else
        xc=w.x;
    end
    [xcent,xpeak,fwhh,xneg,xpos,ypeak]=peak_cwhh_xye(xc,w.signal,w.error,fac,~inner);
    wout=peak_summary(w,fac,xcent,xpeak,xneg,xpos,ypeak);
    if isnan(xcent)
        warning('No peak defined by half-height points')
    end
else
    xpeak=zeros(size(w));
    xcent=zeros(size(w));
    fwhh=zeros(size(w));
    xneg=zeros(size(w));
    xpos=zeros(size(w));
    ypeak=zeros(size(w));
    peak=true;
    wout=repmat(IX_dataset_1d,size(win));
    for i=1:nw
        if length(w(i).x)~=length(w(i).signal)
            xc=0.5*(w(i).x(1:end-1)+w(i).x(2:end));
        else
            xc=w.x;
        end
        [xcent(i),xpeak(i),fwhh(i),xneg(i),xpos(i),ypeak(i)]=peak_cwhh_xye(xc,w(i).signal,w(i).error,fac,~inner);
        wout(i)=peak_summary(w(i),fac,xcent(i),xpeak(i),xneg(i),xpos(i),ypeak(i));
        if isnan(xcent(i)) && peak
            peak=false;
            warning('No peak defined by half-height points for at least one spectrum')
        end
    end
end

%---------------------------------------------------------------------------------------------------------
function wout=peak_summary(win,fac,xcent,xpeak,xneg,xpos,ypeak)
% Create a spectrum that summarises the result of the peak analysis of a histogram spectrum

if isnan(xcent)
    wout=win;
    wout.signal=NaN(size(win.signal));
    wout.error=zeros(size(win.error));
else
%     xlo=win.x(1);
%     xhi=win.x(end);
    xlo=xneg;
    xhi=xpos;
    ywid=fac*ypeak;
    if xpeak>=xcent
        xpk=[xcent,xcent,xcent,xcent,xpeak,xpeak,xpeak];
        ypk=[ywid,ypeak,0,ywid,ywid,ypeak,ywid];
    else
        xpk=[xpeak,xpeak,xpeak,xcent,xcent,xcent,xcent];
        ypk=[ywid,ypeak,ywid,ywid,ypeak,0,ywid];
    end
    x=[[xlo,xneg,xneg],xpk,[xpos,xpos,xhi]];
    y=[[0,0,ywid],ypk,[ywid,0,0]];
    e=zeros(size(y));
    newtitle={'Peak analysis'};
    if ~isempty(win.title)
        [ok,newtitle]=str_make_cellstr(win.title,newtitle);
    end
    wout=IX_dataset_1d(x,y,e,newtitle,win.x_axis,win.s_axis);
end

%---------------------------------------------------------------------------------------------------------
function [inner,ok,mess]=use_inner(opt)
ok=true;
mess='';
if ischar(opt)
    if strncmpi(opt,'inner',numel(opt))
        inner=true;
    elseif strncmpi(opt,'outer',numel(opt))
        inner=false;
    else
        ok=false;
        mess='Unrecognised peak width option';
    end
end
