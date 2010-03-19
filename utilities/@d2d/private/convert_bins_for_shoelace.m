function [xout,yout,sout,eout,nout]=convert_bins_for_shoelace(win,wref)
%
% Converts data in the d2d object win into appropriate format for the
% shoelace rebinning function (i.e. bin corners rather than bin
% boundaries). The co-ordinate system is defined by the d2d object wref. If
% wref is empty then the co-ordinate system remains unchanged.
%
% RAE 23/9/09
%

%First arrange win's axes so that we have the bin corners and sig/err/npix
%matrices in the correct format. At present sig etc are arranged to correspond to
%points on an ndgrid.

win=d2d(win);

xin=win.p{1}'; yin=win.p{2}';

xtmp=[]; ytmp=[];
for i=1:(length(yin)-1)
    newx=[xin(1:end-1); xin(2:end); xin(2:end); xin(1:end-1)];
    xtmp=[xtmp newx];
    newy=repmat([yin(i); yin(i); yin(i+1); yin(i+1)],1,numel(xin)-1);
    ytmp=[ytmp newy];
end
sout=reshape(win.s,1,numel(win.s)); eout=reshape(win.e,1,numel(win.e));
nout=reshape(win.npix,1,numel(win.npix));


%If wref exists then we must convert the co-ordinate system for xout and
%yout:
if ~isempty(wref)
    %transform co-ordinates of win on to those of wref
    u11=win.u_to_rlu([1:3],win.pax(1)); u12=win.u_to_rlu([1:3],win.pax(2));
    u21=wref.u_to_rlu([1:3],wref.pax(1)); u22=wref.u_to_rlu([1:3],wref.pax(2));
    %
%     u11=u11./((sum(u11.^2))); u12=u12./((sum(u12.^2)));%modified during debug
%     u21=u21./((sum(u21.^2))); u22=u22./((sum(u22.^2)));%seems to work now
    %u11=u11./((sum(u11.^2))); u12=u12./((sum(u12.^2)));%modified during debug
    u21=u21./((sum(u21.^2))); u22=u22./((sum(u22.^2)));%seems to work now

    %
    T=[dot(u11,u21) dot(u12,u21); dot(u11,u22) dot(u12,u22)];%transformation matrix
    sw=[xtmp(1,:); ytmp(1,:)];%bin corner co-ordinates (south-west, south-east, etc)
    se=[xtmp(2,:); ytmp(2,:)];
    ne=[xtmp(3,:); ytmp(3,:)];
    nw=[xtmp(4,:); ytmp(4,:)];
    %
    sw_new=T*sw; se_new=T*se; ne_new=T*ne; nw_new=T*nw;%transformed co-ords
    xout=[sw_new(1,:); se_new(1,:); ne_new(1,:); nw_new(1,:)];
    yout=[sw_new(2,:); se_new(2,:); ne_new(2,:); nw_new(2,:)];

else
    xout=xtmp; yout=ytmp;
end









