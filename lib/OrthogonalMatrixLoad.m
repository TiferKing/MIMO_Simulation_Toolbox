function [OrthogonalSignal] = OrthogonalMatrixLoad(IQSignal, varargin)
%OrthogonalMatrixLoad Load orthogonal matrix to multi-channel.
%Introduction:
%   In some special scenarios, the channel does not have enough
%   orthogonality. The orthogonal matrix can add more orthogonality to the
%   signal in order to increase the communication capacity.
%Syntax:
%   OrthogonalSignal = OrthogonalMatrixLoad(IQSignal, MatrixPreset)
%   OrthogonalSignal = OrthogonalMatrixLoad(IQSignal, 'Custom', OrthogonalMatrix)
%Description:
%   OrthogonalSignal = OrthogonalMatrixLoad(IQSignal, MatrixPreset)
%       returns the base signal with preset orthogonal matrix.
%   OrthogonalSignal = OrthogonalMatrixLoad(IQSignal, 'Custom', OrthogonalMatrix)
%       returns the base signal with custom orthogonal matrix.
%Input Arguments:
%   IQSignal: (AnalogSignal)
%       Baseband signals.
%   MatrixPreset: (string)
%       Type of matrix, it is one of blow:
%       'OAM': IDFT matrix.
%       'ZC': Zadoff-Chu matrix.
%   OrthogonalMatrix: (matrix)
%       User defined orthogonal matrix.
%Output Arguments:
%   OrthogonalSignal: (AnalogSignal)
%       Baseband signals loaded orthogonal matrix.
%Author:
%   Tifer King
%License:
%   Please refer to the 'LICENSE' file included in the root directory 
%   of the project.

    OrthogonalSignal = IQSignal;
    DefaultOrthogonalMatrix = eye(IQSignal.ChannelNum);
    ExpectedMatrixPreset = {'OAM','ZC','Custom'};
    InPar = inputParser;
    addRequired(InPar,'MatrixPreset',@(x) any(validatestring(x,ExpectedMatrixPreset)));
    addOptional(InPar,'OrthogonalMatrix', DefaultOrthogonalMatrix,@ismatrix);
    parse(InPar,varargin{:});
    
    if(strcmp(InPar.Results.MatrixPreset, "OAM"))
        OrthogonalMatrix = dftmtx(IQSignal.ChannelNum)' / IQSignal.ChannelNum;
    elseif(strcmp(InPar.Results.MatrixPreset, "ZC"))
        N = IQSignal.ChannelNum;
        u = 1;
        q = 1;
        cf = mod(IQSignal.ChannelNum, 2);
        ZadoffChuSequence = exp(-1i * (pi * 1 * u * [0 : N - 1] .* ([0 : N - 1] + cf + 2 * q)) / N);
        OrthogonalMatrix = dftmtx(N)' * diag(ZadoffChuSequence * dftmtx(N)') * dftmtx(N) / N;
    elseif(strcmp(InPar.Results.MatrixPreset, "Custom"))
        OrthogonalMatrix = InPar.Results.OrthogonalMatrix;
    end
    OrthogonalSignal.Signal = OrthogonalMatrix * IQSignal.Signal;
end

