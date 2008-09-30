%------------------------------------------------
% Test several timers

aa=exp(sin(rand(1000)).^(pi/2));

bigtic
aa=aa+exp(sin(rand(1000)).^(pi/2));
bigtoc('default timer - 1 lot')

bigtic(1)
aa=aa+exp(sin(rand(1000)).^(pi/2));
bigtoc('default timer - 2 lots')
bigtoc(1,'timer 1 - 1 lot')

bigtic(3)
aa=aa+exp(sin(rand(1000)).^(pi/2));
bigtoc('default timer - 3 lots')
bigtoc(1,'timer 1 - 2 lots')
bigtoc(3,'timer 3 - 1 lot')

ans=sum(aa(:))

%------------------------------------------------
aa=exp(sin(rand(1000)).^(pi/2));

bigtic(1)
aa=aa+exp(sin(rand(1000)).^(pi/2));
time_1=bigtoc(1)

