function IMFFeatures = myEMDFeaturesPowerDyadic(IMF,Fs,XCorrTh, fcDiff)
    % Extract IMF features from lenSound*numIMF sized IMF matrix
    %
    % The ADSAA paper suggest the first 10 IMF. However, DDK voice
    % recordings are much shorter than sustained vowel. The decomposition
    % often times results in less than 10 IMFs. 
    % The average number for DDK vowel is: 
    % *******************************************************************
    % CHANGES MADE: the noise and signal power are calculated based on the
    % return Noise and Signal from myThresholdingSumIMF.m
    % *******************************************************************
    % ADDED: Aug 18, 2019 Beside the original OBW, PdB, SNR, new features
    % OBW Factor, FCenter(3dB), and Dyadic (FCenter-last/FCenter-current)
    % *******************************************************************
    %
    % NOTE: This function call the other two helper functions contained in:
    %   1. myThresholdingSumIMF.m
    %   2. myFindIMFCenterFreq.m
    %
    % Input: 
    %   IMF:     IMF Matrix, each column contains an IMF vector
    %   Fs:      Sampling frequency (Hz.
    %               Ex: Fs for quality voice recording, Fs = 44100 Hz
    %   XCorrTh: Normalized correlation threshold between accumulated sum
    %            of IMF and the original voice. This is used to caculated
    %            the SNR of the voice
    %   fcdiff:  ratio of tolerance between adjacent IMFs. If the IMFs center
    %            frequencies are within this ratio difference, then it is
    %            extremely likely mode mixing has occured. That means the 
    %            same component is spread over multiple IMFs.
    %               Ex: fcdiff = 0.1 means, the center frequencies (FC) of 
    %               two IMFs, IMFi and IMFj should be within 10% distance
    %               of IMFi
    %                   |IMFi-IMFj|/IMFi < 0.1
    %
    % Returns:
    %   IMF Features: a structure containing all the features described in
    %   the paper
    % 
    % Reference:
    %   1. Elsevier Computer Speech and Language (in printing)
    %   2. A. Rueda and S. Krishnan, “Clustering Parkinson's and 
    %       Age-related Voice Impairment Signal Features for Unsupervised 
    %       Learning,” Advances in Data Science and Adaptive Analysis, 2018.
    %       https://doi.org/10.1142/S2424922X18400077
    
%%
    
    % Length of the sound and number of IMFs
    [lenIMF, numIMF]    = size(IMF);
    if (numIMF>lenIMF) 
        IMF = IMF';
        [lenIMF, numIMF]    = size(IMF);
    end
    IMFFeatures.numIMF  = numIMF;
    
    % To avoid divide by 0 for SNR calculatio n
    smallError      = 0.000000001;
    smallSignal     = ones(lenIMF,1)*smallError;
    
    
    % 10 Features per group
    OBW     = zeros(1,10);
    OBWRatio = zeros(1,10);
    PobwdB     = zeros(1,10);
    FCenter = zeros(1,8);    % Only record the first 8 Center frequencies. Higher order has meaninless low values
    Dyadic  = zeros(1,6);     % IMF2/IMF3 -> IMF7/IMF8 The center frequency of the IMFs are way too small
    
    
    % Accumulated sum
    accSumIMF   = zeros(lenIMF,1);
    Sound       = sum(IMF,2);
    
    
    
    for i = 1:numIMF
        
        
        % Determine the accumulated sum for SNR calculation
        currentIMF = IMF(:,i);  % Current IMF being worked on
        accSumIMF = accSumIMF + currentIMF;
        % XCorrelation between currentIMF and the accumulated-sum IMF
        maxCorr = max(xcorr(Sound, accSumIMF)); 
        % L2-Norm between accumulated-sum IMF and Sound
        absDiff = abs(Sound-accSumIMF);
        L2Norm = sum(absDiff.*absDiff);      %Column vector
        
        
        
        % Bandwidth information 
        [BW, Flo, Fhi, POWER] = obw(currentIMF,Fs);
        [BW3dB, Flo3dB, Fhi3dB, tmpP3dB] = powerbw(currentIMF, Fs);
        
        
        tmpFCenter(i) = (Flo3dB+Fhi3dB)/2;
            
        %IMFFeatures.numIMF(i) = numIMF;
        %IMFFeatures.IMFnumber(i) = i;
        tmpOBW(i) = BW;
        tmpPdB(i) = 10*log10(POWER);
        P3dB(i) = 10*log10(tmpP3dB);
        
        % Taking power factor as P_i/P_(i+1), for 2<i<7
        if i>2
            tmpOBWRatio(i-2) = tmpOBW(i-1)/tmpOBW(i);
            if i<9
                logFreqDist = log2(tmpFCenter(i-1))-log2(tmpFCenter(i));
                P3dBBalancing(i-2) = (P3dB(i-1)-P3dB(i))/(10*(logFreqDist));
                PobwRatio(i-2) = tmpPdB(i-1)-P3dB(i);
                
%                 P3dBRatio(i-2) = P3dB(i-1)/P3dB(i);
%                 PobwRatio(i-2) = tmpPdB(i-1)/P3dB(i);
%                 

            end
        end
        
        
        XCorr(i) = maxCorr;
        Distance(i) = L2Norm;
        
    end
    
    rawFCenter = myFindIMFCenterFreq(tmpFCenter, fcDiff);
    FCenterNext = rawFCenter(2:end);
    tmpDyadic = rawFCenter(1:end-1)./FCenterNext;
    
    if numIMF > 10
        OBW = tmpOBW(1:10);
        OBWRatio = tmpOBWRatio(1:10);
        PobwdB = tmpPdB(1:10);
    else
        OBW(1:numIMF) = tmpOBW;
        OBWRatio(1:numIMF-1) = tmpOBWRatio;
        PobwdB(1:numIMF) = tmpPdB;
    end
    if numIMF<8
        FCenter(1:numIMF) = rawFCenter;
        Dyadic(1:numIMF-1) = tmpDyadic(2:end);
    else
        FCenter = rawFCenter(1:8);
        Dyadic = tmpDyadic(2:7);

    end

    IMFFeatures.OBW = OBW;
    IMFFeatures.OBWRatio = OBWRatio;
    IMFFeatures.PobwdB = PobwdB;
    IMFFeatures.PobwRatio = PobwRatio;
    IMFFeatures.P3dB  = P3dB(1:8);
    IMFFeatures.P3dBBalancing = P3dBBalancing;
    IMFFeatures.FCenter = FCenter;
    IMFFeatures.FCRatio = Dyadic;
    
    
    % Determine the noise IMFs and calculate PowerNoise, PowerSignal and SNR
    XCorr = XCorr/max(XCorr);
    Distance = Distance/max(Distance);
    [Signal, Noise, IdxIMFSignal] = myThresholdingSumIMF(IMF,XCorr,XCorrTh);

    IMFFeatures.SNRdB = snr(Signal,Noise+smallSignal);
    
    %% Plotting the XCorr
    
    PLOT = 0;
    
    if PLOT
        figure();
        plot(XCorr); hold on;
        plot(Distance);
        legend('XCorr','L2Norm');
        xlabel('IMF'); 
    end
    
    
return