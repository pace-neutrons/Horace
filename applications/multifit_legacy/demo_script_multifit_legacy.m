%% -----------------------------------------------
%   Script to demonstrate use of multifit
% ------------------------------------------------

% Type
%    >> help multifit
% to get detailed help

% Make some test data
% --------------------
xx=1:15;
yy=[1.9933    2.0435    2.5417    3.0345    3.4903    4.2549    9.8465   13.0729    8.4943    5.1915,...
    3.9964    4.6556    4.5898    4.6356    4.7903];
ee=[0.3193    0.2581    0.4204    0.5126    0.6102    0.6172    1.0672    1.6066    1.6252    0.5983,...
    0.7297    0.7162    0.9162    0.4998    0.6911];


% Fit a gaussian to the test data
% ---------------------------------
% Simple Gaussian, unconstrained fit
% (The parameters are height,centre,st.dev, background intercept and background slope)
[yfit,fitdata]=multifit(xx,yy,ee,@gauss_bkgd,[10,7,1,0,0]);

% Fix the height and centre
[yfit,fitdata]=multifit(xx,yy,ee,@gauss_bkgd,[10,7,1,0,0],[0,0,1,1,1]);

% Fix the height to be a fixed multiple of the width, as given by the ratio of the initial values
% That is, bind parameter 1 to parameter 3
[yfit,fitdata]=multifit(xx,yy,ee,@gauss_bkgd,[10,7,1,0,0],[1,1,1,1,1],{1,3});

% Fix height to be a fixed multiple of the width, and the slope a fixed multiple of the 
% intercept. Keep centre fixed.
% In this case, the ratio of slope to gradient cannot be estimated from the initial values (as that is 0/0)
% so give the ratio of 0.1 explicitly in the binding argument. Note that the syntax demands
% an extra zero - it looks cumbersome, but that is because multifit has a much greater generality than
% described here and in particular the binding description can perform more functions which need this
% extra argument).
% 
[yfit,fitdata]=multifit(xx,yy,ee,@gauss_bkgd,[10,7,1,0,0],[1,1,0,1,1],{{1,3},{5,4,0,0.1}});


%% -----------------------------------------------
%   Demonstration using IX_dataset_1d object
% ------------------------------------------------
% This enables all the arithmetic and plotting functionality to be used

% Make some test data
% --------------------
xx=1:15;
yy=[1.9933    2.0435    2.5417    3.0345    3.4903    4.2549    9.8465   13.0729    8.4943    5.1915,...
    3.9964    4.6556    4.5898    4.6356    4.7903];
ee=[0.3193    0.2581    0.4204    0.5126    0.6102    0.6172    1.0672    1.6066    1.6252    0.5983,...
    0.7297    0.7162    0.9162    0.4998    0.6911];

wdata=IX_dataset_1d (xx,yy,ee,'Noisy Gaussian data','Energy','Counts');
dp(wdata)   % 'draw points' - markers and error bars

% Fit a gaussian to the test data
% ---------------------------------
% Simple Gaussian, unconstrained fit
% (The parameters are height,centre,st.dev, background intercept and background slope)
[wfit,fitdata]=multifit(wdata,@gauss_bkgd,[10,7,1,0,0]);
dp(wdata)   % draw data points
pl(wfit)    % overplot line

% Fix the height and centre
[wfit,fitdata]=multifit(wdata,@gauss_bkgd,[10,7,1,0,0],[0,0,1,1,1]);
dp(wdata)   % draw data points
pl(wfit)    % overplot line

% Fix the height to be a fixed multiple of the width, as given by the ratio of the initial values
% That is, bind parameter 1 to parameter 3
[wfit,fitdata]=multifit(wdata,@gauss_bkgd,[10,7,1,0,0],[1,1,1,1,1],{1,3});
dp(wdata)   % draw data points
pl(wfit)    % overplot line

% Fix height to be a fixed multiple of the width, and the slope a fixed multiple of the 
% intercept. Keep centre fixed.
% In this case, the ratio of slope to gradient cannot be estimated from the initial values (as that is 0/0)
% so give the ratio of 0.1 explicitly in the binding argument. Note that the syntax demands
% an extra zero - it looks cumbersome, but that is because multifit has a much greater generality than
% described here and in particular the binding description can perform more functions which need this
% extra argument).
% 
[wfit,fitdata]=multifit(wdata,@gauss_bkgd,[10,7,1,0,0],[1,1,0,1,1],{{1,3},{5,4,0,0.1}});
dp(wdata)   % draw data points
pl(wfit)    % overplot line

% Evaluate the fit on a much finer set of x values
wtmp = linspace(wdata,1000);
wcalc = func_eval(wtmp,@gauss_bkgd,fitdata.p);
acolor blue
dp(wdata)
acolor red
pl(wcalc)
