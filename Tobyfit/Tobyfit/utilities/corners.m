function d = corners(n,which)
% For a given dimensionality, n, return the principle axes and
% the generalized (body, face, etc.) diagonal directions.

% G. S. Tucker

% Check inputs
if nargin<2 || isempty(which)
    just_positives = false;
else
    switch lower(which)
        case {'p','pos','positive'}
            just_positives = true;
        otherwise
            just_positives = false;
    end
end

if ~(isnumeric(n) && isfinite(n) && mod(n,1)==0)
    error('The only input to corners should be an integer specifying the dimensionality')
end
% [~,maxsize] = computer;
% % Error if output dimensions are too large
% if n*factorial(n) > maxsize
%    error(message('MATLAB:pmaxsize'))
% end

fn = 'corners.h5'; % Move this somewhere sensible

if ~exist(fn,'file')
    setup_h5(fn);
end
if just_positives
    base = 'pos';
else
    base = 'all';
end

% Do the actual work (don't bother sorting)
d = inner_corners(n);

    function d=inner_corners(n)
    o = [-1; 0; 1];
    % Check if we've already calculated this:
    if has_h5(fn,base,n)
        d = get_h5(fn,base,n);
        return;
    end
    % Otherwise, we have some work to do: 
    % To start, determine the next-lower dimension corners recursively
    p = inner_corners(n-1);
    % The number of n-1 corners returned
    np = size(p,1);
    % To every set of corners, append in turn 0, 1, and -1 then find the full
    % set of permutations of the new n dimensional vectors
    pp=arrayfun(@(x)(cat(2,x*ones(np,1),p)),o,'uniformoutput',false);
    % pp=arrayfun(@(x)(row_perms(cat(2, p, ones(np,1)*x))),[0,1,-1],'uniformoutput',false);
    % Remove any repeated vectors
    % d = unique( cat(1, pp{:}), 'rows');
    d = cat(1,pp{:});
    if just_positives
        % And finally remove any vectors which have a later-in-the-list
        % mirrored vector (v == -v).
        d = unique_to_a_sign(d);
    end

    insert_h5(fn,base,n,d);
    end

end


function setup_h5(filename)
    h5create(filename,'/all_dimensions',[1,Inf],'ChunkSize',[1,1]);
    h5create(filename,'/all_corners/1',[3,1]);
    h5write(filename,'/all_dimensions',1,[1,1],[1,1]);
    h5write(filename,'/all_corners/1',[-1;0;1]);
    h5create(filename,'/pos_dimensions',[1,Inf],'ChunkSize',[1,1]);
    h5create(filename,'/pos_corners/1',[2,1]);
    h5write(filename,'/pos_dimensions',1,[1,1],[1,1]);
    h5write(filename,'/pos_corners/1',[0;1]);
end
function insert_h5(filename,base,d,p)
    h5write(filename, sprintf('/%s_dimensions',base),d,[1,d],[1,1])
    keyname = sprintf('/%s_corners/%d',base,d);
    h5create(filename,keyname,size(p));
    h5write(filename,keyname,p)
end
function tf=has_h5(filename,base,d)
    dims = h5read(filename,sprintf('/%s_dimensions',base));
    if numel(dims)>=d && dims(d)==d
        tf = true;
    else
        tf = false;
    end
end
function p=get_h5(filename,base,d)
    p=h5read(filename, sprintf('/%s_corners/%d',base,d));
end


function B =unique_to_a_sign(A)
[N,dim]=size(A);
notanegative = true(N,1);
for i=1:N
    if notanegative(i)
        Ai = A(i,:)./norm(A(i,:));
        for j=i+1:N
            Aj = -A(j,:)./norm(A(j,:));
            if abs( sum(Ai .* Aj) - 1 ) < dim*eps
                notanegative(i) = false;
                break; % just out of the inner loop
            end
        end
    end
end
B=A(notanegative,:);
end

