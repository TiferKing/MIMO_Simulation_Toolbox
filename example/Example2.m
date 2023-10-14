%Example2 OFDM-OAM communications in ideal channel.
%Author:
%   Tifer King
%License:
%   Please refer to the 'LICENSE' file included in the root directory 
%   of the project.

LoadEnvironment;

%% Simulation config
DataLegth = 8000;
ChannelNum = 8;
ChannelNoise = -200;
FramePreambleLength = 400;
SequenceMode = "prbs31";
AnalogSignalPreset = "50Ohm-2.5V";
DigitalSignalPreset = "LVCMOS3V3";
BaseAnalogSampleRate = 10e9;
BaseBitRate = 10e8;
BaseModulationMode = "QPSK";
BaseShapingBeta = 0.25;
BaseShapingSpan = 8;
BaseOrthogonalPreset = "OAM";
CarrierFrequency = 5.8e9;
CarrierSampleRate = 1000e9;
MaxSimulationFrequency = CarrierFrequency * 5;
OFDMSubCarrierNum = 400;
OFDMCyclicPrefixNum = 4;
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
OFDMBase = OFDMLoad(IQBase, OFDMSubCarrierNum, OFDMCyclicPrefixNum);
OrthogonalBase = OrthogonalMatrixLoad(OFDMBase, BaseOrthogonalPreset);
FramePreamble = PreambleGen(ChannelNum, FramePreambleLength, IQBase.SampleRate, @ZadoffChuGen, AnalogSignalPreset);
FrameSignal = FrameEncapsulate(OrthogonalBase, FramePreamble);
ShapingFilter = ShapingFilterDesign(BaseShapingBeta, BaseShapingSpan, BaseAnalogSampleRate, IQBase.SampleRate);
ShapedSignal = ChannelShaping(FrameSignal, ShapingFilter, BaseAnalogSampleRate);
OFDMVisualizer(IQBase, OFDMSubCarrierNum, OFDMCyclicPrefixNum, ShapingFilter, BaseAnalogSampleRate);
ProbeSpectrum(ShapedSignal, false, 'Shaped Signal Spectrum');
CarrierSignal = CarrierGen(CarrierFrequency, ChannelNum, CarrierSampleRate, ShapedSignal.TimeStart, ShapedSignal.TimeEndurance, AnalogSignalPreset);
ProbeSpectrum(CarrierSignal, false, 'Carrier Signal Spectrum', 'Span', [(CarrierFrequency - 0.5e9) (CarrierFrequency + 0.5e9)]);
TransmiteSignal = IQMixing(ShapedSignal, CarrierSignal);
ProbeWave(TransmiteSignal, true, 'Transmitted Signal');
ProbeSpectrum(TransmiteSignal, false, 'Transmitted Spectrum');
TxPower = ProbeSignalPower(TransmiteSignal, 'TxPower');

ChannelImpulse = IdealOAMChannel(ChannelNum, ChannelNum, AntennaRadiusTx, AntennaRadiusRx, AntennaPositionRx, AntennaEulerianAngleRx, MaxSimulationFrequency, CarrierFrequency, CarrierSampleRate, true);
for index = 0 : ChannelNum / 2
    IdealOAMVisualizer(ChannelNum, ChannelNum, AntennaRadiusTx, AntennaRadiusRx, AntennaPositionRx, AntennaEulerianAngleRx, CarrierFrequency, index, true, BeamDisplayRange);
end
ProbeChannelImpulse(ChannelImpulse);
RecivedSignal = Channel(TransmiteSignal, ChannelImpulse, ChannelNoise);

ProbeWave(RecivedSignal, true, 'Recived Signal');
ProbeSpectrum(RecivedSignal, false, 'Recived Spectrum');
RxPower = ProbeSignalPower(RecivedSignal, 'RxPower');
CarrierSignal = CarrierGen(CarrierFrequency, ChannelNum, CarrierSampleRate, RecivedSignal.TimeStart, RecivedSignal.TimeEndurance, AnalogSignalPreset);
BaseSignal = IQDemixing(RecivedSignal, CarrierSignal, BaseAnalogSampleRate, @DemixingResampleFilter);
[PayloadSiganl, ChannelEstimation] = FrameDecapsulate(BaseSignal, FramePreamble, ShapingFilter);
DeorthogonalBase = OrthogonalMatrixUnload(PayloadSiganl, BaseOrthogonalPreset);
ProbeConstellation(DeorthogonalBase, false, BaseModulationMode, 'Recived IQ Base');
ProbeSpectrum(DeorthogonalBase, false, 'Recived IQ Base Spectrum');
SymbolSignal = BaseSymbolSample(DeorthogonalBase, IQBase.SampleRate);
RecoveredSignal = OFDMUnload(SymbolSignal, OFDMSubCarrierNum, OFDMCyclicPrefixNum);
ProbeConstellation(RecoveredSignal, false, BaseModulationMode, 'Decoded IQ Base');
RecivedData = Demodulation(RecoveredSignal, BaseModulationMode, DigitalSignalPreset);
ErrorRate = ProbeBitError(BaseData, RecivedData, 'Recv');

FreeEnvironment;
