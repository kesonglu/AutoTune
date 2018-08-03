function CorrectedDate = PitchShift(BlockDate,Ratio)
global Fs;
global CircleBuf gains1 gains2 delays1 delays2;
global ph1 ph2 pstep ovrlp sd  fgain pWrite1 step_size CircleLen ;
pMaxDelay = 0.03;
pRate = (1 - Ratio) / pMaxDelay;
pPhaseStep = pRate / Fs;
pstep = pPhaseStep;
CorrectedDate  = zeros(step_size,1);
for i = 1:step_size
    in = BlockDate(i,1);
    ph1 = mod((ph1 + pstep),1);
    ph2 = mod((ph2 + pstep),1);
    
    % delayline2 is approaching its end. fade in delayline1
    if((ph1 < ovrlp) && (ph2 >= (1 - ovrlp)))
        
        delays1(i) = sd * ph1;
        delays2(i) = sd * ph2;
        
        % Use equal power cross-fade rule
        % gain1 = cos((1 - percent) * pi/2)
        % gain2 = cos(percent * pi/2);
        
        gains1(i) = cos((1 - (ph1* fgain)) * pi/2);
        gains2(i) = cos(((ph2 - (1 - ovrlp)) * fgain) * pi/2);
        
        % delayline1 is active
    elseif((ph1 > ovrlp) && (ph1 < (1 - ovrlp)))
        
        % delayline2 shouldn't move while delayline1 is active
        ph2 = 0;
        
        delays1(i) = sd * ph1;
        
        gains1(i) = 1;
        gains2(i) = 0;
        
        % delayline1 is approaching its end. fade in delayline2
    elseif((ph1 >= (1 - ovrlp)) && (ph2 < ovrlp))
        
        delays1(i) = sd * ph1;
        delays2(i) = sd * ph2;
        
        % Use equal power cross-fade rule
        % gain1 =  cos(percent * pi/2);
        % gain2 =  cos((1 - percent) * pi/2);
        gains1(i) = cos(((ph1 - (1 - ovrlp)) * fgain) * pi/2);
        gains2(i) = cos((1 - (ph2* fgain)) * pi/2);
        
        % delayline2 is active
    elseif((ph2 > ovrlp) && (ph2 < (1 - ovrlp)))
        
        % delayline1 shouldn't move while delayline2 is active
        ph1 = 0;
        
        delays2(i) = sd * ph2;
        
        gains1(i) = 0;
        gains2(i) = 1;
        
    end
    % DelayLine1
    pWrite1 = pWrite1 + 1;
    if(pWrite1>CircleLen)
        pWrite1 = 1;
    end
    CircleBuf(pWrite1) = in;
    % 
    temp = delays1(i)*1;  
    curDepth = fix(delays1(i)*1);
    D1 = temp - fix(curDepth);
    D2 =1 - D1;
    pRead1 = pWrite1 - curDepth;
    if(pRead1<1)
        pRead1= pRead1 + CircleLen;
    end
    out1 = CircleBuf(pRead1);
    pRead1 = pRead1 - 1;
    if(pRead1<1)
        pRead1= pRead1 + CircleLen;
    end
    out2 = CircleBuf(pRead1);
    DelayOut1 = (out1*D2) + (out2*D1);
    DelayOut1 = DelayOut1*gains1(i);
    
    % DelayLine2 
     temp = delays2(i)*1;  
    curDepth = fix(delays2(i)*1);
    D1 = temp - fix(curDepth);
    D2 = 1 - D1;
    
    pRead2 = pWrite1 - curDepth;
    if(pRead2<1)
        pRead2= pRead2 + CircleLen;
    end
    out1 = CircleBuf(pRead2);
    pRead2 = pRead2 - 1;
    if(pRead2<1)
        pRead2= pRead2 + CircleLen;
    end
    out2 = CircleBuf(pRead2);
    DelayOut2 = (out1*D2) + (out2*D1);
    DelayOut2 = DelayOut2*gains2(i);
    CorrectedDate(i) = DelayOut2+DelayOut1;       
end