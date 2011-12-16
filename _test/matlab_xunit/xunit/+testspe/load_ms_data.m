function data=load_ms_data(filename,ndet,ne)
% function data=load_spe(spe_filename,ndet,ne)
%
%   >> data = load_spe(file)
%
if ~exist('ndet','var')
    ndet =25;
    n_theta=5;
    n_psi =5;    
else
    nd_root=sqrt(ndet);
    n_theta=floor(nd_root);
    n_psi  =floor(ndet/n_theta);
    ndet   = n_theta*n_psi;
end
if ~exist('ne','var')
    ne=100;
end
th_min=5;
th_max=30;
dth   = (th_max-th_min)/n_theta;
theta = (th_min+((1:n_theta)-1)*dth);
ps_min=-10;
ps_max= 10;
dps   = (ps_max-ps_min)/n_psi;
psi   = ps_min+((1:n_psi)-1)*dps;


[fp,fn]=fileparts(filename);

data.filedir =fp;
data.filename=[fn,'.spe'];
data.total_ndet=ndet;

[data.S,data.ERR]  =signal(ndet,ne);
data.en =(1:ne)-2;
%
data.Ei = ne+1;
% phx
data.detfiledir =fp;
data.detfilename=[fn,'.phx'];

data.det_group =(1:ndet)';
data.det_theta =repmat(theta*pi/180,1,n_psi)';
data.det_psi   =reshape(ones(n_theta,1)*psi*pi/180,n_theta*n_psi,1);
data.det_dtheta=ones(n_theta*n_psi,1)*dth*0.8*pi/180;
data.det_dpsi  =ones(n_theta*n_psi,1)*dps*0.8*pi/180;

function [s,e]=signal(ndet,ne)
x=1:ndet;
y=1:ne;
[XI,YI]=meshgrid(y,x);

SigmaX=0.2*ndet;
SigmaY=0.2*ne;
s=100*exp(-((XI-0.5*ndet)/SigmaX).^2-((YI-0.5*ne)/SigmaY).^2);
e=0.5./s;





