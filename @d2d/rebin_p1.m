function wout = rebin_p1(win,varargin)
%  rebin_p1 rebin p1 axis of a Horace d2d object
%
%  new_dataset = rebin_p1(dataset_2d,option) or 
%  new_dataset = rebin_p1(dataset_2d,xlo,dx,xhi) or
%  new_dataset = rebin_p1(dataset_2d, xlo, xhi),
%
%  Inputs: 
% ---------
%   datset_2d:      d2d object to rebin
%   option:         xref or xdesc, 
%   ylo to yhi:     range to rebin, 
%   dy:             intervals. 
%
%  rebins an d2d object along the p1 axis according to the specific arguments
%--------------------------------------------------------------------------
%   rebin_p1(w1,xref)      rebin w1 with the bin boundaries of xref (*** Note: reverse of Genie-2)
%
%   rebin_p1(w1,xdesc)  xdesc is an array of boundaries and intervals. Linear or logarithmic
%  ------------------------ rebinning can be accommodated by conventionally specifying the rebin
%                           interval as positive or negative respectively:
%   e.g. rebin_p1(w1,[2000,10,3000])  and
%        rebin_p1(w1,2000,10,3000)
%
%   rebins from 2000 to 3000 in bins of 10
%
%   e.g. rebin_p1(w1,[5,-0.01,3000])  and
%        rebin_p1(w1,5,-0.01,3000)
%
%   rebins along p1 axis from 5 to 3000 with logarithmically spaced bins with
%                                 width equal to 0.01 the lower bin boundary 
% 
%  The conventions can be mixed on one line:
%   e.g. rebin_p1(w1,[5,-0.01,1000,20,4000,50,20000])
%
%  Rebinning between two limits along p1 maintaining the existing bin boundaries between those limits
%  is achieved with
%
%   rebin_p1(w1,[xlo,xhi])  retain only the data between XLO and XHI, otherwise maintaining the
%  existing bin boundaries. 
%
%   xlo, dx and xhi can be column arrays if required.
%--------------------------
%
%  general form:
%   rebin_p1(w1,[x_1,dx_1,x_2,dx_2,...,x_n,dx_n,x_n+1])  
%
%------------Arrays of dataset_2d and option--------------------
%
% if dataset_2d is an array, every member of the array will be rebinned
% according to option. 
%
% If option is an array the same size as the dataset,
% dataset(i) will be rebinned along p1 with option(i), this should be a column vector if given as xdesc 
% (i.e. [xlo1, dx1, xhi1; xlo2, dx2, xhi2]) 
% 
% if using separate arguments (i.e. new_dataset = rebin_p1(old_dataset, xlo, dx, xhi) 
% then xlo, dx and xhi may be column or row vectors, 
% an array of xref may also be given as column or row vectors.
%
% e.g. : new_dataset = rebin_p1(dataset_2d(1:2),[200,50,10000;100,30,5000]) or 
%        new_dataset = rebin_p1(dataset_2d(1:2),[200,100],[50;30],[10000,5000])
%
% both rebin dataset_2d(1) along p1 between 200 and 10,000 with bins of 50 and
% dataset_2d(2) between 100 and 5000 with bins of 30
% 
% This mirrors the libisis function rebin_x. See libisis documenation for
% advanced usage.
%--------------------------------------------------------------------------
%-------------------

wout = dnd_data_op(win, @rebin_p1, 'd2d' , 2, varargin{:});
