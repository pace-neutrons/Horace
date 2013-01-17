function y=conv_gau_lor(x,sig,gam,opt)
% Calculates the convolution of normalised Lorentzian and Gaussian functions
%
%   >> y = conv_gau_exp(x, sig, tau)
%
%   sig     Standard deviation of normalised Gaussian
%               (1/sqrt(2*pi*abs(sig))) * exp(-0.5(x/sig).^2)
%
%   gam     Half-width half-height of Lorentzian function
%               (1/abs(gam)) *
%                                         0    x/tau  -ve
%          (i.e. if tau is -ve, then the exponential is non-zero for -ve x)
% Original fortran code: T.G.Perring 23/3/95 - updated to Matlab Jan 2013
%
% ---------------------------------------------------------------------------------------
% For testing purposes only, can use with an additional argument to select the algorithm
% algorithm that computes the scaled complementary error function with a complex argument
% (The algorithm is tricky, and it has been known for an odd result to pop up
% in limiting cases)
%
%   >> y = conv_gau_exp(x, sig, tau, opt)
%   
%   opt='g' (Gautschi)
%       'w' (Weideman)
%       'p' (Poppe)
%       'd' (default) - whichever of the above has been copied to the default

if sig~=0 && gam~=0         % convolution
    if nargin==3
        w=werf(complex(x/(abs(sig)*sqrt(2)),abs(gam)/(abs(sig)*sqrt(2))*ones(size(x))));
    else
        if lower(opt)=='g'
            w=werf_Gautschi(complex(x/(abs(sig)*sqrt(2)),abs(gam)/(abs(sig)*sqrt(2))*ones(size(x))));
        elseif lower(opt)=='w'
            w=werf_Weideman(complex(x/(abs(sig)*sqrt(2)),abs(gam)/(abs(sig)*sqrt(2))*ones(size(x))));
        elseif lower(opt)=='p'
            w=werf_Poppe(complex(x/(abs(sig)*sqrt(2)),abs(gam)/(abs(sig)*sqrt(2))*ones(size(x))));
        elseif lower(opt)=='d'
            w=werf(complex(x/(abs(sig)*sqrt(2)),abs(gam)/(abs(sig)*sqrt(2))*ones(size(x))));
        else
            error('unrecognised option')
        end
    end
    y=real(w)/(sig*sqrt(2*pi));
    
elseif sig~=0 && gam==0     % Gaussian
    y=(1/(sqrt(2*pi)*abs(sig))) * exp(-0.5*(x/sig).^2);
    
elseif sig==0 && gam~=0     % Lorenzian
    y=(abs(gam)/pi)./(x.^2+gam^2);
    
else                        % delta function
    y=zeros(size(x));
    y(x==0)=Inf;
end

%--------------------------------------------------------------------------------------------------
% Insert into the first if block to test different methods of evaluating convolution:
%
%     if isequal(lower(opt),'g')
%         y=werf_Gautschi(x(:)/(sig*sqrt(2)),gam/(sig*sqrt(2))*ones(numel(x),1))/(sig*sqrt(2*pi));
%         y=reshape(y,size(x));
%     elseif isequal(lower(opt),'w')
%         w=werf_Weideman(complex(x(:)/(sig*sqrt(2)),gam/(sig*sqrt(2))*ones(numel(x),1)));
%         y=real(w)/(sig*sqrt(2*pi));
%     elseif isequal(lower(opt),'s')
%         w=werf_Winiecki(complex(x(:)/(sig*sqrt(2)),gam/(sig*sqrt(2))*ones(numel(x),1)));
%         y=real(w)/(sig*sqrt(2*pi));
%     else
%         error('unrecognised option')
%     end