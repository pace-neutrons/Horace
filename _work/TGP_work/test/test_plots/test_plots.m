%% Setup
lattice=[2*pi 2*pi 2*pi 90 90 90];
rlp=[0,0,0; 0.5,0,0; 0.5,0.5,0; 0.5,0.5,0.5; 0,0,0; 0.5,0.5,0];
labels={'G','X','M','R','G','M'};

gap=5; js=4; optic=10;
pars=[gap,js];
pars_2=[gap,js,optic];


%% Test dispersion_plot

[wd1,wt1]=dispersion_plot(lattice,rlp,@disp_bcc_hfm,pars,'labels',labels);
[wd2,wt2]=dispersion_plot(lattice,rlp,@disp_bcc_hfm_2,pars_2,'labels',labels);


%% Test disp2sqw_plot

wdsqw1=disp2sqw_plot(lattice,rlp,@disp_bcc_hfm,pars,[0,0.25,50],2,'labels',labels);
wdsqw2=disp2sqw_plot(lattice,rlp,@disp_bcc_hfm_2,pars_2,[0,0.25,50],2,'labels',labels);


%% Test sqw_plot

wsqw1=sqw_plot(lattice,rlp,@sqw_bcc_hfm,[pars,1,2,0],[0,0.25,50],'labels',labels);
wsqw2=sqw_plot(lattice,rlp,@sqw_bcc_hfm_2,[pars_2,1,2,0],[0,0.25,50],'labels',labels);
