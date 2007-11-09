function mess_completion (varargin)
% Prints a message detailing level of completion if elapsed time exceeds a certain
% threshold since the previous message, or if change in the fraction of completion
% exceeds another threshold.
%
%   >> mess_completion (ntot, time_ref, completion_ref)  % to initialise
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

% T.G.Perring   29/06/2007

persistent  initialised ntot t_thresh n_ratio_thresh t_start t_prev_msg n_ratio_prev_msg

% Initialise
if nargin==3
    initialised = true;
    ntot = varargin{1};
    t_thresh = varargin{2};
    n_ratio_thresh = varargin{3};
    try % Only want to call 'tic' if we have to, to minimise influence in other code
        t_start = toc;
    catch
        tic
        t_start = toc;
    end
    t_prev_msg = t_start;
    n_ratio_prev_msg = 0;
    return
end

% If no previous initialisation, print warning message
if ~exist('initialised','var')
    disp ('Completion monitoring with mess_completion requires initialisation first')
    return
end

if nargin==0  % task completed
    disp(['Task completed in ',num2str(toc-t_start),' seconds'])
else
    n=varargin{1};
    delta_n_ratio = (n/ntot)-n_ratio_prev_msg;
    delta_t = toc-t_prev_msg;
    if delta_n_ratio > n_ratio_thresh || delta_t>t_thresh
        disp(['Completed ',num2str((100*n/ntot),'%5.1f'),'% of task in ',num2str(toc-t_start),' seconds'])
        t_prev_msg = toc;
        n_ratio_prev_msg = n/ntot;
    end
end
