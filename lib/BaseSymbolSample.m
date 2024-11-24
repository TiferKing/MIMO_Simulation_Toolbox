function [SymbolSignal] = BaseSymbolSample(BaseSignal, SymbolSampleRate)
%BaseSymbolSample Sample the symbol from the baseband.
%Introduction:
%   Sample the analog signal at its optimal sample point and convert it
%   into symbols.
%Syntax:
%   SymbolSignal = BaseSymbolSample(BaseSignal, SymbolSampleRate)
%Description:
%   SymbolSignal = BaseSymbolSample(BaseSignal, SymbolSampleRate) 
%       returns the symbol sampled from baseband in symbol rate.
%Input Arguments:
%   BaseSignal: (AnalogSignal)
%       The signal that contains the baseband content.
%   SymbolSampleRate: (double)
%       The sample rate (in Sa/s) of the baseband symbols.
%Output Arguments:
%   SymbolSignal: (AnalogSignal)
%       The signal that contains the symbols.
%Author:
%   Tifer King
%License:
%   Please refer to the 'LICENSE' file included in the root directory 
%   of the project.

    ChannelNum = BaseSignal.ChannelNum;
    TimeStart = BaseSignal.TimeStart;
    TimeEndurance = floor(BaseSignal.TimeEndurance * SymbolSampleRate) / SymbolSampleRate;
    DownSampleRate = BaseSignal.SampleRate / SymbolSampleRate;
    SymbolSignal = InitAnalogSignal(BaseSignal.ChannelNum, TimeStart, TimeEndurance, SymbolSampleRate, 'Template', 'As', BaseSignal);
    if(DownSampleRate == 1)
        SymbolSignal.Signal = BaseSignal.Signal;
    else
        for index = 1 : ChannelNum
            SymbolSignal.Signal(index, :) = downsample(BaseSignal.Signal(index,:), DownSampleRate, round(DownSampleRate / 2));
        end
    end
end

