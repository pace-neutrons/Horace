#############################
Script for making simulations
#############################

Simulations
-----------

::

   %Simulation of generic function (e.g. peaks) and S(Q,w) models

   %========= S(Q,w) model simulations ========================

   %simulate on sqw objects using S(Q,w) model for the physics

   %Use sqw_eval for S(Q,w) models
   sim_slice=sqw_eval(my_slice,@my_sqw_model,[1,2,3,4]);
   sim_slice_dnd=sqw_eval(d2d(my_slice),@my_sqw_model,[1,2,3,4]);

   %Here my_slice is an sqw object. We have a Matlab function on our path called my_sqw_model.m, and there are
   %some parameters associated with this model, [1,2,3,4].
   %
   %The form (1st line) of my_sqw_model.m should be:
   % function weight=my_sqw_model(h,k,l,e,pars)
   % the pars are the vector of input parameters we used above
   %
   % An example of an S(Q,w) model is given in the Horace "functions" directory, in the Matlab m-file
   % "demo_FM_spinwaves_2dSlice_sqw.m


   %Simulating a dnd and an sqw that are notionally the same gives different results, since for the sqw all of the contributing
   %detector pixels are simulated and then re-summed, whereas for the dnd just single points at the centre of bins are used
   %So if the intensity varies across a bin the dnd simulation will not capture this


   %========== Generic function simulation ==================

   %Use func_eval for generic functions
   peak_cut=func_eval(my_cut,@mgauss,[1,-1,0.1,2,0,0.1,1,1,0.1]);

   %Here the function mgauss is included in the Horace distribution (in the functions directory). It only works on 1-dimensional cuts, and simulates multiple
   %gaussians. The syntax is the same as for the sqw_eval function, so the vector argument is a list of input parameters for the function
   %In the case of mgauss, they are [amplitude1, centre1, width1, amplitude2, centre2, width2, ...., amplitudeM, centreM, widthM]
   %for M gaussians







Plotting dispersion
-------------------






::




   alatt=[2.87,2.87,2.87];
   angdeg=[90,90,90];

   lattice=[alatt,angdeg];
   rlp=[0,0,0; 1/2,0,0; 1/2,1/2,0; 1/2,1/2,1/2; 0,0,0; 0,0,1/2;];
   pars=[1,2,3,4,5];
   ecent=[0,0.1,10];
   fwhh=0.1;
   disp2sqw_plot(lattice,rlp,@my_dispersion_function,pars,ecent,fwhh);


   %The dispersion function has different (but similar) form to cross section functions
   %
   % The inputs are h,k,l and parameters; the outputs are the energy (i.e. dispersion) and spectral weight at that point

   %Here is an example dispersion function
   function [wdisp1,s_yy]=sr122_disp(qh,qk,ql,p)
   %
   % SrFe2As2 cross-section, from Tobyfit
   %

   %  Spin waves for FeAs, from Ewings et al., PRB 78
   %  Lattice parameters as for orthorhombic lattice i.e. a ~= b ~5.6Ang
   %
   % \tp(1)\tS_eff
   % \tp(2)\tSK_ab
   % \tp(3)\tSK_c
   %
   %    If ircoss=201:
   % \tp(4)\tSJ_1a
   % \tp(5)\tSJ_1b
   % \tp(6)\tSJ_2
   %
   %    If icross=202
   % \tp(4)\tS(2J2+J_1a)
   % \tp(5)\tS(2J2-J_1b)
   % \tp(6)\tSJ1a-SJ1b
   %
   % \tp(7)\tSJ_c
   % \tp(8)\tinverse lifetime gamma (= energy half-width)
   % \tp(19)\t0 if S(Q,w) as theory, =1 if multiply S(Q,w) by energy transfer
   % \tp(20)\t0 if twinned; 1 if twin #1 ; -1 if twin #2

   % If icross=207
   % As cross-section 204, but deal with J1a, J1b, J2 directly.

   s_eff = p(1);
   sj_1a = p(4);
   sj_1b = p(5);
   sj_2  = p(6);
   sj_c  = p(7);
   sjplus = sj_1a+(2.sj_2);
   sjminus = (2.sj_2)-sj_1b;
   sk_ab = 0.5.(sqrt((sjplus+sj_c).^2 + 10.5625) - (sjplus+sj_c));
   sk_c  = sk_ab;
   gam   = p(8);
   temp=4;

   alatt=[5.57,5.51,12.298];
   arlu=2pi./alatt;
   qsqr = (qh*arlu(1)).^2 + (qk*arlu(2)).^2 + (qlarlu(3)).^2;


   weight=zeros(size(qh));

   %First twin:
   a_q = 2.*( sj_1b.*(cos(pi.*qk)-1) + sj_1a + 2.*sj_2 + sj_c ) + (3.sk_ab+sk_c);
   d_q = 2.*( sj_1a.*cos(pi.*qh) + 2.*sj_2.*cos(pi.*qh).*cos(pi.*qk) + sj_c.*cos(pi.*ql) );
   c_anis = sk_ab-sk_c;

   wdisp1 = sqrt(abs(a_q.^2-(d_q+c_anis).^2));
   %wdisp2 = sqrt(abs(a_q.^2-(d_q-c_anis).^2));

   s_yy = s_eff.((a_q-d_q-c_anis)./wdisp1);
