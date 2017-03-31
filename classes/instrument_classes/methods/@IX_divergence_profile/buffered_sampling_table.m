function [table,ind]=buffered_sampling_table(div_in,varargin)
% Return lookup table for array of divergence profile objects
%
%   >> [table,ind] = buffered_sampling_table (div)
%   >> [table,ind] = buffered_sampling_table (div, npnt)
%   >> [table,ind] = buffered_sampling_table (...,opt1,opt2,...)
%
% Input:
% ------
%   div       Array of IX_divergence_profile objects (need not be unique)
%
%   npnt        Number of sampling points for the table. Uses default if not given.
%              The default is that in the lookup table if it is read, otherwise it is
%              the default in the lookup table method.
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
%   table       Lookup table of unique chopper entries, size=[npnt,nchop]
%              where npnt=number of points in lookup table, nchop=number of
%              unique chopper entries. Use the look-up table to convert a
%              random number from uniform distribution in the range 0 to 1
%              into a time deviation in microseconds.
%   ind         Index into the lookup table: ind(i) is the column for div(i)
%              ind is a row vector.
%
% Note:
% - If the number of chopper objects is less than a critical value, they
%   will be computed rather checked to see if they are in the stored table
%   in order to save the overheads of checking.
% - The size of the lookup table is restricted to a certain maximum size.
%   Earlier entries will be deleted if new ones have to be added. THe lookup
%   table will always have the length of the number of unique entries in the
%   most recent call, as it is assumed that this is the mostlikely next occasion
%   the function will be called for again.


nd_crit=1;      % if number of choppers is less than or equal to this, simply compute
nd_max=1000;    % Maximum number of chopper lookup tables that can be stored on disk
filename=fullfile(tempdir,'IX_divergence_profile_store.mat');

[div,~,ind]=unique(div_in);
div=div(:);     % ensure column vector
ind=ind(:)';    % ensure row vector
nd=numel(div);

% Parse optional arguments
check_store_def=(nd>nd_crit);   % default value of check_store

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
    [ok,mess,div0,table0]=read_store(filename);   % if file does not exist, then ok=true but div0 is empty
    if ok && ~isempty(div0) && (isempty(npnt)||npnt==size(table0,1))
        % Look for entries in the lookup table
        [ix,iv]=array_filter(div,div0);
        npnt0=size(table0,1);
        if numel(ix)==0         % no stored entries for the input choppers
            table=fill_table(div,npnt0,fast{:});
            [ok,mess]=write_store(filename,div,table,div0,table0,nd_max);
            if ~ok, warning(mess), end
        elseif numel(ix)==nd    % all entries previously stored
            table=table0(:,iv);
        else
            new=true(nd,1); new(ix)=false;
            table_new=fill_table(div(new),npnt0,fast{:});
            table=zeros(npnt0,nd);
            table(:,new)=table_new;
            table(:,ix)=table0(:,iv);
            [ok,mess]=write_store(filename,div(new),table_new,div0,table0,nd_max);
            if ~ok, warning(mess), end
        end
    else
        % Problem reading the store, or it doesn't exist, or the number of points is different. Create with new values if can.
        if ~ok, warning(mess), end
        table=fill_table(div,npnt,fast{:});
        [ok,mess]=write_store(filename,div,table);
        if ~ok, warning(mess), end
    end
else
    table=fill_table(div,npnt,fast{:});
end


%==================================================================================================
function table=fill_table(div,npnt,varargin)
nf=numel(div);
if isempty(npnt)
    table=sampling_table(div(1),varargin{:});   % column vector
    if nf>1
        table=repmat(table,[1,nf]);
        npnt_def=size(table,1);
        for i=2:nf
            table(:,i)=sampling_table(div(i),npnt_def,varargin{:});
        end
    end
else
    table=zeros(npnt,nf);
    for i=1:nf
        table(:,i)=sampling_table(div(i),npnt,varargin{:});
    end
end

%==================================================================================================
function [ok,mess,div_store,table_store]=read_store(filename)
% Read stored divergence profile lookup table
% ok=true if file does not exist

if exist(filename,'file')
    disp('Reading stored divergence profile lookup table...')
    try
        load(filename,'-mat');
        ok=true;
        mess='';
    catch
        ok=false;
        mess='Unable to read divergence profile lookup table file';
        div_store=[];
        table_store=[];
    end
else
    ok=true;
    mess='';
    div_store=[];
    table_store=[];
end


%--------------------------------------------------------------------------------------------------
function [ok,mess]=write_store(filename,div,table,div0,table0,nd_max)
% Write divergence profile lookup table up to a maximum number of entries
% Always write the first entry; then add as many of the second as possible

if nargin==3
    div_store=div;
    table_store=table;
else
    nd=size(div,1);
    nd0=size(div0,1);
    if nd>=nd_max
        div_store=div; table_store=table;
    elseif nd0>nd_max-nd
        div_store=[div;div0(1:nd_max-nd)]; table_store=[table,table0(:,1:nd_max-nd)];
    else
        div_store=[div;div0]; table_store=[table,table0];
    end
end

try
    disp('Writing divergence profile lookup table to file store...')
    save(filename,'div_store','table_store','-mat')
    ok=true;
    mess='';
catch
    ok=false;
    mess='Error writing divergence profile lookup table file';
end


%--------------------------------------------------------------------------------------------------
function [ok,mess]=delete_store(filename)
% Read stored divergence profile lookup table

if exist(filename,'file')
    try
        disp('Deleting divergence profile chopper lookup table...')
        delete(filename)
        ok=true;
        mess='';
    catch
        ok=false;
        mess='Unable to delete divergence profile lookup table file';
    end
else
    ok=true;
    mess='';
end
