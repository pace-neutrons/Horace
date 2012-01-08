function [ok,xbounds,any_lim_inf,is_descriptor,any_dx_zero,mess]=rebin_boundaries_description_parse(nax,opt,varargin)
% Check rebin descriptor has valid format, and returns in standard form [x1,dx1,x2,dx2,x3,...]
%
%   >> [ok,xbounds,any_lim_inf,is_descriptor,any_dx_zero,mess]=rebin_boundaries_description_parse(nax,opt)    % sets output descriptors to [] for all nax axes
%   >> [ok,xbounds,any_lim_inf,is_descriptor,any_dx_zero,mess]=rebin_boundaries_description_parse(nax,opt,arg1,arg2,...)    % general case (see below)
%
% Input:
% ------
%   nax                     Number of rebin descriptors that is expected (nax>=1)
%
%   opt                     Type check options: structure with fields
%                               empty_is_full_range     true: [] or '' ==> [-Inf,Inf];
%                                                       false ==> [-Inf,0,Inf]
%                               range_is_one_bin        true: [x1,x2]  ==> one bin
%                                                       false ==> [x1,0,x2]
%                               array_is_descriptor     true:  interpret array of three or more elements as descripor
%                                                       false: interpet as actual bin boundaries
%                               bin_boundaries          true:  intepret x values as bin boundaries
%                                                       false: interpret as bin centres
%   arg1,arg2,...           Binning description
%
%   One rebin axis (i.e. nax=1 only):
%   - - - - - - - - - - - - - - - - - 
%     [] or ''              Single bin over full range of data i.e. equivalent to [-Inf,Inf] (empty_is_full_range==true)
%                      *OR* Leave bins as they are (empty_is_full_range==false)
%     0                     Leave bins as they are i.e. treated as [-Inf,0,Inf]
%     dx                    Equally spaced bins width dx centred on x=0 and over full range of data i.e. equivalent to [-Inf,dx,Inf] (must have dx>0)
%     x1,x2                 Single bin (range_is_one_bin==true)
%                      *OR* Keep original bins in the range xlo to xhi i.e. equivalent to [xlo,0,xhi] (range_is_one_bin==false)
%
% If array_is_descriptor==true, there are two possibilities for three or more arguments:
%  - If bin_boundaries==true:
%     x1,dx1,x2           -|where -Inf<=x1<x2<x3...<xn<=Inf and 
%     x1,dx1,x2,dx2,x3,...-|     dx +ve: equal bin sizes between corresponding limits
%                                dx -ve: logarithmic bins between corresponding limits
%                                      (note: if dx1<0 then dx1>0, dx2<0 then dx2>0 ...)
%                                dx=0  : retain existing bins between corresponding limits
%  - If bin_boundaries==false:
%     x1,dx1,x2             where x1<x2 x1 and x2 both finite and dx>0: bin centres at x1, x1+dx1, x1+2*dx1, ...
%
% If array_is_descriptor==false, then three or more arguments are interpreted as bin boundaries
%     x1,x2,x3,...          where -Inf<=x1<x2<x3<...xn<=Inf
%
%
%   Any number of rebin axes (i.e. any value of nax):
%   - - - - - - - - - - - - - - - - - - - - - - - - -
%     xdescr1, xdescr2,...  Set of rebin descriptors where each descriptor is a vector with one of the above forms
%
%
% Output:
% -------
%   ok              True if no problems, false if error found in input e.g. not strictly monotonic boundaries
%   xbounds         Cell array of rebin vectors {xbins1, xbins2,...}; [] if ok==false. The form of each vector is
%               Descriptor:     [x1,dx1,x2,dx2,...xn]
%                               where -Inf<=x1<x2<x3...<xn<=Inf; n>=2
%                                dx +ve: equal bin sizes between corresponding limits
%                                dx -ve: logarithmic bins between corresponding limits
%                                      (note: if dx1<0 then dx1>0, dx2<0 then dx2>0 ...)
%                                dx=0  : retain existing bins between corresponding limits
%
%               Bin boundaries: [x1,x2,...xn]
%                               where -Inf<=x1<x2<x3...<xn<=Inf; n>=2
%                   
%   any_lim_inf     Logical array; an element is true if either or both limits are infinite
%   is_descriptor   Logical array; an element is true if xbounds is a descriptor of bin boundaries;
%                  or is false if xbounds contains actual bin boundaries
%   any_dx_zero     Logical array; an element is true if one or more dx in the corresponding
%                  descriptor is zero (false if is_descriptor==false)
%   mess            Error message if ok==false (empty otherwise)


% If no bins given, return [] for each rebin axis
if numel(varargin)==0
    ok=true;
    xbounds=cell(1,nax);
    for i=1:nax
        if opt.empty_is_full_range
            xbounds{i}=[-Inf,Inf];
            any_lim_inf=true(1,nax);
            is_descriptor=false(1,nax);
            any_dx_zero=false(1,nax);
        else
            xbounds{i}=[-Inf,0,Inf];
            any_lim_inf=true(1,nax);
            is_descriptor=true(1,nax);
            any_dx_zero=true(1,nax);
        end
    end
    mess='';
    return
end

% Parse input
if nax==1
    if ~(numel(varargin)==1 && (isempty(varargin{1}) || (isnumeric(varargin{1})&&isvector(varargin{1}))))
        % input is not a single empty argument or a numeric vector, so only valid input is non empty numeric scalars
        xvals=zeros(1,numel(varargin));
        for i=1:numel(varargin)
            if ~isempty(varargin{i}) && isnumeric(varargin{i}) && isscalar(varargin{i})
                xvals(i)=varargin{i};
            else
                ok=false; xbounds={}; any_lim_inf=false(1,0); is_descriptor=false(1,0); any_dx_zero=false(1,0);
                mess='Check bin boundary descriptor is a numeric vector or list of scalars';
                return
            end
        end
        [ok,xbounds,any_lim_inf,is_descriptor,any_dx_zero,mess]=rebin_boundaries_description_parse_single(opt,xvals);
        if ~ok, xbounds={}; any_lim_inf=false(1,0); is_descriptor=false(1,0); any_dx_zero=false(1,0); end
        return
    end
end

if nax==numel(varargin)
    xbounds=cell(1,nax);
    any_lim_inf=false(1,nax);
    is_descriptor=false(1,nax);
    any_dx_zero=false(1,nax);
    for i=1:nax
        [ok,xbounds{i},any_lim_inf(i),is_descriptor(i),any_dx_zero(i),mess]=rebin_boundaries_description_parse_single(opt,varargin{i});
        if ~ok, xbounds={}; any_lim_inf=false(1,0); is_descriptor=false(1,0); any_dx_zero=false(1,0); return, end
    end
else
    ok=false; xbounds={}; any_lim_inf=false(1,0); is_descriptor=false(1,0); any_dx_zero=false(1,0);
    mess='Check number of bin boundary descriptors matches number of rebin axes';
end
