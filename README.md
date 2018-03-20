this program is comprised of two files written in Matlab language
the first:(Ray_SNR.m) 
	generate random signal 
	modulate it using BPSK 
	pass it through Rayleigh fading channel
	call neural network model 
	demodulate and calculate Bit Error Rate
the second: (mynn)
	is function creates NN object 
	trains and classifies signal
