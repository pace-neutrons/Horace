function test_parsing(nloop)

inpars={[13,14],'hello','missus',true};
argname={'name','newplot','type'};
argvals={[11,12,13,14],'zoot',rand(4,3),true,false,'suit'};
arglist = struct('name','',...
                 'newplot',true,...
                 'type','d');
             
% Fill array of arguments             
tic
argscell=cell(1,nloop);             
argscell_key=cell(1,nloop);             
for i=1:nloop
    indpar=logical(round(rand(size(inpars))));
    indarg=logical(round(rand(size(argname))));
    indval=round(0.501+5.990*rand(1,sum(indarg)));
%     disp(indarg)
%     disp(indval)
    args=[argname(indarg);argvals(indval)];
    argcell{i}=[inpars(indpar),args(:)'];
    argcell_key{i}=args(:)';
end
toc

% %----
% for i=1:nloop
%     [para,keyworda,presenta] = parse_arguments(argcell{i},arglist);
%     [parb,keywordb,presentb] = parse_args_simple(argcell{i},arglist);
%     if ~isequal(para,parb)
%         disp('par problem');
%     end
%     if ~isequal(keyworda,keywordb)
%         disp('par problem');
%     end
%     if ~isequal(presenta,presentb)
%         disp('par problem');
%     end
% end
% %----


disp('Parse_arguments')
tic
n=0;
for i=1:nloop
    [par,keyword,present] = parse_arguments(argcell{i},arglist);
    n=n+numel(par)+numel(keyword)+numel(present);
end
disp(n)
t=toc;
disp(1e6*t/nloop);

disp('Parse_args_simple')
tic
n=0;
for i=1:nloop
    [par,keyword,present] = parse_args_simple(argcell{i},arglist);
    n=n+numel(par)+numel(keyword)+numel(present);
end
disp(n)
t=toc;
disp(1e6*t/nloop);

disp('Parse_keywords')
tic
n=0;
for i=1:nloop
    [ok,mess,ind,val] = parse_keywords(argname,argcell_key{i}{:});
    if ~ok, error(mess), end
    n=n+sum(ind)+numel(val);
end
disp(n)
t=toc;
disp(1e6*t/nloop);
