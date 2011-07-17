xbounds=[1,4,5];
x=[0.9,1,1.1,4,5,6];
x=[15,16,17]
x=[2,3,3,4,4,4,5,5]

% Interesting case
xbounds=[1,4,4,5];
x=[2,3,3,4,4,4,5,5]


xbounds=[1,4,5];
x=[4.2,4.3,4.7]
x=[2,5,5,5]
x=[2,4,4,4]
x=[4,4,4]
x=[5,5,5]

xbounds=[1,2,3,4,5]
x=[1.3,2,4,6]
x=[1.3,2,4,5]


ibin = bin_index (x,xbounds,true), ibin2 = bin_index2 (x,xbounds,true)


ibin = bin_index (x,xbounds,false), ibin2 = bin_index2 (x,xbounds,false)

