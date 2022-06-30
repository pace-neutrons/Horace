function test_parsing_1(nloop)
% Test the equivalence and relative speed of parse_arguments, parse_args_simple and parse_keywords
%
%   >> timing_parse_functions           % Default 500 loops
%   >> timing_parse_functions(nloop)
%
% Author: T.G.Perring

banner_to_screen(mfilename)

if nargin==0
    nloop=500;  % default value
end

% General parse_keywords test (extract from removed test_parsing_2)
[ok,mess,ind,val]=parse_keywords({'moo','hel','hello'},'hel',14);
assertTrue(ok,['Problem with parse_keywords: ',mess]);
assertEqual(ind,2)
assertEqual(val{1},14)


inpars={[13,14],'hello','missus',true};
argname={'name','newplot','type'};
argvals={[11,12,13,14],'zoot',rand(4,3),true,false,'suit'};
arglist = struct('name','',...
                 'newplot',true,...
                 'type','d');
             
% Fill array of arguments to test parsing functions
disp('Creating some test input arguments...')
argcell=cell(1,nloop);             
argcell_key=cell(1,nloop);             
for i=1:nloop
    indpar=logical(round(rand(size(inpars))));
    indarg=logical(round(rand(size(argname))));
    indval=round(0.501+5.990*rand(1,sum(indarg)));
    args=[argname(indarg);argvals(indval)];
    argcell{i}=[inpars(indpar),args(:)'];
    argcell_key{i}=args(:)';
end
disp(' ')



% Test relative speed of parse_arguments, parse_args_simple and parse_keywords
disp('Parse_arguments')
tic
n=0;
for i=1:nloop
    [par,keyword,present] = parse_arguments(argcell{i},arglist);
    n=n+numel(par)+numel(keyword)+numel(present);
end
n_parse_arguments=n;
t=toc;
disp(['     Time per function call (microseconds): ',num2str(1e6*t/nloop)]);
disp(' ')


disp('Parse_keywords')
tic
n=0;
for i=1:nloop
    [ok,mess,ind,val] = parse_keywords(argname,argcell_key{i}{:});
    if ~ok, assertTrue(false,mess), end
    n=n+sum(ind)+numel(val);
end
if n==n_parse_arguments
    disp('Whoopee! (a message to prevent clever optimization by Matlab)')
end

t=toc;
disp(['     Time per function call (microseconds): ',num2str(1e6*t/nloop)]);
disp(' ')

% Success announcement
% --------------------
banner_to_screen([mfilename,': Test(s) passed'],'bot')
