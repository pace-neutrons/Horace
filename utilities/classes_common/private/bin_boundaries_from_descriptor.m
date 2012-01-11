function [x_out, ok, mess] = bin_boundaries_from_descriptor (xbounds, x_in, use_mex, force_mex)
% Get new x bin boundaries from a bin boundary descriptor
%
%   >> [x_out, ok]=bin_boundaries_from_descriptor (xbounds)
%   >> [x_out, ok]=bin_boundaries_from_descriptor (xbounds, x_in)
%
% Input:
% ------
%   xbounds     Histogram bin boundaries descriptor:
%                   (x_1, del_1, x_2,del_2 ... x_n-1, del_n-1, x_n)
%                   Bin from x_1 to x_2 in units of del_1 etc.
%                       del > 0: linear bins
%                       del < 0: logarithmic binning
%                       del = 0: Use bins from input array
%                   [If only two elements, then interpreted as lower and upper bounds, with DEL=0]
%
%   x_in        Input x-array bin boundaries - only used where DEL=0 for one of the rebin ranges
%              Provide a dummy *numerical* value e.g. 0 if it is known that it is not needed; the
%              mex implementation needs a numerical value.
%
%   use_mex     Determine if should try mex file implementation first
%              if use_mex==true:  use mex file implementation
%              if use_mex==false: use matlab implementation
%
%   force_mex   If use_mex==true, determine if forces mex only, only allows matlab implementation to catch error
%              if force_mex==true: do not allow matlab implementation to catch error
%              if force_mex==false: allow matlab to catch on error condition in call to mex file
%
% Output:
% --------
%   x_out       Bin boundaries for rebin array.
%
%   ok          =true  if no problems
%               =false if a problem (and x_out is set to [])
%
%   mess        Error message
%
%   if ok is omitted, then the error message is printed to the screen.

if use_mex
    try
        x_out=bin_boundaries_from_descriptor_mex(xbounds,x_in);
        ok=true;
        mess='';
    catch
        if ~force_mex
            display(['Error calling mex function ',mfilename,'_mex. Calling matlab equivalent'])
            use_mex=false;
        else
            x_out=[];
            ok=false;
            if ~isempty(lasterr)
                mess=lasterr;
            else
                mess=['Error calling mex function ',mfilename,'_mex'];  % guarantees a message
            end
        end
    end
end

if ~use_mex
    [x_out,ok,mess]=bin_boundaries_from_descriptor_matlab(xbounds,x_in);
end

if nargout<2
    error(mess)
end
