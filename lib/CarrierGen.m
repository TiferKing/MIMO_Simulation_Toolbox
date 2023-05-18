function [CarrierSignal] = CarrierGen(Frequency, Channel, SampleRate, StartTime, Endurance, SignalPreset)
%CarrierGen Generate carrier signals.
%Introduction:
%   Generate carrier signals for each channel with the same phase and 
%   amplitude. Users can specify the start time and endurance of the
%   carrier signal.
%Syntax:
%   CarrierSignal = CarrierGen(Frequency, Channel, SampleRate, StartTime, Endurance, SignalPreset)
%Description:
%   CarrierSignal = CarrierGen(Frequency, Channel, SampleRate, StartTime, Endurance, SignalPreset)
%       returns carrier for each channel.
%Input Arguments:
%   Frequency: (double)
%       Carrier frequency in Hz.
%   Channel: (positive integer scalar)
%       Number of channels.
%   SampleRate: (double)
%       Carrier sample rate in Sa/s.
%   StartTime: (double)
%       Carrier start time in second.
%   Endurance: (double)
%       Carrier endurance in second.
%   SignalPreset: (string)
%       The preset reference voltage and impedance of signal, please refer
%       to 'InitAnalogSignal' for more detail.
%Output Arguments:
%   CarrierSignal: (AnalogSignal)
%       The signal that contains the carrier.
%Author:
%   Tifer King
%License:
%   Please refer to the 'LICENSE' file included in the root directory 
%   of the project.

    CarrierSignal = InitAnalogSignal(Channel, StartTime, Endurance, SampleRate, SignalPreset);
    Carrierindex = [1 : round(Endurance * SampleRate)] / SampleRate;
    Carrier = exp(1i * (2 * pi * Frequency * Carrierindex));
    for index = 1 : Channel
        CarrierSignal.Signal(index,:) = Carrier;
    end
end

