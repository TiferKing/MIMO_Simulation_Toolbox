function [BaseSignal] = IQDemixing(AnalogSignal, CarrierSignal, SampleRate, FilterDesignFx)
%IQDemixing Mixing radio band signal to baseband.
%Introduction:
%   IQDemixer can demodulate the in-phase and quadrature components of a
%   signal independently.
%Syntax:
%   BaseSignal = IQDemixing(AnalogSignal, CarrierSignal, SampleRate, FilterDesignFx)
%Description:
%   BaseSignal = IQDemixing(AnalogSignal, CarrierSignal, SampleRate, FilterDesignFx)
%       returns the baseband signal.
%Input Arguments:
%   AnalogSignal: (AnalogSignal)
%       Radio frequency signal.
%   CarrierSignal: (AnalogSignal)
%       Local-oscillator signal.
%   SampleRate: (double)
%       Baseband sample rate.
%   FilterDesignFx: (function)
%       Design downconvert filter. The function will called in:
%       FilterDesignFx(LOSampleRate, BaseSampleRate);
%Output Arguments:
%   BaseSignal: (AnalogSignal)
%       Baseband signal.
%Author:
%   Tifer King
%License:
%   Please refer to the 'LICENSE' file included in the root directory 
%   of the project.

    [UpRate,DownRate] = rat(SampleRate / CarrierSignal.SampleRate);
    
    if AnalogSignal.TimeStart > CarrierSignal.TimeStart
        TimeStart = CarrierSignal.TimeStart;
    else
        TimeStart = AnalogSignal.TimeStart;
    end
    if (AnalogSignal.TimeStart + AnalogSignal.TimeEndurance) > (CarrierSignal.TimeStart + CarrierSignal.TimeEndurance)
        TimeEndurance = (AnalogSignal.TimeStart + AnalogSignal.TimeEndurance) - TimeStart;
    else
        TimeEndurance = (CarrierSignal.TimeStart + CarrierSignal.TimeEndurance) - TimeStart;
    end
    if AnalogSignal.ChannelNum > CarrierSignal.ChannelNum
        ChannelNum = AnalogSignal.ChannelNum;
    else
        ChannelNum = CarrierSignal.ChannelNum;
    end
    RFSampleRate = AnalogSignal.SampleRate;
    RFSignal = zeros(ChannelNum, round(TimeEndurance * RFSampleRate));
    LOSignal = zeros(ChannelNum, round(TimeEndurance * RFSampleRate));
    RFStartIndex = round((AnalogSignal.TimeStart - TimeStart) * RFSampleRate + 1);
    RFStopIndex = round((AnalogSignal.TimeEndurance) * RFSampleRate + RFStartIndex - 1);
    LOStartIndex = round((CarrierSignal.TimeStart - TimeStart) * RFSampleRate + 1);
    LOStopIndex = round((CarrierSignal.TimeEndurance) * RFSampleRate + LOStartIndex - 1);
    RFSignal(:,RFStartIndex : RFStopIndex) = AnalogSignal.Signal;
    LOSignal(:,LOStartIndex : LOStopIndex) = CarrierSignal.Signal;
    
    MixSignal = RFSignal .* LOSignal;
    Filter = FilterDesignFx(CarrierSignal.SampleRate, SampleRate);
    MixSignal = filter(Filter,1,MixSignal,[],2);
    TimeEndurance = ceil(TimeEndurance * SampleRate) / SampleRate;
    BaseSignal = InitAnalogSignal(ChannelNum, TimeStart, TimeEndurance, SampleRate, 'Template', 'As', AnalogSignal);
    for index = 1 : ChannelNum
        BaseSignal.Signal(index,:) = resample(MixSignal(index,:), UpRate, DownRate);
    end
end

