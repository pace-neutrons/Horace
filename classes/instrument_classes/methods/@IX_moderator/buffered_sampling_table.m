function [table,t_av,ind,fwhh,profile]=buffered_sampling_table(moderator_in,ei_in,varargin)
% Return lookup table for array of moderator objects
%
%   >> [table,t_av,ind,fwhh,profile] = buffered_sampling_table (moderator, ei)
%   >> [table,t_av,ind,fwhh,profile] = buffered_sampling_table (moderator, ei, npnt)
%   >> [table,t_av,ind,fwhh,profile] = buffered_sampling_table (...,opt1,opt2,...)
%
% Input:
% ------
%   moderator   Array of IX_moderator objects (need not be unique)
%
%   ei          Array of corresponding incident energies
%
%   npnt        Number of sampling points for the table. Uses default if not given.
%              The default is that in the lookup table if it is read, otherwise it is
%              the default in the lookup table method.
%               If the number is different to that in the stored lookup table,
%              if read, the stored lookup table will be purged.
%
%   opt1,...    Options:
%                   'fast'      Use fast algorithm for computing lookup tables
%                              Not quite as accurate as the default
%
%                   'purge'     Clear file buffer prior to writing new entries
%                              (will be deleted even if no new entry will be written)
%
%                   'nocheck'   Do not check to see if the stored lookup table
%                              holds the data, regardless of the default threshold
%                              for the number of moderator entries for checking
%                              the file is exceeded. Any stored lookup will not be
%                              added to.
%
%                   'check'     Force a check, even if the default threshold
%                              is not exceeded. If additional lookup entries
%                              have to be created, they will be added to the
%                              stored lookup.
%
%
% Output:
% -------
%   table       Lookup table of unique moderator entries, size=[npnt,nmod]
%              where npnt=number of points in lookup table, nmod=number of
%              unique moderator entries. Elements are time in reduced units.
%              Use the look-up table to convert a random number from uniform
%              distribution in the range 0 to 1 into reduced time deviation
%              0 <= t_red <= 1. Convert to true time using the equation
%              t = t_av * (t_red/(1-t_red))
%
%   t_av        First moment of time, size=[1,nmod] (microseconds)
%
%   ind         Index into the lookup table: ind(i) is the column for moderator(i)
%              ind is a row vector.
%
%   fwhh        Full width half height, size=[1,nmod] (microseconds)
%
%   profile     Lookup table of profile, normalised to peak height=1, for
%              equally spaced intervals of t_red in the range 0 =< t_red =< 1
%
% Note:
% - If the number of moderator objects is less than a critical value, they
%   will be computed rather checked to see if they are in the stored table
%   in order to save the overheads of checking.
% - The size of the lookup table is restricted to a certain maximum size.
%   Earlier entries will be deleted if new ones have to be added. THe lookup
%   table will always have the length of the number of unique entries in the
%   most recent call, as it is assumed that this is the mostlikely next occasion
%   the function will be called for again.


nm_crit=1;      % if number of moderators is less than or equal to this, simply compute
nm_max=1000;    % Maximum number of moderator lookup tables that can be stored on disk
filename=fullfile(tempdir,'IX_moderator_store.mat');

% Get list of moderators whose pulse width depends on ei
nm=numel(moderator_in);
if numel(ei_in)~=nm
    error('Number of moderators and number of incident energies must match')
end
status=false(size(moderator_in));
for i=1:nm
    status(i)=pulse_depends_on_ei(moderator_in(i));
end
ei_tmp=ei_in;
ei_tmp(~status)=0;  % set ei=0 for those moderators whose pulse shape does not depend on ei

% Get list of unique moderators
[moderator,ei,~,ind]=unique_mod_ei(moderator_in,ei_tmp);
moderator=moderator(:); % ensure column vector
ei=ei(:);               % ensure column vector
ind=ind(:)';            % ensure row vector
nm=numel(moderator);

% Parse optional arguments
check_store_def=(nm>nm_crit);   % default value of check_store

arglist=struct('fast',0,'purge',0,'check',check_store_def);
flags={'fast','purge','check'};
[par,opt] = parse_arguments(varargin,arglist,flags);

if numel(par)==1
    npnt=par{1};
elseif numel(par)==0
    npnt=[];    % signifies use default
else
    error('Check number of arguments')
end

if opt.purge
    [ok,mess]=delete_store(filename);
    if ~ok, warning(mess), end
end

check_store=opt.check;

if opt.fast
    fast={'fast'};
else
    fast={};
end


% Fill lookup table, creating or adding entries for the stored lookup file
if check_store
    [ok,mess,moderator0,ei0,table0,t_av0,fwhh0,profile0]=read_store(filename);   % if file does not exist, then ok=true but moderator0 is empty
    if ok && ~isempty(moderator0) && (isempty(npnt)||npnt==size(table0,1))
        % Look for entries in the lookup table
        [ix,iv]=array_filter_mod_ei(moderator,ei,moderator0,ei0);
        npnt0=size(table0,1);
        npro0=size(profile0,1);
        if numel(ix)==0         % no stored entries for the input moderators
            [table,t_av,fwhh,profile]=fill_table(moderator,ei,npnt0,fast{:});
            [ok,mess]=write_store(filename,moderator,ei,table,t_av,fwhh,profile,...
                moderator0,ei0,table0,t_av0,fwhh0,profile0,nm_max);
            if ~ok, warning(mess), end
        elseif numel(ix)==nm    % all entries previously stored
            table=table0(:,iv);
            t_av=t_av0(iv);
            fwhh=fwhh0(iv);
            profile=profile0(iv);
        else
            new=true(nm,1); new(ix)=false;
            [table_new,t_av_new,fwhh_new,profile_new]=fill_table(moderator(new),ei(new),npnt0,fast{:});
            table=zeros(npnt0,nm);
            table(:,new)=table_new;
            table(:,ix)=table0(:,iv);
            t_av=zeros(1,nm);
            t_av(new)=t_av_new;
            t_av(ix)=t_av0(iv);
            fwhh=zeros(1,nm);
            fwhh(new)=fwhh_new;
            fwhh(ix)=fwhh0(iv);
            profile=zeros(npro0,nm);
            profile(:,new)=profile_new;
            profile(:,ix)=profile0(:,iv);
            [ok,mess]=write_store(filename,moderator(new),ei(new),table_new,t_av_new,fwhh_new,profile_new,...
                moderator0,ei0,table0,t_av0,fwhh0,profile0,nm_max);
            if ~ok, warning(mess), end
        end
    else
        % Problem reading the store, or it doesn't exist, or the number of points is different. Create with new values if can.
        if ~ok, warning(mess), end
        [table,t_av,fwhh,profile]=fill_table(moderator,ei,npnt,fast{:});
        [ok,mess]=write_store(filename,moderator,ei,table,t_av,fwhh,profile);
        if ~ok, warning(mess), end
    end
else
    [table,t_av,fwhh,profile]=fill_table(moderator,ei,npnt,fast{:});
end


%==================================================================================================
function [moderator_sort,ei_sort,m,n]=unique_mod_ei(moderator, ei, varargin)
% Joint sorting of moderator and incident energy as if they were one object

S=catstruct(struct_special(moderator(:)),struct('ei',num2cell(ei(:))));
[~,m,n] = uniqueStruct(S,varargin{:});
moderator_sort=moderator(m);
ei_sort=ei(m);


%--------------------------------------------------------------------------------------------------
function [ind,indv]=array_filter_mod_ei(moderator,ei,moderator0,ei0,varargin)
% Bespoke version of array_filter treating moderator and incident energy as if they were one object

S =catstruct(struct_special(moderator(:)) ,struct('ei',num2cell(ei(:))));
S0=catstruct(struct_special(moderator0(:)),struct('ei',num2cell(ei0(:))));
[ind,indv]=array_filter(S,S0,varargin{:});


%==================================================================================================
function [table,t_av,fwhh,profile]=fill_table(moderator,ei,npnt,varargin)
nm=numel(moderator);
t_av=zeros(1,nm);
fwhh=zeros(1,nm);
if isempty(npnt)
    [table,t_av(1),fwhh(1),profile]=sampling_table(moderator(1),ei(1),varargin{:});   % column vector
    npnt=size(table,1);
else
    [table,t_av(1),fwhh(1),profile]=sampling_table(moderator(1),ei(1),npnt,varargin{:});   % column vector
end
if nm>1
    table=repmat(table,[1,nm]);
    profile=repmat(profile,[1,nm]);
    for i=2:nm
        [table(:,i),t_av(i),fwhh(i),profile(:,i)]=sampling_table(moderator(i),ei(i),npnt,varargin{:});
    end
end

% %==================================================================================================
% % Version of fill_table prior to 21/2/17:
%
% function [table,t_av,fwhh,profile]=fill_table(moderator,ei,npnt,varargin)
% nm=numel(moderator);
% t_av=zeros(1,nm);
% fwhh=zeros(1,nm);
% if isempty(npnt)
%     [table,t_av(1)]=sampling_table(moderator(1),ei(1),varargin{:});   % column vector
%     [~,~,fwhh(1)]=pulse_width(moderator(1),ei(1));
%     npnt_def=size(table,1);
%     % For profile:
%     npro=5*npnt_def;
%     profile=zeros(npro,nm);
%     t_red=[0;(1:npro-2)'/(npro-1)];     % omit last point; assume pulse height zero at t_red=1
%     profile(1:end-1,1)=pulse_shape(moderator(1),ei(1),t_av(1)*(t_red./(1-t_red)));
%     if nm>1
%         table=repmat(table,[1,nm]);
%         for i=2:nm
%             [table(:,i),t_av(i)]=sampling_table(moderator(i),ei(i),npnt_def,varargin{:});
%             [~,~,fwhh(i)]=pulse_width(moderator(i),ei(i));
%             profile(1:end-1,i)=pulse_shape(moderator(i),ei(i),t_av(i)*(t_red./(1-t_red)));
%         end
%     end
% else
%     table=zeros(npnt,nm);
%     % For profile:
%     npro=5*npnt;
%     profile=zeros(npro,nm);
%     t_red=[0;(1:npro-2)'/(npro-1)];     % omit last point; assume pulse height zero at t_red=1
%     for i=1:nm
%         [table(:,i),t_av(i)]=sampling_table(moderator(i),ei(i),npnt,varargin{:});
%         [~,~,fwhh(i)]=pulse_width(moderator(i),ei(i));
%         profile(1:end-1,i)=pulse_shape(moderator(i),ei(i),t_av(i)*(t_red./(1-t_red)));
%     end
% end
% % Normalise profiles to unit height at peak
% profile=profile./repmat(max(profile,[],1),npro,1);

%==================================================================================================
function [ok,mess,moderator_store,ei_store,table_store,t_av_store,fwhh_store,profile_store]=...
    read_store(filename)
% Read stored moderator lookup table
% ok=true if file does not exist

if exist(filename,'file')
    disp('Reading stored moderator lookup table...')
    try
        load(filename,'-mat');
        ok=true;
        mess='';
    catch
        ok=false;
        mess='Unable to read moderator lookup table file';
        moderator_store=[];
        ei_store=[];
        table_store=[];
        t_av_store=[];
        fwhh_store=[];
        profile_store=[];
    end
    % Check fields
    if ~exist('ei_store','var') || ~exist('table_store','var') ||...
            ~exist('t_av_store','var') ||  ~exist('fwhh_store','var') ||...
            ~exist('profile_store','var')
        mess='Moderator lookup table file has old format - being ignored';
        moderator_store=[];
        ei_store=[];
        table_store=[];
        t_av_store=[];
        fwhh_store=[];
        profile_store=[];
    end
else
    ok=true;
    mess='';
    moderator_store=[];
    ei_store=[];
    table_store=[];
    t_av_store=[];
    fwhh_store=[];
    profile_store=[];
end


%--------------------------------------------------------------------------------------------------
function [ok,mess]=write_store(filename,moderator,ei,table,t_av,fwhh,profile,...
    moderator0,ei0,table0,t_av0,fwhh0,profile0,nf_max)
% Write moderator lookup table up to a maximum number of entries
% Always write the first entry; then add as many of the second as possible

if nargin==6
    moderator_store=moderator;
    ei_store=ei;
    table_store=table;
    t_av_store=t_av;
    fwhh_store=fwhh;
    profile_store=profile;
else
    nf=size(moderator,1);
    nf0=size(moderator0,1);
    if nf>=nf_max
        moderator_store=moderator;
        ei_store=ei;
        table_store=table;
        t_av_store=t_av;
        fwhh_store=fwhh;
        profile_store=profile;
    elseif nf0>nf_max-nf
        moderator_store=[moderator;moderator0(1:nf_max-nf)];
        ei_store=[ei;ei0(1:nf_max-nf)];
        table_store=[table,table0(:,1:nf_max-nf)];
        t_av_store=[t_av,t_av0(1:nf_max-nf)];
        fwhh_store=[fwhh,fwhh0(1:nf_max-nf)];
        profile_store=[profile,profile0(1:nf_max-nf)];
    else
        moderator_store=[moderator;moderator0];
        ei_store=[ei;ei0];
        table_store=[table,table0];
        t_av_store=[t_av,t_av0];
        fwhh_store=[fwhh,fwhh0];
        profile_store=[profile,profile0];
    end
end

try
    disp('Writing moderator lookup table to file store...')
    save(filename,'moderator_store','ei_store','table_store',...
        't_av_store','fwhh_store','profile_store','-mat')
    ok=true;
    mess='';
catch
    ok=false;
    mess='Error writing moderator lookup table file';
end


%--------------------------------------------------------------------------------------------------
function [ok,mess]=delete_store(filename)
% Read stored moderator lookup table

if exist(filename,'file')
    try
        disp('Deleting stored moderator lookup table...')
        delete(filename)
        ok=true;
        mess='';
    catch
        ok=false;
        mess='Unable to delete moderator lookup table file';
    end
else
    ok=true;
    mess='';
end
