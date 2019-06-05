% Create some samples
s1 = IX_sample([1,1,0],[0,0,1],'cuboid',[2,3,4]);
s2 = IX_sample([1,1,0],[0,0,1],'cuboid',[10,15,20]);
s3 = IX_sample([1,1,0],[0,0,1],'cuboid',[0.5,0.7,1]);


%--------------------------------------------------------------------------
% Test the lookup table
% ----------------------

arr1 = [s3,s1];
arr2 = [s2,s1,s3];
arr3 = [s3,s2];

objlookup = object_lookup({arr1,arr2,arr3});

nsamp = 1e7;
ind = randselection([2,3],[ceil(nsamp/10),10]);
xsamp = rand_ind(objlookup,2,ind);


tmp=xsamp(:,ind==2);
ps = max(tmp,[],2)-min(tmp,[],2);
if max(abs(ps(:)-s1.ps(:)))>1e-5
    error('Problem with random sampling from sample')
end


tmp=xsamp(:,ind==3);
ps = max(tmp,[],2)-min(tmp,[],2);
if max(abs(ps(:)-s3.ps(:)))>1e-5
    error('Problem with random sampling from sample')
end

%--------------------------------------------------------------------------
% Speed test old and new
% ----------------------

sold = IX_sample(true,[1,1,0],[0,0,1],'cuboid',[2,3,4]);
snew = IX_sample([1,1,0],[0,0,1],'cuboid',[2,3,4]);

tic;
xold = random_points(sold,1e7);
toc;

tic;
xnew = snew.rand(1,1e7);
toc;

% Test using lookup as we would have it in practice (just one sample shape)

slookup = object_lookup (repmat(snew,181,1));

ind = ones(1,1e7);
tic
xlook = slookup.rand_ind(ind);
toc



