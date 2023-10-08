%Example1 OAM communications in ideal channel.
%Author:
%   Tifer King
%License:
%   Please refer to the 'LICENSE' file included in the root directory 
%   of the project.

LoadEnvironment;

%% Simulation config
DataLegth = 800;
ChannelNum = 8;
ChannelNoise = -150;
FramePreambleLength = 67;
SequenceMode = "prbs31";
AnalogSignalPreset = "50Ohm-2.5V";
DigitalSignalPreset = "LVCMOS3V3";
BaseAnalogSampleRate = 1e9;
BaseBitRate = 1e8;
BaseModulationMode = "QPSK";
BaseShapingBeta = 0.25;
BaseShapingSpan = 8;
BaseOrthogonalPreset = "OAM";
CarrierFrequency = 5.8e9;
CarrierSampleRate = 1000e9;
MaxSimulationFrequency = CarrierFrequency * 5;
%MaxChannelImpulseEndurance = 12 / (pi * MaxSimulationFrequency);
AntennaRadiusTx = 0.5;
AntennaRadiusRx = 0.5;
AntennaPositionRx = [0; 0; 10];
AntennaEulerianAngleRx = [0; 0; 0];
BeamDisplayRange = 'Auto';

%% Simulation Flow
close all;
BaseData = DigitalSignalGen(ChannelNum, DataLegth, BaseBitRate, SequenceMode, DigitalSignalPreset);
IQBase = Modulation(BaseData, BaseModulationMode, AnalogSignalPreset);
ProbeConstellation(IQBase, false, BaseModulationMode,'Transmitted IQ Base');
OrthogonalBase = OrthogonalMatrixLoad(IQBase, BaseOrthogonalPreset);
FramePreamble = PreambleGen(ChannelNum, FramePreambleLength, IQBase.SampleRate, @ZadoffChuGen, AnalogSignalPreset);
FrameSignal = FrameEncapsulate(OrthogonalBase, FramePreamble);
ShapingFilter = ShapingFilterDesign(BaseShapingBeta, BaseShapingSpan, BaseAnalogSampleRate, IQBase.SampleRate);
ShapedSignal = ChannelShaping(FrameSignal, ShapingFilter, BaseAnalogSampleRate);
ProbeSpectrum(ShapedSignal, false, 'Shaped Signal Spectrum');
CarrierSignal = CarrierGen(CarrierFrequency, ChannelNum, CarrierSampleRate, ShapedSignal.TimeStart, ShapedSignal.TimeEndurance, AnalogSignalPreset);
ProbeSpectrum(CarrierSignal, false, 'Carrier Signal Spectrum', 'Span', [5.75e9 5.85e9]);
TransmiteSignal = IQMixing(ShapedSignal, CarrierSignal);
ProbeWave(TransmiteSignal, true, 'Transmitted Signal');
ProbeSpectrum(TransmiteSignal, false, 'Transmitted Spectrum');
TxPower = ProbeSignalPower(TransmiteSignal, 'TxPower');

%ChannelImpulse = InitChannelImpulseResponse(ChannelNum, ChannelNum, 0, MaxChannelImpulseEndurance, CarrierSampleRate, 0, MaxSimulationFrequency, 'Gaussian');
ChannelImpulse = IdealOAMChannel(ChannelNum, ChannelNum, AntennaRadiusTx, AntennaRadiusRx, AntennaPositionRx, AntennaEulerianAngleRx, MaxSimulationFrequency, CarrierFrequency, CarrierSampleRate, true);
IdealOAMVisualizer(ChannelNum, ChannelNum, AntennaRadiusTx, AntennaRadiusRx, AntennaPositionRx, AntennaEulerianAngleRx, CarrierFrequency, 1, true, BeamDisplayRange);
ProbeChannelImpulse(ChannelImpulse);
RecivedSignal = Channel(TransmiteSignal, ChannelImpulse, ChannelNoise);

ProbeWave(RecivedSignal, true, 'Recived Signal');
ProbeSpectrum(RecivedSignal, false, 'Recived Spectrum', 'Span', [5.6e9 6.0e9]);
RxPower = ProbeSignalPower(RecivedSignal, 'RxPower');
CarrierSignal = CarrierGen(CarrierFrequency, ChannelNum, CarrierSampleRate, RecivedSignal.TimeStart, RecivedSignal.TimeEndurance, AnalogSignalPreset);
BaseSignal = IQDemixing(RecivedSignal, CarrierSignal, BaseAnalogSampleRate, @DemixingResampleFilter);
[PayloadSiganl, ChannelEstimation] = FrameDecapsulate(BaseSignal, FramePreamble, ShapingFilter);
DeorthogonalBase = OrthogonalMatrixUnload(PayloadSiganl, BaseOrthogonalPreset);
ProbeConstellation(DeorthogonalBase, false, BaseModulationMode, 'Recived IQ Base');
ProbeSpectrum(DeorthogonalBase, false, 'Recived IQ Base Spectrum');
SymbolSignal = BaseSymbolSample(DeorthogonalBase, IQBase.SampleRate);
ProbeConstellation(SymbolSignal, false, BaseModulationMode, 'Decoded IQ Base');
RecivedData = Demodulation(SymbolSignal, BaseModulationMode, DigitalSignalPreset);
ErrorRate = ProbeBitError(BaseData, RecivedData, 'Recv');

FreeEnvironment;
