##################
Script for fitting
##################

::

   %============= Fitting a single 1d cut with a generic peak =================

   %====
   %Simplest case allows all parameters to be free
   pars_in=[0.4,-0.7,0.1,0.5,-0.2,0.1,0.5,0.2,0.1,0.4,0.6,0.1,0.4,1.3,0.1];%vector of input parameters, in this case characterising some gaussian peaks

   [wfit,fitdata]=fit_func(my_cut-0.3,@mgauss,pars_in);%note subtraction of 0.3 to account for background (see later for background fitting)

   %The output wfit is an object that covers the same range as the data and is the resultant best fit.
   %The output fitdata is a structure array giving information about the fit (parameters, errors, chi^2, correlation matrix, etc)

   %Plot the result in a nice way (data is black circles + errorbars, fit is red line)
   acolor black
   plot(my_cut-0.3);%crude background subtraction
   acolor red
   pl(wfit)


   %====
   %Keep the widths of all the peaks fixed, but allow heights and centres to vary;

   pars_in=[0.4,-0.8,0.1,0.5,-0.22,0.1,0.5,0.22,0.1,0.4,0.8,0.1,0.4,1.2,0.1];

   pars_free=[1,1,0,1,1,0,1,1,0,1,1,0,1,1,0];%vector same size as that giving inputs, with 0 for parameter to be kept fixed, 1 for allowed to vary

   [wfit,fitdata]=fit_func(my_cut-0.3,@mgauss,pars_in,pars_free);

   %====
   %Now bind some of the positions to follow symmetry (i.e. position of peaks for Q<0 are  reflection of those at Q>0)
   pars_in=[0.4,-0.8,0.07,0.5,-0.22,0.07,0.5,0.22,0.07,0.4,0.8,0.07,0.4,1.2,0.07];

   pars_free=[1,1,0,1,1,0,1,1,0,1,1,0,1,1,0];

   pars_bind={{2,11,0,-1},{5,8,0,-1}};%ensures symmetry about x=0; 2nd parameter is bound to 11th parameter in ratio -1, ditto the 5th and 8th parameters

   [wfit,fitdata]=fit_func(my_cut-0.3,@mgauss,pars_in,pars_free,pars_bind);


   %====
   %Repeat the above, but using some of the options
   pars_in=[0.4,-0.8,0.07,0.5,-0.22,0.07,0.5,0.22,0.07,0.4,0.8,0.07,0.4,1.2,0.07];

   pars_free=[1,1,0,1,1,0,1,1,0,1,1,0,1,1,0];

   pars_bind={{2,11,0,-1},{5,8,0,-1}};%ensures symmetry about x=0

   [wfit,fitdata]=fit_func(my_cut(1)-0.35,@multigauss,pars_in,pars_free,pars_bind,'list',2,'fit',[0.001 50 0.001]);

   %This example of setting 'list' to 2 gives a very verbose output to the Matlab command window as the fit progresses.
   %Setting 'fit' to [0.001 50 0.001] (from the default setting of fcp=[0.0001 30 0.0001]) changes respectively:
   %    - The relative step length for calculation of partial derivatives
   %    - The maximum number of iterations
   %    - The stopping criterion, that is the relative change in chi-squared (i.e. stops if chisqr_new-chisqr_old < fcp(3)chisqr_old)


   %============== Fitting a single cut with an S(Q,w) model ======================

   %The syntax, in terms of options, is the same as for fit_func. But this time the routine we use is called fit_sqw

   pars=[1,2,3,4]
   pfree=[1,1,1,1]

   [wfit,fitdata]=fit_sqw(my_cut-0.3,@my_sqw_model,pars,pfree,'list',1);%this time we choose a medium level of verbosity during the fit



   %============= Fitting a cut with a foreground and background ==================

   %We will use fit_sqw (S(Q,w) model for the cross-section) here, i.e. use fit_sqw. The same syntax applies for fit_func.

   %We will fit a linear background model (in the format used for func_eval and fit_func; the function needs to be on the Matlab path like the model function)
   bgpars=[1,1];
   bgfree=[1,1];

   [wfit,fitdata]=fit_sqw(my_cut,@my_sqw_model,pars,pfree,@linear_bg,bgpars,bgfree,'list',1);


   %============= Fitting multiple cuts simultaneously with the same foreground but different backgrounds ===========

   %Here we have an array of cuts (or slices). They are all fitted with the same foreground function and parameters, but the background
   %for each cut is allowed to be different. This corresponds to the most realistic situation you will encounter in your data analysis

   %Make an array of cuts:
   my_en=[2:2:10];
   for i=1:numel(my_en)
	my_cut(i)=cut_sqw(data_source,proj,[0,0.1:8],[-1,1],[-1,1],[my_en(i)-25,my_en(i)+25]);
   end

   %If all of the backgrounds have the same form (e.g. they are all linear) but have different parameters, then this is easy,
   %since we can just re-use the code from above:

   pars=[1,2,3,4]
   pfree=[1,1,1,1]

   bgpars=[1,1];
   bgfree=[1,1];

   [wfit,fitdata]=multifit_sqw(my_cut,@my_sqw_model,pars,pfree,@linear_bg,bgpars,bgfree,'list',1);


   %But suppose the backgrounds have different functional forms. Now we need to use cell arrays for the background function, parameters and pfree.
   %In the example here we have a mixture of linear and quadratic backgrounds

   bgfunc={@linear_bg,@linear_bg,@linear_bg,@quadratic_bg,@quadratic_bg};
   bgpars={[1,0],[2,0],[2,1],[3,2,2],[3,0,1]};%use different initial guesses and different free/fixed parameters for the background
   bgfree={[1,1],[1,1],[1,1],[1,1,1],[1,1,1]};

   [wfit,fitdata]=fit_sqw(my_cut,@my_sqw_model,pars,pfree,bgfunc,bgpars,bgfree,'list',1);
