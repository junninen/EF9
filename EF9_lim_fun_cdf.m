function lim=EF9_lim_fun_cdf(x, par)
%
% cumulative normal distribution scaled from min to max
%
% lim=EF9_lim_fun_cdf(x, par)
% par=[min,max,mu,sig]
%
% see also: cdf

% Heikki Junninen
% Aug 2011

mn=par(1);
mx=par(2);
mu=par(3);
sig=par(4);

lim=cdf('norm',1:size(x,2),mu,sig)*(mx-mn)+mn;

