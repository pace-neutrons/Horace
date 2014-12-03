function run_label = run_label_init (varargin)
% Create run_label structure
%
%   >> run_label = run_label_init           % dummy e.g. for return after an error
%   >> run_label = run_label_init (nspe, nsqw)    % nochange
%   >> run_label = run_label_init (nspe)        % nochange
%   >> run_label = run_label_init (ix)
%
%
% Output:
% -------
%   run_label   Structure that defines how run indicies in the sqw data must be
%              renumbered. Arrays ix and ixarr are filled for all cases; For the
%              simple but frequent cases of nochange or simple offset
%              that information is stored too.
%           run_label.ix        Cell array with length equal to the number of data sources,
%                              each entry being a column vector of the new labels for the
%                              corresponding run in the output sqw data. That is, ix{i}(j)
%                              is the new run number for the jth run of the ith sqw file.
%           run_label.ixarr     Alternative representation of the same information: an
%                              array with size [<max_number_runs_in_a_header_block>,
%                              <number_of_header_blocks>] so that each column contains the
%                              new labels for the corresponding run in the output sqw data.
%                              That is, ix(i,j) is the index of the entry in header_out
%                              corresponding to the ith run of the jth input sqw file.
%           run_label.nochange  true if the run indicies in all header blocks are
%                              to be left unchanged [this happens when combining
%                              sqw data from cuts taken from the same master sqw file]
%           run_label.offset    If not empty, then contains column vector length equal to
%                              the number of input header blocks with offsets to add
%                              to the corresponding runs [this happens typically when
%                              using gen_sqw or accumulate_sqw, as every sqw file
%                              corresponds to a different spe file]


% Original author: T.G.Perring
%
% $Revision: 909 $ ($Date: 2014-09-12 18:20:05 +0100 (Fri, 12 Sep 2014) $)


if nargin==0
    % Create default output e.g. for when returning run_label when an error occured
    % -----------------------------------------------------------------------------
    run_label=struct('ix',{{}},'ixarr',[],'nochange',false,'offset',[]);
    
elseif nargin==2 && isnumeric(varargin{1}) && isnumeric(varargin{2})
    % Case of a single set of runs that is the same for all sqw datasets
    % ------------------------------------------------------------------
    nspe=varargin{1};       % the number of spe files
    nsqw=varargin{2};       % the number of sqw data sets
    if ~(isscalar(nspe) && isscalar(nsqw))
        error('Check ''nspe'' and ''nsqw'' are both scalar')
    end
    ix=repmat({(1:nspe)'},nsqw,1);      % allow for case where nsqw==1 because all header were the same
    ixarr=repmat((1:nspe)',1,nsqw);
    run_label=struct('ix',{ix},'ixarr',ixarr,'nochange',true,'offset',0);
    
elseif nargin==1 && isnumeric(varargin{1})
    % All sqw data have different runs
    % --------------------------------
    nspe=varargin{1}(:);    % array of the number of spe files in each sqw data sets
    if isempty(nspe)
        error('Check ''nspe'' is a non-empty array')
    end
    if numel(nspe)>1
        ix=mat2cell((1:sum(nspe))',nspe);
        ixarr=zeros(max(nspe),numel(nspe));
        for i=1:numel(nspe)
            ixarr(1:nspe(i),i)=ix{i};
        end
        offset=cumsum([0;nspe(1:end-1)]);
        run_label=struct('ix',{ix},'ixarr',ixarr,'nochange',false,'offset',offset);
    else
        ix={(1:nspe)'};
        ixarr=(1:nspe)';
        run_label=struct('ix',{ix},'ixarr',ixarr,'nochange',true,'offset',0);
    end
    
elseif nargin==1 && iscell(varargin{1})
    % General case
    % ------------
    ix=varargin{1}(:);
    nspe=zeros(numel(ix),1);
    for i=1:numel(ix)
        if isnumeric(ix{i}) && ~isempty(ix{i})
            nspe(i)=numel(ix{i});
        else
            error(['Check element ',num2str(i),' of ''ix'' is a non-empty array'])
        end
    end
    ixarr=zeros(max(nspe),numel(nspe));
    isoffset=true;
    offset=zeros(numel(nspe),1);
    for i=1:numel(nspe)
        ixarr(1:nspe(i),i)=ix{i};
        if isoffset
            if all(diff(ix{i}))
                offset(i)=ix{i}(1)-1;
            else
                isoffset=false;
            end
        end
    end
    if isoffset
        if all(offset==0)
            nochange=true;
        else
            nochange=false;
        end
        run_label=struct('ix',{ix},'ixarr',ixarr,'nochange',nochange,'offset',offset);
    else
        run_label=struct('ix',{ix},'ixarr',ixarr,'nochange',false,'offset',[]);
    end
    
end
