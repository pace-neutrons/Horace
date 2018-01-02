function [table,t_av]=refine_moderator_sampling_table_buffer (pulse_model,pp,ei)
% Buffer moderator lookup tables for moderator refinement
%
% Clear buffer:
%   >> refine_moderator_sampling_table_buffer
%
% Return lookup table for the particular set of parameters:
%   >> [table,t_av]=refine_moderator_sampling_table_buffer (pulse_model,pp,ei)
%
% Input:
% ------
%   pulse_model Pulse shape model name
%   pp          Pulse shape model parameters
%   ei          Incident energy (meV)
%
% Output:
% -------
%   table       Lookup table (column vector)
%               Use the look-up table to convert a random number from uniform
%              distribution in the range 0 to 1 into reduced time deviation
%              0 <= t_red <= 1. Convert to true time using the equation
%                   t = t_av * (t_red/(1-t_red))
%   t_av        First moment of time distribution
%              Time here is in seconds (NOT microseconds)
%
%
%  This is a temporary buffer because during refinement the moderator parameters
% will be varied, but for any one iteration of the fit, the same table will be
% used many times.
%  The number of tables stored locally will reach a maximum equal to (n+1), where
% n is the number of moderator parameters being refined ((2n+1) if partial
% derivatives are calculated as (f(p+dp)-f(p-dp))/2*dp).
%  The buffer must be cleared at the end of the fitting.

% Operations
% - clean
% - extract (give pp, see if in table, if yes return values, if not, return empty arrays
% - add (add to stored values; if buffer not big enough, double its size and then add)


persistent ntable pulse_model_store pp_store ei_store t_av_store table_store

% Cleanup if no input arguments and return
% ----------------------------------------
if nargin==0
    ntable=[]; pulse_model_store=[]; pp_store=[]; ei_store=[]; t_av_store=[]; table_store=[];
    return
end

% Retrieve lookup table, or compute and store if not already stored
% -----------------------------------------------------------------
% If there are stored variables, check these first, and return if already stored
if ~isempty(ntable)
    if strcmp(pulse_model,pulse_model_store)    % check pulse model name matches
        % Retrive from stored variables if can
        for i=1:ntable
            if all(pp(:)==pp_store(:,i)) && ei==ei_store(i)
                table=table_store(:,i);
                t_av=t_av_store(i);
                return
            end
        end
    else    % indicate that the store is to be reinitialised
        ntable=[];
    end
end

% Not in the store, so compute
moderator=IX_moderator(0,0,pulse_model,pp);
[table,t_av]=sampling_table(moderator,ei,'fast');
t_av=1e-6*t_av;     % convert to seconds

% Make sure the store is big enough to hold the new table
if isempty(ntable)  % need to create stored variables before filling them
    ntable_max_0=2;% default size of lookup table
    % Initialise stored variables
    ntable=0;
    pulse_model_store=pulse_model;
    pp_store=zeros(numel(pp),ntable_max_0);
    ei_store=zeros(1,ntable_max_0);
    t_av_store=zeros(1,ntable_max_0);
    table_store=zeros(numel(table),ntable_max_0);
else                % double the size of the store if already full
    if ntable==numel(t_av_store)
        disp(['Doubling size of moderator refinement store (currently full with ',num2str(ntable),' entries'])
        pp_store=[pp_store,zeros(size(pp_store))];
        ei_store=[ei_store,zeros(size(ei_store))];
        t_av_store=[t_av_store,zeros(size(t_av_store))];
        table_store=[table_store,zeros(size(table_store))];
    end
end

% Update the store
ntable=ntable+1;
pp_store(:,ntable)=pp(:);
ei_store(ntable)=ei;
t_av_store(ntable)=t_av;
table_store(:,ntable)=table;
end
