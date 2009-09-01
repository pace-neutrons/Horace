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
%   ntot            Total length of task (could be total number of iterations)
%   t_thresh        Message printed if time since last print exceeds this threshold
%   n_ratio_thresh  Message printed if change in ratio n/ntot exceeds this threshold
%
% Input on subsequent calls:
%   n               Current position in completion of task (could be interation number)

% Original author: T.G.Perring
%
% $Revision: 101 $ ($Date: 2007-01-25 09:10:34 +0000 (Thu, 25 Jan 2007) $)

persistent  initialised itimer ntot t_thresh n_ratio_thresh t_start t_prev_msg n_ratio_prev_msg

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
    return
end

% If no previous initialisation, print warning message
if isempty(initialised)||~initialised
    disp ('Completion monitoring with mess_completion requires initialisation first')
    return
end

if nargin==0  % task completed
    t = bigtoc(itimer);
    disp(['Task completed in ',num2str(t(1)-t_start),' seconds'])
    initialised=false;
else
    n = varargin{1};
    t = bigtoc(itimer);
    delta_n_ratio = (n/ntot)-n_ratio_prev_msg;
    delta_t = t(1)-t_prev_msg;
    if delta_n_ratio > n_ratio_thresh || delta_t>t_thresh
        disp(['Completed ',num2str((100*n/ntot),'%5.1f'),'% of task in ',num2str(t(1)-t_start),' seconds'])
        t_prev_msg = t(1);
        n_ratio_prev_msg = n/ntot;
    end
end
