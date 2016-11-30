function [T, N] = transenshuffle(M, lag, nbins)
%TRANSENSHUFFLE Calculate the transfer entropy for a shuffled time series that has
%already been lined up with LagData
%   Calculates the transfer entropy of X>Y, the amount by which knowledge
%   of variable X at a time lag reduces the uncertainty in variable Y. M =
%   [X Y], and lag is the time lag of interest. nbins is the number of bins
%   used to discretize the probability distributions.
%Written by Laurel Larsen. Modified 10/28/16. Normalized by the total
%entropy in variable Y. 
Minput = shuffle(M(:,1:2));

%M1-M4 below are lagged vectors of inputs for the marginal and joint entropy components of the Knuth
%(2015) formulation of transfer entropy.
M4 = LagData([Minput Minput(:,2)], [0 0 -lag]); 
M1 = M4(:,[1 3]);
M2 = M4(:, 2:3); 
M3 = M4(:,2); 
%Now calculate the joint and marginal entropy components:
[T1, n_valid_pairs1] = jointentropy(M1,nbins(2));
[T2, n_valid_pairs2] = jointentropy(M2,nbins(2));
[n3, ~] = histcounts(M3, nbins(1));
T3= -sum(n3(n3>0)/sum(n3(n3>0)).*log2(n3(n3>0)/sum(n3(n3>0)))); %Nonnormalized Shannon entropy of variable Y
[T4, n_valid_pairs4] = jointentropy3(M4,nbins(3));
[nn, ~] = histcounts(M(:,2), nbins(1)); %PDF of variable Y
Tn = -sum(nn(nn>0)/sum(nn(nn>0)).*log2(nn(nn>0)/sum(nn(nn>0)))); %Nonnormalized Shannon entropy of variable Y.
% If needed, correct the Shannon entropy components to the same scale (only
% changes T1-4 if you are using different numbers of bins for the 1D, 2D,
% and 3D joint probability distribution estimates). It is recommended,
% though, that nbins(1)=nbins(2)=nbins(3).
T1 = T1*log2(nbins(1))/log2(nbins(2));
T2 = T2*log2(nbins(1))/log2(nbins(2));
T4 = T4*log2(nbins(1))/log2(nbins(3));
T = (T1+T2-T3-T4)/Tn; %Knuth formulation of transfer entropy
N = min([n_valid_pairs1 n_valid_pairs2 n_valid_pairs4]);
end

