function [ok,xbounds,any_lim_inf,is_descriptor,any_dx_zero,mess]=rebin_boundaries_description_parse_single_(opt,xvals)
% Check boundary descriptors are OK for a single axis.
% See rebin_boundaries_description_parse for valid input
if isempty(xvals)
    ok=true;
    if opt.empty_is_full_range
        xbounds=[-Inf,Inf]; any_lim_inf=true; is_descriptor=false; any_dx_zero=false;
    else
        xbounds=[-Inf,0,Inf]; any_lim_inf=true; is_descriptor=true; any_dx_zero=true;
    end
    mess='';
    
elseif isnumeric(xvals) && isvector(xvals)
    if ~any(isnan(xvals))
        if isscalar(xvals)
            if xvals==0
                ok=true; xbounds=[-Inf,0,Inf]; any_lim_inf=true; is_descriptor=true; any_dx_zero=true; mess='';
            else
                ok=true; xbounds=[-Inf,xvals,Inf]; any_lim_inf=true; is_descriptor=true; any_dx_zero=false; mess='';
            end

        elseif numel(xvals)==2
            if xvals(1)<xvals(2)
                if opt.range_is_one_bin
                    ok=true; xbounds=[xvals(1),xvals(2)]; any_lim_inf=any(isinf(xvals)); is_descriptor=false; any_dx_zero=false; mess='';
                else
                    ok=true; xbounds=[xvals(1),0,xvals(2)]; any_lim_inf=any(isinf(xvals)); is_descriptor=true; any_dx_zero=true; mess='';
                end
            else
                ok=false; xbounds=[]; any_lim_inf=false; is_descriptor=false; any_dx_zero=false;
                mess='Upper limit must be greater than lower limit in a rebin descriptor';
            end
            
        else
            if opt.array_is_descriptor
                if opt.bin_boundaries
                    if rem(numel(xvals),2)==1
                        if all(diff(xvals(1:2:end)))>0    % strictly monotonic increasing
                            xvals_lo=xvals(1:2:end-1);
                            if isinf(xvals_lo(1)), xvals_lo=xvals(3); end    % permit -Inf as first element in descriptor
                            if all(xvals_lo>0 | xvals(2:2:end-1)>=0)
                                ok=true;
                                if size(xvals,1)>1, xbounds=xvals'; else, xbounds=xvals; end     % make row vector
                                any_lim_inf=isinf(xbounds(1))|isinf(xbounds(end));
                                is_descriptor=true;
                                if any(xvals(2:2:end)==0)
                                    any_dx_zero=true;
                                else
                                    any_dx_zero=false;
                                end
                                mess='';
                            else
                                ok=false; xbounds=[]; any_lim_inf=false; is_descriptor=false; any_dx_zero=false;
                                mess='Rebin descriptor cannot have logarithmic bins for negative axis values';
                            end
                        else
                            ok=false; xbounds=[]; any_lim_inf=false; is_descriptor=false; any_dx_zero=false;
                            mess='Bin ranges in rebin descriptor must be strictly monotonic increasing';
                        end 
                    else
                        ok=false; xbounds=[]; any_lim_inf=false; is_descriptor=false; any_dx_zero=false;
                        mess='Check rebin descriptor has correct number of elements';
                    end
                else
                    if numel(xvals)==3 && xvals(1)<xvals(3) && xvals(2)>0
                        ok=true;
                        xbounds=[xvals(1)-xvals(2)/2,xvals(2),xvals(3)+xvals(2)/2];
                        any_lim_inf=isinf(xbounds(1))|isinf(xbounds(end));
                        is_descriptor=true; any_dx_zero=false; mess='';
                    else
                        ok=false; xbounds=[]; any_lim_inf=false; is_descriptor=false; any_dx_zero=false;
                        mess='Rebin descriptor for bin centres must have three elements in the form [xlo,dx,xhi], xlo<xhi and dx>0';
                    end
                end
            else
                if all(diff(xvals)>0)
                    ok=true;
                    if size(xvals,1)>1, xbounds=xvals'; else, xbounds=xvals; end     % make row vector
                    any_lim_inf=isinf(xbounds(1))|isinf(xbounds(end));
                    is_descriptor=false; any_dx_zero=false; mess='';
                else
                    ok=false; xbounds=[]; any_lim_inf=false; is_descriptor=false; any_dx_zero=false;
                    mess='Rebin boundaries must be strictly monotonic increasing vector i.e. all bin widths > 0';
                end
            end       

        end
        
    else
        ok=false; xbounds=[]; any_lim_inf=false; is_descriptor=false; any_dx_zero=false;
        mess='Rebin descriptor cannot contain any NaNs';
    end
    
else
    ok=false; xbounds=[]; any_lim_inf=false; is_descriptor=false; any_dx_zero=false;
    mess='Rebin descriptor must be a numeric vector';
end
