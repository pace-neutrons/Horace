function [table,ind]=buffered_sampling_table(fermi_in,varargin)
% Return lookup table for array of Fermi chopper objects
%
%   >> table = buffered_sampling_table (fermi)
%   >> table = buffered_sampling_table (fermi, npnt)
%   >> table = buffered_sampling_table (...,opt)
%
% Input:
% ------
%   fermi       Array of IX_fermi_chopper objects (need not be unique)
%
%   npnt        Number of sampling points for the table. Uses default if not given.
%              The default is that in the lookup table if it is read, otherwise it is
%              the default in the lookup table method.
%               If the number is different to that in the stored lookup table,
%              if read, the stored lookup table will be purged.
%
%   opt         Option:
%                   'purge'     Clear file buffer prior to writing new entries
%                              (will be deleted even if no new entry will be written)
%
%                   'nocheck'   Do not check to see if the stored lookup table
%                              holds the data, regardless of the default threshold
%                              for the number of chopper entries for checking
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
%              unique chopper entries.
%   ind         Index into the lookup table: ind(i) is the column for fermi(i)
%              ind is a column vector.
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


nf_crit=1;  % if number of choppers is less than or equal to this, simply compute
nf_max=1000;
filename=fullfile(tempdir,'IX_fermi_chopper_store.mat');

[fermi,im,ind]=unique(fermi_in);
fermi=fermi(:);     % ensure column vector
ind=ind(:);         % ensure column vector
nf=numel(fermi);
if nf<=nf_crit
    check_store=false;
else
    check_store=true;
end

% Strip off option
if nargin>1 && ischar(varargin{end})
    opt=varargin{end};
    if strcmpi(opt,'purge')
        [ok,mess]=delete_store(filename);
        if ~ok, warning(mess), end
    elseif strcmpi(opt,'check')
        check_store=true;
    elseif strcmpi(opt,'nocheck')
        check_store=false;
    else
        error('Unrecognised options')
    end
    narg=numel(varargin)-1;
else
    narg=numel(varargin);
end

% Check if number of points is given
if narg==1
    npnt=varargin{1};
else
    npnt=[];    % signifies use default
end

% Fill lookup table, creating or adding entries for the stored lookup file
if check_store
    [ok,mess,fermi0,table0]=read_store(filename);   % if file does not exist, then ok=true but fermi0 is empty
    if ok && ~isempty(fermi0) && (isempty(npnt)||npnt==size(table0,1))
        % Look for entries in the lookup table
        [ix,iv]=array_filter(fermi,fermi0);
        npnt0=size(table0,1);
        if numel(ix)==0         % no stored entries for the input choppers
            table=fill_table(fermi,npnt0);
            [ok,mess]=write_store(filename,fermi,table,fermi0,table0,nf_max);
            if ~ok, warning(mess), end
        elseif numel(ix)==nf    % all entries previously stored
            table=table0(:,iv);
        else
            new=true(nf,1); new(ix)=false;
            table_new=fill_table(fermi(new),npnt0);
            table=zeros(npnt0,nf);
            table(:,new)=table_new;
            table(:,ix)=table0(:,iv);
            [ok,mess]=write_store(filename,fermi(new),table_new,fermi0,table0,nf_max);
            if ~ok, warning(mess), end
        end
    else
        % Problem reading the store, or it doesn't exist, or the number of points is different. Create with new values if can.
        if ~ok, warning(mess), end
        table=fill_table(fermi,npnt);
        [ok,mess]=write_store(filename,fermi,table);
        if ~ok, warning(mess), end
    end
else
    table=fill_table(fermi,npnt);
end


%==================================================================================================
function table=fill_table(fermi,npnt)
nf=numel(fermi);
if isempty(npnt)
    table=sampling_table(fermi(1))';   % column vector
    if nf>1
        table=repmat(table,[1,nf]);
        npnt_def=size(table,1);
        for i=2:nf
            table(:,i)=sampling_table(fermi(i),npnt_def)';
        end
    end
else
    table=zeros(npnt,nf);
    for i=1:nf
        table(:,i)=sampling_table(fermi(i),npnt)';
    end
end

%==================================================================================================
function [ok,mess,fermi_store,table_store]=read_store(filename)
% Read stored Fermi chopper lookup table
% ok=true if file does not exist

if exist(filename,'file')
    disp('Reading stored Fermi chopper lookup table...')
    try
        load(filename,'-mat');
        ok=true;
        mess='';
    catch
        ok=false;
        mess='Unable to read Fermi chopper lookup table file';
        fermi_store=[];
        table_store=[];
    end
else
    ok=true;
    mess='';
    fermi_store=[];
    table_store=[];
end


%--------------------------------------------------------------------------------------------------
function [ok,mess]=write_store(filename,fermi,table,fermi0,table0,nf_max)
% Write Fermi chopper lookup table up to a maximum number of entries
% Always write the first entry; then add as many of the second as possible

if nargin==3
    fermi_store=fermi;
    table_store=table;
else
    nf=size(fermi,1);
    nf0=size(fermi0,1);
    if nf>=nf_max
        fermi_store=fermi; table_store=table;
    elseif nf0>nf_max-nf
        fermi_store=[fermi;fermi0(1:nf_max-nf)]; table_store=[table,table0(:,1:nf_max-nf)];
    else
        fermi_store=[fermi;fermi0]; table_store=[table,table0];
    end
end

try
    disp('Writing Fermi chopper lookup table to file store...')
    save(filename,'fermi_store','table_store','-mat')
    ok=true;
    mess='';
catch
    ok=false;
    mess='Error writing Fermi chopper lookup table file';
end


%--------------------------------------------------------------------------------------------------
function [ok,mess]=delete_store(filename)
% Read stored Fermi chopper lookup table

if exist(filename,'file')
    try
        disp('Deleting stored Fermi chopper lookup table...')
        delete(filename)
        ok=true;
        mess='';
    catch
        ok=false;
        mess='Unable to delete Fermi chopper lookup table file';
    end
else
    ok=true;
    mess='';
end
