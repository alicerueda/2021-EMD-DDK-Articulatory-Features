function [Signal, Noise, IdxIMFSignal] = myThresholdingSumIMF(IMF,xcorr,threshold)

% This function takes the IMFs obtained from EMD and their corresponding
% cross-correlationship (xcorr) to the original signal to reconstruct the
% clean signal.
%
% The clean signal is reconstructed by adding all the IMF that its xcorr is
% above the normalized noise xcorr. The default threshold is 0.05.

% input variable:
%   IMF  : a matrix contain IMFs in column vectors
%   xcorr: a vector of cross-correlations between SumIMF and the original
%   signal

    addIMF = ones(length(xcorr),1); % assuming all IMF are not noise
    addIMF(xcorr<threshold) = 0;    % IMFs with xcorr below threshold are considered noise
    Signal = IMF*addIMF;
    Noise = IMF*(1-addIMF);
    IdxIMFSignal = find(addIMF>0,1); % The first Signal IMF index

return