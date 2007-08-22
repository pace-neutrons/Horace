function wout = rebin_p2(win,varargin)
%  rebin_p2 rebin p2 axis of a 2d dataset object for Horace
%
%  new_dataset = rebin_p2(dataset_2d,option) or 
%  new_dataset = rebin_p2(dataset_2d,ylo,dy,yhi) or
%  new_dataset = rebin_p2(dataset_2d, ylo, yhi),
%
%  inputs: 
%----------
%   datset_2d:      d2d object to rebin
%   option:         yref or ydesc, 
%   ylo to yhi:     range to rebin, 
%   dy:             intervals. 
%
%   inputs may be arrays (see below)
%
%  rebins an d2d object along the p2 axis according to the specific arguments
%--------------------------------------------------------------------------
%   rebin_p2(w1,yref)      rebin w1 with the bin boundaries of yref (*** Note: reverse of Genie-2)
%
%   rebin_p2(w1,ydesc)  xdesc is an array of boundaries and intervals. Linear or logarithmic
%  ------------------------ rebinning can be accommodated by conventionally specifying the rebin
%                           interval as positive or negative respectively:
%   e.g. rebin_p2(w1,[2000,10,3000])  and
%        rebin_p2(w1,2000,10,3000)
%
%   rebins from 2000 to 3000 in bins of 10
%
%   e.g. rebin_p2(w1,[5,-0.01,3000])  and
%        rebin_p2(w1,5,-0.01,3000)
%
%   rebins along p2 axis from 5 to 3000 with logarithmically spaced bins with
%                                 width equal to 0.01 the lower bin boundary 
% 
%  The conventions can be mixed on one line:
%   e.g. rebin_p2(w1,[5,-0.01,1000,20,4000,50,20000])
%
%  Rebinning between two limits along x maintaining the existing bin boundaries between those limits
%  is achieved with
%
%   rebin_p2(w1,[ylo,yhi])  retain only the data between YLO and YHI, otherwise maintaining the
%  ------------------------ existing bin boundaries. 
%
%  general form:
%   rebin_p2(w1,[y_1,dy_1,y_2,dy_2,...,y_n,dy_n,y_n+1])  
%
%------------Arrays of dataset_2d and option--------------------
% if dataset_2d is an array, every member of the array will be rebinned
% according to option. 
%
% If option is an array the same size as the dataset,
% dataset(i) will be rebinned along p2 with option(i), this should be a column vector if given as ydesc 
% (i.e. [ylo1, dy1, yhi1; ylo2, dy2, yhi2]) 
% 
% if using separate arguments (i.e. new_dataset = rebin_p2(old_dataset, ylo, dy, yhi) 
% then ylo, dy and yhi may be column or row vectors, 
% an array of yref may also be given as column or row vectors.
%
% e.g. : new_dataset = rebin_p2(dataset_2d(1:2),[200,50,10000;100,30,5000]) or 
%        new_dataset = rebin_p2(dataset_2d(1:2),[200,100],[50;30],[10000,5000])
%
% both rebin dataset_2d(1) along p2 between 200 and 10,000 with bins of 50 and
% dataset_2d(2) between 100 and 5000 with bins of 30
% 
%
% This mirrors the libisis function rebin_y. See libisis documenation for
% advanced usage.
%--------------------------------------------------------------------------
%-------------------

wout = dnd_data_op(win, @rebin_p2, 'd2d' , 2, varargin{:});