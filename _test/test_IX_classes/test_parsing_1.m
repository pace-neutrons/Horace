function test_parsing_1(nloop)
% Test the equivalence and relative speed of parse_arguments, parse_args_simple and parse_keywords
%
%   >> timing_parse_functions           % Default 500 loops
%   >> timing_parse_functions(nloop)

if nargin==0
    nloop=500;  % default value
end

inpars={[13,14],'hello','missus',true};
argname={'name','newplot','type'};
argvals={[11,12,13,14],'zoot',rand(4,3),true,false,'suit'};
arglist = struct('name','',...
                 'newplot',true,...
                 'type','d');
             
% Fill array of arguments to test parsing functions
disp('Creating some test input arguments...')
argscell=cell(1,nloop);             
argscell_key=cell(1,nloop);             
for i=1:nloop
    indpar=logical(round(rand(size(inpars))));
    indarg=logical(round(rand(size(argname))));
    indval=round(0.501+5.990*rand(1,sum(indarg)));
    args=[argname(indarg);argvals(indval)];
    argcell{i}=[inpars(indpar),args(:)'];
    argcell_key{i}=args(:)';
end
disp(' ')

% Test equivalence of parse_arguments and parse_args_simple
disp('Testing equivalence of parse_arguments and parse_args_simple...')
for i=1:nloop
    [para,keyworda,presenta] = parse_arguments(argcell{i},arglist);
    [parb,keywordb,presentb] = parse_args_simple(argcell{i},arglist);
    if ~isequal(para,parb) || ~isequal(keyworda,keywordb) || ~isequal(presenta,presentb)
        disp('Unequal output argument(s)');
        disp('Input arguments')
        disp('   parameters:')
        disp(argcell{i})
        disp('   arglist:')
        disp(arglist)
        error('Unequal output')
    end
end
disp('parse_arguments and parse_args_simple gave equal output')
disp(' ')
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

disp('Parse_args_simple')
tic
n=0;
for i=1:nloop
    [par,keyword,present] = parse_args_simple(argcell{i},arglist);
    n=n+numel(par)+numel(keyword)+numel(present);
end
n_parse_args_simple=n;
t=toc;
disp(['     Time per function call (microseconds): ',num2str(1e6*t/nloop)]);
disp(' ')
if n_parse_arguments~=n_parse_args_simple
    error('parse_arguments and parse_args_simple are not equivalent')
end

disp('Parse_keywords')
tic
n=0;
for i=1:nloop
    [ok,mess,ind,val] = parse_keywords(argname,argcell_key{i}{:});
    if ~ok, error(mess), end
    n=n+sum(ind)+numel(val);
end
if n==n_parse_args_simple
    disp('Whoopee! (a message to prevent clever optimisation by matlab)')
end

t=toc;
disp(['     Time per function call (microseconds): ',num2str(1e6*t/nloop)]);
disp(' ')
