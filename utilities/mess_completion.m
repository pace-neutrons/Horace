function mess_completion (varargin)
% Prints a message detailing level of completion if elapsed time exceeds a certain
% threshold since the previous message, or if change in the fraction of completion
% exceeds another threshold. Useful for printing messages that monitor the state
% of completion of long tasks.
%
%   >> mess_completion (ntot, t_thresh, n_ratio_thresh)  % to initialise
%   >> mess_completion (n)      % to test and print messages
%   >> mess_completion          % print termination message
%
% Input on initialisation:
% ------------------------
%   ntot            Total length of task (could be total number of iterations)
%   t_thresh        Message printed if time since last print exceeds this threshold
%   n_ratio_thresh  Message printed if change in ratio n/ntot exceeds this threshold
%
% Input on subsequent calls:
% --------------------------
%   n               Current position in completion of task (could be iteration number)

% Original author: T.G.Perring
%
% $Revision$ ($Date$)

persistent  initialised itimer ntot t_thresh n_ratio_thresh t_start t_prev_msg n_ratio_prev_msg

hor_log_level=config_store.instance().get_value('hor_config','log_level');
% Initialise
if nargin==3
    ntot = varargin{1};
    t_thresh = varargin{2};
    n_ratio_thresh = varargin{3};
    itimer = bigtic;
    t_start = 0;
    t_prev_msg = 0;
    n_ratio_prev_msg = 0;
    initialised = true;
    if hor_log_level>1    
        fprintf(' Task started on  %4d/%02d/%02d %02d:%02d:%02d\n',fix(clock));        
    end
    
    return
end

% If no previous initialisation, print warning message
if isempty(initialised)||~initialised
    disp ('Completion monitoring with mess_completion requires initialisation first')
    return
end


if nargin==0  % task completed
    t = bigtoc(itimer);
    if hor_log_level>-1
        disp(['Task completed in ',num2str(t(1)-t_start),' seconds'])
    end
    if hor_log_level>1
        fprintf(' At the time  %4d/%02d/%02d %02d:%02d:%02d\n',fix(clock));
    end
    initialised=false;
else
    n = varargin{1};
    t = bigtoc(itimer);
    delta_n_ratio = (n/ntot)-n_ratio_prev_msg;
    delta_t = t(1)-t_prev_msg;
    if delta_n_ratio > n_ratio_thresh || delta_t>t_thresh
        if hor_log_level>-1
            disp(['Completed ',num2str((100*n/ntot),'%5.1f'),'% of task in ',num2str(t(1)-t_start),' seconds'])
        end
        t_prev_msg = t(1);
        n_ratio_prev_msg = n/ntot;
    end
end
