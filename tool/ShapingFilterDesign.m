function [Filter] = ShapingFilterDesign(Beta, ShapingSpan, BaseSampleRate, BaseBitRate)
%ShapingFilterDesign Design channel shaping filter.
%Introduction:
%   This function designs the shaping filter utilized in shaping the
%   signals to avoid inter symbol interference.
%Syntax:
%   Filter = ShapingFilterDesign(Beta, ShapingSpan, BaseSampleRate, BaseBitRate)
%Description:
%   Filter = ShapingFilterDesign(Beta, ShapingSpan, BaseSampleRate, BaseBitRate)
%       returns the designed filter.
%Input Arguments:
%   Beta: (double)
%       Rolloff factor for raised cosine FIR pulse-shaping filter.
%   ShapingSpan: (positive integer scalar)
%       Number of symbols effected.
%   BaseSampleRate: (double)
%       Baseband signal sample rate in Sa/s.
%   BaseBitRate: (double)
%       Baseband signal binary stream bit rate in bit/s.
%Output Arguments:
%   Filter: (matrix)
%       Filter coefficient.
%Author:
%   Tifer King
%License:
%   Please refer to the 'LICENSE' file included in the root directory 
%   of the project.

    Filter = rcosdesign(Beta, ShapingSpan, BaseSampleRate / BaseBitRate, "sqrt");
end

