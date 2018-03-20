clear all; clc;
%close all;
% Create Rayleigh fading channel object.


chan = rayleighchan(1/1000000,50,1.0e-004 * [0 0.0400 0.0800 0.1200],[0 -3 -6 -9]);
%delayVector = 1.0e-004 * [0 0.0400 0.0800 0.1200];
%gainVector = [0 -3 -6 -9]; % Average path gains (dB)
% Generate data and apply fading channel.
M = 2; % DBPSK modulation order
hMod = comm.BPSKModulator; % Create a DPSK modulator
hDemod = comm.BPSKDemodulator; % Create a DPSK demodulator
tx = randi([0 M-1],500,1); % Generate a random bit stream
dpskSig = step(hMod, tx); % DPSK modulate the signal
y = zeros(size(dpskSig));
for i=1:length(dpskSig)
    if dpskSig(i) == 1.0000+0.0000i
        y(i) = 1;
    else
        y(i) = -1;
    end
end
Y = eye(M);
yxx = zeros(500,2);
for i=1:length(dpskSig)
    if y(i) == 1
        yxx(i,:) = Y(1,:);
    else
        yxx(i,:) = Y(2,:);
    end
end

fadedSig = filter(chan,dpskSig); % Apply the channel effects
% Compute error rate for different values of SNR.
SNR = 0:2:20; % Range of SNR values, in dB.
numSNR = length(SNR);
berVec = zeros(3, numSNR);
% Create an AWGNChannel and ErrorRate calculator System object
hChan = comm.AWGNChannel('NoiseMethod', 'Signal to noise ratio (SNR)');
hErrorCalc = comm.ErrorRate;
ber2=zeros(numSNR,1);
for n = 1:numSNR
hChan.SNR = SNR(n);
rxSig = step(hChan,fadedSig); % Add Gaussian noise
rx = step(hDemod, rxSig); % Demodulate
X = [real(rxSig), imag(rxSig)];
reset(hErrorCalc)
% Compute error rate.
berVec(:,n) = step(hErrorCalc,tx,rx);
output2=mynn(X,yxx);
[aa,ii]=max(output2);
yt=(ii==1);
rxf = step(hDemod, 2*double(yt')-1);
ber2(n)=sum(abs(tx-rxf))/500;
end
BER = berVec(1,:);
figure;
 %Compute theoretical performance results, for comparison.
BERtheory = berfading(SNR,'dpsk',M,1);
%  Plot BER results.
semilogy(SNR,BERtheory,'b-',SNR,BER,'r*');

xlabel('SNR (dB)'); ylabel('BER');
title('Binary DPSK over Rayleigh Fading Channel');
hold;
semilogy(SNR,ber2,'g^-');
legend('Theoretical BER','Without Equalization','Equalized');

tar = [real(dpskSig), imag(dpskSig)];
input_target = [X, tar];
input_target2 = [X, tar(:,1)];

