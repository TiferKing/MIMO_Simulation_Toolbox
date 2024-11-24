function [ShapedSignal] = ChannelShaping(IQSignal, Filter, SampleRate)
%ChannelShaping Upconvert baseband signal and filter it with shaping filter.
%Introduction:
%   The baseband signal that is transmitted into the channel should be
%   oversampled first, because the original signal may have a wide
%   spectrum, and the channel can only pass a narrower signal. In this
%   case, the signal may be affected by inter-symbol interference. To avoid
%   this effect, the signal should be pre-filtered.
%Syntax:
%   ShapedSignal = ChannelShaping(IQSignal, Filter, SampleRate)
%Description:
%   ShapedSignal = ChannelShaping(IQSignal, Filter, SampleRate)
%       returns the shaping filtered signal.
%Input Arguments:
%   IQSignal: (AnalogSignal)
%       Baseband IQ signals.
%   Filter: (vector)
%       Symbol shaping filter coefficient.
%   SampleRate: (double)
%       Upconvert sample rate in Sa/s.
%Output Arguments:
%   ShapedSignal: (matrix)
%       Signal filtered.
%Author:
%   Tifer King
%License:
%   Please refer to the 'LICENSE' file included in the root directory 
%   of the project.

   FilterLength = length(Filter);
   [Channel,IQLength] = size(IQSignal.Signal);
   SignalLength = floor(IQLength * SampleRate / IQSignal.SampleRate + FilterLength);
   ShapedSignal = InitAnalogSignal(Channel, IQSignal.TimeStart, SignalLength / SampleRate, SampleRate, 'Template','As',IQSignal);
   ShapedSignal.Signal = upfirdn([IQSignal.Signal zeros(IQSignal.ChannelNum, 1)]', Filter', SampleRate / IQSignal.SampleRate)';
   % Upfirdn may cause the last sample point to be not upsampled, so it
   % should add an additional zero at the end of the sample to make sure
   % the signal is correct.
   ShapedSignal.TimeEndurance = (SignalLength) / SampleRate;
end

