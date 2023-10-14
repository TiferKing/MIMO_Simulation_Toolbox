function [DigitalSignal] = Demodulation(IQSignal, Mode, SignalPreset)
%Demodulation Convert IQ signal to binary data by demodulation.
%Introduction:
%   This function converts signal to binary by demodulation and paired with
%   'Modulation'.
%Syntax:
%   DigitalSignal = Demodulation(IQSignal, Mode, SignalPreset)
%Description:
%   DigitalSignal = Demodulation(IQSignal, Mode, SignalPreset)
%       returns the binary data stream.
%Input Arguments:
%   IQSignal: (AnalogSignal)
%       Baseband IQ signals.
%   Mode: (string)
%       Method of modulation, it is one of blow:
%       'ASK': Amplitude Shift Keying.
%       'BPSK': Binary Phase-Shift Keying.
%       'QPSK': Quadrature Phase Shift Keying.
%       '16QAM': 16-points Quadrature Amplitude Modulation.
%       '64QAM': 64-points Quadrature Amplitude Modulation.
%       '256QAM': 256-points Quadrature Amplitude Modulation.
%       '1024QAM': 1024-points Quadrature Amplitude Modulation.
%   SignalPreset: (string)
%       The preset reference voltage, impedance and different pair of
%       signal, please refer to 'InitDigitalSignal' for more detail.
%Output Arguments:
%   DigitalSignal: (DigitalSignal)
%       Recovered binary stream.
%Author:
%   Tifer King
%License:
%   Please refer to the 'LICENSE' file included in the root directory 
%   of the project.

    ChannelNum = IQSignal.ChannelNum;
    TimeStart = IQSignal.TimeStart;
    TimeEndurance = IQSignal.TimeEndurance;
    SampleRate = IQSignal.SampleRate;
    SignalLength = size(IQSignal.Signal, 2);
    if(strcmp(Mode, "ASK"))
        DigitalSignal = InitDigitalSignal(ChannelNum, TimeStart, TimeEndurance, SampleRate, SignalPreset);
        DigitalSignal.Signal = double(real(IQSignal.Signal) > 0.5);
    elseif(strcmp(Mode, "BPSK"))
        DigitalSignal = InitDigitalSignal(ChannelNum, TimeStart, TimeEndurance, SampleRate, SignalPreset);
        DigitalSignal.Signal = double(real(IQSignal.Signal) > 0);
    elseif (strcmp(Mode, "QPSK"))
        BitStream = zeros(2, SignalLength, ChannelNum);
        IQStream = reshape(IQSignal.Signal.', 1, SignalLength, []);
        BitStream(1,:,:) = double(real(IQStream) > 0);
        BitStream(2,:,:) = double(imag(IQStream) > 0);
        DigitalSignal = InitDigitalSignal(ChannelNum, TimeStart, TimeEndurance, SampleRate * 2, SignalPreset);
        BitStream = reshape(BitStream, 1, [], ChannelNum);
        DigitalSignal.Signal = reshape(BitStream, [], ChannelNum)';
    elseif (strcmp(Mode, "16QAM"))
        BitStream = zeros(4, SignalLength, ChannelNum);
        IQStream = reshape(IQSignal.Signal.', 1, SignalLength, []) * (3 / 2);
        BitStream(1,:,:) = double(real(IQStream) > 0);
        BitStream(3,:,:) = double(imag(IQStream) > 0);
        IQStream = IQStream - ((BitStream(1,:,:) * 2 - 1) + (BitStream(3,:,:) * 2 - 1) * 1i);
        BitStream(2,:,:) = double(real(IQStream) > 0);
        BitStream(4,:,:) = double(imag(IQStream) > 0);
        DigitalSignal = InitDigitalSignal(ChannelNum, TimeStart, TimeEndurance, SampleRate * 4, SignalPreset);
        BitStream = reshape(BitStream, 1, [], ChannelNum);
        DigitalSignal.Signal = reshape(BitStream, [], ChannelNum)';
    elseif (strcmp(Mode, "64QAM"))
        BitStream = zeros(6, SignalLength, ChannelNum);
        IQStream = reshape(IQSignal.Signal.', 1, SignalLength, []) * (7 / 2);
        BitStream(1,:,:) = double(real(IQStream) > 0);
        BitStream(4,:,:) = double(imag(IQStream) > 0);
        IQStream = IQStream - ((BitStream(1,:,:) * 4 - 2) + (BitStream(4,:,:) * 4 - 2) * 1i);
        BitStream(2,:,:) = double(real(IQStream) > 0);
        BitStream(5,:,:) = double(imag(IQStream) > 0);
        IQStream = IQStream - ((BitStream(2,:,:) * 2 - 1) + (BitStream(5,:,:) * 2 - 1) * 1i);
        BitStream(3,:,:) = double(real(IQStream) > 0);
        BitStream(6,:,:) = double(imag(IQStream) > 0);
        DigitalSignal = InitDigitalSignal(ChannelNum, TimeStart, TimeEndurance, SampleRate * 6, SignalPreset);
        BitStream = reshape(BitStream, 1, [], ChannelNum);
        DigitalSignal.Signal = reshape(BitStream, [], ChannelNum)';
    elseif (strcmp(Mode, "256QAM"))
        BitStream = zeros(8, SignalLength, ChannelNum);
        IQStream = reshape(IQSignal.Signal.', 1, SignalLength, []) * (15 / 2);
        BitStream(1,:,:) = double(real(IQStream) > 0);
        BitStream(5,:,:) = double(imag(IQStream) > 0);
        IQStream = IQStream - ((BitStream(1,:,:) * 8 - 4) + (BitStream(5,:,:) * 8 - 4) * 1i);
        BitStream(2,:,:) = double(real(IQStream) > 0);
        BitStream(6,:,:) = double(imag(IQStream) > 0);
        IQStream = IQStream - ((BitStream(2,:,:) * 4 - 2) + (BitStream(6,:,:) * 4 - 2) * 1i);
        BitStream(3,:,:) = double(real(IQStream) > 0);
        BitStream(7,:,:) = double(imag(IQStream) > 0);
        IQStream = IQStream - ((BitStream(3,:,:) * 2 - 1) + (BitStream(7,:,:) * 2 - 1) * 1i);
        BitStream(4,:,:) = double(real(IQStream) > 0);
        BitStream(8,:,:) = double(imag(IQStream) > 0);
        DigitalSignal = InitDigitalSignal(ChannelNum, TimeStart, TimeEndurance, SampleRate * 8, SignalPreset);
        BitStream = reshape(BitStream, 1, [], ChannelNum);
        DigitalSignal.Signal = reshape(BitStream, [], ChannelNum)';
    elseif (strcmp(Mode, "1024QAM"))
        BitStream = zeros(10, SignalLength, ChannelNum);
        IQStream = reshape(IQSignal.Signal.', 1, SignalLength, []) * (31 / 2);
        BitStream(1,:,:) = double(real(IQStream) > 0);
        BitStream(6,:,:) = double(imag(IQStream) > 0);
        IQStream = IQStream - ((BitStream(1,:,:) * 16 - 8) + (BitStream(6,:,:) * 16 - 8) * 1i);
        BitStream(2,:,:) = double(real(IQStream) > 0);
        BitStream(7,:,:) = double(imag(IQStream) > 0);
        IQStream = IQStream - ((BitStream(2,:,:) * 8 - 4) + (BitStream(7,:,:) * 8 - 4) * 1i);
        BitStream(3,:,:) = double(real(IQStream) > 0);
        BitStream(8,:,:) = double(imag(IQStream) > 0);
        IQStream = IQStream - ((BitStream(3,:,:) * 4 - 2) + (BitStream(8,:,:) * 4 - 2) * 1i);
        BitStream(4,:,:) = double(real(IQStream) > 0);
        BitStream(9,:,:) = double(imag(IQStream) > 0);
        IQStream = IQStream - ((BitStream(4,:,:) * 2 - 1) + (BitStream(9,:,:) * 2 - 1) * 1i);
        BitStream(5,:,:) = double(real(IQStream) > 0);
        BitStream(10,:,:) = double(imag(IQStream) > 0);
        DigitalSignal = InitDigitalSignal(ChannelNum, TimeStart, TimeEndurance, SampleRate * 10, SignalPreset);
        BitStream = reshape(BitStream, 1, [], ChannelNum);
        DigitalSignal.Signal = reshape(BitStream, [], ChannelNum)';
    end
end

