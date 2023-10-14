function [OFDMSignal] = OFDMLoad(IQSignal, SubCarrierNum, CyclicPrefixNum)
    
    StartTime = IQSignal.TimeStart + SubCarrierNum * (1 / IQSignal.SampleRate);
    EnduranceTime = (SubCarrierNum + CyclicPrefixNum) / SubCarrierNum * IQSignal.TimeEndurance;
    OFDMSignal = InitAnalogSignal(IQSignal.ChannelNum, StartTime, EnduranceTime, IQSignal.SampleRate, 'Template', 'As', IQSignal);
    [ChannelNum, IQLength] = size(IQSignal.Signal);
    RawLength = IQLength / SubCarrierNum;
    if(round(RawLength) ~= RawLength)
        warning("The input signal length is not an integer multiple of 'SubCarrierNum'.");
    end
    RawSignal = reshape(IQSignal.Signal', SubCarrierNum, RawLength, ChannelNum);
    BaseSignal = ifft(RawSignal) * sqrt(SubCarrierNum);
    OrthogonalSignal = reshape([BaseSignal((SubCarrierNum - CyclicPrefixNum + 1) : SubCarrierNum, :, :); BaseSignal], RawLength * (SubCarrierNum + CyclicPrefixNum), ChannelNum)';
    OFDMSignal.Signal = OrthogonalSignal;
end

