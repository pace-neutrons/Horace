function varargout = resol_conv_tobyfit_mc_control (varargin)
% Reset the random number generator status for the current dataset if required within multifit
%
% Cleanup:
% --------
%   >> resol_conv_tobyfit_mc_control
%
%
% Initialise multifit control:
% ----------------------------
% To allow multifit to control return arguments, if active:
%
%   >> resol_conv_tobyfit_mc_control ('multifit', sz)   % sz=size of dataset array
%
% (The default is that multifit is not allowed to control return arguments)
%
%
% Set index: (not under control of multifit)
% ----------
%   >> resol_conv_tobyfit_mc_control (ind)       % numeric array of dataset indicies
%
%
% Retrive status:
% ---------------
%   >> [ind,rng_state]=resol_conv_tobyfit_mc_control
%
%       ind         Index, or array of indicies, of datasets to be evaluated
%       rng_state   Cell array of states of random number generator, same number
%                  of elements as ind.
%                   If empty, then no state to be set
%
% If under multifit control, the rng_state will be returned as required in least-squares
% fitting routine of multifit according to function values being stored or partial
% derivatives being calculated. For the final function evaluation of multifit the
% appropriate rng_state is also returned.


persistent ind multifit_control foreground_rng background_rng

own_control=(isempty(multifit_control) || ~multifit_control);

if nargout>0 && nargin==0
    if ~own_control
        [isfitting,index,foreground,store_calcs]=multifit_gateway_get_state;
        varargout{1}=index;
        if isfitting && ~isempty(foreground_rng) && ~isempty(background_rng)
            if store_calcs  % calculated values will be stored; save corresponding rng status
                varargout{2}={};
                if foreground
                    foreground_rng{index}=rng;
                else
                    background_rng{index}=rng;
                end
            else
                if foreground
                    varargout{2}=foreground_rng(index);
                else
                    varargout{2}=background_rng(index);
                end
            end
        else
            if nargout>=2, varargout{2}={}; end
        end
    else
        varargout{1}=ind;
        if nargout>=2, varargout{2}=cell(size(ind)); end     % no rng status stored unless multifit
    end
    
elseif nargout==0
    % Clean, initialise multifit parameters, or set index
    if nargin==0    % Clean up
        ind=[];
        multifit_control=[];
        foreground_rng=[];
        background_rng=[];
        
    elseif nargin==1 && isnumeric(varargin{1})  % Set index.
        if own_control
            if isempty(varargin{1})
                ind=[];     % will be interpreted as meaning 'all valid indicies'
            elseif all((varargin{1}(:)-round(varargin{1}))==0) && all(varargin{1}(:)>0)
                ind=varargin{1};
            else
                error('Dataset indicies must all be integers greater than zero')
            end
        else
            error('Cannot set dataset index for function evaluation if under multifit control')
        end
        
    elseif nargin==2 && isstringmatchi(varargin{1},'multifit')  % Initialise multifit control
        ind=[];
        multifit_control=true;
        if isrowvector(varargin{2}) && isnumeric(varargin{2}) && all(varargin{2}>=0) && all((varargin{2}-round(varargin{2}))==0)
            foreground_rng=cell(varargin{2});
            background_rng=cell(varargin{2});
        else
            error('Invalid argument: size array must be row vector of non-negative integers')
        end
        
    else
        
    end
    
else
    error('Check number of input and output arguments')
end
