clear variables
close all

load('Noise_samples.mat', 'Noise_samples')

figure_index = 1 ;
Noise_types = fieldnames(Noise_samples) ;
for nti = 1:length(Noise_types)
    Noise = Noise_types{nti} ;
    
    figure(figure_index)
    
    subplot(3, 1, 1)
    plot(Noise_samples.(Noise))
    xlabel('Iteration')
    title(Noise, 'Interpreter', 'None')
    
    spectre = fftshift(fft(Noise_samples.(Noise))) ;
    
    subplot(3, 1, 2)
    semilogy(abs(spectre(ceil(length(spectre)/2:end))))
    xlabel('Pulse / Sample rate (rad)')
    ylabel('Amplitude')
    
    subplot(3, 1, 3)
    plot(angle(spectre(ceil(length(spectre)/2:end))))
    xlabel('Pulse / Sample rate (rad)')
    ylabel('Phase')
    ylim([-pi, pi])
    
    figure_index = figure_index + 1 ;
end