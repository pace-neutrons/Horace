function transf_list=combine_equiv_keyword(data_source,proj,pos,step,erange,outfile,keyword,varargin)
%
% Sub-function of combine_equivalent_zones. A keyword has been supplied to
% combine_equivalent_zones. Options are
% -cyclic : cyclic permutations, with no sign changes of h,k,l
% -cycwithneg : cyclic permutations with +ve and -ve h,k,l
% -ab : all equivalent zones in ab plane
% -ac : --------"----------- in ac plane
% -bc : --------"----------- in bc plane
%
% RAE 30/3/2010


%All of the inputs have been checked by this stage, so we do not need to do
%that again.

%We are combining equivalent wavevectors, depending on the keyword chosen,
%package them up in a cell array and then pass them to combine_equiv_list

%Must loop through all required permutations of pos, and then discard
%repetitions:

%Initialise zonelist as a matrix to begin with. Turn it into a cell array
%later:
h=pos(1); k=pos(2); l=pos(3);
if strcmp(keyword,'-cycwithneg')
    zonelist=zeros(24,3);%notice that the maximum multiplicity for cyclic permutations is 24
    for i=1:3
        [hnew,knew,lnew]=permute_indices(h,k,l,i);
        neglist=make_neg_indices(hnew,knew,lnew);
        zonelist([(1+8*(i-1)):(8+8*(i-1))],:)=neglist;
    end
elseif strcmp(keyword,'-cyclic')
    zonelist=zeros(3,3);%notice that the maximum multiplicity for cyclic without -ve numbers is 3
    for i=1:3
        [hnew,knew,lnew]=permute_indices(h,k,l,i);
        zonelist(i,:)=[hnew,knew,lnew];
    end
elseif strcmp(keyword,'-ab')
    neglist=make_neg_indices(h,k,l);
    thelist=neglist([1:3 5],:);
    zonelist=thelist;
    neglist=make_neg_indices(k,h,l);
    thelist=neglist([1:3 5],:);
    zonelist=[zonelist; thelist];
elseif strcmp(keyword,'-ac')
    neglist=make_neg_indices(h,k,l);
    thelist=neglist([1 2 4 6],:);
    zonelist=thelist;
    neglist=make_neg_indices(l,k,h);
    thelist=neglist([1 2 4 6],:);
    zonelist=[zonelist; thelist];
elseif strcmp(keyword,'-bc')
    neglist=make_neg_indices(h,k,l);
    thelist=neglist([1 3 4 7],:);
    zonelist=thelist;
    neglist=make_neg_indices(h,l,k);
    thelist=neglist([1 3 4 7],:);
    zonelist=[zonelist; thelist];
end

zonelist=unique(zonelist,'rows');%this removes rows that are repeated.
sz=size(zonelist);
zonelist=mat2cell(zonelist,ones(1,sz(1)),3);%conver to cell array of correct format
%i.e. where each element is a 1-by-3 vector
%
%Now pass on to the master function:
transf_list=combine_cuts_list(data_source,proj,pos,step,erange,outfile,zonelist,varargin{:});

%==========================================================================
function [hnew,knew,lnew]=permute_indices(h,k,l,ind)
%
% Lookup table for permutations of h,k,l
%

lookuptab=cell(1,3);
lookuptab{1}=[h,k,l];
lookuptab{2}=[k,l,h];
lookuptab{3}=[l,h,k];
t=lookuptab{ind};
hnew=t(1); knew=t(2); lnew=t(3);

%==========================================================================
function neglist=make_neg_indices(h,k,l)
%
% For a given h,k,l generate the 8 possible variations of making one or
% more axes negative:

neglist=zeros(8,3);
neglist(1,:)=[h,k,l];
neglist(2,:)=[-h,k,l];
neglist(3,:)=[h,-k,l];
neglist(4,:)=[h,k,-l];
neglist(5,:)=[-h,-k,l];
neglist(6,:)=[-h,k,-l];
neglist(7,:)=[h,-k,-l];
neglist(8,:)=[-h,-k,-l];
