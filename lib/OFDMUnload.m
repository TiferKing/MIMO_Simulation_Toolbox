function [IQSignal] = OFDMUnload(OFDMSignal, SubCarrierNum, CyclicPrefixNum)
    
    StartTime = OFDMSignal.TimeStart + (SubCarrierNum + CyclicPrefixNum) * (1 / OFDMSignal.SampleRate);
    EnduranceTime = SubCarrierNum / (SubCarrierNum + CyclicPrefixNum) * OFDMSignal.TimeEndurance;
    StartTimeMin = OFDMSignal.TimeStart + OFDMSignal.TimeEndurance - EnduranceTime;
    if (StartTime < StartTimeMin)
        StartTime = StartTimeMin;
    end
    IQSignal = InitAnalogSignal(OFDMSignal.ChannelNum, StartTime, EnduranceTime, OFDMSignal.SampleRate, 'Template', 'As', OFDMSignal);
    [ChannelNum, OFDMLength] = size(OFDMSignal.Signal);
    RawLength = OFDMLength / (SubCarrierNum + CyclicPrefixNum);
    if(round(RawLength) ~= RawLength)
        warning("The input signal length is not an integer multiple of 'SubCarrierNum'.");
    end
    RawSignal = reshape(OFDMSignal.Signal', (SubCarrierNum + CyclicPrefixNum), RawLength, ChannelNum);
    BaseSignal = fft(RawSignal((CyclicPrefixNum + 1) : end, :, :)) / sqrt(SubCarrierNum);
    RecoveredSignal = reshape(BaseSignal, RawLength * SubCarrierNum, ChannelNum)';
    IQSignal.Signal = RecoveredSignal;
end

