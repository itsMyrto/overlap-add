% Opening the audio - the input signal
[x,Fs] = audioread('grimelabinc_TurnDown.wav');

% Keeping the left channel (first column) since x is a multichannel audio 
x = x(:,1);
% sound(x,Fs);

% Since x is a column vector we it needs to be converted into a row vector 
x = x';
figure(1),freqz(x);

% Defining the lowpass filter with 300 samples and cutoff frequency fc=0.15
h = fir1(299,0.15,'low');
figure(2), stem(h), title("Low-Pass Filter");
figure(3), freqz(h);

% Computing the length of x[n] and h[n]
x_length = length(x);
h_length = length(h);

% Initializing the length of each data sequence 
L = 300000;
N = L + h_length - 1;

% Computing and padding some extra zeros in the signal x (only if it is needed). 
% This is ONLY for when the length of x divided by L gives a remainder different than 0  
extra_zeros = mod(-x_length,L);
x = [x, zeros(1,extra_zeros)];
x_new_length = length(x);

% Padding some extra zeros to the filter so that the length is equal to
% the length of each sequence
h = [h, zeros(1,N-h_length)];

% Calculating the number of sequences that we need to break the signal x
stages = x_new_length / L;

% This is the part of the x signal that will be extracted in the first loop
selection = 1:L;

% Calculating the Fourier Transform of h because it will be used inside the
% loop
H = fft(h);

% This is going to be a 2D array that will store all the y_i sequences from
% that will be generated inside the loop
y = [];
for stage=1:stages 
    x_i = [x(selection), zeros(1,N- L)];
    X_i = fft(x_i); 
    y_i = ifft(X_i.*H);
    y = [y; y_i]; 
    selection=stage*L+1:(stage+1)*L;
end

% Now that all y_i sequences are stored, the last step is to add their
% shifted versions

% Shift amount of the y_1
shift = L; 

% The amount of 0's that the y_i's will be filled with
total_zeros = (stages-1) * L; 

% Creating a 2D array that will store all the y_i's but shifted and adding
% the y_0 which shift amount is equal to zero
y_new = [y(1,:), zeros(1,total_zeros)]; 

% Shifting the elements of every y_i (which is now called y_temp) and add
% them in a new row in y_new
for i=2:stages
    y_temp = [y(i,:), zeros(1,total_zeros)];
    y_temp = circshift(y_temp,shift);
    y_new = [y_new; y_temp];
    shift = shift + L;
end

% Calculating the summary of each column. Now y_new is an 1-D row vector
% and the output of the overlap-add method
y_new = sum(y_new);
figure(4),freqz(y_new);

% sound(y_new,Fs);
% audiowrite('new_audio.wav',y_new,Fs);
