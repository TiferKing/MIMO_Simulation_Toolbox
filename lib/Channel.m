function [OutputSignal] = Channel(InputSignal, ChannelImpulse, NoisedBW)
%Channel Channel simulation.
%Introduction:
%   Simulate the signal transmission through the channel with a specific
%   impulse response and a specific noise level.
%Syntax:
%   OutputSignal = Channel(InputSignal, ChannelImpulse, NoisedBW)
%Description:
%   OutputSignal = Channel(InputSignal, ChannelImpulse, NoisedBW)
%       returns the signal recived.
%Input Arguments:
%   InputSignal: (AnalogSignal)
%       Transmitted signals.
%   ChannelImpulse: (ChannelImpulseResponse)
%       Channel impulse response for each channel.
%   NoisedBW: (double)
%       AWGN nois power in dBW.
%Output Arguments:
%   OutputSignal: (AnalogSignal)
%       Recived signals.
%Author:
%   Tifer King
%License:
%   Please refer to the 'LICENSE' file included in the root directory 
%   of the project.

    SampleRate = InputSignal.SampleRate;
    InputLength = InputSignal.TimeEndurance * InputSignal.SampleRate;
    [UpRate,DownRate] = rat(InputSignal.SampleRate / ChannelImpulse.SampleRate);
    ImpulseLength = round(ChannelImpulse.TimeEndurance * SampleRate);
    ChannelImpulseInput = zeros(ChannelImpulse.ChannelOutputNum, ChannelImpulse.ChannelInputNum, ImpulseLength);
    if (UpRate ~= DownRate)
    % In case the input signals have a different sample rate from the
    % channel impulse response, the channel impulse response will be
    % resampled.
        for indexrow = 1 : ChannelImpulse.ChannelOutputNum
            for indexcolumn = 1 : ChannelImpulse.ChannelInputNum
                ChannelImpulseInput(indexrow, indexcolumn,:) = resample(reshape(ChannelImpulse.Signal(indexrow, indexcolumn,:), 1, []), UpRate, DownRate);
                if (sum(ChannelImpulseInput(indexrow, indexcolumn,:)) ~= 0)
                    AmplificationFactor = sum(ChannelImpulse.Signal(indexrow, indexcolumn,:)) / sum(ChannelImpulseInput(indexrow, indexcolumn,:));
                else
                    AmplificationFactor = 1;
                end
                ChannelImpulseInput(indexrow, indexcolumn,:) = AmplificationFactor * ChannelImpulseInput(indexrow, indexcolumn,:);
                % Resampling the channel impulse response may change its
                % amplitude, so it should be rescaled.
            end
        end
    else
        ChannelImpulseInput = ChannelImpulse.Signal;
    end
    TimeStart = InputSignal.TimeStart + ChannelImpulse.TimeStart;
    TimeEndurance = (ImpulseLength + InputLength - 1) / SampleRate;
    OutputSignal = InitAnalogSignal(ChannelImpulse.ChannelOutputNum, TimeStart, TimeEndurance, SampleRate, 'Template','As',InputSignal);
    OutputSignal.Signal = ChannelConvolution(InputSignal.Signal, ChannelImpulseInput) / db2mag(ChannelImpulse.AttenuationdB);
    % Keeping the amplitude (power) of the signal correct is important.
    % Rescaling can adjust the signal to the correct amplitude.
    ReferencePower = pow2db(OutputSignal.ReferenceVoltage ^ 2 / OutputSignal.ReferenceImpedance);
    % ReferencePower calculates the reference power of the signal based on
    % a specific reference voltage and reference impedance. In other words,
    % it represents the power when the signal is 1.
    StandardizedPower = ReferencePower - mag2db(OutputSignal.ReferenceVoltage / sqrt(OutputSignal.ReferenceImpedance));
    % MATLAB always assumes that the reference impedance is 1 Ohm and the
    % reference voltage is 1 V when calculating power, so it needs to be
    % standardized in this case.
    OutputSignal.Signal = awgn(OutputSignal.Signal, ReferencePower - NoisedBW - pow2db(ChannelImpulse.ChannelInputNum), StandardizedPower);
end

