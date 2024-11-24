function [FrameSignal] = FrameEncapsulate(BaseSignal, PreambleSignal)
%FrameEncapsulate Encapsulate the frame using the specified preamble.
%Introduction:
%   Combine the preamble signal and the baseband data into a single signal
%   stream.
%Syntax:
%   FrameSignal = FrameEncapsulate(BaseSignal, PreambleSignal)
%Description:
%   FrameSignal = FrameEncapsulate(BaseSignal, PreambleSignal)
%       returns the base signal of frame.
%Input Arguments:
%   BaseSignal: (AnalogSignal)
%       Baseband data payload.
%   PreambleSignal: (AnalogSignal)
%       The preamble signal.
%Output Arguments:
%   FrameSignal: (AnalogSignal)
%       Signal of frame.
%Author:
%   Tifer King
%License:
%   Please refer to the 'LICENSE' file included in the root directory 
%   of the project.

    ChannelNum = BaseSignal.ChannelNum;
    TimeStart = BaseSignal.TimeStart + PreambleSignal.TimeStart;
    TimeEndurance = BaseSignal.TimeEndurance;
    if (PreambleSignal.SampleRate < BaseSignal.SampleRate)
        % If the sample rate of the preamble signal is slower than the
        % baseband signal, the preamble should be first upsampled.
        Preamble = SignalResample(PreambleSignal, BaseSignal.SampleRate, 'previous');
        TimeEndurance = BaseSignal.TimeEndurance + Preamble.TimeEndurance;
    elseif (PreambleSignal.SampleRate > BaseSignal.SampleRate)
        Preamble = PreambleSignal;
        TimeEndurance = BaseSignal.TimeEndurance + PreambleSignal.TimeEndurance;
        warning("Preamble cannot sample faster than base, ignore the sample rate.");
    else
        Preamble = PreambleSignal;
    end
    FrameSignal = InitAnalogSignal(ChannelNum, TimeStart, TimeEndurance, BaseSignal.SampleRate, 'Template', 'As', BaseSignal);
    FrameSignal.Signal = [Preamble.Signal BaseSignal.Signal];
end

