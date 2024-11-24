%RFSoC Single Path Example ideal channel.
%Author:
%   Tifer King
%License:
%   Please refer to the 'LICENSE' file included in the root directory 
%   of the project.

LoadEnvironment;

%% Simulation config
DataLegth = 10000 * 8;
ChannelNum = 1;
ChannelNoise = -200;
FramePreambleLength = 167;
SequenceMode = "prbs31";
AnalogSignalPreset = "50Ohm-2.5V";
DigitalSignalPreset = "LVCMOS3V3";
BaseAnalogSampleRate = 6.5536e9;
BaseAnalogSampleRateRx = 4.9152e9;
BaseBitRate = 163.84e6 * 2;
BaseModulationMode = "256QAM";
BaseShapingBeta = 0.25;
BaseShapingSpan = 16;
CarrierFrequency = 1.5e9;
CarrierSampleRate = 6.5536e9;
CarrierSampleRateRx = 4.9152e9;
MaxSimulationFrequency = CarrierFrequency * 5;
MaxChannelImpulseEndurance = 12 / (pi * MaxSimulationFrequency);

%% Simulation Flow
close all;
BaseData = DigitalSignalGen(ChannelNum, DataLegth, BaseBitRate, SequenceMode, DigitalSignalPreset);
IQBase = Modulation(BaseData, BaseModulationMode, AnalogSignalPreset);
ProbeConstellation(IQBase, false, BaseModulationMode,'Transmitted IQ Base');
FramePreamble = PreambleGen(ChannelNum, FramePreambleLength, IQBase.SampleRate, @ZadoffChuGen, AnalogSignalPreset);
FrameSignal = FrameEncapsulate(IQBase, FramePreamble);
ShapingFilterTx = ShapingFilterDesign(BaseShapingBeta, BaseShapingSpan, BaseAnalogSampleRate, IQBase.SampleRate);
ShapedSignal = ChannelShaping(FrameSignal, ShapingFilterTx, BaseAnalogSampleRate);
ProbeSpectrum(ShapedSignal, false, 'Shaped Signal Spectrum');
CarrierSignal = CarrierGen(CarrierFrequency, ChannelNum, CarrierSampleRate, ShapedSignal.TimeStart, ShapedSignal.TimeEndurance, AnalogSignalPreset);
ProbeSpectrum(CarrierSignal, false, 'Carrier Signal Spectrum', 'Span', [(CarrierFrequency - 0.1e9) (CarrierFrequency + 0.1e9)]);
TransmiteSignal = IQMixing(ShapedSignal, CarrierSignal);
ProbeWave(TransmiteSignal, true, 'Transmitted Signal');
ProbeSpectrum(TransmiteSignal, false, 'Transmitted Spectrum');
TxPower = ProbeSignalPower(TransmiteSignal, 'TxPower');

ChannelImpulse = InitChannelImpulseResponse(ChannelNum, ChannelNum, 0, MaxChannelImpulseEndurance, CarrierSampleRate, 0, MaxSimulationFrequency, 'Gaussian');
ProbeChannelImpulse(ChannelImpulse);
RecivedSignal = Channel(TransmiteSignal, ChannelImpulse, ChannelNoise);

ProbeWave(RecivedSignal, true, 'Recived Signal');
ProbeSpectrum(RecivedSignal, false, 'Recived Spectrum', 'Span', [(CarrierFrequency - 400e6) (CarrierFrequency + 400e6)]);
RxPower = ProbeSignalPower(RecivedSignal, 'RxPower');
RecivedSignal.Signal = circshift(RecivedSignal.Signal, 0, 4);
RecivedSignal = SignalResample(RecivedSignal, CarrierSampleRateRx);
CarrierSignal = CarrierGen(CarrierFrequency, ChannelNum, CarrierSampleRateRx, RecivedSignal.TimeStart, RecivedSignal.TimeEndurance, AnalogSignalPreset);
BaseSignal = IQDemixing(RecivedSignal, CarrierSignal, BaseAnalogSampleRateRx, @DemixingResampleFilter);
ShapingFilterRx = ShapingFilterDesign(BaseShapingBeta, BaseShapingSpan, BaseAnalogSampleRateRx, IQBase.SampleRate);
[PayloadSiganl, ChannelEstimation] = FrameDecapsulate(BaseSignal, FramePreamble, BaseData.TimeEndurance, ShapingFilterRx);
ProbeConstellation(PayloadSiganl, false, BaseModulationMode, 'Recived IQ Base');
ProbeSpectrum(PayloadSiganl, false, 'Recived IQ Base Spectrum');
SymbolSignal = BaseSymbolSample(PayloadSiganl, IQBase.SampleRate);
ProbeConstellation(SymbolSignal, false, BaseModulationMode, 'Decoded IQ Base');
RecivedData = Demodulation(SymbolSignal, BaseModulationMode, DigitalSignalPreset);
ErrorRate = ProbeBitError(BaseData, RecivedData, 'Recv');

FreeEnvironment;
