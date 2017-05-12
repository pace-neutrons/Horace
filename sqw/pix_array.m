classdef pix_array
    % class describes pixels array and its limits
    
    %   Detailed explanation goes here
    
    properties(Dependent)
        %Array containing data for each pixel:
        % If npixtot=sum(npix), then pix(9,npixtot) contains:
        % u1      -|
        % u2       |  Coordinates of pixel in the projection axes
        % u3       |
        % u4      -|
        % irun        Run index in the header block from which pixel came
        % idet        Detector group number in the detector listing for the pixel
        % ien         Energy bin number for the pixel in the array in the (irun)th header
        % signal      Signal array
        % err         Error array (variance i.e. error bar squared)
        pix
        
        pix_range
    end
    properties(Access=protected)
        pix_ = [];
        pix_range_ = [Inf,Inf,Inf,Inf;... %True range of the data along each axis [urange(2,4)]
            -Inf,-Inf,-Inf,-Inf]
    end
    
    methods
        function obj = pix_array(varargin)
            if nargin>0
                obj.pix = varargin{1};
            end
        end
        function pixels = get.pix(obj)
            pixels = obj.pix_;
        end
        function range = get.pix_range(obj)
            range = obj.pix_range_;
        end
        %------------------------------------------------------------------
        
    end
    
end

