function transf_list=combine_equiv_basic(data_source,proj,pos,step,erange,outfile,varargin)
%
% Sub-function of combine_equivalent_zones
%
% RAE 30/3/2010
%

%All of the inputs have been checked by this stage, so we do not need to do
%that again.

%We are combining all equivalent wavevectors, so all we need to do here is
%work out what are the equivalent zones, package them up in a cell array
%and then pass them to combine_equiv_list

%Must loop through all possible permutations of pos, and then discard
%repetitions:

%Initialise zonelist as a matrix to begin with. Turn it into a cell array
%later:
h=pos(1); k=pos(2); l=pos(3);
zonelist=zeros(48,3);
for i=1:6
    [hnew,knew,lnew]=permute_indices(h,k,l,i);
    neglist=make_neg_indices(hnew,knew,lnew);
    zonelist([(1+8*(i-1)):(8+8*(i-1))],:)=neglist;
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

lookuptab=cell(1,6);
lookuptab{1}=[h,k,l];
lookuptab{2}=[h,l,k];
lookuptab{3}=[k,h,l];
lookuptab{4}=[k,l,h];
lookuptab{5}=[l,h,k];
lookuptab{6}=[l,k,h];
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

