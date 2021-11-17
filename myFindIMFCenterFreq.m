function FCenter = myFindIMFCenterFreq(tmpFCenter,fcDiff)

% Taking the vector of center frequencies of the IMFs
% remove the ones within 10% difference to its adjacent IMF
    
    % Sorting the center frequency by descending order
    tmpFCenter  = sort(tmpFCenter,'descend');
    
    % Initialized the resulting center frequencey (FCenter) with first one
    % as the highest frequency value
    lenFC = length(tmpFCenter);
    currentIdx = 2;
    FCenter = [tmpFCenter(1)];
    perDiff = 0;  % This is to find the difference between the current 
                  % target with the subsequent lower frequencies to see 
                  % if they are still within the tolerated percentage
                  % differece
    
    
    %
    while currentIdx < lenFC
        nextIdx = currentIdx + 1;
        while perDiff < fcDiff
            currentFreq = tmpFCenter(currentIdx);
            nextFreq = tmpFCenter(nextIdx);
            perDiff = abs(currentFreq-nextFreq)/currentFreq;
            nextIdx = nextIdx + 1;
            if nextIdx > lenFC
                break;
            end
                        
        end
        perDiff = 0;
        FCenter = [FCenter, currentFreq];
        currentIdx = nextIdx-1;
        
    end
    


end